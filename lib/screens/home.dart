import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Theme-aware colors
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final boxColor = isDarkMode ? const Color(0xFF2B2B2B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF4A4949);
    final subTextColor = isDarkMode ? Colors.white70 : const Color(0xFFA4A3A3);
    final iconColor = isDarkMode ? Colors.white : const Color(0xFF676666);

    return Scaffold(
      backgroundColor: backgroundColor,
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
            final name = data['name'] ?? 'User';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= TOP BAR =================
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
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.notifications_none, color: iconColor),
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/notifications'),
                            ),
                            IconButton(
                              icon: Icon(Icons.brightness_6, color: iconColor),
                              onPressed: toggleTheme,
                            ),
                            IconButton(
                              icon: Icon(Icons.logout, color: iconColor),
                              onPressed: logout,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // ================= GREETING =================
                    Text(
                      'Welcome, $name 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // ================= CIRCLE =================
                    Center(
                      child: Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFA822D9),
                            width: 6,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Center(
                      child: Text(
                        'Discover something new today.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: subTextColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ================= CHAT =================
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/chatbot'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: AssetImage('assets/chatbg2.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start New Chat',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Learn through conversation. Ask questions, get instant explanations.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ================= GRID =================
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/image'),
                            child: _infoBox(
                              icon: Icons.remove_red_eye_outlined,
                              title: 'Image Analysis',
                              desc:
                              'Analyze and identify with AI.\nEnhance your learning.',
                              boxColor: boxColor,
                              iconColor: iconColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/courses'),
                            child: _infoBox(
                              icon: Icons.menu_book_outlined,
                              title: 'Go to Courses',
                              desc:
                              'Access categorized lessons.\nSharpen your knowledge.',
                              boxColor: boxColor,
                              iconColor: iconColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
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

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String desc,
    required Color boxColor,
    required Color iconColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
