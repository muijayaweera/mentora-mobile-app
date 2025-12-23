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
  bool isDarkMode = true;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  // Define your themes
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F4F4),
    primarySwatch: Colors.teal,
    iconTheme: const IconThemeData(color: Color(0xFF676666)),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFF4A4949)), // <- updated
        bodySmall: TextStyle(color: Color(0xFF4A4949)),
        bodyLarge: TextStyle(color: Color(0xFF4A4949)),
      ),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ostomy Trainer',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/intro': (context) => IntroScreen(toggleTheme: toggleTheme),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => HomeScreen(
          toggleTheme: toggleTheme,
          isDarkMode: isDarkMode, // pass current theme to HomeScreen
        ),
        '/chatbot': (context) => const ChatbotScreen(),
        '/image': (context) => const ImageScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
