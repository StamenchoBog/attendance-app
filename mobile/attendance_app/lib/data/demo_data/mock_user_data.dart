import '../models/student.dart';
import '../models/professor.dart';

class MockUsers {
  // Mock student data - using real FINKI naming patterns
  static Student getMockStudent() {
    return const Student(
      studentIndex: "161123", // Primary test student with realistic name
      email: "stefan.nikolovski@students.finki.ukim.mk",
      lastName: "Николовски",
      firstName: "Стефан",
      parentName: "Александар",
      studyProgramCode: "KN23", // Computer Science
    );
  }

  // Mock professor data - using real FINKI professor
  static Professor getMockProfessor() {
    return const Professor(
      id: "sasho.gramatikov",
      name: "Сашо Граматиков",
      email: "sasho.gramatikov@finki.ukim.mk",
      title: "PROFESSOR",
      orderingRank: 50,
      officeName: "Б-301",
    );
  }

  // Alternative test students with real names
  static List<Student> getAlternativeTestStudents() {
    return [
      const Student(
        studentIndex: "162123",
        email: "ana.petrovska@students.finki.ukim.mk",
        lastName: "Петровска",
        firstName: "Ана",
        parentName: "Марко",
        studyProgramCode: "SIIS23", // Software Engineering
      ),
      const Student(
        studentIndex: "163123",
        email: "marko.stojanov@students.finki.ukim.mk",
        lastName: "Стојанов",
        firstName: "Марко",
        parentName: "Петар",
        studyProgramCode: "KI23", // Computer Engineering
      ),
    ];
  }

  // Real FINKI professors for comprehensive testing
  static List<Professor> getAlternativeTestProfessors() {
    return [
      const Professor(
        id: "bojana.koteska",
        name: "Бојана Котеска",
        email: "bojana.koteska@finki.ukim.mk",
        title: "PROFESSOR",
        orderingRank: 35,
        officeName: "Б-306",
      ),
      const Professor(
        id: "kostadin.mishev",
        name: "Костадин Мишев",
        email: "kostadin.mishev@finki.ukim.mk",
        title: "PROFESSOR",
        orderingRank: 40,
        officeName: "Б-308",
      ),
      const Professor(
        id: "katerina.zdravkova",
        name: "Катерина Здравкова",
        email: "katerina.zdravkova@finki.ukim.mk",
        title: "PROFESSOR",
        orderingRank: 45,
        officeName: "223",
      )
    ];
  }
}
