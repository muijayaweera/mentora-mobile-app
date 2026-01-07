import '../models/course_progress.dart';

class CourseProgressStore {
  static final Map<String, CourseProgress> _progress = {};

  static CourseProgress getProgress(String courseId) {
    return _progress.putIfAbsent(
      courseId,
          () => CourseProgress(courseId: courseId),
    );
  }

  static void updateProgress(
      String courseId, {
        int? lastLessonIndex,
        bool? completed,
      }) {
    final progress = getProgress(courseId);

    if (lastLessonIndex != null) {
      progress.lastLessonIndex = lastLessonIndex;
    }
    if (completed != null) {
      progress.completed = completed;
    }
  }
}
