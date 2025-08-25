import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:attendance_app/data/repositories/class_session_repository.dart';
import 'package:attendance_app/data/repositories/professor_repository.dart';
import 'package:attendance_app/data/repositories/room_repository.dart';
import 'package:attendance_app/data/repositories/subject_repository.dart';
import 'package:get_it/get_it.dart';
import './api/api_client.dart';
import '../repositories/student_repository.dart';
// Import other repositories

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // Register API client as singleton
  locator.registerLazySingleton(() => ApiClient());
  
  // Register repositories lazily (created only when first requested)
  locator.registerLazySingleton(() => StudentRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => AttendanceRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => ClassSessionRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => ProfessorRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => RoomRepository(locator<ApiClient>()));
  locator.registerLazySingleton(() => SubjectRepository(locator<ApiClient>()));
  // locator.registerLazySingleton(() => CourseRepository(locator<ApiClient>()));
  // Register other repositories
}