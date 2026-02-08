import 'package:aivio/data/model/conversation_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SavedSummary extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int timesViewed;
  final String? groupId;
  final String? extractedText;
  final Map<String, dynamic>? settings;
  final List<ConversationMessage>? conversations;

  const SavedSummary({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.timesViewed = 0,
    this.groupId,
    this.extractedText,
    this.settings,
    this.conversations,
  });

  factory SavedSummary.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List<ConversationMessage>? conversations;
    if (data['conversations'] != null) {
      conversations = (data['conversations'] as List<dynamic>)
          .map(
            (item) => ConversationMessage.fromMap(item as Map<String, dynamic>),
          )
          .toList();
    }

    return SavedSummary(
      id: doc.id,
      title: data['title'] ?? 'Untitled Summary',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      timesViewed: data['timesViewed'] ?? 0,
      groupId: data['groupId'],
      extractedText: data['extractedText'],
      settings: data['settings'] as Map<String, dynamic>?,
      conversations: conversations,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'timesViewed': timesViewed,
      'groupId': groupId,
      'extractedText': extractedText,
      'settings': settings,
      'conversations': conversations?.map((c) => c.toMap()).toList(),
    };
  }

  SavedSummary copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    int? timesViewed,
    String? groupId,
    String? extractedText,
    Map<String, dynamic>? settings,
    List<ConversationMessage>? conversations,
  }) {
    return SavedSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      timesViewed: timesViewed ?? this.timesViewed,
      groupId: groupId ?? this.groupId,
      extractedText: extractedText ?? this.extractedText,
      settings: settings ?? this.settings,
      conversations: conversations ?? this.conversations,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    createdAt,
    timesViewed,
    groupId,
    extractedText,
    settings,
    conversations,
  ];
}
