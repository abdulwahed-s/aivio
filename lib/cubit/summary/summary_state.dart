part of 'summary_cubit.dart';

abstract class SummaryState extends Equatable {
  const SummaryState();

  @override
  List<Object?> get props => [];
}

class SummaryInitial extends SummaryState {}

class SummaryLoading extends SummaryState {
  final String message;

  const SummaryLoading({required this.message});

  @override
  List<Object?> get props => [message];
}

class SummaryLoaded extends SummaryState {
  final String content;
  final String? summaryId;
  final String? summaryTitle;
  final String? extractedText;
  final SummarySettings? settings;
  final List<ConversationMessage> conversations;

  const SummaryLoaded({
    required this.content,
    this.summaryId,
    this.summaryTitle,
    this.extractedText,
    this.settings,
    this.conversations = const [],
  });

  @override
  List<Object?> get props => [
    content,
    summaryId,
    summaryTitle,
    extractedText,
    settings,
    conversations,
  ];

  SummaryLoaded copyWith({
    String? content,
    String? summaryId,
    String? summaryTitle,
    String? extractedText,
    SummarySettings? settings,
    List<ConversationMessage>? conversations,
  }) {
    return SummaryLoaded(
      content: content ?? this.content,
      summaryId: summaryId ?? this.summaryId,
      summaryTitle: summaryTitle ?? this.summaryTitle,
      extractedText: extractedText ?? this.extractedText,
      settings: settings ?? this.settings,
      conversations: conversations ?? this.conversations,
    );
  }
}

class SummaryLoadingOverlay extends SummaryLoaded {
  final String loadingMessage;

  const SummaryLoadingOverlay({
    required super.content,
    super.summaryId,
    super.summaryTitle,
    super.extractedText,
    super.settings,
    super.conversations,
    required this.loadingMessage,
  });

  @override
  List<Object?> get props => [
    content,
    summaryId,
    summaryTitle,
    extractedText,
    settings,
    conversations,
    loadingMessage,
  ];
}

class SummaryError extends SummaryState {
  final String message;

  const SummaryError(this.message);

  @override
  List<Object?> get props => [message];
}
