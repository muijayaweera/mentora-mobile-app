import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/ui_constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  Future<void> signup() async {
    try {
      setState(() => isLoading = true);

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pushReplacementNamed(context, '/login');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful! Please login.")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Signup failed')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
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

            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/loginn.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    color: Colors.black.withOpacity(0.35),
                    child: Column(
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
                          controller: nameController,
                          icon: Icons.person_outline,
                          hint: 'Full name',
                        ),

                        const SizedBox(height: 20),

                        _inputField(
                          controller: emailController,
                          icon: Icons.email_outlined,
                          hint: 'Email address',
                        ),

                        const SizedBox(height: 20),

                        _inputField(
                          controller: passwordController,
                          icon: Icons.lock_outline,
                          hint: 'Password',
                          isPassword: true,
                          showText: showPassword,
                          toggleShowText: () {
                            setState(() => showPassword = !showPassword);
                          },
                        ),

                        const SizedBox(height: 20),

                        _inputField(
                          controller: confirmPasswordController,
                          icon: Icons.lock_outline,
                          hint: 'Confirm password',
                          isPassword: true,
                          showText: showConfirmPassword,
                          toggleShowText: () {
                            setState(() => showConfirmPassword = !showConfirmPassword);
                          },
                        ),

                        const SizedBox(height: 28),

                        GestureDetector(
                          onTap: () {
                            if (passwordController.text != confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Passwords don't match")),
                              );
                              return;
                            }
                            signup();
                          },
                          child: Container(
                            height: 46,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: buttonGradient,
                              borderRadius: BorderRadius.circular(buttonRadius),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                'Sign Up',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
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

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool showText = false,
    VoidCallback? toggleShowText,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !showText,
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPassword
            ? GestureDetector(
          onTap: toggleShowText,
          child: Icon(showText ? Icons.visibility : Icons.visibility_off, size: 18),
        )
            : null,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
