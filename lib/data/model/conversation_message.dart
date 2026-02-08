import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';


class ConversationMessage extends Equatable {
  final String question;
  final String answer;
  final DateTime timestamp;

  const ConversationMessage({
    required this.question,
    required this.answer,
    required this.timestamp,
  });

  factory ConversationMessage.fromMap(Map<String, dynamic> map) {
    return ConversationMessage(
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  @override
  List<Object?> get props => [question, answer, timestamp];
}
