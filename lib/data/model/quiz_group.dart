import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class QuizGroup extends Equatable {
  final String id;
  final String name;
  final int color; 
  final DateTime createdAt;
  final int quizCount;

  const QuizGroup({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    this.quizCount = 0,
  });

  factory QuizGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizGroup(
      id: doc.id,
      name: data['name'] ?? 'Untitled Group',
      color: data['color'] ?? 0xFF6B5CE7, 
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      quizCount: data['quizCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'quizCount': quizCount,
    };
  }

  QuizGroup copyWith({
    String? id,
    String? name,
    int? color,
    DateTime? createdAt,
    int? quizCount,
  }) {
    return QuizGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      quizCount: quizCount ?? this.quizCount,
    );
  }

  @override
  List<Object?> get props => [id, name, color, createdAt, quizCount];
}
