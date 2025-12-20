import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo text
                  Text(
                    'mentora.',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFA822D9),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Circle
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFA822D9),
                        width: 5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Sign in to your account',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 24),

                          _inputField(
                            icon: Icons.email_outlined,
                            hint: 'Enter your email',
                          ),
                          const SizedBox(height: 16),

                          _inputField(
                            icon: Icons.lock_outline,
                            hint: 'Enter your password',
                            isPassword: true,
                          ),

                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),

                          const Spacer(),

                          _gradientButton(text: 'Sign In'),

                          const SizedBox(height: 16),

                          Text(
                            "Don't have an account? Sign Up!",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
Widget _inputField({
  required IconData icon,
  required String hint,
  bool isPassword = false,
}) {
  return TextField(
    obscureText: isPassword,
    style: const TextStyle(color: Colors.black),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: Colors.grey),
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

Widget _gradientButton({required String text}) {
  return Container(
    width: double.infinity,
    height: 48,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: const LinearGradient(
        colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
      ),
    ),
    child: Center(
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
