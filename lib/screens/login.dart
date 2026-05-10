import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/ui_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  bool isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter your email and password.');
      return;
    }

    if (!isValidEmail(email)) {
      showMessage('Please enter a valid email address.');
      return;
    }

    try {
      setState(() => isLoading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage('Enter your email first to reset your password.');
      return;
    }

    if (!isValidEmail(email)) {
      showMessage('Please enter a valid email address.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showMessage('Password reset email sent. Please check your inbox.');
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Could not send reset email.');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
          child: Column(
            children: [
              const SizedBox(height: 8),

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

              const SizedBox(height: 34),

              SizedBox(
                height: 130,
                width: 130,
                child: Image.asset(
                  'assets/images/home_orb1.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: textDark,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Continue your ostomy care learning journey.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: subTextLight,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              _inputField(
                controller: emailController,
                icon: Icons.email_outlined,
                hint: 'E-mail',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

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

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: forgotPassword,
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFA822D9),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: isLoading ? null : login,
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
                      'Sign In',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 34),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/signup'),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: textDark,
                    ),
                    children: const [
                      TextSpan(text: "Don’t have an account? "),
                      TextSpan(
                        text: "Sign Up",
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