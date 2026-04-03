import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/ui_constants.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'User'; // ✅ ADD THIS LINE
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
                          ).createShader(bounds),
                          child: Text(
                            'mentora.',
                            style: GoogleFonts.poppins(
                              fontSize: 27,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                Navigator.pushNamed(context, '/notifications');
                              },
                              icon: const Icon(
                                Icons.notifications_none_outlined,
                                color: Color(0xFF676666),
                                size: 24,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                              icon: const Icon(
                                Icons.person_outline,
                                color: Color(0xFF676666),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'Welcome, $name.',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 40),


                    Center(
                      child: SizedBox(
                        height: 170,
                        width: 170,
                        child: Image.asset(
                          'assets/images/home_orb1.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    Text(
                      'Discover something new today.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF555555),
                      ),
                    ),

                    const SizedBox(height: 68),

                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/courses'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB86AF2), Color(0xFFA13CF0)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.16),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Go to Courses',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Access categorized lessons. Sharpen your knowledge.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      height: 1.65,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              height: 42,
                              width: 42,
                              decoration: const BoxDecoration(
                                color: Color(0xFF9829E9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.menu_book_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/image'),
                            child: _smallCard(
                              title: 'Image Analysis',
                              description:
                              'Analyze and identify with AI. Enhance your learning.',
                              icon: Icons.remove_red_eye_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/chatbot'),
                            child: _smallCard(
                              title: 'Start New Chat',
                              description:
                              'Learn through conversation. Ask questions, get instant explanations.',
                              icon: Icons.chat_bubble_outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _smallCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3E3E3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SizedBox(
        height: 122,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  height: 1.75,
                  color: const Color(0xFF666666),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 32,
                width: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFA12FEA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}