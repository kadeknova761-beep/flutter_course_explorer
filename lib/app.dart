// Nama: Kadek Nova Krisna Putra | NIM: 2415051117

import 'package:flutter/material.dart';

import 'app_keys.dart';
import 'screens/account_home_page.dart';
import 'screens/login_page.dart';
import 'services/auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer',
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // Check Session: ada session -> Home, tidak ada -> Login
      home: AuthService.instance.isLoggedIn
          ? const AccountHomePage()
          : const LoginPage(),
    );
  }
}
