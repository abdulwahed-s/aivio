import 'package:aivio/core/services/gemini_service.dart';
import 'package:aivio/core/services/document_services.dart';
import 'package:aivio/core/services/assignment_firestore_service.dart';
import 'package:aivio/data/model/assignment_settings.dart';
import 'package:aivio/data/model/saved_assignment.dart';
import 'package:aivio/data/model/conversation_message.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'assignment_state.dart';

class AssignmentCubit extends Cubit<AssignmentState> {
  String? _currentUserId;

  AssignmentCubit() : super(AssignmentInitial());

  final DocumentService _documentService = DocumentService();
  final GeminiService _geminiService = GeminiService(
    "AIzaSyA-_6E4NQMS5MyoISA0-kkSkrKNSHAJzCo",
  );
  final AssignmentFirestoreService _firestoreService =
      AssignmentFirestoreService();

  void setUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> pickAndProcessDocumentForAssignment({
    AssignmentSettings? settings,
    bool saveToFirestore = true,
  }) async {
    try {
      final assignmentSettings = settings ?? const AssignmentSettings();

      emit(const AssignmentLoading(message: 'Selecting document...'));

      final documentFile = await _documentService.pickDocumentFile();
      if (documentFile == null) {
        emit(AssignmentInitial());
        return;
      }

      emit(
        const AssignmentLoading(message: 'Extracting text from document...'),
      );
      final documentText = await _documentService.extractTextFromDocument(
        documentFile,
      );

      emit(
        const AssignmentLoading(
          message: 'Generating assignment help with AI...',
        ),
      );
      final help = await _geminiService.generateAssignmentHelp(
        documentText,
        helpType: assignmentSettings.helpType,
        detailLevel: assignmentSettings.detailLevel,
        userNotes: assignmentSettings.userNotes,
      );

      if (help.isEmpty) {
        emit(
          const AssignmentError(
            'No assignment help was generated. Please try again.',
          ),
        );
        return;
      }

      String? assignmentId;
      if (saveToFirestore && _currentUserId != null) {
        emit(const AssignmentLoading(message: 'Saving assignment help...'));
        final fileName = documentFile.name.replaceAll(
          RegExp(r'\.(pdf|docx|txt|pptx)$'),
          '',
        );
        assignmentId = await _firestoreService.saveAssignment(
          userId: _currentUserId!,
          title: fileName,
          content: help,
          extractedText: documentText,
          settings: {
            'helpType': assignmentSettings.helpType.name,
            'detailLevel': assignmentSettings.detailLevel.name,
            'userNotes': assignmentSettings.userNotes,
          },
        );
      }

      emit(
        AssignmentLoaded(
          content: help,
          assignmentId: assignmentId,
          assignmentTitle: assignmentId != null
              ? documentFile.name.replaceAll(
                  RegExp(r'\.(pdf|docx|txt|pptx)$'),
                  '',
                )
              : null,
          extractedText: documentText,
          settings: assignmentSettings,
          conversations: const [],
        ),
      );
    } catch (e) {
      emit(AssignmentError(e.toString()));
    }
  }

  Future<void> loadSavedAssignment(SavedAssignment savedAssignment) async {
    try {
      emit(const AssignmentLoading(message: 'Loading assignment help...'));

      if (_currentUserId != null) {
        await _firestoreService.incrementViewCount(
          userId: _currentUserId!,
          assignmentId: savedAssignment.id,
        );
      }

      emit(
        AssignmentLoaded(
          content: savedAssignment.content,
          assignmentId: savedAssignment.id,
          assignmentTitle: savedAssignment.title,
          extractedText: savedAssignment.extractedText,
          settings: savedAssignment.settings,
          conversations: savedAssignment.conversations ?? [],
        ),
      );
    } catch (e) {
      emit(AssignmentError(e.toString()));
    }
  }

  void resetAssignment() {
    emit(AssignmentInitial());
  }

  Future<void> deleteAssignment(String assignmentId) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.deleteAssignment(
        userId: _currentUserId!,
        assignmentId: assignmentId,
      );
    } catch (e) {
      emit(AssignmentError('Failed to delete assignment: $e'));
    }
  }

  Future<void> renameAssignment(String assignmentId, String newTitle) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.updateAssignmentTitle(
        userId: _currentUserId!,
        assignmentId: assignmentId,
        newTitle: newTitle,
      );
    } catch (e) {
      emit(AssignmentError('Failed to rename assignment: $e'));
    }
  }

  Future<void> askFollowUpQuestion(String question) async {
    final currentState = state;
    if (currentState is! AssignmentLoaded) return;

    final userMessage = ConversationMessage(
      question: question,
      answer: '...',
      timestamp: DateTime.now(),
    );

    final updatedConversations = List<ConversationMessage>.from(
      currentState.conversations,
    )..add(userMessage);

    emit(
      AssignmentLoadingOverlay(
        message: 'Generating answer...',
        previousState: currentState.copyWith(
          conversations: updatedConversations,
        ),
      ),
    );

    try {
      final answer = await _geminiService.generateAssignmentFollowUpResponse(
        question: question,
        assignmentContent: currentState.content,
        extractedText: currentState.extractedText ?? '',
        helpType:
            currentState.settings?.helpType ?? AssignmentHelpType.stepByStep,
        detailLevel:
            currentState.settings?.detailLevel ??
            AssignmentDetailLevel.detailed,
      );

      final aiMessage = ConversationMessage(
        question: question,
        answer: answer,
        timestamp: DateTime.now(),
      );

      final finalConversations = List<ConversationMessage>.from(
        currentState.conversations,
      )..add(aiMessage);

      if (currentState.assignmentId != null && _currentUserId != null) {
        await _firestoreService.addConversationToAssignment(
          userId: _currentUserId!,
          assignmentId: currentState.assignmentId!,
          conversation: aiMessage,
        );
      }

      emit(currentState.copyWith(conversations: finalConversations));
    } catch (e) {
      emit(AssignmentError('Failed to get answer: $e'));

      emit(currentState);
    }
  }
}
