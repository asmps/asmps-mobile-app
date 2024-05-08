import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/custom_text_field.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _loginController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String login = _loginController.text;
    final String password = _passwordController.text;
    final String url =
        'http://10.0.2.2:5190/api/Authorization'; // Измененный URL

    late String role;

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({'login': login, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String token = responseData[
            'accessToken']; // Сервер возвращает токен в поле 'accessToken'

        // Сохраняем токен в SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // Разбор и обработка токена
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        await prefs.setString('roles', decodedToken['role']);

        role = decodedToken['role'];

        if (decodedToken['role'] == 'Deanery') {
          // Переход на страницу администратора
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Вы вошли как администратор.'),
          ));
        }

        // Переход на домашнюю страницу
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    token: token,
                    role: role,
                  )),
        );
      } else {
        // Обработка ошибок авторизации
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Не удалось войти. Пожалуйста, проверьте свои учетные данные.'),
        ));
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Произошла ошибка.'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вход в систему', textAlign: TextAlign.center),
        centerTitle: true, // Здесь центрируем заголовок
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'ASMPS',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            CustomTextField(
              controller: _loginController,
              labelText: 'Логин',
            ),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Пароль',
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading ? CircularProgressIndicator() : Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
