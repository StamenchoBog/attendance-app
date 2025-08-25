import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance_app/core/theme/color_palette.dart';

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
        // 
        // Leading widget (Logo)
        //
        leadingWidget ?? 
          Image(
            image: const AssetImage('assets/logo/finki_logo.png'),
            height: 30.h,
          ),
          
        SizedBox(width: 15.w),
        
        ///
        /// Search field
        ///
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: searchHintText,
              hintStyle: TextStyle(fontSize: 14.sp, color: ColorPalette.iconGrey),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 10.w, right: 6.w),
                child: Icon(
                  CupertinoIcons.search,
                  size: 20.sp,
                  color: ColorPalette.iconGrey,
                ),
              ),
              prefixIconConstraints: BoxConstraints(minHeight: 20.h, minWidth: 20.w),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0),
              filled: true,
              fillColor: ColorPalette.searchBarFill,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
            ),
            style: TextStyle(fontSize: 14.sp, color: ColorPalette.textPrimary),
            onChanged: onSearchChanged,
          ),
        ),
      ],
    );
  }
}
