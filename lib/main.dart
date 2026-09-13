import 'package:flutter/material.dart';
import 'package:mishkah/screens/splash_screen.dart';


void main() {
  runApp(const MishkahApp());
}

class MishkahApp extends StatelessWidget {
  const MishkahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مشكاة',
      home: const SplashScreen(),
    );
  }
}