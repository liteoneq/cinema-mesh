import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(const CinemaMeshApp());
}

class CinemaMeshApp extends StatelessWidget {
  const CinemaMeshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سينما ميش',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      home: const HomeScreen(),
    );
  }
