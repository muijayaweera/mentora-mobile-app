import '../models/course.dart';
import '../models/lesson.dart';

final sampleCourse = Course(
  id: 'c1',
  title: 'Fundamentals of Ostomy Care',
  overview:
  'Learn the essential practices of ostomy care — from understanding stoma types to providing effective patient education and support.',
  lessons: [
    Lesson(
      id: 'l1',
      title: 'Introduction to Ostomies',
      content:
      'An ostomy is a surgically created opening on the abdomen that allows waste to leave the body...',
      order: 1,
    ),
    Lesson(
      id: 'l2',
      title: 'Types of Stomas and Appliances',
      content: 'There are different types of stomas depending on the surgery...',
      order: 2,
    ),
    Lesson(
      id: 'l3',
      title: 'Routine Care and Hygiene',
      content: 'Daily care routines are essential for stoma health...',
      order: 3,
    ),
  ],
);
