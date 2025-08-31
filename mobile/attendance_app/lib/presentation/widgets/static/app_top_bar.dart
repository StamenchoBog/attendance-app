import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';

class AppTopBar extends StatelessWidget {
  final String searchHintText;
  final Function(String)? onSearchChanged;
  final Widget? leadingWidget;
  final Widget? trailingWidget;

  const AppTopBar({
    super.key,
    this.searchHintText = 'Search',
    this.onSearchChanged,
    this.leadingWidget,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Leading widget (Logo)
        leadingWidget ??
            Image(image: const AssetImage('assets/logo/finki_logo.png'), height: AppConstants.iconSizeLarge),

        UIHelpers.horizontalSpace(AppConstants.spacing16),

        // Search field
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: searchHintText,
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.iconGrey),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: AppConstants.spacing12, right: AppConstants.spacing8),
                child: Icon(CupertinoIcons.search, size: AppConstants.iconSizeMedium, color: ColorPalette.iconGrey),
              ),
              prefixIconConstraints: BoxConstraints(
                minHeight: AppConstants.iconSizeMedium,
                minWidth: AppConstants.iconSizeMedium,
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: AppConstants.spacing12, horizontal: 0),
              filled: true,
              fillColor: ColorPalette.searchBarFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                borderSide: BorderSide.none,
              ),
            ),
            style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textPrimary),
            onChanged: onSearchChanged,
          ),
        ),
      ],
    );
  }
}
