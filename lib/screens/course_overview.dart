import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import 'lesson_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  static const Color primaryPurple = Color(0xFFA822D9);
  static const Color primaryPink = Color(0xFFC514C2);
  static const Color pageBg = Color(0xFFF8F7FA);

  Future<void> loadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

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
    if (lastLessonIndex > 0) return 'Continue Learning';
    return 'Get Started';
  }

  Future<void> openLessonAt(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          allLessons: lessons,
          courseId: widget.course.id,
          startIndex: index,
        ),
      ),
    );

    await loadProgress();

    if (result != null && result is int) {
      setState(() {
        lastLessonIndex = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount =
    courseCompleted ? lessons.length : lastLessonIndex.clamp(0, lessons.length);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
            ).createShader(bounds);
          },
          child: Text(
            'mentora.',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _overviewCard(completedCount),
              const SizedBox(height: 24),
              _sectionHeader(),
              const SizedBox(height: 14),
              Expanded(
                child: isLoadingLessons
                    ? const Center(
                  child: CircularProgressIndicator(color: primaryPurple),
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
                    return _lessonTile(index);
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (courseCompleted)
                _completedInfoBox()
              else
                _continueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewCard(int completedCount) {
    final total = lessons.isEmpty ? 1 : lessons.length;
    final progress = lessons.isEmpty ? 0.0 : completedCount / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: primaryPurple.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryPurple, primaryPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.course.title,
            style: GoogleFonts.poppins(
              color: textDark,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (widget.course.level.trim().isNotEmpty)
                _chip(widget.course.level, Icons.layers_rounded),
              if (widget.course.duration.trim().isNotEmpty)
                _chip(widget.course.duration, Icons.access_time_rounded),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Overview',
            style: GoogleFonts.poppins(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.course.overview,
            style: GoogleFonts.poppins(
              color: subTextLight,
              fontSize: 13.5,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF0EAF5),
              valueColor: const AlwaysStoppedAnimation(primaryPurple),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            courseCompleted
                ? 'Course completed'
                : '$completedCount of ${lessons.length} lessons completed',
            style: GoogleFonts.poppins(
              color: courseCompleted ? Colors.green : subTextLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Lesson Topics',
          style: GoogleFonts.poppins(
            color: textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '${lessons.length} lessons',
          style: GoogleFonts.poppins(
            color: subTextLight,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _lessonTile(int index) {
    final lesson = lessons[index];
    final isCompletedLesson = courseCompleted || index < lastLessonIndex;
    final isCurrent = !courseCompleted && index == lastLessonIndex;
    final isUnlocked = courseCompleted || index <= lastLessonIndex;

    return Opacity(
      opacity: isUnlocked ? 1 : 0.48,
      child: GestureDetector(
        onTap: isUnlocked ? () => openLessonAt(index) : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompletedLesson
                  ? Colors.green.withOpacity(0.22)
                  : isCurrent
                  ? primaryPurple.withOpacity(0.35)
                  : Colors.black.withOpacity(0.04),
              width: isCurrent ? 1.3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: isCompletedLesson
                      ? Colors.green.withOpacity(0.10)
                      : isCurrent
                      ? primaryPurple.withOpacity(0.10)
                      : const Color(0xFFF0F0F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: isCompletedLesson
                      ? const Icon(
                    Icons.check_rounded,
                    color: Colors.green,
                    size: 22,
                  )
                      : isUnlocked
                      ? Text(
                    '${lesson.order}',
                    style: GoogleFonts.poppins(
                      color: primaryPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                      : const Icon(
                    Icons.lock_rounded,
                    color: Colors.grey,
                    size: 19,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _lessonStatusPill(
                isCompletedLesson: isCompletedLesson,
                isCurrent: isCurrent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lessonStatusPill({
    required bool isCompletedLesson,
    required bool isCurrent,
  }) {
    String text;
    Color color;
    IconData icon;

    if (isCompletedLesson) {
      text = 'Done';
      color = Colors.green;
      icon = Icons.check_circle_rounded;
    } else if (isCurrent) {
      text = 'Current';
      color = primaryPurple;
      icon = Icons.play_circle_fill_rounded;
    } else {
      text = 'Locked';
      color = Colors.grey;
      icon = Icons.lock_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        onPressed: lessons.isEmpty
            ? null
            : () async {
          final safeStartIndex =
          lastLessonIndex >= lessons.length ? 0 : lastLessonIndex;
          await openLessonAt(safeStartIndex);
        },
        child: Text(
          buttonText,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _completedInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.green.withOpacity(0.22)),
      ),
      child: Text(
        'Course completed. Tap any lesson above to review it.',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: Colors.green,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _chip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primaryPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primaryPurple, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: primaryPurple,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}