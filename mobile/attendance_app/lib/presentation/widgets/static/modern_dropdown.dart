import 'package:flutter/material.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:logger/logger.dart';

class ModernDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final String Function(T) getDisplayText;
  final void Function(T?) onChanged;
  final String Function(T)? getSearchText;
  final bool isLoading;
  final IconData? prefixIcon;

  static final Logger _logger = Logger();

  const ModernDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.getDisplayText,
    required this.onChanged,
    this.getSearchText,
    this.isLoading = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
        border: Border.all(color: ColorPalette.placeholderGrey, width: 1.5),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child:
          isLoading
              ? Container(
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                child: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(prefixIcon, size: AppConstants.iconSizeSmall, color: ColorPalette.iconGrey),
                      SizedBox(width: AppConstants.spacing12),
                    ],
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                      ),
                    ),
                    SizedBox(width: AppConstants.spacing12),
                    Text('Loading...', style: AppTextStyles.bodySmall.copyWith(color: ColorPalette.secondaryTextColor)),
                  ],
                ),
              )
              : Container(
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T?>(
                    value: value,
                    hint: Row(
                      children: [
                        if (prefixIcon != null) ...[
                          Icon(prefixIcon, size: AppConstants.iconSizeSmall, color: ColorPalette.iconGrey),
                          SizedBox(width: AppConstants.spacing12),
                        ],
                        Expanded(
                          child: Text(
                            hint,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: ColorPalette.secondaryTextColor,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: AppConstants.iconSizeSmall,
                      color: value != null ? ColorPalette.primaryColor : ColorPalette.iconGrey,
                    ),
                    style: AppTextStyles.bodySmall.copyWith(color: ColorPalette.primaryTextColor),
                    dropdownColor: Colors.white,
                    menuMaxHeight: 300,
                    onChanged: (T? newValue) {
                      _logger.d('DropdownButton onChanged called with: $newValue');
                      onChanged(newValue);
                    },
                    items: [
                      // Add clear filter option if value is not null
                      if (value != null)
                        DropdownMenuItem<T?>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(Icons.clear, size: AppConstants.iconSizeSmall, color: ColorPalette.errorColor),
                              SizedBox(width: AppConstants.spacing12),
                              Text(
                                'Clear filter',
                                style: AppTextStyles.bodySmall.copyWith(color: ColorPalette.errorColor),
                              ),
                            ],
                          ),
                        ),
                      // Add divider if clear option exists
                      if (value != null && items.isNotEmpty)
                        DropdownMenuItem<T?>(enabled: false, value: null, child: const Divider(height: 1)),
                      // Add regular items
                      ...items.map<DropdownMenuItem<T?>>((T item) {
                        return DropdownMenuItem<T?>(
                          value: item,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: AppConstants.spacing8,
                              horizontal: AppConstants.spacing4,
                            ),
                            child: Text(
                              getDisplayText(item),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: value == item ? ColorPalette.primaryColor : ColorPalette.primaryTextColor,
                                fontWeight: value == item ? FontWeight.w600 : FontWeight.normal,
                              ),
                              overflow: TextOverflow.visible,
                              maxLines: 2,
                              softWrap: true,
                            ),
                          ),
                        );
                      }),
                    ],
                    selectedItemBuilder: (BuildContext context) {
                      List<Widget> selectedItems = [];

                      // Skip the clear filter option and divider in selected item builder
                      if (value != null) {
                        selectedItems.add(Container()); // Placeholder for clear filter
                      }
                      if (value != null && items.isNotEmpty) {
                        selectedItems.add(Container()); // Placeholder for divider
                      }

                      // Add the actual items
                      selectedItems.addAll(
                        items.map<Widget>((T item) {
                          return Row(
                            children: [
                              if (prefixIcon != null) ...[
                                Icon(prefixIcon, size: AppConstants.iconSizeSmall, color: ColorPalette.primaryColor),
                                SizedBox(width: AppConstants.spacing12),
                              ],
                              Expanded(
                                child: Text(
                                  getDisplayText(item),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: ColorPalette.primaryTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );

                      return selectedItems;
                    },
                  ),
                ),
              ),
    );
  }
}
