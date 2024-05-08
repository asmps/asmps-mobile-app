import 'lesson.dart';

class Schedule {
  final String title;
  final List<LessonInSchedule> lessons;

  Schedule({
    required this.title,
    required this.lessons,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    var lessonList = json['lessons'] as List;
    List<LessonInSchedule> lessons =
        lessonList.map((lesson) => LessonInSchedule.fromJson(lesson)).toList();

    // Сортировка занятий по dayId, а затем по lessonOrderId
    lessons.sort((a, b) {
      if (a.dayId != b.dayId) {
        return a.dayId.compareTo(b.dayId);
      } else {
        return a.lessonOrderId.compareTo(b.lessonOrderId);
      }
    });

    return Schedule(
      title: json['title'],
      lessons: lessons,
    );
  }
}
