import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import 'lesson_screen.dart';

// 🔥 Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ same UI constants style as courses page
import '../constants/ui_constants.dart';

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

  Future<void> fetchLessons() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course.id)
          .collection('modules')
          .orderBy('order')
          .get();

      debugPrint('Course ID: ${widget.course.id}');
      debugPrint('Modules found: ${snapshot.docs.length}');
      for (final doc in snapshot.docs) {
        debugPrint('Module ${doc.id}: ${doc.data()}');
      }

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

  @override
  void initState() {
    super.initState();
    loadProgress();
    fetchLessons();
  }

  String get buttonText {
    if (courseCompleted) return 'Review Course';
    if (lastLessonIndex > 0) return 'Continue Learning';
    return 'Get Started';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        title: Text(
          'Course Overview',
          style: GoogleFonts.poppins(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceLight,
                  borderRadius: BorderRadius.circular(24),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.title,
                      style: GoogleFonts.poppins(
                        color: textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _chip(widget.course.level),
                        const SizedBox(width: 8),
                        Text(
                          widget.course.duration,
                          style: GoogleFonts.poppins(
                            color: subTextLight,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Overview',
                      style: GoogleFonts.poppins(
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.course.overview,
                      style: GoogleFonts.poppins(
                        color: subTextLight,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Lesson Topics',
                style: GoogleFonts.poppins(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

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
                      color: subTextLight,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                    : ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    final isCurrent = index == lastLessonIndex;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFFD9B1F2)
                              : borderLight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.035),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4E8FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${lesson.order}',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFA822D9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              lesson.title,
                              style: GoogleFonts.poppins(
                                color: textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            Text(
                              'Current',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFA822D9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color(0xFFA822D9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

  Widget _chip(String text) {
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