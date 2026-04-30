import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/ui_constants.dart';
import '../models/course.dart';
import 'course_overview.dart';
import 'badge_details_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  int badgeCount = 0;
  List<Course> allCourses = [];
  Map<String, dynamic> courseProgressMap = {};
  bool isLoading = true;
  String searchQuery = '';

  static const Color primaryPurple = Color(0xFFA822D9);
  static const Color primaryPink = Color(0xFFC514C2);
  static const Color softBg = Color(0xFFF8F7FA);

  @override
  void initState() {
    super.initState();
    fetchCoursesAndProgress();
  }

  Future<void> fetchCoursesAndProgress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      final coursesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('status', isEqualTo: 'published')
          .get();

      final fetchedCourses = coursesSnapshot.docs.map((doc) {
        final data = doc.data();

        return Course(
          id: doc.id,
          title: data['title'] ?? '',
          overview: data['description'] ?? '',
          level: data['level'] ?? '',
          duration: data['estimatedDuration'] ?? '',
          lessons: const [],
        );
      }).toList();

      Map<String, dynamic> progressMap = {};

      int fetchedBadgeCount = 0;

      if (user != null) {
        final badgeSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('badges')
            .get();

        fetchedBadgeCount = badgeSnap.docs.length;
      }

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null && userData['courseProgress'] != null) {
            progressMap = Map<String, dynamic>.from(userData['courseProgress']);
          }
        }
      }

      setState(() {
        allCourses = fetchedCourses;
        courseProgressMap = progressMap;
        badgeCount = fetchedBadgeCount;
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
    final filteredCourses = allCourses.where((course) {
      final query = searchQuery.toLowerCase().trim();
      if (query.isEmpty) return true;

      return course.title.toLowerCase().contains(query) ||
          course.overview.toLowerCase().contains(query) ||
          course.level.toLowerCase().contains(query);
    }).toList();

    final List<Course> suggestedCourses = [];
    final List<Course> inProgressCourses = [];
    final List<Course> completedCourses = [];

    for (final course in filteredCourses) {
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
      backgroundColor: softBg,
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: primaryPurple,
          ),
        )
            : allCourses.isEmpty
            ? _emptyState("No published courses available yet.")
            : RefreshIndicator(
          color: primaryPurple,
          onRefresh: fetchCoursesAndProgress,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      "mentora.",
                      style: GoogleFonts.poppins(
                        fontSize: 27,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                _searchBar(),

                if (badgeCount > 0)
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BadgeDetailsScreen(),
                        ),
                      );

                      fetchCoursesAndProgress();
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 18, bottom: 24),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryPurple.withOpacity(0.12),
                            primaryPink.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: primaryPurple.withOpacity(0.10)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: primaryPurple,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Achievements',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.5,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$badgeCount earned • Tap to view badges',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    color: subTextLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 28),

                if (filteredCourses.isEmpty)
                  _emptyState("No courses matched your search.")
                else ...[
                  if (suggestedCourses.isNotEmpty) ...[
                    _sectionTitle("Suggested For You"),
                    const SizedBox(height: 14),
                    ...suggestedCourses.map(
                          (course) => _courseTile(
                        context,
                        course,
                        statusLabel: "Start",
                        statusIcon: Icons.play_arrow_rounded,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (inProgressCourses.isNotEmpty) ...[
                    _sectionTitle("In Progress"),
                    const SizedBox(height: 14),
                    ...inProgressCourses.map(
                          (course) => _courseTile(
                        context,
                        course,
                        statusLabel: "Continue",
                        statusIcon: Icons.timelapse_rounded,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (completedCourses.isNotEmpty) ...[
                    _sectionTitle("Completed"),
                    const SizedBox(height: 14),
                    ...completedCourses.map(
                          (course) => _courseTile(
                        context,
                        course,
                        statusLabel: "Completed",
                        statusIcon: Icons.check_circle_rounded,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: GoogleFonts.poppins(
          color: textDark,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: "Search courses",
          hintStyle: GoogleFonts.poppins(
            color: subTextLight,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: primaryPurple,
            size: 22,
          ),
          suffixIcon: searchQuery.isEmpty
              ? null
              : IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: subTextLight,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                searchQuery = '';
              });
            },
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
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
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _courseTile(
      BuildContext context,
      Course course, {
        required String statusLabel,
        required IconData statusIcon,
      }) {
    final completed = _isCompleted(course.id);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseOverviewScreen(course: course),
          ),
        );

        fetchCoursesAndProgress();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: completed
                ? Colors.green.withOpacity(0.25)
                : primaryPurple.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryPurple.withOpacity(0.15),
                ),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: primaryPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: textDark,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (course.level.trim().isNotEmpty)
                        _badge(course.level),
                      if (course.duration.trim().isNotEmpty)
                        _durationBadge(course.duration),
                      _statusBadge(statusLabel, statusIcon, completed),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: primaryPurple,
              ),
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
        color: primaryPurple.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: primaryPurple,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _durationBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 13,
            color: subTextLight,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: subTextLight,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String text, IconData icon, bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: completed
            ? Colors.green.withOpacity(0.10)
            : primaryPink.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: completed ? Colors.green : primaryPink,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: completed ? Colors.green : primaryPink,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: subTextLight,
          ),
        ),
      ),
    );
  }
}