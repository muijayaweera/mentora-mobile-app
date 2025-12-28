import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'home.dart';

class AuthGate extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const AuthGate({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Logged in
        if (snapshot.hasData) {
          return HomeScreen(
            toggleTheme: toggleTheme,
            isDarkMode: isDarkMode,
          );
        }

        // Logged out
        return const LoginScreen();
      },
    );
  }
}
