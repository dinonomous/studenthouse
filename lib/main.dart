import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studenthouse/pages/home.dart';
import 'package:studenthouse/pages/splash_screen.dart';
import 'package:studenthouse/pages/welcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF262424),
        scaffoldBackgroundColor: const Color(0xFFEEE5DA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF262424),
          foregroundColor: Color(0xFFEEE5DA),
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF262424),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF262424),
          foregroundColor: Color(0xFFEEE5DA),
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system, // Follows system theme
      home: const SplashScreen(), // Use SplashScreen as the initial route
    );
  }
}