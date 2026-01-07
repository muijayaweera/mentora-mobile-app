import 'lesson.dart';

class Course {
  final String id;
  final String title;
  final String overview;
  final String level;      // Beginner / Intermediate / Advanced
  final String duration;   // e.g. "45 mins", "1h 20m"
  final List<Lesson> lessons;

  Course({
    required this.id,
    required this.title,
    required this.overview,
    required this.level,
    required this.duration,
    required this.lessons,
  });
}
