import '../models/student.dart';
import '../models/professor.dart';

class MockUsers {
  // Mock student data
  static Student getMockStudent() {
    return Student(
      studentIndex: "1612023",
      email: "aleksandar.petrov@students.finki.ukim.mk",
      lastName: "Петров",
      firstName: "Александар",
      parentName: "Петров",
      studyProgramCode: "KN23_1"
    );
  }
  
  // Mock professor data
  static Professor getMockProfessor() {
    return Professor(
      id: "sasho.gramatikov",
      name: "Сашо Граматиков",
      email: "sasho.gramatikov@finki.ukim.mk",
      title: "ASSOCIATE_PROFESSOR",
      orderingRank: 35,
      officeName: null
    );
  }
}