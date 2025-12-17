import 'lesson.dart';

class Course {
  final String id;
  final String title;
  final String overview;
  final List<Lesson> lessons;

  Course({
    required this.id,
    required this.title,
    required this.overview,
    required this.lessons,
  });
}
