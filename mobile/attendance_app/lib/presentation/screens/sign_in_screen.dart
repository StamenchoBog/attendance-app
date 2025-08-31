import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/presentation/screens/professor_dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/presentation/screens/student_dashboard.dart';
import 'package:attendance_app/presentation/screens/cas_login_screen.dart';
import 'package:attendance_app/data/services/api/api_roles.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  static final Logger _logger = Logger();

  // --- Placeholder Functions ---
  void _handleCasSignIn(BuildContext context) {
    _logger.i("Continue with CAS tapped");
    // TODO: Implement CAS Sign In logic & navigation

    fastPush(
      context,
      CasLoginScreen(
        onLoginSuccess: (user) {
          if (user.role == ApiRoles.studentRole) {
            fastPushReplacement(context, const StudentDashboard());
          } else if (user.role == ApiRoles.professorRole) {
            fastPushReplacement(context, const ProfessorDashboard());
          }
        },
      ),
    );
  }

  void _openTermsOfService() {
    _logger.i("Terms of Service tapped");
    // TODO: Implement navigation to Terms of Service
  }

  void _openPrivacyPolicy() {
    _logger.i("Privacy Policy tapped");
    // TODO: Implement navigation to Privacy Policy
  }

  // --- End Placeholder Functions ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.pureWhite,
      body: SafeArea(
        child: Stack(
          children: [
            if (kDebugMode)
              Positioned(
                top: AppConstants.spacing12,
                right: AppConstants.spacing12,
                child: PopupMenuButton<String>(
                  onSelected: (String result) {
                    if (result == 'student') {
                      Provider.of<UserProvider>(context, listen: false).mockLoginAs('student');
                      fastPushReplacement(context, const StudentDashboard());
                    } else if (result == 'professor') {
                      Provider.of<UserProvider>(context, listen: false).mockLoginAs('professor');
                      fastPushReplacement(context, const ProfessorDashboard());
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'student',
                          child: Text(
                            'Login as Student (Dev)',
                            style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textPrimary),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'professor',
                          child: Text(
                            'Login as Professor (Dev)',
                            style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textPrimary),
                          ),
                        ),
                      ],
                  icon: Icon(
                    CupertinoIcons.arrow_down_right_square,
                    color: ColorPalette.iconGrey,
                    size: AppConstants.iconSizeMedium,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // --- Logo ---
                  Image(
                    image: const AssetImage('assets/logo/finki_logo.png'),
                    height: AppConstants.spacing64,
                    fit: BoxFit.contain,
                  ),

                  // --- End Logo ---
                  UIHelpers.verticalSpace(AppConstants.spacing16),

                  // --- App Title ---
                  Text(
                    'Attendance Verifier',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading1.copyWith(color: ColorPalette.textPrimary),
                  ),

                  // --- End App Title ---
                  UIHelpers.verticalSpaceXLarge,

                  // --- Section Title ---
                  Text(
                    'Sign-in',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading2.copyWith(color: ColorPalette.textPrimary),
                  ),

                  // --- End Section Title ---
                  UIHelpers.verticalSpaceSmall,

                  // --- Subtitle ---
                  Text(
                    'Login via the Central Authentication System',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary),
                  ),

                  // --- End Subtitle ---
                  UIHelpers.verticalSpaceLarge,

                  // --- Sign In Button ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.buttonBackgroundLight,
                      foregroundColor: ColorPalette.textPrimary,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius8)),
                    ),
                    onPressed: () => _handleCasSignIn(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(image: const AssetImage('assets/logo/cas_logo.png'), height: AppConstants.iconSizeMedium),
                        UIHelpers.horizontalSpace(AppConstants.spacing12),
                        Text(
                          'Continue with CAS',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorPalette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- End Sign In Button ---
                  UIHelpers.verticalSpace(AppConstants.spacing24),

                  // --- Disclaimer Text ---
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTextStyles.caption.copyWith(color: ColorPalette.textSecondary, height: 1.4),
                      children: <TextSpan>[
                        const TextSpan(text: 'By clicking continue, you agree to our '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: AppTextStyles.caption.copyWith(
                            color: ColorPalette.darkBlue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = _openTermsOfService,
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppTextStyles.caption.copyWith(
                            color: ColorPalette.darkBlue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = _openPrivacyPolicy,
                        ),
                      ],
                    ),
                  ),

                  // --- End Disclaimer Text ---
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
