import 'package:test_app/src/models/attendance_student_lesson.dart';

class GroupStudent {
  /// Название группы
  final String name;

  /// Список студентов данной группы
  final List<AttendanceStudentInLesson> studentInLesson;

  GroupStudent({required this.name, required this.studentInLesson});

  factory GroupStudent.fromJson(Map<String, dynamic> json) {
    // Извлекаем данные из JSON и создаем экземпляр GroupStudentDto
    return GroupStudent(
      name: json['name'] ?? '', // Название группы
      studentInLesson: (json['studentInLesson'] as List<dynamic>).map((item) {
        // Преобразуем список студентов в соответствующие модели данных
        return AttendanceStudentInLesson.fromJson(item);
      }).toList(),
    );
  }
}
