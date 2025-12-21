import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/ui_constants.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // =========================
            // TOP SECTION
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
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 28),

            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFA822D9),
                  width: 6,
                ),
              ),
            ),

            const SizedBox(height: 28),

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
                      image: AssetImage('assets/loginn.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    color: Colors.black.withOpacity(0.35),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Create your account',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 26),

                        _inputField(
                          icon: Icons.person_outline,
                          hint: 'Full name',
                        ),

                        const SizedBox(height: 20),

                        _inputField(
                          icon: Icons.email_outlined,
                          hint: 'Email address',
                        ),

                        const SizedBox(height: 20),

                        _inputField(
                          icon: Icons.lock_outline,
                          hint: 'Password',
                          isPassword: true,
                        ),

                        const SizedBox(height: 28),

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
                              'Sign Up',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Already have an account? Sign In',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
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
    return SizedBox(
      width: double.infinity,
      child: TextField(
        obscureText: isPassword,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20),
          suffixIcon:
          isPassword ? const Icon(Icons.visibility_off, size: 18) : null,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
