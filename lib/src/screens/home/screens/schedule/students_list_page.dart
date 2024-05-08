import 'package:flutter/material.dart';
import 'package:test_app/src/models/attendance_student_lesson.dart';
import 'package:test_app/src/models/group_student.dart';

class StudentsListPage extends StatelessWidget {
  final List<GroupStudent> groupStudentDtos;

  StudentsListPage({required this.groupStudentDtos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Студенты'),
      ),
      body: ListView.builder(
        itemCount: groupStudentDtos.length,
        itemBuilder: (context, index) {
          final group = groupStudentDtos[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _buildGroupHeader(group.name),
              SizedBox(height: 5),
              ...group.studentInLesson
                  .map((student) => _buildStudentTile(student)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroupHeader(String groupName) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey.shade300,
      child: Text(
        groupName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStudentTile(AttendanceStudentInLesson student) {
    return ListTile(
      title: Text(student.fullName),
      subtitle: Text('Статус посещения: ${student.isAttendance ? '+' : '-'}'),
      trailing: Text('Дата: ${student.attendanceDateTime.toString()}'),
    );
  }
}
