import '../models/course.dart';
import '../models/lesson.dart';

final sampleCourse = Course(
  id: 'c1',
  title: 'Fundamentals of Ostomy Care',
  overview:
  'This course helps you understand the basics of living with an ostomy, '
      'including daily care, hygiene, and building confidence in your routine.',
  lessons: [
    Lesson(
      id: 'l1',
      order: 1,
      title: 'Understanding Your Ostomy',
      content:
      'An ostomy is a surgically created opening that allows waste to leave '
          'the body. In this lesson, you’ll learn why ostomies are created, '
          'the different types, and how they support your health and recovery.',
    ),
    Lesson(
      id: 'l2',
      order: 2,
      title: 'Daily Care & Hygiene',
      content:
      'Daily care is essential for comfort and confidence. This lesson '
          'covers cleaning around the stoma, changing your pouch system, '
          'and recognizing signs of irritation or infection.',
    ),
    Lesson(
      id: 'l3',
      order: 3,
      title: 'Diet & Lifestyle Adjustments',
      content:
      'Living with an ostomy doesn’t mean giving up your lifestyle. '
          'Here we discuss diet tips, hydration, physical activity, '
          'and managing social situations with ease.',
    ),
    Lesson(
      id: 'l4',
      order: 4,
      title: 'Building Confidence & Emotional Wellbeing',
      content:
      'It’s normal to experience emotional changes. This lesson focuses on '
          'self-confidence, body image, and practical tips to help you feel '
          'empowered and supported.',
    ),
  ],
);
