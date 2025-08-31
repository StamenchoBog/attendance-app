import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/constants/app_constants.dart';

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxShape shape;
  final double borderRadius;

  const SkeletonLoader({super.key, this.width, this.height, this.shape = BoxShape.rectangle, this.borderRadius = 8.0});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorPalette.skeletonBaseColor,
      highlightColor: ColorPalette.skeletonHighlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ColorPalette.placeholderGrey,
          shape: shape,
          borderRadius:
              shape == BoxShape.rectangle
                  ? BorderRadius.circular(borderRadius == 8.0 ? AppConstants.borderRadius8 : borderRadius.r)
                  : null,
        ),
      ),
    );
  }
}
