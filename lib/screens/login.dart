import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/ui_constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // =========================
            // TITLE (MATCHES INTRO)
            // =========================
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: Text(
                'mentora.',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // =========================
            // CIRCLE (MATCHES INTRO)
            // =========================
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: purple,
                  width: 6,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Push bottom section slightly lower
            const SizedBox(height: 10),

            // =========================
            // BOTTOM IMAGE SECTION
            // =========================
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/signin.png'),
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Overlay
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    color: Colors.black.withOpacity(0.35),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =========================
                        // HEADING
                        // =========================
                        Text(
                          'Sign in to your account',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _inputField(
                          icon: Icons.email_outlined,
                          hint: 'Enter your email',
                        ),

                        const SizedBox(height: 14),

                        _inputField(
                          icon: Icons.lock_outline,
                          hint: 'Enter your password',
                          isPassword: true,
                        ),

                        const SizedBox(height: 6),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // =========================
                        // SIGN IN BUTTON
                        // =========================
                        Container(
                          height: 46,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: buttonGradient,
                            borderRadius:
                            BorderRadius.circular(buttonRadius),
                          ),
                          child: Center(
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Center(
                          child: Text(
                            "Don't have an account? Sign Up!",
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // INPUT FIELD WIDGET
  // =========================
  Widget _inputField({
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon:
        isPassword ? const Icon(Icons.visibility_off) : null,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
