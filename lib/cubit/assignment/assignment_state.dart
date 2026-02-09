part of 'assignment_cubit.dart';

abstract class AssignmentState extends Equatable {
  const AssignmentState();

  @override
  List<Object?> get props => [];
}

class AssignmentInitial extends AssignmentState {}

class AssignmentLoading extends AssignmentState {
  final String message;

  const AssignmentLoading({this.message = 'Loading...'});

  @override
  List<Object?> get props => [message];
}

class AssignmentLoadingOverlay extends AssignmentState {
  final String message;
  final AssignmentLoaded previousState;

  const AssignmentLoadingOverlay({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

class AssignmentLoaded extends AssignmentState {
  final String content;
  final String? assignmentId;
  final String? assignmentTitle;
  final String? extractedText;
  final AssignmentSettings? settings;
  final List<ConversationMessage> conversations;

  const AssignmentLoaded({
    required this.content,
    this.assignmentId,
    this.assignmentTitle,
    this.extractedText,
    this.settings,
    this.conversations = const [],
  });

  AssignmentLoaded copyWith({
    String? content,
    String? assignmentId,
    String? assignmentTitle,
    String? extractedText,
    AssignmentSettings? settings,
    List<ConversationMessage>? conversations,
  }) {
    return AssignmentLoaded(
      content: content ?? this.content,
      assignmentId: assignmentId ?? this.assignmentId,
      assignmentTitle: assignmentTitle ?? this.assignmentTitle,
      extractedText: extractedText ?? this.extractedText,
      settings: settings ?? this.settings,
      conversations: conversations ?? this.conversations,
    );
  }

  @override
  List<Object?> get props => [
    content,
    assignmentId,
    assignmentTitle,
    extractedText,
    settings,
    conversations,
  ];
}

class AssignmentError extends AssignmentState {
  final String message;

  const AssignmentError(this.message);

  @override
  List<Object?> get props => [message];
}
