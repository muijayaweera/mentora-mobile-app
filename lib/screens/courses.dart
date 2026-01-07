import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/sample_courses.dart';
import '../data/course_progress_store.dart';
import '../models/course.dart';
import 'course_overview.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ================= PROGRESS LOGIC =================
    final List<Course> suggestedCourses = [];
    final List<Course> inProgressCourses = [];
    final List<Course> completedCourses = [];

    for (final course in sampleCourses) {
      final progress = CourseProgressStore.getProgress(course.id);

      if (progress.completed) {
        completedCourses.add(course);
      } else if (progress.lastLessonIndex > 0) {
        inProgressCourses.add(course);
      } else {
        suggestedCourses.add(course);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TOP BAR =================
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

            // ================= SEARCH (UI ONLY) =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search courses",
                  hintStyle: GoogleFonts.poppins(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= SUGGESTED =================
            if (suggestedCourses.isNotEmpty) ...[
              Text(
                "Suggested For You",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ...suggestedCourses.map(
                    (course) => _courseTile(context, course),
              ),
              const SizedBox(height: 30),
            ],

            // ================= IN PROGRESS =================
            if (inProgressCourses.isNotEmpty) ...[
              Text(
                "In Progress",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ...inProgressCourses.map(
                    (course) => _courseTile(context, course),
              ),
              const SizedBox(height: 30),
            ],

            // ================= COMPLETED =================
            if (completedCourses.isNotEmpty) ...[
              Text(
                "Completed",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ...completedCourses.map(
                    (course) => _courseTile(context, course),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= COURSE TILE =================
  Widget _courseTile(BuildContext context, Course course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseOverviewScreen(course: course),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _badge(course.level),
                const SizedBox(width: 8),
                Text(
                  course.duration,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= LEVEL BADGE =================
  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFA822D9).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA822D9)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
