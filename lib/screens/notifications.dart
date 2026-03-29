import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/ui_constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
                  ).createShader(bounds);
                },
                child: Text(
                  "mentora.",
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Notifications",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Stay updated with your learning and activity.",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: subTextLight,
                ),
              ),

              const SizedBox(height: 28),

              _sectionHeader("Yesterday"),
              const SizedBox(height: 14),
              _notifItem(
                icon: Icons.image_outlined,
                text: "Image analysis completed - Stoma Complications Identified",
              ),
              _notifItem(
                icon: Icons.menu_book_outlined,
                text: "New course available: Pre-operative Care",
              ),
              _notifItem(
                icon: Icons.emoji_events_outlined,
                text: "New badge unlocked",
              ),
              _notifItem(
                icon: Icons.feedback_outlined,
                text: "Help us improve: 1-min feedback on the new chatbot",
              ),

              const SizedBox(height: 28),

              _sectionHeader("Last Week"),
              const SizedBox(height: 14),
              _notifItem(
                icon: Icons.image_outlined,
                text: "Image analysis completed - Stoma Complications Identified",
              ),
              _notifItem(
                icon: Icons.menu_book_outlined,
                text: "New course available: Pre-operative Care",
              ),
              _notifItem(
                icon: Icons.emoji_events_outlined,
                text: "New badge unlocked",
              ),
              _notifItem(
                icon: Icons.feedback_outlined,
                text: "Help us improve: 1-min feedback on the new chatbot",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: subTextLight,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _notifItem({
    required IconData icon,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF4E8FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFA822D9),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: textDark,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}