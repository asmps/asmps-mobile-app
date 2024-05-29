import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:test_app/src/models/user.dart';
import 'package:test_app/src/screens/auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  final String token;

  ProfilePage({required this.token});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> _userFuture;
  final String url = 'http://10.0.2.2:5190/api/Users/current';

  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _patronymicController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _patronymicController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    // Очистка данных аутентификации
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Переход на страницу входа
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<User> _fetchUserData() async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String userId =
          responseData['id']; // Сервер возвращает токен в поле 'id'

      // Сохраняем токен в SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      return User.fromJson(responseData);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> _saveUserData() async {
    // Получаем новые значения из контроллеров
    String newName = _nameController.text;
    String newSurname = _surnameController.text;
    String newPatronymic = _patronymicController.text;
    String newEmail = _emailController.text;

    // Формируем тело запроса
    Map<String, dynamic> requestBody = {
      'name': newName,
      'surname': newSurname,
      'patronymic': newPatronymic,
      'email': newEmail,
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      // Данные успешно обновлены
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Данные успешно сохранены')),
      );
    } else {
      // Произошла ошибка при обновлении данных
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении данных')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error.toString());
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка загрузки данных'),
                  SizedBox(height: 20), // Расстояние между текстом и кнопкой
                  ElevatedButton.icon(
                    onPressed: () {
                      // Действия для выхода из аккаунта
                      _logout(context);
                    },
                    icon: Icon(Icons.exit_to_app),
                    label: Text('Выход'),
                  ),
                ],
              ),
            );
          } else {
            // Заполнение данных пользователя в контроллеры
            _nameController.text = snapshot.data!.name;
            _surnameController.text = snapshot.data!.surname;
            _patronymicController.text = snapshot.data!.patronymic ?? '';
            _emailController.text = snapshot.data!.email ?? '';

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Имя'),
                  ),
                  TextFormField(
                    controller: _surnameController,
                    decoration: InputDecoration(labelText: 'Фамилия'),
                  ),
                  TextFormField(
                    controller: _patronymicController,
                    decoration: InputDecoration(labelText: 'Отчество'),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveUserData,
                          icon: Icon(Icons.save),
                          label: Text('Сохранить'),
                        ),
                      ),
                      SizedBox(width: 10), // Пространство между кнопками
                      ElevatedButton.icon(
                        onPressed: () {
                          // Действия для выхода из аккаунта
                          _logout(context);
                        },
                        icon: Icon(Icons.exit_to_app),
                        label: Text('Выход'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
