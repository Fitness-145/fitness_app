import 'package:firebase_core/firebase_core.dart';
import 'package:fitness_app/firebase_options.dart';
import 'package:fitness_app/user/screens/loginscreen.dart';
import 'package:fitness_app/user/screens/welcomscreen.dart'; // Welcome screen import
 // Home screen after login
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(), // Welcome screen when app starts
        '/home': (context) => const WelcomeScreen(), // After login, navigate here
        '/login': (context) => const LoginScreen(), // Login screen
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const WelcomeScreen()); // Handle unknown routes
      },
    );
  }
}
