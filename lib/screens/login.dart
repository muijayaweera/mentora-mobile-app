import 'package:flutter/material.dart';
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
            // =========================
            // TOP SECTION (BLACK ONLY)
            // =========================
            const SizedBox(height: 40),

            const Text(
              'mentora.',
              style: TextStyle(
                color: purple,
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: purple,
                  width: 6,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // BOTTOM SECTION (IMAGE ONLY)
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

                  // Dark overlay + content
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    color: Colors.black.withOpacity(0.35),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sign in to your account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 20),

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
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Container(
                          height: 48,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: buttonGradient,
                            borderRadius:
                            BorderRadius.circular(buttonRadius),
                          ),
                          child: const Center(
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Center(
                          child: Text(
                            "Don't have an account? Sign Up!",
                            style: TextStyle(
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
        const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
