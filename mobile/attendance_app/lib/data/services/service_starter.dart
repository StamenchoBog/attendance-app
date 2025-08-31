import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:attendance_app/data/repositories/class_session_repository.dart';
import 'package:attendance_app/data/repositories/course_repository.dart';
import 'package:attendance_app/data/repositories/presentation_repository.dart';
import 'package:attendance_app/data/repositories/professor_repository.dart';
import 'package:attendance_app/data/repositories/proximity_verification_repository.dart';
import 'package:attendance_app/data/repositories/qr_repository.dart';
import 'package:attendance_app/data/repositories/report_repository.dart';
import 'package:attendance_app/data/repositories/room_repository.dart';
import 'package:attendance_app/data/repositories/semester_repository.dart';
import 'package:attendance_app/data/repositories/student_group_repository.dart';
import 'package:attendance_app/data/repositories/subject_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './api/api_client.dart';
import '../repositories/student_repository.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // Register Dio instance with base configuration
  locator.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_URL'] ?? '',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );
    return dio;
  });

  // Register API client as singleton
  locator.registerLazySingleton(() => ApiClient());

  // Register all repositories lazily (created only when first requested)
  locator.registerLazySingleton(() => StudentRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => AttendanceRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => ClassSessionRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => CourseRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => PresentationRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => ProfessorRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => ProximityVerificationRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => QRRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => ReportRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => RoomRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => SemesterRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => StudentGroupRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => SubjectRepository(locator<ApiClient>()));
}
