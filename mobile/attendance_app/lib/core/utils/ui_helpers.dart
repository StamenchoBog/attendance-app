import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_text_styles.dart';
import '../theme/color_palette.dart';
import '../constants/app_constants.dart';

/// Common UI utility functions to reduce code duplication
class UIHelpers {
  // Common spacing widgets
  static Widget get verticalSpaceSmall => SizedBox(height: AppConstants.spacing8);

  static Widget get verticalSpaceMedium => SizedBox(height: AppConstants.spacing16);

  static Widget get verticalSpaceLarge => SizedBox(height: AppConstants.spacing24);

  static Widget get verticalSpaceXLarge => SizedBox(height: AppConstants.spacing32);

  static Widget get horizontalSpaceSmall => SizedBox(width: AppConstants.spacing8);

  static Widget get horizontalSpaceMedium => SizedBox(width: AppConstants.spacing16);

  static Widget get horizontalSpaceLarge => SizedBox(width: AppConstants.spacing24);

  // Custom spacing
  static Widget verticalSpace(double height) => SizedBox(height: height);

  static Widget horizontalSpace(double width) => SizedBox(width: width);

  // Common box decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: ColorPalette.surfaceColor,
    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
  );

  static BoxDecoration get roundedCardDecoration => BoxDecoration(
    color: ColorPalette.surfaceColor,
    borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
  );

  static BoxDecoration get circularDecoration => BoxDecoration(
    color: ColorPalette.surfaceColor,
    shape: BoxShape.circle,
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
  );

  // Common dividers
  static Widget get divider => const Divider(color: ColorPalette.dividerColor, thickness: 1, height: 1);

  static Widget get thickDivider => const Divider(color: ColorPalette.dividerColor, thickness: 2, height: 2);

  // Loading indicators
  static Widget get loadingIndicator =>
      const Center(child: CircularProgressIndicator(color: ColorPalette.primaryColor));

  static Widget loadingIndicatorWithText(String text) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: ColorPalette.primaryColor),
        UIHelpers.verticalSpaceMedium,
        Text(
          text,
          style: TextStyle(fontSize: AppConstants.fontSizeMedium, color: ColorPalette.secondaryTextColor),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  // Common fade transition
  static Widget fadeTransition(Widget child, Animation<double> animation) {
    return FadeTransition(opacity: animation, child: child);
  }

  // Common slide transition
  static Widget slideTransition(Widget child, Animation<Offset> animation) {
    return SlideTransition(position: animation, child: child);
  }

  // Safe area wrapper
  static Widget safeAreaWrapper(Widget child) {
    return SafeArea(child: child);
  }

  // Padding wrapper
  static Widget paddingWrapper(Widget child, {EdgeInsets? padding}) {
    return Padding(padding: padding ?? AppConstants.paddingScreenDefault, child: child);
  }

  // Common gesture detector for dismissing keyboard
  static Widget keyboardDismisser(Widget child) {
    return GestureDetector(onTap: () => FocusManager.instance.primaryFocus?.unfocus(), child: child);
  }

  // Common refresh indicator
  static Widget refreshWrapper(Widget child, Future<void> Function() onRefresh) {
    return RefreshIndicator(onRefresh: onRefresh, color: ColorPalette.primaryColor, child: child);
  }

  // Common list separator
  static Widget get listSeparator => UIHelpers.verticalSpaceSmall;

  // Common empty state
  static Widget emptyState({required String message, IconData? icon, Widget? action}) {
    return Center(
      child: Padding(
        padding: AppConstants.paddingLarge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppConstants.iconSizeXLarge * 2, color: ColorPalette.secondaryTextColor),
              UIHelpers.verticalSpaceMedium,
            ],
            Text(
              message,
              style: TextStyle(fontSize: AppConstants.fontSizeBody, color: ColorPalette.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[UIHelpers.verticalSpaceLarge, action],
          ],
        ),
      ),
    );
  }

  /// Displays a dialog to notify the user that Bluetooth is required.
  static Future<void> showBluetoothRequiredDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius16)),
            title: Row(
              children: [
                Icon(Icons.bluetooth_disabled, color: ColorPalette.errorColor, size: 24),
                SizedBox(width: 8),
                Text(
                  'Bluetooth Required',
                  style: AppTextStyles.heading3.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: Text(
              'Bluetooth is required for beacon detection during attendance verification. Please turn on Bluetooth and try again.\n\nNote: You can still register attendance without beacon detection if needed.',
              style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary, height: 1.4),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: ColorPalette.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }
}
