import 'package:flutter/material.dart';
import 'package:test_app/src/screens/home/screens/profile_page.dart';
import 'package:test_app/src/screens/home/screens/qrcode_page.dart';
import 'package:test_app/src/screens/home/screens/schedule/schedule_page.dart';

class HomePage extends StatelessWidget {
  final String token;
  final String role;

  HomePage({required this.token, required this.role});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // количество вкладок
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('ASMPS'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Рассписание'),
              Tab(text: 'Личный профиль'),
              Tab(text: 'QR-код'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Виджеты для каждой вкладки
            SchedulePage(
              token: token,
              role: role,
            ),
            ProfilePage(token: token),
            QRCodePage(),
          ],
        ),
      ),
    );
  }
}
