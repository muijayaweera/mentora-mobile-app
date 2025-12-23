import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomeScreen({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    // Colors based on theme
    final bgColor = isDarkMode ? const Color(0xFF1C1C1C) : const Color(0xFFF5F4F4);
    final boxColor = isDarkMode ? const Color(0xFF2B2B2B) : const Color(0xFFFFFFFF);
    final textColor = isDarkMode ? Colors.white : const Color(0xFFA4A3A3);
    final iconColor = isDarkMode ? Colors.white : const Color(0xFF676666);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: Text(
                        'mentora.',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white, // stays white, gradient shows anyway
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/notifications'),
                          child: Icon(Icons.notifications_none, size: 28, color: iconColor),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: toggleTheme,
                          child: Icon(Icons.brightness_6, size: 28, color: iconColor),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: Icon(Icons.person_outline, size: 28, color: iconColor),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 60),

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

                const SizedBox(height: 50),

                Center(
                  child: Text(
                    'Discover something new today.',
                    style: GoogleFonts.poppins(fontSize: 16, color: textColor.withOpacity(0.7)),
                  ),
                ),

                const SizedBox(height: 50),

                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/chatbot'),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: isDarkMode
                          ? const DecorationImage(
                        image: AssetImage('assets/chatbg2.png'),
                        fit: BoxFit.cover,
                      )
                          : null,
                      color: isDarkMode ? null : boxColor,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start New Chat', style: GoogleFonts.poppins(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                          'Learn through conversation. Ask questions, get instant explanations.',
                          style: GoogleFonts.poppins(color: textColor.withOpacity(0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/image'),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: boxColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.remove_red_eye_outlined, color: iconColor, size: 28),
                              const SizedBox(height: 14),
                              Text('Image Analysis', style: GoogleFonts.poppins(color: textColor, fontSize: 15, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text(
                                'Analyze and identify with AI.\nEnhance your learning.',
                                style: GoogleFonts.poppins(color: textColor.withOpacity(0.7), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/courses'),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: boxColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.menu_book_outlined, color: iconColor, size: 28),
                              const SizedBox(height: 14),
                              Text('Go to Courses', style: GoogleFonts.poppins(color: textColor, fontSize: 15, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text(
                                'Access categorized lessons.\nSharpen your knowledge.',
                                style: GoogleFonts.poppins(color: textColor.withOpacity(0.7), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
