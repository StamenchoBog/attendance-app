import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
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
    _animationController = AnimationController(duration: AppConstants.animationMedium, vsync: this);
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
      await Future.delayed(AppConstants.animationSlow);

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
                Icon(Icons.check_circle, color: Colors.white, size: AppConstants.iconSizeMedium),
                UIHelpers.horizontalSpace(AppConstants.spacing8),
                const Text('Language preference saved'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius8)),
            margin: EdgeInsets.all(AppConstants.spacing16),
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
          style: AppTextStyles.heading3.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
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
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20, vertical: AppConstants.spacing20),
              child: Column(
                children: [
                  const ProfileHeaderWidget(),
                  UIHelpers.verticalSpace(AppConstants.spacing20),
                  Container(
                    padding: EdgeInsets.all(AppConstants.spacing16),
                    decoration: BoxDecoration(
                      color: ColorPalette.lightestBlue,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                      border: Border.all(color: ColorPalette.lightBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppConstants.spacing8),
                          decoration: BoxDecoration(
                            color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
                          ),
                          child: Icon(
                            CupertinoIcons.globe,
                            color: ColorPalette.darkBlue,
                            size: AppConstants.iconSizeMedium,
                          ),
                        ),
                        UIHelpers.horizontalSpace(AppConstants.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Language',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorPalette.textPrimary,
                                ),
                              ),
                              UIHelpers.verticalSpace(AppConstants.spacing4),
                              Text(
                                'Choose your preferred language for the app interface',
                                style: AppTextStyles.caption.copyWith(color: ColorPalette.textSecondary),
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

            UIHelpers.verticalSpace(AppConstants.spacing16),

            // Language Options Section
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppConstants.spacing20),
                      child: Row(
                        children: [
                          Text(
                            'Available Languages',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ColorPalette.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppConstants.spacing8,
                              vertical: AppConstants.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: ColorPalette.lightestBlue,
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                            ),
                            child: Text(
                              '${availableLanguages.length} languages',
                              style: AppTextStyles.caption.copyWith(
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
                        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
                        itemCount: availableLanguages.length,
                        separatorBuilder: (context, index) => UIHelpers.divider,
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
                      padding: EdgeInsets.all(AppConstants.spacing20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(AppConstants.borderRadius16),
                          bottomRight: Radius.circular(AppConstants.borderRadius16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.info_circle, color: Colors.orange, size: AppConstants.iconSizeSmall),
                          UIHelpers.horizontalSpace(AppConstants.spacing8),
                          Expanded(
                            child: Text(
                              'Language selection is ready for implementation. Restart app after changing language.',
                              style: AppTextStyles.caption.copyWith(
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

            UIHelpers.verticalSpace(AppConstants.spacing20),
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
      duration: AppConstants.animationFast,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isChangingLanguage ? null : onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16, vertical: AppConstants.spacing16),
            child: Row(
              children: [
                // Flag emoji
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
                    border: Border.all(
                      color: isSelected ? ColorPalette.darkBlue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(child: Text(flag, style: TextStyle(fontSize: AppConstants.fontSizeHeading))),
                ),
                UIHelpers.horizontalSpace(AppConstants.spacing16),

                // Language info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            languageName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: ColorPalette.textPrimary,
                            ),
                          ),
                          if (isDefault) ...[
                            UIHelpers.horizontalSpace(AppConstants.spacing8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing8, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppConstants.borderRadius4),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: Colors.green),
                              ),
                            ),
                          ],
                        ],
                      ),
                      UIHelpers.verticalSpace(2.h),
                      Text(
                        '$nativeName • $languageCode',
                        style: AppTextStyles.caption.copyWith(color: ColorPalette.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                if (_isChangingLanguage && isSelected)
                  SizedBox(
                    width: AppConstants.iconSizeMedium,
                    height: AppConstants.iconSizeMedium,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.darkBlue),
                    ),
                  )
                else if (isSelected)
                  Container(
                    width: AppConstants.iconSizeMedium,
                    height: AppConstants.iconSizeMedium,
                    decoration: BoxDecoration(
                      color: ColorPalette.darkBlue,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                    ),
                    child: Icon(CupertinoIcons.check_mark, color: Colors.white, size: AppConstants.iconSizeSmall),
                  )
                else
                  Container(
                    width: AppConstants.iconSizeMedium,
                    height: AppConstants.iconSizeMedium,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
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
