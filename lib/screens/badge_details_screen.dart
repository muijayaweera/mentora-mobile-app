import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/ui_constants.dart';

class BadgeDetailsScreen extends StatefulWidget {
  const BadgeDetailsScreen({super.key});

  @override
  State<BadgeDetailsScreen> createState() => _BadgeDetailsScreenState();
}

final List<Map<String, dynamic>> allPossibleBadges = [
  {
    'id': 'quiz_starter',
    'title': 'Quiz Starter',
    'description': 'Complete your first quick check.',
    'icon': '🔥',
    'type': 'quiz',
  },
  {
    'id': 'perfect_quiz',
    'title': 'Perfect Quiz',
    'description': 'Answer all questions correctly in a lesson quiz.',
    'icon': '🎯',
    'type': 'quiz',
  },
  {
    'id': 'course_completed',
    'title': 'Course Completed',
    'description': 'Complete all lessons in a course.',
    'icon': '📘',
    'type': 'course',
  },
  {
    'id': 'first_course_completed',
    'title': 'First Milestone',
    'description': 'Complete your first course in Mentora.',
    'icon': '🏆',
    'type': 'course',
  },
  {
    'id': 'three_perfect_quizzes',
    'title': 'Accuracy Streak',
    'description': 'Earn 3 perfect quiz badges.',
    'icon': '💎',
    'type': 'quiz',
  },
];

class _BadgeDetailsScreenState extends State<BadgeDetailsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> badges = [];

  static const Color primaryPurple = Color(0xFFA822D9);
  static const Color primaryPink = Color(0xFFC514C2);
  static const Color pageBg = Color(0xFFF8F7FA);

  @override
  void initState() {
    super.initState();
    fetchBadges();
  }

  Future<void> fetchBadges() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('badges')
          .orderBy('earnedAt', descending: true)
          .get();

      setState(() {
        badges = snap.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching badges: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              colors: [primaryPink, primaryPurple],
            ).createShader(bounds);
          },
          child: Text(
            'mentora.',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: primaryPurple),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroCard(),
              const SizedBox(height: 24),
              Text(
                'Earned Badges',
                style: GoogleFonts.poppins(
                  color: textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              if (badges.isEmpty)
                _emptyState()
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allPossibleBadges.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.88,
                  ),
                  itemBuilder: (context, index) {
                    final badgeTemplate = allPossibleBadges[index];

                    final earnedBadge = badges.where((earned) {
                      final earnedId = earned['id'].toString();

                      return earnedId == badgeTemplate['id'] ||
                          earnedId.startsWith('${badgeTemplate['id']}_');
                    }).toList();

                    final isEarned = earnedBadge.isNotEmpty;

                    return _badgeCard(
                      isEarned ? earnedBadge.first : badgeTemplate,
                      isLocked: !isEarned,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF7ECFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: primaryPurple.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryPurple, primaryPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: primaryPurple.withOpacity(0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${badges.length} Badges Earned',
                  style: GoogleFonts.poppins(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your learning milestones and quiz achievements.',
                  style: GoogleFonts.poppins(
                    color: subTextLight,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeCard(Map<String, dynamic> badge, {bool isLocked = false}) {
    final icon = badge['icon'] ?? '🏅';
    final title = badge['title'] ?? 'Badge';
    final description = badge['description'] ?? '';
    final type = badge['type'] ?? 'achievement';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFFF1F1F3) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryPurple.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: isLocked
                  ? const Icon(
                Icons.lock_rounded,
                color: Colors.grey,
                size: 26,
              )
                  : Text(
                icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: isLocked ? Colors.grey : textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 7),
          Expanded(
            child: Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: isLocked ? Colors.grey : subTextLight,
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: isLocked
                  ? Colors.grey.withOpacity(0.12)
                  : primaryPink.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isLocked ? 'LOCKED' : type.toString().toUpperCase(),
              style: GoogleFonts.poppins(
                color: isLocked ? Colors.grey : primaryPurple,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryPurple.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text(
            '🏅',
            style: const TextStyle(fontSize: 44),
          ),
          const SizedBox(height: 10),
          Text(
            'No badges yet',
            style: GoogleFonts.poppins(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete quizzes and courses to unlock achievements.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: subTextLight,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}