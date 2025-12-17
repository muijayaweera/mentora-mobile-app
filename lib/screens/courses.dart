import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/sample_courses.dart';
import 'course_overview.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: mentora + badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.shield_outlined, color: Colors.white70),
              ],
            ),

            const SizedBox(height: 25),

            // Search Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: GoogleFonts.poppins(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Suggested For You
            Text(
              "Suggested For You",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _courseTile(context),
            const SizedBox(height: 12),
            _courseTile(context),

            const SizedBox(height: 25),

            // My Courses Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Courses",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
                Text(
                  "See All",
                  style:
                  GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _courseTile(context),
            const SizedBox(height: 12),
            _courseTile(context),

            const SizedBox(height: 25),

            // All Courses Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "All Courses",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
                Text(
                  "See All",
                  style:
                  GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _courseTile(context),
            const SizedBox(height: 12),
            _courseTile(context),
          ],
        ),
      ),
    );
  }

  // Course Tile Widget
  Widget _courseTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CourseOverviewScreen(course: sampleCourse),
          ),
        );
      },
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Fundamentals of Ostomy Care',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
