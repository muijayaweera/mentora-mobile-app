import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/ui_constants.dart';
import '../models/course.dart';
import 'course_overview.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Course> allCourses = [];
  Map<String, dynamic> courseProgressMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCoursesAndProgress();
  }

  Future<void> fetchCoursesAndProgress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      // 1) Fetch published courses from Firestore
      final coursesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .get();

      debugPrint('Courses found: ${coursesSnapshot.docs.length}');

      for (final doc in coursesSnapshot.docs) {
        debugPrint('Course ID: ${doc.id}');
        debugPrint('Data: ${doc.data()}');
      }

      final fetchedCourses = coursesSnapshot.docs.map((doc) {
        final data = doc.data();

        return Course(
          id: doc.id,
          title: data['title'] ?? '',
          overview: data['overview'] ?? '',
          level: data['level'] ?? '',
          duration: data['duration'] ?? '',
          lessons: const [], // lessons will be fetched later in course_overview.dart
        );
      }).toList();

      // 2) Fetch user progress from Firestore
      Map<String, dynamic> progressMap = {};

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null && userData['courseProgress'] != null) {
            progressMap = Map<String, dynamic>.from(
              userData['courseProgress'],
            );
          }
        }
      }

      setState(() {
        allCourses = fetchedCourses;
        courseProgressMap = progressMap;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching courses/progress: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  int _getLastLessonIndex(String courseId) {
    final progress = courseProgressMap[courseId];
    if (progress == null) return 0;

    if (progress is Map<String, dynamic>) {
      return progress['lastLessonIndex'] ?? 0;
    }

    if (progress is Map) {
      return progress['lastLessonIndex'] ?? 0;
    }

    return 0;
  }

  bool _isCompleted(String courseId) {
    final progress = courseProgressMap[courseId];
    if (progress == null) return false;

    if (progress is Map<String, dynamic>) {
      return progress['completed'] ?? false;
    }

    if (progress is Map) {
      return progress['completed'] ?? false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final List<Course> suggestedCourses = [];
    final List<Course> inProgressCourses = [];
    final List<Course> completedCourses = [];

    for (final course in allCourses) {
      final completed = _isCompleted(course.id);
      final lastLessonIndex = _getLastLessonIndex(course.id);

      if (completed) {
        completedCourses.add(course);
      } else if (lastLessonIndex > 0) {
        inProgressCourses.add(course);
      } else {
        suggestedCourses.add(course);
      }
    }

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFA822D9),
          ),
        )
            : allCourses.isEmpty
            ? Center(
          child: Text(
            "No published courses available yet.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: subTextLight,
            ),
          ),
        )
            : SingleChildScrollView(
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
                ...suggestedCourses
                    .map((course) => _courseTile(context, course)),
                const SizedBox(height: 26),
              ],

              if (inProgressCourses.isNotEmpty) ...[
                _sectionTitle("In Progress"),
                const SizedBox(height: 14),
                ...inProgressCourses
                    .map((course) => _courseTile(context, course)),
                const SizedBox(height: 26),
              ],

              if (completedCourses.isNotEmpty) ...[
                _sectionTitle("Completed"),
                const SizedBox(height: 14),
                ...completedCourses
                    .map((course) => _courseTile(context, course)),
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
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseOverviewScreen(course: course),
          ),
        );

        // Refresh progress after returning from course overview / lessons
        fetchCoursesAndProgress();
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