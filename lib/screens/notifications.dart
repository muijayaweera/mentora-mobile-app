import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 55),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Notifications",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 30),

            _sectionHeader("Yesterday"),
            const SizedBox(height: 12),
            _notifItem("Image analysis completed - Stoma Complications Identified"),
            _notifItem("New course Available; Pre-operative Care"),
            _notifItem("New Badge Available"),
            _notifItem("Help us improve: 1-min feedback on the new chatbot?"),

            const SizedBox(height: 25),

            _sectionHeader("Last Week"),
            const SizedBox(height: 12),
            _notifItem("Image analysis completed - Stoma Complications Identified"),
            _notifItem("New course Available; Pre-operative Care"),
            _notifItem("New Badge Available"),
            _notifItem("Help us improve: 1-min feedback on the new chatbot?"),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white54,
        fontSize: 14,
      ),
    );
  }

  Widget _notifItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }
}
