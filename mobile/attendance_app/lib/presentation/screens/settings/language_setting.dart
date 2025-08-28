import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Widgets
import 'package:attendance_app/presentation/widgets/specific/profile_header_widget.dart';

// Enhanced language options with more details
const List<Map<String, dynamic>> availableLanguages = [
  {'code': 'mk', 'name': 'Македонски', 'nativeName': 'Macedonian', 'flag': '🇲🇰', 'isDefault': false},
  {'code': 'en', 'name': 'English', 'nativeName': 'English', 'flag': '🇬🇧', 'isDefault': true},
  {'code': 'sq', 'name': 'Shqip', 'nativeName': 'Albanian', 'flag': '🇦🇱', 'isDefault': false},
];

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> with TickerProviderStateMixin {
  String _selectedLanguageCode = 'en';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isChangingLanguage = false;

  static final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _loadLanguagePreference();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to load saved language preference
  void _loadLanguagePreference() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final savedLanguage = sharedPreferences.getString('languageCode');

    if (savedLanguage != null) {
      setState(() {
        _selectedLanguageCode = savedLanguage;
      });
    }
  }

  void _selectLanguage(String languageCode) async {
    if (_selectedLanguageCode != languageCode) {
      setState(() {
        _isChangingLanguage = true;
      });

      // Simulate language change process
      await Future.delayed(const Duration(milliseconds: 500));

      // Update UI
      setState(() {
        _selectedLanguageCode = languageCode;
        _isChangingLanguage = false;
      });

      // Save to SharedPreferences
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString('languageCode', languageCode);

      _logger.i('Selected language: $languageCode');

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text('Language preference saved'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }

      // TODO: Implement actual language change logic
      // This would integrate with your localization system
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Language Settings',
          style: TextStyle(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600, fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: ColorPalette.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                children: [
                  const ProfileHeaderWidget(),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: ColorPalette.lightestBlue,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: ColorPalette.lightBlue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: ColorPalette.darkBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(CupertinoIcons.globe, color: ColorPalette.darkBlue, size: 24.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Language',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: ColorPalette.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Choose your preferred language for the app interface',
                                style: TextStyle(fontSize: 13.sp, color: ColorPalette.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Language Options Section
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Row(
                        children: [
                          Text(
                            'Available Languages',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: ColorPalette.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: ColorPalette.lightestBlue,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '${availableLanguages.length} languages',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: ColorPalette.darkBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: availableLanguages.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final lang = availableLanguages[index];
                          final isSelected = _selectedLanguageCode == lang['code'];
                          final isDefault = lang['isDefault'] as bool;

                          return _buildEnhancedLanguageOptionTile(
                            flag: lang['flag'] as String,
                            languageName: lang['name'] as String,
                            nativeName: lang['nativeName'] as String,
                            languageCode: lang['code'] as String,
                            isSelected: isSelected,
                            isDefault: isDefault,
                            onTap: () => _selectLanguage(lang['code'] as String),
                          );
                        },
                      ),
                    ),

                    // Footer with implementation note
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.info_circle, color: Colors.orange, size: 16.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Language selection is ready for implementation. Restart app after changing language.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: ColorPalette.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // Enhanced language option tile with better design
  Widget _buildEnhancedLanguageOptionTile({
    required String flag,
    required String languageName,
    required String nativeName,
    required String languageCode,
    required bool isSelected,
    required bool isDefault,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isChangingLanguage ? null : onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                // Flag emoji
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected ? ColorPalette.darkBlue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(child: Text(flag, style: TextStyle(fontSize: 20.sp))),
                ),
                SizedBox(width: 16.w),

                // Language info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            languageName,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: ColorPalette.textPrimary,
                            ),
                          ),
                          if (isDefault) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.green),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$nativeName • $languageCode',
                        style: TextStyle(fontSize: 13.sp, color: ColorPalette.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                if (_isChangingLanguage && isSelected)
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.darkBlue),
                    ),
                  )
                else if (isSelected)
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(color: ColorPalette.darkBlue, borderRadius: BorderRadius.circular(12.r)),
                    child: Icon(CupertinoIcons.check_mark, color: Colors.white, size: 14.sp),
                  )
                else
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
