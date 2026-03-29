import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/ui_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: bgLight,
      );
    }

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'User';
            final email = data['email'] ?? user.email ?? '';

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
                    ).createShader(bounds),
                    child: Text(
                      "mentora.",
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceLight,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFA822D9),
                              width: 3,
                            ),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF8EEFC),
                                Color(0xFFF3E4FA),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFFA822D9),
                            size: 46,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: textDark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.edit_outlined,
                              color: iconLight,
                              size: 18,
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: subTextLight,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Your learning profile and account settings",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: subTextLight,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  _menuCard(
                    icon: Icons.settings_outlined,
                    title: "App Settings",
                    subtitle: "Manage your preferences and experience",
                    onTap: () {},
                  ),

                  const SizedBox(height: 14),

                  _menuCard(
                    icon: Icons.info_outline,
                    title: "About Us",
                    subtitle: "Learn more about Mentora",
                    onTap: () {},
                  ),

                  const SizedBox(height: 14),

                  _menuCard(
                    icon: Icons.logout_rounded,
                    title: "Log Out",
                    subtitle: "Sign out from your account",
                    isLogout: true,
                    onTap: logout,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLogout ? const Color(0xFFF0D9F7) : borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: isLogout
                    ? const Color(0xFFFCEFFD)
                    : const Color(0xFFF4E8FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFA822D9),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: subTextLight,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: iconLight,
            ),
          ],
        ),
      ),
    );
  }
}