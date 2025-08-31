import 'package:flutter/material.dart';

class ColorPalette {
  // Primary brand colors - Modern blue theme for faculty
  static const Color primary50 = Color(0xFFEFF6FF); // Lightest blue
  static const Color primary100 = Color(0xFFDBEAFE); // Very light blue
  static const Color primary200 = Color(0xFFBFDBFE); // Light blue
  static const Color primary300 = Color(0xFF93C5FD); // Medium light blue
  static const Color primary400 = Color(0xFF60A5FA); // Medium blue
  static const Color primary500 = Color(0xFF3B82F6); // Main brand blue
  static const Color primary600 = Color(0xFF2563EB); // Dark blue
  static const Color primary700 = Color(0xFF1D4ED8); // Darker blue
  static const Color primary800 = Color(0xFF1E40AF); // Very dark blue
  static const Color primary900 = Color(0xFF1E3A8A); // Darkest blue

  // Legacy color mappings for backward compatibility
  static const Color lightestBlue = primary50;
  static const Color lightBlue = primary200;
  static const Color darkBlue = primary600;
  static const Color primaryColor = primary500; // Main brand color

  // Neutral colors - Modern gray scale
  static const Color neutral50 = Color(0xFFFAFAFA); // Lightest gray
  static const Color neutral100 = Color(0xFFF5F5F5); // Very light gray
  static const Color neutral200 = Color(0xFFE5E5E5); // Light gray
  static const Color neutral300 = Color(0xFFD4D4D4); // Medium light gray
  static const Color neutral400 = Color(0xFFA3A3A3); // Medium gray
  static const Color neutral500 = Color(0xFF737373); // Gray
  static const Color neutral600 = Color(0xFF525252); // Dark gray
  static const Color neutral700 = Color(0xFF404040); // Darker gray
  static const Color neutral800 = Color(0xFF262626); // Very dark gray
  static const Color neutral900 = Color(0xFF171717); // Darkest gray

  // Background colors - Clean and modern
  static const Color backgroundColor = neutral50; // Light background
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure white cards
  static const Color surfaceColor = Color(0xFFFFFFFF); // Surface elements
  static const Color containerBackground = neutral100; // Light containers

  // Text colors - Improved hierarchy and readability
  static const Color textPrimary = neutral900; // Primary text (darkest)
  static const Color textSecondary = neutral600; // Secondary text
  static const Color textTertiary = neutral500; // Tertiary text
  static const Color textDisabled = neutral400; // Disabled text
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White text on blue
  static const Color textDark = neutral800; // Dark text (legacy support)

  // Legacy text color support
  static const Color primaryTextColor = textPrimary;
  static const Color secondaryTextColor = textSecondary;

  // Status colors - Modern and accessible
  static const Color successColor = Color(0xFF10B981); // Modern green
  static const Color warningColor = Color(0xFFF59E0B); // Modern amber
  static const Color errorColor = Color(0xFFEF4444); // Modern red
  static const Color infoColor = primary500; // Brand blue for info
  static const Color criticalColor = Color(0xFF7C3AED); // Purple for critical

  // Interactive states
  static const Color focusColor = primary500;
  static const Color hoverColor = primary100;
  static const Color pressedColor = primary200;
  static const Color disabledColor = neutral300;
  static const Color dividerColor = neutral200;

  // Common whites and transparency
  static const Color pureWhite = Color(0xFFFFFFFF);
  static Color whiteTransparent08 = pureWhite.withValues(alpha: 0.08);
  static Color whiteTransparent20 = pureWhite.withValues(alpha: 0.20);
  static Color whiteTransparent80 = pureWhite.withValues(alpha: 0.80);

  // UI element colors - More consistent
  static Color placeholderGrey = neutral400;
  static Color iconGrey = neutral500;
  static Color searchBarFill = neutral100;
  static Color iconColor = neutral600;

  // Skeleton loader colors - Subtle and modern
  static Color skeletonBaseColor = neutral200;
  static Color skeletonHighlightColor = neutral100;

  // Button variations
  static const Color buttonBackgroundLight = neutral100;
  static const Color screenBackgroundLight = neutral50;

  // Semantic color mappings for better UX
  static const Color onlineColor = successColor;
  static const Color offlineColor = neutral400;
  static const Color pendingColor = warningColor;
  static const Color verifiedColor = successColor;
  static const Color absentColor = errorColor;

  // Surface elevation colors (for cards and elevated surfaces)
  static const Color elevation1 = Color(0xFFFFFFFF); // Level 1 elevation
  static const Color elevation2 = Color(0xFFFEFEFE); // Level 2 elevation
  static const Color elevation3 = Color(0xFFFDFDFD); // Level 3 elevation

  // Border colors
  static const Color borderPrimary = neutral200;
  static const Color borderSecondary = neutral300;
  static const Color borderFocus = primary500;
  static const Color borderError = errorColor;
  static const Color borderSuccess = successColor;
}
