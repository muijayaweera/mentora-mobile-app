import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/ui_constants.dart';
import '../data/sample_courses.dart';
import '../data/course_progress_store.dart';
import '../models/course.dart';
import 'course_overview.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                "Courses",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Continue learning through guided ostomy care modules.",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: subTextLight,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  style: GoogleFonts.poppins(
                    color: textDark,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search, color: iconLight),
                    hintText: "Search courses",
                    hintStyle: GoogleFonts.poppins(
                      color: subTextLight,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              if (suggestedCourses.isNotEmpty) ...[
                _sectionTitle("Suggested For You"),
                const SizedBox(height: 14),
                ...suggestedCourses.map((course) => _courseTile(context, course)),
                const SizedBox(height: 26),
              ],

              if (inProgressCourses.isNotEmpty) ...[
                _sectionTitle("In Progress"),
                const SizedBox(height: 14),
                ...inProgressCourses.map((course) => _courseTile(context, course)),
                const SizedBox(height: 26),
              ],

              if (completedCourses.isNotEmpty) ...[
                _sectionTitle("Completed"),
                const SizedBox(height: 14),
                ...completedCourses.map((course) => _courseTile(context, course)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: textDark,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

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
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surfaceLight,
          borderRadius: BorderRadius.circular(20),
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
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF4E8FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFFA822D9),
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: GoogleFonts.poppins(
                      color: textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _badge(course.level),
                      const SizedBox(width: 8),
                      Text(
                        course.duration,
                        style: GoogleFonts.poppins(
                          color: subTextLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
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

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF4E8FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color(0xFFA822D9),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}