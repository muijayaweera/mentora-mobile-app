import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson.dart';
import '../models/quiz_question.dart';
import 'quiz_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/ui_constants.dart';

class LessonScreen extends StatefulWidget {
  final List<Lesson> allLessons;
  final String courseId;
  final int startIndex;

  const LessonScreen({
    super.key,
    required this.allLessons,
    required this.courseId,
    this.startIndex = 0,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final ScrollController _scrollController = ScrollController();
  late int currentIndex;
  bool isCheckingQuiz = false;

  static const Color primaryPurple = Color(0xFFA822D9);
  static const Color primaryPink = Color(0xFFC514C2);
  static const Color pageBg = Color(0xFFF8F7FA);

  @override
  void initState() {
    super.initState();
    currentIndex = widget.startIndex;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    Future.delayed(const Duration(milliseconds: 60), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> saveProgress({bool completed = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {
        'courseProgress': {
          widget.courseId: {
            'lastLessonIndex': currentIndex,
            'completed': completed,
          }
        }
      },
      SetOptions(merge: true),
    );
  }

  Future<List<QuizQuestion>> fetchQuizQuestions(String lessonId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(lessonId)
        .collection('questions')
        .get();

    return snapshot.docs.map((doc) => QuizQuestion.fromDoc(doc)).toList();
  }

  Future<void> openQuizThenProceed({required bool completeCourse}) async {
    final lesson = widget.allLessons[currentIndex];

    setState(() {
      isCheckingQuiz = true;
    });

    try {
      final questions = await fetchQuizQuestions(lesson.id);

      if (!mounted) return;

      setState(() {
        isCheckingQuiz = false;
      });

      if (questions.isNotEmpty) {
        final quizFinished = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              courseId: widget.courseId,
              lessonId: lesson.id,
              lessonTitle: lesson.title,
              questions: questions,
            ),
          ),
        );

        if (quizFinished != true) return;
      }

      if (completeCourse) {
        await saveProgress(completed: true);
        if (!mounted) return;
        Navigator.pop(context, currentIndex);
      } else {
        setState(() {
          currentIndex++;
        });
        await saveProgress();
        _scrollToTop();
      }
    } catch (e) {
      debugPrint('Error opening quiz: $e');

      if (!mounted) return;

      setState(() {
        isCheckingQuiz = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load quiz. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.allLessons[currentIndex];
    final isFirstLesson = currentIndex == 0;
    final isLastLesson = currentIndex == widget.allLessons.length - 1;
    final progressValue = (currentIndex + 1) / widget.allLessons.length;

    return WillPopScope(
      onWillPop: () async {
        await saveProgress();
        Navigator.pop(context, currentIndex);
        return false;
      },
      child: Scaffold(
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
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _lessonHeader(lesson, progressValue),

                const SizedBox(height: 16),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.035),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Text(
                        lesson.content,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 14.5,
                          height: 1.75,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (isCheckingQuiz)
                  const Center(
                    child: CircularProgressIndicator(
                      color: primaryPurple,
                    ),
                  )
                else if (isLastLesson)
                  _primaryButton(
                    text: 'Complete Module',
                    onPressed: () async {
                      await openQuizThenProceed(completeCourse: true);
                    },
                  )
                else
                  Row(
                    children: [
                      if (!isFirstLesson)
                        Expanded(
                          flex: 4,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryPurple,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: primaryPurple.withOpacity(0.75),
                                width: 1.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                currentIndex--;
                              });
                              await saveProgress();
                              _scrollToTop();
                            },
                            child: Text(
                              'Previous',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (!isFirstLesson) const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: _primaryButton(
                          text: 'Next Lesson',
                          onPressed: () async {
                            await openQuizThenProceed(completeCourse: false);
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lessonHeader(Lesson lesson, double progressValue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primaryPurple.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryPurple, primaryPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: textDark,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Lesson ${currentIndex + 1} of ${widget.allLessons.length}',
                  style: GoogleFonts.poppins(
                    color: subTextLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: const Color(0xFFF0EAF5),
                    valueColor: const AlwaysStoppedAnimation(primaryPurple),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryPurple,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}