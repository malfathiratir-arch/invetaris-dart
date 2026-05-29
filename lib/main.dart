import 'package:flutter/material.dart';
import 'package:inventory_apps/views/onboarding_page.dart';

void main() {
  runApp(const FoodNinjaApp());
}

class FoodNinjaApp extends StatelessWidget {
  const FoodNinjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InvenTrack',
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}
