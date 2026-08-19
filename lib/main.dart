import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const StutiMallikaApp());
}

class StutiMallikaApp extends StatelessWidget {
  const StutiMallikaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stutimallika',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3E7D6),
        primaryColor: const Color(0xFF7C5A3A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF7C5A3A),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5A3A),
          primary: const Color(0xFF7C5A3A),
          secondary: const Color(0xFFE8863A),
          surface: const Color(0xFFFFFAF3),
        ),
        fontFamily: 'Serif', // Use a serif font for traditional look
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
