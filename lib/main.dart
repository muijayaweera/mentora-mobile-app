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

class OstomyApp extends StatefulWidget {
  const OstomyApp({super.key});

  @override
  State<OstomyApp> createState() => _OstomyAppState();
}

class _OstomyAppState extends State<OstomyApp> {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primarySwatch: Colors.teal,
    iconTheme: const IconThemeData(color: Colors.black),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
    ),
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1C1C1C),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    ),
  );

  bool isDarkMode = true;

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
