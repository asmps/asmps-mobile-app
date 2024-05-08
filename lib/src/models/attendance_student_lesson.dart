class AttendanceStudentInLesson {
  /// ФИО студента
  final String fullName;

  /// Дата посещения
  final DateTime attendanceDateTime;

  /// Посещаемость
  final bool isAttendance;

  AttendanceStudentInLesson({
    required this.fullName,
    required this.attendanceDateTime,
    required this.isAttendance,
  });

  factory AttendanceStudentInLesson.fromJson(Map<String, dynamic> json) {
    // Извлекаем данные из JSON и создаем экземпляр AttendanceStudentInLessonDto
    return AttendanceStudentInLesson(
      fullName: json['FullName'] ?? '', // ФИО студента
      attendanceDateTime:
          DateTime.parse(json['AttendanceDateTime']), // Дата посещения
      isAttendance: json['IsAttendance'] ?? false, // Посещаемость
    );
  }
}
