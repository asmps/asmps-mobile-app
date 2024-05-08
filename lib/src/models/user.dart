import 'package:intl/intl.dart';

class User {
  final String id;
  final String name;
  final String surname;
  final String? patronymic;
  final String? email;
  final String role;
  final String createdDate;

  User({
    required this.id,
    required this.name,
    required this.surname,
    this.patronymic,
    this.email,
    required this.role,
    required this.createdDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      patronymic: json['patronymic'],
      email: json['email'],
      role: json['role'],
      createdDate: DateFormat('dd.MM.yyyy HH:mm:ss')
          .format(DateTime.parse(json['createdDate'])),
    );
  }
}
