import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App-wide constants to reduce magic numbers and ensure consistency
class AppConstants {
  // Spacing constants
  static double get spacing0 => 0.h;

  static double get spacing2 => 2.h;

  static double get spacing4 => 4.h;

  static double get spacing8 => 8.h;

  static double get spacing12 => 12.h;

  static double get spacing16 => 16.h;

  static double get spacing20 => 20.h;

  static double get spacing24 => 24.h;

  static double get spacing32 => 32.h;

  static double get spacing40 => 40.h;

  static double get spacing48 => 48.h;

  static double get spacing64 => 64.h;

  // Border radius constants
  static double get borderRadius4 => 4.r;

  static double get borderRadius8 => 8.r;

  static double get borderRadius12 => 12.r;

  static double get borderRadius16 => 16.r;

  static double get borderRadius20 => 20.r;

  static double get borderRadius24 => 24.r;

  // Icon sizes
  static double get iconSizeSmall => 16.sp;

  static double get iconSizeMedium => 24.sp;

  static double get iconSizeLarge => 32.sp;

  static double get iconSizeXLarge => 48.sp;

  // Font sizes
  static double get fontSizeSmall => 12.sp;

  static double get fontSizeMedium => 14.sp;

  static double get fontSizeBody => 16.sp;

  static double get fontSizeTitle => 18.sp;

  static double get fontSizeHeading => 20.sp;

  static double get fontSizeLarge => 24.sp;

  // Common dimensions
  static double get buttonHeight => 48.h;

  static double get appBarHeight => 56.h;

  static double get bottomNavHeight => 60.h;

  static double get cardElevation => 2.0;

  static double get dialogElevation => 8.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Common padding values
  static EdgeInsets get paddingSmall => EdgeInsets.all(spacing8);

  static EdgeInsets get paddingMedium => EdgeInsets.all(spacing16);

  static EdgeInsets get paddingLarge => EdgeInsets.all(spacing24);

  static EdgeInsets get paddingHorizontal => EdgeInsets.symmetric(horizontal: spacing24);

  static EdgeInsets get paddingVertical => EdgeInsets.symmetric(vertical: spacing20);

  static EdgeInsets get paddingScreenDefault => EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing20);

  // Common margin values
  static EdgeInsets get marginSmall => EdgeInsets.all(spacing8);

  static EdgeInsets get marginMedium => EdgeInsets.all(spacing16);

  static EdgeInsets get marginLarge => EdgeInsets.all(spacing24);

  // Timeouts and durations
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration qrCodeTimeout = Duration(minutes: 15);
  static const Duration bluetoothScanTimeout = Duration(seconds: 30);
  static const Duration proximityVerificationTimeout = Duration(seconds: 30);
}
