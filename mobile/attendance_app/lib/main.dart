import 'package:attendance_app/data/providers/date_provider.dart';
import 'package:attendance_app/data/providers/time_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/providers/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'presentation/screens/sign_in_screen.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/presentation/screens/student_dashboard.dart';
import 'package:attendance_app/presentation/screens/professor_dashboard.dart';
import 'data/models/student.dart';
import 'package:attendance_app/data/models/professor.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    throw Exception('Error loading .env file: $e');
  }

  setupServiceLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DateProvider()),
        ChangeNotifierProvider(create: (_) => TimeProvider()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Logger logger = Logger();
    return ScreenUtilInit(
      // Set the design size of your UI prototype (in logical pixels)
      // Common sizes: iPhone X/11 Pro: Size(375, 812), Google Pixel: Size(360, 690)
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context , child) {
        return MaterialApp(
          title: 'Attendance Verifier',
          // Add localization delegates and supported locales
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: ColorPalette.darkBlue),
            scaffoldBackgroundColor: Colors.white,
            brightness: Brightness.light,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              }
            )
          ),

          // Screens
          home: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoading) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              
              final user = userProvider.currentUser;
              
              if (user == null) {
                return SignInScreen();
              } else if (user is Student) {
                return StudentDashboard();
              } else if (user is Professor) {
                logger.i("Professor dashboard is in development");
                // TODO: Redirect to professor dashboard
                return ProfessorDashboard();
              } else {
                // Fallback
                return SignInScreen();
              }
            },
          ),
        );
      }
    );
  }
}