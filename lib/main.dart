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
import 'screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const OstomyApp());
}

class OstomyApp extends StatefulWidget {
  const OstomyApp({super.key});

  @override
  State<OstomyApp> createState() => _OstomyAppState();
}

class _OstomyAppState extends State<OstomyApp> {
  bool isDarkMode = false; // changed

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7F7F9),
    primaryColor: const Color(0xFFA822D9),
    iconTheme: const IconThemeData(color: Color(0xFF676666)),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE7E7E7),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF2E2E2E)),
        bodyMedium: TextStyle(color: Color(0xFF2E2E2E)),
        bodySmall: TextStyle(color: Color(0xFF7A7A7A)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFA822D9), width: 1.2),
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: const Color(0xFF9A9A9A),
      ),
    ),
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1C1C1C),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ostomy Trainer',
      theme: isDarkMode ? darkTheme : lightTheme,
      home: AuthGate(
        toggleTheme: toggleTheme,
        isDarkMode: isDarkMode,
      ),
      routes: {
        '/intro': (context) => IntroScreen(toggleTheme: toggleTheme),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => HomeScreen(
          toggleTheme: toggleTheme,
          isDarkMode: isDarkMode,
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