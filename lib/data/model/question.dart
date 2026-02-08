import 'package:equatable/equatable.dart';

enum QuestionType { mcq, essay }

class Question extends Equatable {
  final String question;
  final QuestionType type;
  final List<String>? options; 
  final int? correctAnswerIndex; 
  final String? explanation;
  final String? sampleAnswer; 

  const Question({
    required this.question,
    required this.type,
    this.options,
    this.correctAnswerIndex,
    this.explanation,
    this.sampleAnswer,
  });

  bool get isMCQ => type == QuestionType.mcq;
  bool get isEssay => type == QuestionType.essay;

  factory Question.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'mcq';
    final type = typeStr == 'essay' ? QuestionType.essay : QuestionType.mcq;

    return Question(
      question: json['question'] as String,
      type: type,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      correctAnswerIndex: json['correctAnswerIndex'] as int?,
      explanation: json['explanation'] as String?,
      sampleAnswer: json['sampleAnswer'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'type': type == QuestionType.essay ? 'essay' : 'mcq',
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'sampleAnswer': sampleAnswer,
    };
  }

  @override
  List<Object?> get props => [
    question,
    type,
    options,
    correctAnswerIndex,
    explanation,
    sampleAnswer,
  ];
}
