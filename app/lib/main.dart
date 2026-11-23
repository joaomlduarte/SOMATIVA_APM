import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'tema.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mange Flix',
      debugShowCheckedModeBanner: false,
      theme: temaApp,
      home: const LoginScreen(),
    );
  }
}
