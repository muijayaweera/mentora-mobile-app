import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final int order;
  final String imageUrl;

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.order,
    required this.imageUrl,
  });

  factory QuizQuestion.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    print("QUESTION DOC ID: ${doc.id}");
    print("QUESTION RAW DATA: $data");
    print("OPTIONS RAW VALUE: ${data['options']}");
    print("OPTIONS RAW TYPE: ${data['options']?.runtimeType}");

    return QuizQuestion(
      id: doc.id,
      questionText: data['questionText'] ?? '',
      options: (data['options'] as List<dynamic>? ?? [])
          .map((option) => option.toString())
          .toList(),
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
      explanation: data['explanation'] ?? '',
      order: data['order'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}