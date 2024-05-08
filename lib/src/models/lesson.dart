import 'lesson_info.dart';

class LessonInSchedule {
  final LessonInScheduleInfo lessonInScheduleInfo;
  final int dayId;
  final int lessonOrderId;
  final String? note;

  LessonInSchedule({
    required this.lessonInScheduleInfo,
    required this.dayId,
    required this.lessonOrderId,
    this.note,
  });

  factory LessonInSchedule.fromJson(Map<String, dynamic> json) {
    return LessonInSchedule(
      lessonInScheduleInfo:
          LessonInScheduleInfo.fromJson(json['lessonInScheduleInfoDto']),
      dayId: json['dayId'], // Добавляем геттер dayId
      lessonOrderId: json['lessonOrderId'],
      note: json['note'],
    );
  }
}
