import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson.dart';
import '../models/quiz_question.dart';
import 'quiz_screen.dart';

// 🔥 Firebase
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
  late int currentIndex;
  bool isCheckingQuiz = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.startIndex;
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
      print("COURSE ID USED BY APP: ${widget.courseId}");
      print("LESSON ID USED BY APP: ${lesson.id}");
      final questions = await fetchQuizQuestions(lesson.id);
      print("QUESTIONS FOUND: ${questions.length}");

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
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: bgLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: textDark),
          title: Text(
            'Lesson',
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
                        lesson.title,
                        style: GoogleFonts.poppins(
                          color: textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Lesson ${currentIndex + 1} of ${widget.allLessons.length}',
                        style: GoogleFonts.poppins(
                          color: subTextLight,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: const Color(0xFFF1E7F8),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFA822D9),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.035),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        lesson.content,
                        style: GoogleFonts.poppins(
                          color: subTextLight,
                          fontSize: 14,
                          height: 1.75,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                if (isCheckingQuiz)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFA822D9),
                    ),
                  )
                else if (isLastLesson)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFA822D9),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        await openQuizThenProceed(completeCourse: true);
                      },
                      child: Text(
                        'Complete Module',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      if (!isFirstLesson)
                        Expanded(
                          flex: 4,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFA822D9),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(
                                color: Color(0xFFA822D9),
                                width: 1.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                currentIndex--;
                              });
                              await saveProgress();
                            },
                            child: Text(
                              'Previous',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      if (!isFirstLesson) const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFFA822D9),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            await openQuizThenProceed(completeCourse: false);
                          },
                          child: Text(
                            'Next Lesson',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
}