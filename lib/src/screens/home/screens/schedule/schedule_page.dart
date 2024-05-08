import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:test_app/src/models/attendance_student_lesson.dart';
import 'package:test_app/src/models/group_student.dart';
import 'package:test_app/src/models/lesson.dart';
import 'package:test_app/src/models/schedule.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:test_app/src/screens/home/screens/schedule/students_list_page.dart';

class SchedulePage extends StatefulWidget {
  final String token;
  final String role;

  SchedulePage({required this.token, required this.role});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late Future<Schedule> _scheduleFuture;
  late String _url; // Измененный URL

  final ScrollController _scrollController = ScrollController();
  String _currentWeek = '';
  String _currentDay = '';
  int _lastDayIndex = 0; // Переменная для хранения индекса последнего дня

  @override
  void initState() {
    super.initState();
    _url = widget.role == 'Student'
        ? 'http://10.0.2.2:5190/api/Schedules/schedule-for-student'
        : 'http://10.0.2.2:5190/api/Schedules/schedule-for-teacher';
    _scheduleFuture = _fetchSchedule();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<Schedule> _fetchSchedule() async {
    final response = await http.get(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Schedule.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load schedule. Response body: ${response.body}');
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final lessonIndices =
        _scrollController.position.pixels; // Позиция скролла в пикселях
    final lessonIndex = (lessonIndices / 140).toInt(); // Индекс занятия

    final currentWeek = (lessonIndex ~/ 12) + 1; // Определяем текущую неделю
    final currentDayIndex =
        (lessonIndex % 12) ~/ 2; // Определяем индекс дня текущей недели
    final currentDay = getDayOfWeek(currentDayIndex); // Получаем название дня

    // Определяем, является ли текущий день понедельником
    final isMonday = currentDayIndex == 0;

    // При достижении понедельника, инкрементируем текущую неделю
    if (isMonday && _lastDayIndex != 0) {
      setState(() {
        _currentWeek =
            'Неделя ${currentWeek + 1}'; // Инкрементируем текущую неделю
        _currentDay = currentDay; // Обновляем текущий день
      });
    } else {
      setState(() {
        _currentWeek = 'Неделя $currentWeek'; // Обновляем текущую неделю
        _currentDay = currentDay; // Обновляем текущий день
      });
    }

    _lastDayIndex =
        currentDayIndex; // Сохраняем индекс текущего дня для следующей проверки
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('$_currentWeek - $_currentDay'),
      ),
      body: FutureBuilder<Schedule>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error.toString());
            return Center(child: Text('Ошибка загрузки расписания'));
          } else {
            return ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data!.lessons.length,
              itemBuilder: (context, index) {
                final lesson = snapshot.data!.lessons[index];
                final dayOfWeek = getDayOfWeek(lesson.dayId);

                if (index == 0 ||
                    lesson.dayId != snapshot.data!.lessons[index - 1].dayId) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      _buildDayScheduleHeader(dayOfWeek),
                      _buildLessonTile(lesson),
                    ],
                  );
                } else {
                  return _buildLessonTile(lesson);
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildDayScheduleHeader(String dayOfWeek) {
    return Container(
      color: Colors.grey.shade200,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        dayOfWeek,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLessonTile(LessonInSchedule lesson) {
    return ListTile(
      title: Text(
        '${lesson.lessonInScheduleInfo.discipline}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () {
        if (widget.role == 'Teacher') {
          _showStudentsForLesson(context, lesson);
        } else {
          _showLessonDetails(context, lesson);
        }
      },
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Тип: ${lesson.lessonInScheduleInfo.type}'),
          Text('Время: ${getLessonStartTime(lesson.lessonOrderId)}'),
          Text('Учитель: ${lesson.lessonInScheduleInfo.teacher}'),
          Text('Аудитория: ${lesson.lessonInScheduleInfo.audience}'),
        ],
      ),
    );
  }

  void _showLessonDetails(BuildContext context, LessonInSchedule lesson) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Информация о занятии'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Предмет: ${lesson.lessonInScheduleInfo.discipline}'),
              Text('Преподаватель: ${lesson.lessonInScheduleInfo.teacher}'),
              Text('Время: ${getLessonStartTime(lesson.lessonOrderId)}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _confirmPresence(context, lesson);
                },
                child: Text('Подтвердить присутствие'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStudentsForLesson(
      BuildContext context, LessonInSchedule lesson) async {
    final lessonId = lesson.lessonInScheduleInfo.lessonId;
    final url =
        'http://10.0.2.2:5190/api/Teachers/get-students-in-lesson/$lessonId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<GroupStudent> groupStudentDtos =
            (json.decode(response.body) as List)
                .map((data) => GroupStudent.fromJson(data))
                .toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StudentsListPage(groupStudentDtos: groupStudentDtos),
          ),
        );
      } else {
        throw Exception('Failed to load students for lesson');
      }
    } catch (error) {
      print('Error load list: $error');
      // Обработка ошибки при получении данных
    }
  }

  void _confirmPresence(BuildContext context, LessonInSchedule lesson) async {
    // Определение URL вашего API
    final url = Uri.parse('http://10.0.2.2:5190/api/Students/attendance');

    // Парсим JWT
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);

    final String studentId = decodedToken['LOCAL AUTHORITY'];

    // Параметры для отправки на сервер
    var body = jsonEncode({
      'studentId': studentId,
      'attendanceDateTime': DateTime.now().toLocal().toIso8601String(),
      'lessonId': lesson.lessonInScheduleInfo
          .lessonId, // Предполагается, что lessonId доступен
      'isAttendance': true, // Предполагается, что подтверждаете присутствие
    });

    // Отправка POST-запроса на сервер
    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    // Проверка статуса ответа
    if (response.statusCode == 200) {
      // Если запрос успешен, выводим сообщение об успешном подтверждении присутствия
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Присутствие на занятии "${lesson.lessonInScheduleInfo.discipline}" подтверждено'),
      ));
      print(
          'Присутствие на занятии ${lesson.lessonInScheduleInfo.discipline} подтверждено');
      Navigator.of(context).pop(); // Закрываем диалоговое окно
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ошибка при подтверждении присутствия: ${response.body}'),
      ));
      // Если запрос завершился неудачей, выводим сообщение об ошибке
      print(
          'Ошибка при подтверждении присутствия: ${lesson.lessonInScheduleInfo.lessonId}');
      // Здесь можно добавить код для отображения сообщения об ошибке пользователю
    }
  }

  String getLessonStartTime(int lessonOrderId) {
    final List<String> lessonStartTimes = [
      '8:30 - 10:00', // 8:30 - 10:00, lessonOrderId = 0
      '10:15 - 11:45', // 10:15 - 11:45, lessonOrderId = 1
      '12:00 - 13:30', // 12:00 - 13:30, lessonOrderId = 2
      '14:00 - 15:30', // 14:00 - 15:30, lessonOrderId = 3
      '15:45 - 17:15', // 15:45 - 17:15, lessonOrderId = 4
      '17:30 - 19:00', // 17:30 - 19:00, lessonOrderId = 5
      '19:15 - 20:45', // 19:15 - 20:45, lessonOrderId = 6
    ];

    if (lessonOrderId >= 0 && lessonOrderId < lessonStartTimes.length) {
      return lessonStartTimes[lessonOrderId];
    } else {
      // Обработка неправильного lessonOrderId
      return '';
    }
  }

  String getDayOfWeek(int dayId) {
    final daysOfWeek = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
    ];
    return daysOfWeek[dayId % 6];
  }
}
