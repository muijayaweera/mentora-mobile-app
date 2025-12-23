import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/ui_constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 44),

            // =========================
            // TITLE
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

            const SizedBox(height: 44),

            // =========================
            // CIRCLE
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

            // 👇 pushes bottom section LOWER
            const SizedBox(height: 60),

            // =========================
            // BOTTOM IMAGE SECTION
            // =========================
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36),
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
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
                    color: Colors.black.withOpacity(0.35),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =========================
                        // HEADING
                        // =========================
                        Center(
                          child: Text(
                            'Sign in to your account',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // =========================
                        // INPUTS (NARROWER)
                        // =========================
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: _inputField(
                              icon: Icons.email_outlined,
                              hint: 'Enter your email',
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: _inputField(
                              icon: Icons.lock_outline,
                              hint: 'Enter your password',
                              isPassword: true,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // =========================
                        // SIGN IN BUTTON (MATCH WIDTH)
                        // =========================
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                            child: Container(
                              height: 44,
                              width: MediaQuery.of(context).size.width * 0.85,
                              decoration: BoxDecoration(
                                gradient: buttonGradient,
                                borderRadius: BorderRadius.circular(buttonRadius),
                              ),
                              child: Center(
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),



                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            "Don't have an account? Sign Up!",
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12.5,
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
  // INPUT FIELD
  // =========================
  Widget _inputField({
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      style: GoogleFonts.poppins(
        fontSize: 13, // 👈 smaller text
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        suffixIcon:
        isPassword ? const Icon(Icons.visibility_off, size: 18) : null,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13),
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
