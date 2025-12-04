import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2E),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gradient Logo
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
                ).createShader(bounds);
              },
              child: Text(
                "mentora.",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Profile Avatar Circle
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFA822D9),
                  width: 3,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Name + edit icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sarah Brooklyn",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.edit,
                  color: Colors.white70,
                  size: 16,
                )
              ],
            ),

            const SizedBox(height: 50),

            // Menu options
            _menuItem(Icons.settings_outlined, "App Settings"),
            const SizedBox(height: 20),
            _menuItem(Icons.info_outline, "About Us"),
            const SizedBox(height: 20),
            _menuItem(Icons.logout, "Log Out"),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
