import 'package:flutter/material.dart';

const corPrincipal = Color(0xFFE50914);

final temaApp = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: corPrincipal,
    onPrimary: Colors.white,
    secondary: corPrincipal,
    surface: Color(0xFF1E1E1E),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E1E1E),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: corPrincipal,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
);
