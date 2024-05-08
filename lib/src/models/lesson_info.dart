class LessonInScheduleInfo {
  final String lessonId;
  final List<String>? groups;
  final String discipline;
  final String teacher;
  final String audience;
  final String type;

  LessonInScheduleInfo({
    required this.lessonId,
    this.groups,
    required this.discipline,
    required this.teacher,
    required this.audience,
    required this.type,
  });

  factory LessonInScheduleInfo.fromJson(Map<String, dynamic> json) {
    return LessonInScheduleInfo(
      lessonId: json['id'],
      groups: json['groups'] != null ? List<String>.from(json['groups']) : null,
      discipline: json['discipline'],
      teacher: json['teacher'],
      audience: json['audience'],
      type: json['type'],
    );
  }
}
