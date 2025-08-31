import 'package:attendance_app/data/models/professor.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String? id;
  final String? name;
  final String? imageUrl; // TODO: Optional image URL

  const ProfileHeaderWidget({
    super.key,
    this.id, // Placeholder default
    this.name,
    this.imageUrl,
  });

  String getInitials(String name) {
    if (name.isEmpty) return '';
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 2 ? 2 : names.length;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0];
      }
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;

        // Use provider data if available, otherwise fall back to parameters
        final displayName = user != null ? user.name : name ?? 'Guest User';

        final displayId =
            user != null
                ? (user is Student ? (user).studentIndex : (user is Professor ? (user).title : 'User'))
                : id ?? '';

        final initials = getInitials(displayName);

        return Center(
          child: Column(
            children: [
              UIHelpers.verticalSpace(AppConstants.spacing20),
              CircleAvatar(
                radius: AppConstants.spacing64,
                backgroundColor: ColorPalette.lightestBlue,
                child:
                    imageUrl == null || imageUrl!.isEmpty
                        ? Text(
                          initials,
                          style: AppTextStyles.heading1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ColorPalette.darkBlue.withValues(alpha: 0.8),
                          ),
                        )
                        : ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            width: AppConstants.spacing64 * 2,
                            height: AppConstants.spacing64 * 2,
                            placeholder:
                                (context, url) => const CircularProgressIndicator(color: ColorPalette.darkBlue),
                            errorWidget:
                                (context, url, error) => Text(
                                  initials,
                                  style: AppTextStyles.heading1.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.darkBlue.withValues(alpha: 0.8),
                                  ),
                                ),
                          ),
                        ),
              ),
              UIHelpers.verticalSpace(AppConstants.spacing16),
              Text(
                displayName,
                style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold, color: ColorPalette.textPrimary),
              ),
              UIHelpers.verticalSpace(AppConstants.spacing4),
              Text(displayId, style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary)),
            ],
          ),
        );
      },
    );
  }
}
