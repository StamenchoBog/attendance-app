import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';

enum NotificationType { success, error, warning, info }

class NotificationHelper {
  static void showNotification(
    BuildContext context, {
    required String message,
    required NotificationType type,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    bool showIcon = true,
    bool expandable = false,
    String? copyableText,
    String? copyLabel,
  }) {
    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    // For long messages, show as expandable notification
    if (message.length > 80 || expandable) {
      _showExpandableNotification(
        context,
        message: message,
        type: type,
        color: color,
        icon: icon,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        showIcon: showIcon,
        copyableText: copyableText,
        copyLabel: copyLabel,
      );
      return;
    }

    // For shorter messages, use optimized SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showIcon) ...[
                Padding(padding: EdgeInsets.only(top: 2.h), child: Icon(icon, color: Colors.white, size: 20.sp)),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w500, height: 1.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        action:
            actionLabel != null && onAction != null
                ? SnackBarAction(label: actionLabel, textColor: Colors.white, onPressed: onAction)
                : null,
      ),
    );
  }

  static void _showExpandableNotification(
    BuildContext context, {
    required String message,
    required NotificationType type,
    required Color color,
    required IconData icon,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
    bool showIcon = true,
    String? copyableText,
    String? copyLabel,
  }) {
    // Use overlay entry to show at the top of the screen
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => _ExpandableNotificationSheet(
            message: message,
            type: type,
            color: color,
            icon: icon,
            actionLabel: actionLabel,
            onAction: onAction,
            showIcon: showIcon,
            onDismiss: () {
              if (overlayEntry.mounted) {
                overlayEntry.remove();
              }
            },
            copyableText: copyableText,
            copyLabel: copyLabel,
          ),
    );

    overlayState.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool expandable = false,
  }) {
    showNotification(
      context,
      message: message,
      type: NotificationType.success,
      duration: duration,
      expandable: expandable,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
    String? actionLabel,
    VoidCallback? onAction,
    bool expandable = false,
  }) {
    showNotification(
      context,
      message: message,
      type: NotificationType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      expandable: expandable,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    bool expandable = false,
  }) {
    showNotification(
      context,
      message: message,
      type: NotificationType.warning,
      duration: duration,
      expandable: expandable,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool expandable = false,
  }) {
    showNotification(
      context,
      message: message,
      type: NotificationType.info,
      duration: duration,
      expandable: expandable,
    );
  }

  // New method specifically for success notifications with copyable report IDs
  static void showSuccessWithCopy(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 6),
    bool expandable = true,
    required String copyableText,
    String? copyLabel,
  }) {
    showNotification(
      context,
      message: message,
      type: NotificationType.success,
      duration: duration,
      expandable: expandable,
      copyableText: copyableText,
      copyLabel: copyLabel,
    );
  }

  // New method for error notifications with copyable text
  static void showErrorWithCopy(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 8),
    bool expandable = true,
    String? copyableText,
    String? copyLabel,
  }) {
    showNotification(
      context,
      message: message,
      type: NotificationType.error,
      duration: duration,
      expandable: expandable,
      copyableText: copyableText,
      copyLabel: copyLabel,
    );
  }

  static Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green.shade600;
      case NotificationType.error:
        return Colors.red.shade600;
      case NotificationType.warning:
        return Colors.orange.shade600;
      case NotificationType.info:
        return ColorPalette.darkBlue;
    }
  }

  static IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }
}

class _ExpandableNotificationSheet extends StatelessWidget {
  final String message;
  final NotificationType type;
  final Color color;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showIcon;
  final VoidCallback onDismiss;
  final String? copyableText;
  final String? copyLabel;

  const _ExpandableNotificationSheet({
    required this.message,
    required this.type,
    required this.color,
    required this.icon,
    this.actionLabel,
    this.onAction,
    required this.showIcon,
    required this.onDismiss,
    this.copyableText,
    this.copyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: InkWell(
            onTap: onDismiss,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and close button
                  Row(
                    children: [
                      if (showIcon) ...[Icon(icon, color: Colors.white, size: 24.sp), SizedBox(width: 12.w)],
                      Expanded(
                        child: Text(
                          _getTitleForType(type),
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                      GestureDetector(
                        onTap: onDismiss,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 18.sp),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Message content
                  Container(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: SingleChildScrollView(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  // Action button if provided
                  if (actionLabel != null && onAction != null) ...[
                    SizedBox(height: 16.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          onDismiss();
                          onAction!();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                        ),
                        child: Text(
                          actionLabel!,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ],

                  // Copy button if copyableText is provided
                  if (copyableText != null) ...[
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: copyableText!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                copyLabel ?? 'Copied to clipboard',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, height: 1.3),
                              ),
                              backgroundColor: Colors.green.shade600,
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              margin: EdgeInsets.all(16.w),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                        ),
                        child: Text(
                          copyLabel ?? 'Copy',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 8.h),

                  // Tap to dismiss hint
                  Center(
                    child: Text(
                      'Tap to dismiss',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTitleForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return 'Success';
      case NotificationType.error:
        return 'Error';
      case NotificationType.warning:
        return 'Warning';
      case NotificationType.info:
        return 'Information';
    }
  }
}
