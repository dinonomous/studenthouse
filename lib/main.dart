import 'package:flutter/material.dart';
import 'package:studenthouse/pages/home.dart';
import 'package:studenthouse/pages/welcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Color(0xFF262424),
        scaffoldBackgroundColor: Color(0xFFEEE5DA),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF262424), 
          foregroundColor: Color(0xFFEEE5DA),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF262424),
        scaffoldBackgroundColor: Color(0xFF1A1A1A),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF262424),
          foregroundColor: Color(0xFFEEE5DA), 
        ),
      ),
      themeMode: ThemeMode.system, // Follows system theme
      home: const WelcomePage(),
    );
  }
}
