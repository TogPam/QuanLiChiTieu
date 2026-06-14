import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'controllers/theme_controller.dart';

/// Global navigator key – dùng để điều hướng từ bất cứ đâu (VD: force logout khi JWT hết hạn)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
          navigatorKey: navigatorKey,
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