import 'package:flutter/material.dart';

import 'views/auth_gate.dart';

void main() {
  runApp(const SmartWasteApp());
}

class SmartWasteApp extends StatelessWidget {
  const SmartWasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    const forestGreen = Color(0xFF216A4B);
    return MaterialApp(
      title: 'Smart Waste Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: forestGreen,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F2),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
