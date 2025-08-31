import 'package:flutter/material.dart';
import 'package:attendance_app/core/services/permission_service.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/presentation/screens/sign_in_screen.dart';
import 'package:logger/logger.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final Logger _logger = Logger();
  bool _isCheckingPermissions = true;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isCheckingPermissions = true;
    });

    try {
      // Check if permissions are already granted
      final alreadyGranted = await PermissionService.arePermissionsGranted();

      if (alreadyGranted) {
        _logger.i('All permissions already granted, proceeding to sign in');
        _navigateToSignIn();
        return;
      }

      // Request permissions
      final granted = await PermissionService.requestInitialPermissions(context);

      setState(() {
        _isCheckingPermissions = false;
        _permissionsGranted = granted;
      });

      if (granted) {
        _navigateToSignIn();
      }
    } catch (e) {
      _logger.e('Error checking permissions: $e');
      setState(() {
        _isCheckingPermissions = false;
        _permissionsGranted = false;
      });
    }
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.pureWhite,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo
              Image(
                image: const AssetImage('assets/logo/finki_logo.png'),
                height: AppConstants.spacing64,
                fit: BoxFit.contain,
              ),

              UIHelpers.verticalSpace(AppConstants.spacing16),

              // App Title
              Text(
                'Attendance Verifier',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1.copyWith(color: ColorPalette.primaryTextColor),
              ),

              UIHelpers.verticalSpaceXLarge,

              if (_isCheckingPermissions) ...[
                // Loading state
                CircularProgressIndicator(color: ColorPalette.darkBlue),
                UIHelpers.verticalSpace(AppConstants.spacing24),
                Text(
                  'Setting up your app...',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(color: ColorPalette.primaryTextColor),
                ),
                UIHelpers.verticalSpace(AppConstants.spacing12),
                Text(
                  'Checking required permissions',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.secondaryTextColor),
                ),
              ] else if (!_permissionsGranted) ...[
                // Permission denied state
                Icon(Icons.security, size: AppConstants.spacing64, color: ColorPalette.errorColor),
                UIHelpers.verticalSpace(AppConstants.spacing24),
                Text(
                  'Permissions Required',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading2.copyWith(color: ColorPalette.primaryTextColor),
                ),
                UIHelpers.verticalSpace(AppConstants.spacing16),
                Text(
                  'This app needs certain permissions to function properly. Please grant the required permissions to continue.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.secondaryTextColor),
                ),
                UIHelpers.verticalSpace(AppConstants.spacing32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.darkBlue,
                      foregroundColor: ColorPalette.pureWhite,
                      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius8)),
                    ),
                    onPressed: _checkPermissions,
                    child: Text(
                      'Grant Permissions',
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
