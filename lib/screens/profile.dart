import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/ui_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            "Log Out?",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            "Are you sure you want to sign out from Mentora?",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: subTextLight,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: subTextLight,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA822D9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await logout(context);
              },
              child: Text(
                "Log Out",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void showAbout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 42,
                decoration: BoxDecoration(
                  color: borderLight,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4E8FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Color(0xFFA822D9),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "About Mentora",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Mentora is an AI-powered ostomy care training app designed to support nurses through interactive lessons, quizzes, image recognition, badges, and learning progress tracking.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: subTextLight,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Version 1.0",
                style: GoogleFonts.poppins(
                  color: subTextLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showEditProfile(
      BuildContext context, {
        required String currentName,
        required String email,
      }) {
    final controller = TextEditingController(text: currentName);

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: surfaceLight,
        shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
    return Padding(
    padding: EdgeInsets.fromLTRB(
    24,
    24,
    24,
    MediaQuery.of(sheetContext).viewInsets.bottom + 32,
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        height: 4,
        width: 42,
        decoration: BoxDecoration(
          color: borderLight,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      const SizedBox(height: 22),
      Text(
        "Edit Profile",
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        "Update your display name.",
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          color: subTextLight,
        ),
      ),
      const SizedBox(height: 22),

      TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          color: textDark,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: "Name",
          labelStyle: GoogleFonts.poppins(color: subTextLight),
          filled: true,
          fillColor: bgLight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFA822D9),
              width: 1.4,
            ),
          ),
        ),
      ),

      const SizedBox(height: 12),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Email",
              style: GoogleFonts.poppins(
                color: subTextLight,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: GoogleFonts.poppins(
                color: textDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 22),

      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: subTextLight,
                side: BorderSide(color: borderLight),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(sheetContext),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA822D9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                final newName = controller.text.trim();
                final user = FirebaseAuth.instance.currentUser;

                if (newName.isEmpty || user == null) {
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .set(
                  {'name': newName},
                  SetOptions(merge: true),
                );

                Navigator.of(context).pop();
              },
              child: Text(
                "Save",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ],
    ),
    );
    },
    ).whenComplete(() {
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(backgroundColor: bgLight);
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
                child: CircularProgressIndicator(
                  color: Color(0xFFA822D9),
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
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
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
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
                            ),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFFA822D9),
                            size: 46,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
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
                    icon: Icons.edit_outlined,
                    title: "Edit Profile",
                    subtitle: "Update your name and profile details",
                    onTap: () => showEditProfile(
                      context,
                      currentName: name,
                      email: email,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _menuCard(
                    icon: Icons.info_outline,
                    title: "About Mentora",
                    subtitle: "Learn more about the app",
                    onTap: () => showAbout(context),
                  ),

                  const SizedBox(height: 14),

                  _menuCard(
                    icon: Icons.logout_rounded,
                    title: "Log Out",
                    subtitle: "Sign out from your account",
                    isLogout: true,
                    onTap: () => showLogoutConfirm(context),
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