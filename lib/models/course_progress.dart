class CourseProgress {
  final String courseId;
  int lastLessonIndex;
  bool completed;

  CourseProgress({
    required this.courseId,
    this.lastLessonIndex = 0,
    this.completed = false,
  });
}
