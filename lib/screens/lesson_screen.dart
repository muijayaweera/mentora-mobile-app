import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson.dart';

class LessonScreen extends StatelessWidget {
  final Lesson lesson;
  final List<Lesson> allLessons;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.allLessons,
  });

  @override
  Widget build(BuildContext context) {
    final int currentIndex =
    allLessons.indexWhere((l) => l.id == lesson.id);

    final bool isLastLesson = currentIndex == allLessons.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lesson title
              Text(
                lesson.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

// Lesson progress text
              Text(
                'Lesson ${currentIndex + 1} of ${allLessons.length}',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 8),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / allLessons.length,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(
                    Color(0xFFA822D9),
                  ),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 20),


              const SizedBox(height: 20),

              // Lesson content
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    lesson.content,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Next / Complete button
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
                  onPressed: () {
                    if (isLastLesson) {
                      // Later → Quiz screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Module complete! Quiz coming soon 💜'),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonScreen(
                            lesson: allLessons[currentIndex + 1],
                            allLessons: allLessons,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    isLastLesson ? 'Complete Module' : 'Next Lesson',
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
