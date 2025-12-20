import 'package:flutter/material.dart';
import 'screens/intro.dart';
import 'screens/signin.dart';
import 'screens/signup.dart';
import 'screens/home.dart';
import 'screens/chatbot.dart';
import 'screens/image.dart';
import 'screens/image_recognition.dart';
import 'screens/courses.dart';
import 'screens/notifications.dart';
import 'screens/profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Make sure Flutter is ready
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // uses firebase_options.dart
  );
  runApp(const OstomyApp()); // Start your app
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
      theme: isDarkMode ? darkTheme : lightTheme,
      initialRoute: '/intro',
      routes: {
        '/intro': (context) => IntroScreen(toggleTheme: toggleTheme),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => HomeScreen(toggleTheme: toggleTheme),
        '/chatbot': (context) => const ChatbotScreen(),
        '/image': (context) => const ImageScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },

    );
  }
  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }
}

