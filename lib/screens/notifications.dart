import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/ui_constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _AppNotification {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime? time;

  _AppNotification({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<StreamSubscription> _subs = [];
  final List<_AppNotification> _items = [];

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }

  void _listenToNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final coursesSub = FirebaseFirestore.instance
        .collection('courses')
        .where('status', isEqualTo: 'published')
        .snapshots()
        .listen((snapshot) {
      _removeType('course_');

      for (final doc in snapshot.docs) {
        final data = doc.data();
        _items.add(
          _AppNotification(
            id: 'course_${doc.id}',
            icon: Icons.menu_book_outlined,
            title: 'New course available',
            subtitle: data['title'] ?? data['courseTitle'] ?? 'A new course has been added.',
            time: _toDateTime(data['createdAt']),
          ),
        );
      }

      _sortAndRefresh();
    });

    final badgesSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('badges')
        .snapshots()
        .listen((snapshot) {
      _removeType('badge_');

      for (final doc in snapshot.docs) {
        final data = doc.data();
        _items.add(
          _AppNotification(
            id: 'badge_${doc.id}',
            icon: Icons.emoji_events_outlined,
            title: 'Badge unlocked',
            subtitle: '${data['icon'] ?? '🏆'} ${data['title'] ?? 'New badge'}',
            time: _toDateTime(data['earnedAt']),
          ),
        );
      }

      _sortAndRefresh();
    });

    final quizSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('quizSummaries')
        .snapshots()
        .listen((snapshot) {
      _removeType('quiz_');
      _removeType('review_');

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final score = data['scorePercentage'] ?? 0;
        final lessonTitle = data['lessonTitle'] ?? 'lesson quiz';

        _items.add(
          _AppNotification(
            id: 'quiz_${doc.id}',
            icon: Icons.check_circle_outline,
            title: 'Quiz completed',
            subtitle: 'You scored $score% in $lessonTitle.',
            time: _toDateTime(data['completedAt']),
          ),
        );

        if (score < 60) {
          _items.add(
            _AppNotification(
              id: 'review_${doc.id}',
              icon: Icons.lightbulb_outline,
              title: 'Review recommended',
              subtitle: 'Try revisiting $lessonTitle to strengthen this area.',
              time: _toDateTime(data['completedAt']),
            ),
          );
        }
      }

      _sortAndRefresh();
    });

    _subs.addAll([coursesSub, badgesSub, quizSub]);
  }

  void _removeType(String prefix) {
    _items.removeWhere((item) => item.id.startsWith(prefix));
  }

  void _sortAndRefresh() {
    _items.sort((a, b) {
      final aTime = a.time ?? DateTime(2000);
      final bTime = b.time ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });

    if (mounted) setState(() {});
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  String _timeLabel(DateTime? date) {
    if (date == null) return 'Recently';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hr ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
                  ).createShader(bounds);
                },
                child: Text(
                  'mentora.',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Notifications',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Your latest learning updates and achievements.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: subTextLight,
                ),
              ),

              const SizedBox(height: 30),

              if (_items.isEmpty)
                _emptyState()
              else
                Column(
                  children: _items
                      .map(
                        (item) => _notificationRow(
                      icon: item.icon,
                      title: item.title,
                      subtitle: item.subtitle,
                      time: _timeLabel(item.time),
                    ),
                  )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF4E8FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFFA822D9),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Updates will appear here as you learn.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: subTextLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF4E8FA),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFA822D9),
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: borderLight.withOpacity(0.9),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: subTextLight,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      color: subTextLight.withOpacity(0.8),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}