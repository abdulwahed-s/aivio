import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'question.dart';
import 'quiz_settings.dart';

class SavedQuiz extends Equatable {
  final String id;
  final String title;
  final List<Question> questions;
  final DateTime createdAt;
  final int? bestScore;
  final int timesCompleted;
  final String? groupId;
  final QuizDifficulty? difficulty;

  const SavedQuiz({
    required this.id,
    required this.title,
    required this.questions,
    required this.createdAt,
    this.bestScore,
    this.timesCompleted = 0,
    this.groupId,
    this.difficulty,
  });

  factory SavedQuiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedQuiz(
      id: doc.id,
      title: data['title'] ?? 'Untitled Quiz',
      questions: (data['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      bestScore: data['bestScore'],
      timesCompleted: data['timesCompleted'] ?? 0,
      groupId: data['groupId'],
      difficulty: data['difficulty'] != null
          ? QuizDifficulty.values.firstWhere(
              (d) => d.name == data['difficulty'],
              orElse: () => QuizDifficulty.medium,
            )
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'questions': questions.map((q) => q.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'bestScore': bestScore,
      'timesCompleted': timesCompleted,
      'groupId': groupId,
      'difficulty': difficulty?.name,
    };
  }

  SavedQuiz copyWith({
    String? id,
    String? title,
    List<Question>? questions,
    DateTime? createdAt,
    int? bestScore,
    int? timesCompleted,
    String? groupId,
    QuizDifficulty? difficulty,
  }) {
    return SavedQuiz(
      id: id ?? this.id,
      title: title ?? this.title,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      bestScore: bestScore ?? this.bestScore,
      timesCompleted: timesCompleted ?? this.timesCompleted,
      groupId: groupId ?? this.groupId,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    questions,
    createdAt,
    bestScore,
    timesCompleted,
    groupId,
    difficulty,
  ];
}
