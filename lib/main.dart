import 'package:fitness_app/user/screens/welcomscreen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WelcomeScreen(),
    );
  }
}

