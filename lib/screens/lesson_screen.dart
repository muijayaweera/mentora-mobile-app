import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson.dart';

// 🔥 Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LessonScreen extends StatefulWidget {
  final List<Lesson> allLessons;
  final int startIndex;

  const LessonScreen({
    super.key,
    required this.allLessons,
    this.startIndex = 0,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    // ✅ Start from saved lesson index
    currentIndex = widget.startIndex;
  }

  // ================= SAVE PROGRESS TO FIREBASE =================
  Future<void> saveProgress({bool completed = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'courseProgress': {
          'c1': {
            'lastLessonIndex': currentIndex,
            'completed': completed,
          }
        }
      },
      SetOptions(merge: true),
    );
  }
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final lesson = widget.allLessons[currentIndex];
    final bool isFirstLesson = currentIndex == 0;
    final bool isLastLesson =
        currentIndex == widget.allLessons.length - 1;

    return WillPopScope(
      onWillPop: () async {
        // ✅ Save progress when user leaves lesson screen
        await saveProgress();
        Navigator.pop(context, currentIndex);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2C2C2E),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= TITLE =================
                Text(
                  lesson.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                // ================= PROGRESS TEXT =================
                Text(
                  'Lesson ${currentIndex + 1} of ${widget.allLessons.length}',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 8),

                // ================= PROGRESS BAR =================
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value:
                    (currentIndex + 1) / widget.allLessons.length,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(
                      Color(0xFFA822D9),
                    ),
                    minHeight: 6,
                  ),
                ),

                const SizedBox(height: 20),

                // ================= CONTENT =================
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

                // ================= BUTTONS =================
                if (isLastLesson)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor:
                        const Color(0xFFA822D9),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        // ✅ Mark course as completed
                        await saveProgress(completed: true);
                        Navigator.pop(context, currentIndex);
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
                              padding:
                              const EdgeInsets.symmetric(
                                  vertical: 14),
                              side: const BorderSide(
                                color: Color(0xFFA822D9),
                                width: 1.6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                currentIndex--;
                              });
                              // ✅ Save progress
                              await saveProgress();
                            },
                            child: Text(
                              'Previous',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      if (!isFirstLesson)
                        const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(
                                vertical: 14),
                            backgroundColor:
                            const Color(0xFFA822D9),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              currentIndex++;
                            });
                            // ✅ Save progress
                            await saveProgress();
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
