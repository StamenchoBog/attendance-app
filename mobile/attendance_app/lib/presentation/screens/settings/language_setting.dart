import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Widgets
import 'package:attendance_app/presentation/widgets/specific/profile_header_widget.dart';

// Language options
const List<Map<String, String>> availableLanguages = [
  {'code': 'mk', 'name': 'Macedonian'},
  {'code': 'en', 'name': 'English'},
  {'code': 'sq', 'name': 'Albanian'},
];

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguageCode = 'en';

  static final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
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
      // Update UI
      setState(() {
        _selectedLanguageCode = languageCode;
      });
      
      // Save to SharedPreferences
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString('languageCode', languageCode);
      
      _logger.i('Selected language: $languageCode');
      
      // --- IMPORTANT ---
      // TODO: Implement actual language change logic:
      // Now that we're storing the language code persistently in SharedPreferences,
      // we still need to trigger a reload of the app's Locale using your chosen 
      // state management / localization solution.
      // This usually involves rebuilding the MaterialApp.
      // Example (conceptual using Provider):
      // context.read<LocaleProvider>().setLocale(Locale(languageCode));
      // --- End Language Change Logic ---
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle( color: ColorPalette.textPrimary, fontWeight: FontWeight.w600, fontSize: 18.sp,),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: ColorPalette.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: ListView( // Use ListView for potential scrolling if more languages added
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          // Reusable Profile Header
          const ProfileHeaderWidget(
            // Pass actual user data if available
          ),

          SizedBox(height: 30.h),

          // Language Section Header (matching mockup style)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: ColorPalette.textPrimary,
                    ),
                  ),
                ),
                 Icon( // Downward chevron like mockup
                  CupertinoIcons.chevron_down,
                  size: 20.sp,
                  color: ColorPalette.iconGrey.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),

          SizedBox(height: 15.h),

          // Language Options List
          Column(
            children: availableLanguages.map((lang) {
              bool isSelected = _selectedLanguageCode == lang['code'];
              return _buildLanguageOptionTile(
                languageName: lang['name']!,
                isSelected: isSelected,
                onTap: () => _selectLanguage(lang['code']!),
              );
            }).toList(),
          ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  // Helper widget for each language option tile
  Widget _buildLanguageOptionTile({
    required String languageName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.lightestBlue : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? ColorPalette.lightBlue : ColorPalette.placeholderGrey,
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: ColorPalette.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.check_mark,
                color: ColorPalette.darkBlue,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
