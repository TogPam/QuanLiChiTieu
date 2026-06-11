import 'package:flutter/material.dart';

/// Bộ điều khiển chủ đề toàn cục – dùng ValueNotifier để phát
/// thông báo thay đổi sáng/tối tới toàn bộ ứng dụng.
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  /// true = sáng, false = tối
  final ValueNotifier<bool> isLightMode = ValueNotifier<bool>(true);

  ThemeMode get themeMode =>
      isLightMode.value ? ThemeMode.light : ThemeMode.dark;

  void toggle() {
    isLightMode.value = !isLightMode.value;
  }

  void setLight(bool value) {
    isLightMode.value = value;
  }

  // ── Bảng màu sáng ──────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1C1C1E),
          elevation: 0,
          scrolledUnderElevation: 0.5,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF4B49EB),
          unselectedItemColor: Color(0xFF9CA3AF),
          elevation: 0,
        ),
        cardColor: Colors.white,
      );

  // ── Bảng màu tối ───────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0E14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B1A2A),
          foregroundColor: Color(0xFFE4E1EE),
          elevation: 0,
          scrolledUnderElevation: 0.5,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1B1A2A),
          selectedItemColor: Color(0xFF7C7AFF),
          unselectedItemColor: Color(0xFF6B7280),
          elevation: 0,
        ),
        cardColor: const Color(0xFF1E1D2E),
      );
}
