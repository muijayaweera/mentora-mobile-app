import 'package:flutter/material.dart';
import 'screens/intro.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/home.dart';
import 'screens/chatbot.dart';
import 'screens/image.dart';
import 'screens/image_recognition.dart';
import 'screens/courses.dart';
import 'screens/notifications.dart';
import 'screens/profile.dart';


void main() {
  runApp(const OstomyApp());
}

class OstomyApp extends StatelessWidget {
  const OstomyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ostomy Trainer',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/intro',
      routes: {
        '/intro': (context) => const IntroScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/image': (context) => const ImageScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
