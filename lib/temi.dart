import 'package:flutter/material.dart';

// --- Colori Principali del Brand ---
const Color odysseyBlue = Color.fromARGB(245, 3, 81, 217); // Un blu profondo e intenso
const Color odysseyLightBlue = Color(0xFF1976D2); // Un blu più brillante per gli accenti
const Color odysseyWhite = Colors.white;
const Color odysseyBlack = Color(0xFF212121);
const Color odysseyGrey = Color(0xFF757575);
const Color gradientComplementary = Color.fromARGB(170, 10, 180, 202);

class AppTheme {
  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: odysseyBlue, brightness: Brightness.dark).copyWith(
      primary: odysseyBlue,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 8, 24, 43),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 8, 24, 43),
    ),
    textTheme: const TextTheme(
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: odysseyBlue,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: odysseyBlue,
      ),
      headlineMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headlineSmall: TextStyle(
        fontSize: 14,
        color: odysseyWhite,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: odysseyWhite,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: odysseyWhite,
      ),
    ),
  );

  static final lightTheme = ThemeData(
    fontFamily: "CampoBaseFont",

    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: odysseyBlue, brightness: Brightness.light).copyWith(
      primary: odysseyBlue,
    ),

    scaffoldBackgroundColor: const Color.fromARGB(255, 242, 239, 239),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 242, 239, 239),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: odysseyBlack,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: odysseyBlue,
      ),
      titleSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: odysseyBlue,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      ),
      labelSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: odysseyBlack,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: odysseyBlack,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    //scaffoldBackgroundColor: Colors.white,
  );
}
