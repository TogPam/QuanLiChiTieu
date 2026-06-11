import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'controllers/theme_controller.dart';

void main() {
  runApp(const QuanLyChiTieuApp());
}

class QuanLyChiTieuApp extends StatelessWidget {
  const QuanLyChiTieuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi chủ đề từ ThemeController
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.instance.isLightMode,
      builder: (context, isLight, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Quản Lý Chi Tiêu',
          themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
          theme: ThemeController.lightTheme,
          darkTheme: ThemeController.darkTheme,
          home: const LoginScreen(),
        );
      },
    );
  }
}