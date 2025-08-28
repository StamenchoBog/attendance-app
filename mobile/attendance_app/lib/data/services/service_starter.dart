import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:attendance_app/data/repositories/class_session_repository.dart';
import 'package:attendance_app/data/repositories/professor_repository.dart';
import 'package:attendance_app/data/repositories/proximity_verification_repository.dart';
import 'package:attendance_app/data/repositories/report_repository.dart';
import 'package:attendance_app/data/repositories/room_repository.dart';
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

  // Register repositories lazily (created only when first requested)
  locator.registerLazySingleton(() => StudentRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => AttendanceRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => ClassSessionRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => ProfessorRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => ProximityVerificationRepository());
  locator.registerLazySingleton(() => ReportRepository());
  locator.registerLazySingleton(() => RoomRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => SubjectRepository(locator<ApiClient>()));
}
