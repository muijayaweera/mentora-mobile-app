class CourseProgressStore {
  static final Map<String, int> _progress = {};

  /// Save last lesson index for a course
  static void saveProgress(String courseId, int lessonIndex) {
    _progress[courseId] = lessonIndex;
  }

  /// Get last lesson index (defaults to 0)
  static int getProgress(String courseId) {
    return _progress[courseId] ?? 0;
  }

  /// Check if course has been started
  static bool isStarted(String courseId) {
    return _progress.containsKey(courseId);
  }

  /// Check if course is completed
  static bool isCompleted(String courseId, int totalLessons) {
    return (_progress[courseId] ?? 0) >= totalLessons;
  }
}
