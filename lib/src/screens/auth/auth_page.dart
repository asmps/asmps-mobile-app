import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/src/screens/home/home_page.dart';
import 'login_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
      await prefs.setString('roles', decodedToken['role']);
      await prefs.setString('userId', decodedToken['LOCAL AUTHORITY']);

      final String role = decodedToken['role'];

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => HomePage(
                  token: token,
                  role: role,
                )),
      );
    } else {
      // Если токен отсутствует, переходим на страницу входа
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
