import '../models/course.dart';
import '../models/lesson.dart';

final List<Course> sampleCourses = [
  Course(
    id: 'c1',
    title: 'Fundamentals of Ostomy Care',
    overview:
    'Learn the essential practices of ostomy care — from understanding stoma types to providing effective patient education and support.',
    level: 'Beginner',
    duration: '45 mins',
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
        content:
        'There are different types of stomas depending on the surgery and patient condition...',
        order: 2,
      ),
      Lesson(
        id: 'l3',
        title: 'Routine Care and Hygiene',
        content:
        'Daily care routines are essential for maintaining healthy skin and preventing infection...',
        order: 3,
      ),
    ],
  ),

  Course(
    id: 'c2',
    title: 'Living Confidently With an Ostomy',
    overview:
    'Build confidence in daily activities, social interactions, and emotional well-being while living with an ostomy.',
    level: 'Intermediate',
    duration: '30 mins',
    lessons: [
      Lesson(
        id: 'l4',
        title: 'Adjusting to Daily Life',
        content:
        'Adapting to life with an ostomy involves physical, emotional, and lifestyle adjustments...',
        order: 1,
      ),
      Lesson(
        id: 'l5',
        title: 'Diet and Nutrition Tips',
        content:
        'Understanding how food affects digestion and output can improve comfort and confidence...',
        order: 2,
      ),
    ],
  ),

  Course(
    id: 'c3',
    title: 'Advanced Ostomy Management',
    overview:
    'Deepen your knowledge with advanced care techniques, complication management, and long-term planning.',
    level: 'Advanced',
    duration: '1h 10m',
    lessons: [
      Lesson(
        id: 'l6',
        title: 'Managing Complications',
        content:
        'Learn how to identify and manage common ostomy-related complications early...',
        order: 1,
      ),
      Lesson(
        id: 'l7',
        title: 'Long-Term Stoma Health',
        content:
        'Long-term care focuses on prevention, monitoring, and maintaining overall stoma health...',
        order: 2,
      ),
    ],
  ),
];
