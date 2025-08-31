import '../models/student.dart';
import '../models/professor.dart';

class MockUsers {
  static Student getMockStudent() {
    return const Student(
      studentIndex: "161123",
      email: "stefan.nikolovski@students.finki.ukim.mk",
      lastName: "Николовски",
      firstName: "Стефан",
      parentName: "Александар",
      studyProgramCode: "KN23",
    );
  }

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

  static List<Student> getAlternativeTestStudents() {
    return [
      const Student(
        studentIndex: "162123",
        email: "ana.petrovska@students.finki.ukim.mk",
        lastName: "Петровска",
        firstName: "Ана",
        parentName: "Марко",
        studyProgramCode: "SIIS23",
      ),
      const Student(
        studentIndex: "163123",
        email: "marko.stojanov@students.finki.ukim.mk",
        lastName: "Стојанов",
        firstName: "Марко",
        parentName: "Петар",
        studyProgramCode: "KI23",
      ),
    ];
  }

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
      ),
    ];
  }
}
