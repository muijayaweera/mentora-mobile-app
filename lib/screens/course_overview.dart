import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import 'lesson_screen.dart';

// 🔥 Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseOverviewScreen extends StatefulWidget {
  final Course course;

  const CourseOverviewScreen({super.key, required this.course});

  @override
  State<CourseOverviewScreen> createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends State<CourseOverviewScreen> {
  bool courseCompleted = false;
  int lastLessonIndex = 0;
  bool isLoadingLessons = true;
  List<Lesson> lessons = [];

  // ================= LOAD PROGRESS FROM FIREBASE =================
  Future<void> loadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data();
    if (data == null) return;

    final progress = data['courseProgress']?[widget.course.id];
    if (progress == null) return;

    setState(() {
      lastLessonIndex = progress['lastLessonIndex'] ?? 0;
      courseCompleted = progress['completed'] ?? false;
    });
  }
  // ===============================================================

  // ================= FETCH LESSONS / MODULES =====================
  Future<void> fetchLessons() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course.id)
          .collection('modules')
          .orderBy('order')
          .get();

      final loadedLessons = snapshot.docs.map((doc) {
        final data = doc.data();

        return Lesson(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['contentText'] ?? '',
          order: data['order'] ?? 0,
        );
      }).toList();

      setState(() {
        lessons = loadedLessons;
        isLoadingLessons = false;
      });
    } catch (e) {
      debugPrint('Error fetching lessons: $e');
      setState(() {
        isLoadingLessons = false;
      });
    }
  }
  // ===============================================================

  @override
  void initState() {
    super.initState();
    loadProgress();
    fetchLessons();
  }

  String get buttonText {
    if (courseCompleted) {
      return 'Review Course';
    }
    if (lastLessonIndex > 0) {
      return 'Continue Learning';
    }
    return 'Get Started';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TITLE =================
              Text(
                widget.course.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 25),

              // ================= OVERVIEW =================
              Text(
                'Overview',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.course.overview,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              // ================= LESSON TOPICS =================
              Text(
                'Lesson Topics',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: isLoadingLessons
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFA822D9),
                  ),
                )
                    : lessons.isEmpty
                    ? Center(
                  child: Text(
                    'No lessons available for this course yet.',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                    : ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${lesson.order}. ${lesson.title}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ================= BUTTON =================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFFA822D9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: lessons.isEmpty
                      ? null
                      : () async {
                    final safeStartIndex =
                    lastLessonIndex >= lessons.length
                        ? 0
                        : lastLessonIndex;

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(
                          allLessons: lessons,
                          courseId: widget.course.id,
                          startIndex: safeStartIndex,
                        ),
                      ),
                    );

                    if (result != null && result is int) {
                      await loadProgress();

                      setState(() {
                        lastLessonIndex = result;
                      });
                    }
                  },
                  child: Text(
                    buttonText,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}