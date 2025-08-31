import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/color_palette.dart';

/// Standardized text styles used across the app
/// This reduces duplication of TextStyle definitions while maintaining visual consistency
class AppTextStyles {
  // Heading styles
  static TextStyle get heading1 =>
      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: ColorPalette.primaryTextColor);

  static TextStyle get heading2 =>
      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: ColorPalette.primaryTextColor);

  static TextStyle get heading3 =>
      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: ColorPalette.primaryTextColor);

  // Body text styles
  static TextStyle get bodyLarge =>
      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: ColorPalette.primaryTextColor);

  static TextStyle get bodyMedium =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: ColorPalette.primaryTextColor);

  static TextStyle get bodySmall =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: ColorPalette.secondaryTextColor);

  // Button text styles
  static TextStyle get buttonLarge => TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white);

  static TextStyle get buttonMedium => TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white);

  // Caption and label styles
  static TextStyle get caption =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: ColorPalette.secondaryTextColor);

  static TextStyle get label =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorPalette.primaryTextColor);

  // Status text styles
  static TextStyle get success =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorPalette.successColor);

  static TextStyle get error => TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorPalette.errorColor);

  static TextStyle get warning =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorPalette.warningColor);

  // Helper methods to create variations
  static TextStyle withColor(TextStyle base, Color color) => base.copyWith(color: color);

  static TextStyle withWeight(TextStyle base, FontWeight weight) => base.copyWith(fontWeight: weight);

  static TextStyle withSize(TextStyle base, double size) => base.copyWith(fontSize: size);
}
