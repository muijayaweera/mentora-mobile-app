import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/ui_constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  bool isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showMessage('Please fill in all fields.');
      return;
    }

    if (!isValidEmail(email)) {
      showMessage('Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      showMessage("Passwords don't match.");
      return;
    }

    try {
      setState(() => isLoading = true);

      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'role': 'nurse',
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      showMessage('Signup successful! Please login.');
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Signup failed. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
          child: Column(
            children: [
              const SizedBox(height: 4),

              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
                ).createShader(bounds),
                child: Text(
                  'mentora.',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 118,
                width: 118,
                child: Image.asset(
                  'assets/images/home_orb1.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'Create your account',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: textDark,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Start learning with Mentora today.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: subTextLight,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              _inputField(
                controller: nameController,
                icon: Icons.person_outline,
                hint: 'Full name',
              ),

              const SizedBox(height: 16),

              _inputField(
                controller: emailController,
                icon: Icons.email_outlined,
                hint: 'E-mail',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 30),

              GestureDetector(
                onTap: isLoading ? null : signup,
                child: Container(
                  height: 54,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: buttonGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA822D9).withOpacity(0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.3,
                      ),
                    )
                        : Text(
                      'Sign Up',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: textDark,
                    ),
                    children: const [
                      TextSpan(text: "Already have an account? "),
                      TextSpan(
                        text: "Sign In",
                        style: TextStyle(
                          color: Color(0xFFA822D9),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
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
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool showText = false,
    VoidCallback? toggleShowText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !showText,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: textDark,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF3EEF7),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF817487),
          size: 21,
        ),
        suffixIcon: isPassword
            ? GestureDetector(
          onTap: toggleShowText,
          child: Icon(
            showText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 19,
            color: const Color(0xFF817487),
          ),
        )
            : null,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF817487),
          fontSize: 13.5,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: Color(0xFFA822D9),
            width: 1.3,
          ),
        ),
      ),
    );
  }
}