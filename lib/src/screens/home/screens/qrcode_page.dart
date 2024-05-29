import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodePage extends StatefulWidget {
  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  late String userId = '';
  late String _qrData = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _checkUserInfo();
    _generateQrCode();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _generateQrCode() {
    // Создаем JSON-объект
    Map<String, dynamic> newData = {
      'userId': userId,
      'method': 'QR',
      'timestamp': '${DateTime.now().toUtc()}',
    };

    // Преобразуем JSON-объект в строку
    String jsonString = jsonEncode(newData);

    setState(() {
      _qrData = jsonString;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 20), (timer) {
      _generateQrCode();
    });
  }

  Future<void> _checkUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    await prefs.setString('userId', decodedToken['LOCAL AUTHORITY']);

    String? id = prefs.getString('userId');

    if (id != null) {
      setState(() {
        userId = id;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Не удалось получить информацию о пользователе. Пожалуйста, перезайдите в приложение.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Пропуск QR-код для входа в здание'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 360,
              gapless: false,
              errorStateBuilder: (cxt, err) {
                return Container(
                  child: Center(
                    child: Text(
                      'Ой-ой! Что-то пошло не так...',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
