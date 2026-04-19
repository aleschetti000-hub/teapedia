import 'package:flutter/material.dart';

class AppTheme {
  // Colori principali ispirati al tè
  static const Color primaryGreen = Color(0xFF1D9E75);
  static const Color darkGreen = Color(0xFF085041);
  static const Color lightGreen = Color(0xFFEAF3DE);

  // Colori per le categorie di tè
  static const Color teaGreen = Color(0xFF639922);
  static const Color teaBlack = Color(0xFFA32D2D);
  static const Color teaOolong = Color(0xFFBA7517);
  static const Color teaHerbal = Color(0xFF7F77DD);

  // Sfondi delle card categoria
  static const Color bgGreen = Color(0xFFEAF3DE);
  static const Color bgBlack = Color(0xFFFCEBEB);
  static const Color bgOolong = Color(0xFFFAEEDA);
  static const Color bgHerbal = Color(0xFFEEEDFE);

  // Testi sulle card colorate
  static const Color textGreen = Color(0xFF173404);
  static const Color textBlack = Color(0xFF501313);
  static const Color textOolong = Color(0xFF412402);
  static const Color textHerbal = Color(0xFF26215C);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
    ),
  );
}
