import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/presentation/screens/professor_dashboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/presentation/screens/student_dashboard.dart';
import 'package:attendance_app/presentation/screens/cas_login_screen.dart';
import 'package:attendance_app/data/services/api/api_roles.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';


class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});
  static final Logger _logger = Logger();
  // --- Placeholder Functions ---
  void _handleCasSignIn(BuildContext context) {
    _logger.i("Continue with CAS tapped");
    // TODO: Implement CAS Sign In logic & navigation

    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CasLoginScreen(
        onLoginSuccess: (user) {
          if (user.role == ApiRoles.studentRole) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentDashboard()),
            );
          } else if (user.role == ApiRoles.professorRole) {
            // TODO: Redirect to professor dashboard
          }
        },
      )),
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
    // --- Style Assumptions ---
    const Color primaryTextColor = Colors.black87;
    const Color secondaryTextColor = Colors.black54;
    const Color linkColor = ColorPalette.darkBlue;
    const Color buttonBackgroundColor = Color(0xFFF0F0F0);
    const Color buttonTextColor = Colors.black87;
    // --- End Style Assumptions ---

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const Spacer(flex: 2),

              // --- Logo ---
              Image(
                image: AssetImage('assets/logo/finki_logo.png'),
                height: 60.h,
                fit: BoxFit.contain,
              ),
              // --- End Logo ---

              SizedBox(height: 16.h),

              // --- App Title ---
              Text(
                'Attendance Verifier',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              // --- End App Title ---

              SizedBox(height: 48.h),

              // --- Section Title ---
              Text(
                'Sign-in',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              // --- End Section Title ---

              SizedBox(height: 8.h),

              // --- Subtitle ---
              Text(
                'Login via the Central Authentication System',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: secondaryTextColor,
                ),
              ),
              // --- End Subtitle ---

              SizedBox(height: 24.h),

              // --- Sign In Button ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBackgroundColor,
                  foregroundColor: buttonTextColor,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () => _handleCasSignIn(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage('assets/logo/cas_logo.png'),
                      height: 24.h,
                    ),
                    SizedBox(width: 11.w),
                    Text(
                      'Continue with CAS',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // --- End Sign In Button ---

              if (kDebugMode)
                Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Column(
                    children: [
                      Text('-- For Development Only --', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<UserProvider>(context, listen: false).mockLoginAs('student');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const StudentDashboard()),
                          );
                        },
                        child: const Text('Login as Student (Dev)'),
                      ),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<UserProvider>(context, listen: false).mockLoginAs('professor');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfessorDashboard()),
                          );
                        },
                        child: const Text('Login as Professor (Dev)'),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 24.h),

              // --- Disclaimer Text ---
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: secondaryTextColor,
                    height: 1.4, // Line height often doesn't need scaling
                  ),
                  children: <TextSpan>[
                    const TextSpan(text: 'By clicking continue, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: const TextStyle(
                        color: linkColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _openTermsOfService,
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                        color: linkColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _openPrivacyPolicy,
                    ),
                  ],
                ),
              ),
              // --- End Disclaimer Text ---

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}