import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/ui_constants.dart';
import '../models/quiz_question.dart';
import '../models/badge_award.dart';

class QuizScreen extends StatefulWidget {
  final String courseId;
  final String lessonId;
  final String lessonTitle;
  final List<QuizQuestion> questions;

  const QuizScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.lessonTitle,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool hasAnswered = false;
  int correctCount = 0;

  QuizQuestion get currentQuestion => widget.questions[currentQuestionIndex];

  Future<void> saveAnswer({
    required QuizQuestion question,
    required int selectedIndex,
    required bool isCorrect,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('quizAttempts')
        .add({
      'courseId': widget.courseId,
      'lessonId': widget.lessonId,
      'questionId': question.id,
      'questionText': question.questionText,
      'selectedAnswerIndex': selectedIndex,
      'correctAnswerIndex': question.correctAnswerIndex,
      'isCorrect': isCorrect,
      'answeredAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> handleAnswer(int index) async {
    if (hasAnswered) return;

    final isCorrect = index == currentQuestion.correctAnswerIndex;

    setState(() {
      selectedAnswerIndex = index;
      hasAnswered = true;
      if (isCorrect) correctCount++;
    });

    await saveAnswer(
      question: currentQuestion,
      selectedIndex: index,
      isCorrect: isCorrect,
    );


  }

  Future<bool> hasBadge(String badgeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('badges')
        .doc(badgeId)
        .get();

    return doc.exists;
  }

  Future<void> awardBadge(BadgeAward badge) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final alreadyEarned = await hasBadge(badge.id);
    if (alreadyEarned) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('badges')
        .doc(badge.id)
        .set({
      'title': badge.title,
      'description': badge.description,
      'icon': badge.icon,
      'type': badge.type,
      'courseId': widget.courseId,
      'lessonId': widget.lessonId,
      'earnedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    await showBadgeDialog(badge);
  }

  Future<void> showBadgeDialog(BadgeAward badge) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Badge Unlocked!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(badge.icon, style: const TextStyle(fontSize: 50)),
              const SizedBox(height: 12),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: subTextLight,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA822D9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Yay!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> checkQuizBadges() async {
    final totalQuestions = widget.questions.length;

    await awardBadge(
      BadgeAward(
        id: 'quiz_starter',
        title: 'Quiz Starter',
        description: 'You completed your first quick check.',
        icon: '🔥',
        type: 'quiz',
      ),
    );

    if (correctCount == totalQuestions) {
      await awardBadge(
        BadgeAward(
          id: 'perfect_quiz_${widget.courseId}_${widget.lessonId}',
          title: 'Perfect Quiz',
          description: 'You answered all questions correctly in this lesson.',
          icon: '🎯',
          type: 'quiz',
        ),
      );
    }
  }

  Future<void> goToNextQuestion() async {
    final isLastQuestion =
        currentQuestionIndex == widget.questions.length - 1;

    if (isLastQuestion) {
      await checkQuizBadges();

      if (!mounted) return;
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      currentQuestionIndex++;
      selectedAnswerIndex = null;
      hasAnswered = false;
    });
  }

  Color optionBorderColor(int index) {
    if (!hasAnswered) return borderLight;

    if (index == currentQuestion.correctAnswerIndex) {
      return Colors.green;
    }

    if (index == selectedAnswerIndex &&
        index != currentQuestion.correctAnswerIndex) {
      return Colors.red;
    }

    return borderLight;
  }

  Color optionBgColor(int index) {
    if (!hasAnswered) return surfaceLight;

    if (index == currentQuestion.correctAnswerIndex) {
      return Colors.green.withOpacity(0.08);
    }

    if (index == selectedAnswerIndex &&
        index != currentQuestion.correctAnswerIndex) {
      return Colors.red.withOpacity(0.08);
    }

    return surfaceLight;
  }

  @override
  Widget build(BuildContext context) {
    final progressValue =
        (currentQuestionIndex + 1) / widget.questions.length;


    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        title: Text(
          'Quick Check',
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lessonTitle,
                      style: GoogleFonts.poppins(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Question ${currentQuestionIndex + 1} of ${widget.questions.length}',
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

              const SizedBox(height: 22),

              Text(
                currentQuestion.questionText,
                style: GoogleFonts.poppins(
                  color: textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => handleAnswer(index),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: optionBgColor(index),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: optionBorderColor(index),
                            width: 1.4,
                          ),
                        ),
                        child: Text(
                          currentQuestion.options[index],
                          style: GoogleFonts.poppins(
                            color: textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (hasAnswered && currentQuestion.explanation.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4E8FA),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    currentQuestion.explanation,
                    style: GoogleFonts.poppins(
                      color: subTextLight,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasAnswered ? () async => await goToNextQuestion() : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFA822D9),
                    disabledBackgroundColor: const Color(0xFFD9B1F2),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    currentQuestionIndex == widget.questions.length - 1
                        ? 'Finish Quiz'
                        : 'Next Question',
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