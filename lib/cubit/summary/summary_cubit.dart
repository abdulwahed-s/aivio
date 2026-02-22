import 'package:aivio/core/constant/api_keys.dart';
import 'package:aivio/core/services/gemini_service.dart';
import 'package:aivio/core/services/document_services.dart';
import 'package:aivio/core/services/summary_firestore_service.dart';
import 'package:aivio/data/model/summary_settings.dart';
import 'package:aivio/data/model/saved_summary.dart';
import 'package:aivio/data/model/conversation_message.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'summary_state.dart';

class SummaryCubit extends Cubit<SummaryState> {
  String? _currentUserId;

  SummaryCubit() : super(SummaryInitial());

  final DocumentService _pdfService = DocumentService();
  final GeminiService _geminiService = GeminiService(ApiKeys.geminiApiKey);
  final SummaryFirestoreService _firestoreService = SummaryFirestoreService();

  void setUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> pickAndProcessPdfForSummary({
    SummarySettings? settings,
    bool saveToFirestore = true,
  }) async {
    try {
      final summarySettings = settings ?? const SummarySettings();

      emit(const SummaryLoading(message: 'Selecting PDF...'));

      final pdfFile = await _pdfService.pickDocumentFile();
      if (pdfFile == null) {
        emit(SummaryInitial());
        return;
      }

      emit(const SummaryLoading(message: 'Extracting text from PDF...'));
      final pdfText = await _pdfService.extractTextFromDocument(pdfFile);

      emit(const SummaryLoading(message: 'Generating summary with AI...'));
      final summary = await _geminiService.generateSummary(
        pdfText,
        length: summarySettings.length,
        format: summarySettings.format,
        numberOfSections: summarySettings.numberOfSections,
      );

      if (summary.isEmpty) {
        emit(const SummaryError('No summary was generated. Please try again.'));
        return;
      }

      String? summaryId;
      if (saveToFirestore && _currentUserId != null) {
        emit(const SummaryLoading(message: 'Saving summary...'));
        final fileName = pdfFile.name.replaceAll('.pdf', '');

        final settingsMap = {
          'length': summarySettings.length.name,
          'format': summarySettings.format.name,
        };

        summaryId = await _firestoreService.saveSummary(
          userId: _currentUserId!,
          title: fileName,
          content: summary,
          extractedText: pdfText,
          settings: settingsMap,
        );
      }

      emit(
        SummaryLoaded(
          content: summary,
          summaryId: summaryId,
          summaryTitle: summaryId != null
              ? pdfFile.name.replaceAll('.pdf', '')
              : null,
          extractedText: pdfText,
          settings: summarySettings,
          conversations: const [],
        ),
      );
    } catch (e) {
      emit(SummaryError(e.toString()));
    }
  }

  Future<void> loadSavedSummary(SavedSummary savedSummary) async {
    try {
      emit(const SummaryLoading(message: 'Loading summary...'));

      if (_currentUserId != null) {
        await _firestoreService.incrementViewCount(
          userId: _currentUserId!,
          summaryId: savedSummary.id,
        );
      }

      SummarySettings? settings;
      if (savedSummary.settings != null) {
        try {
          settings = SummarySettings(
            length: SummaryLength.values.firstWhere(
              (e) => e.name == savedSummary.settings!['length'],
              orElse: () => SummaryLength.detailed,
            ),
            format: SummaryFormat.values.firstWhere(
              (e) => e.name == savedSummary.settings!['format'],
              orElse: () => SummaryFormat.keyTopics,
            ),
          );
        } catch (e) {
          settings = null;
        }
      }

      emit(
        SummaryLoaded(
          content: savedSummary.content,
          summaryId: savedSummary.id,
          summaryTitle: savedSummary.title,
          extractedText: savedSummary.extractedText,
          settings: settings,
          conversations: savedSummary.conversations ?? [],
        ),
      );
    } catch (e) {
      emit(SummaryError(e.toString()));
    }
  }

  void resetSummary() {
    emit(SummaryInitial());
  }

  Future<void> deleteSummary(String summaryId) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.deleteSummary(
        userId: _currentUserId!,
        summaryId: summaryId,
      );
    } catch (e) {
      emit(SummaryError('Failed to delete summary: $e'));
    }
  }

  Future<void> renameSummary(String summaryId, String newTitle) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.updateSummaryTitle(
        userId: _currentUserId!,
        summaryId: summaryId,
        newTitle: newTitle,
      );
    } catch (e) {
      emit(SummaryError('Failed to rename summary: $e'));
    }
  }

  Future<void> askFollowUpQuestion(String question) async {
    final currentState = state;
    if (currentState is! SummaryLoaded) return;

    if (currentState.extractedText == null || currentState.settings == null) {
      emit(
        const SummaryError(
          'This summary doesn\'t support Q&A. Please regenerate the summary to use this feature.',
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (state is SummaryError) {
          emit(currentState);
        }
      });
      return;
    }

    try {
      emit(
        SummaryLoadingOverlay(
          content: currentState.content,
          summaryId: currentState.summaryId,
          summaryTitle: currentState.summaryTitle,
          extractedText: currentState.extractedText,
          settings: currentState.settings,
          conversations: currentState.conversations,
          loadingMessage: 'Thinking...',
        ),
      );

      final answer = await _geminiService.generateFollowUpResponse(
        question: question,
        summaryContent: currentState.content,
        extractedText: currentState.extractedText!,
        length: currentState.settings!.length,
        format: currentState.settings!.format,
      );

      final conversation = ConversationMessage(
        question: question,
        answer: answer,
        timestamp: DateTime.now(),
      );

      if (_currentUserId != null && currentState.summaryId != null) {
        await _firestoreService.addConversationToSummary(
          userId: _currentUserId!,
          summaryId: currentState.summaryId!,
          conversation: conversation,
        );
      }

      final updatedConversations = List<ConversationMessage>.from(
        currentState.conversations,
      )..add(conversation);

      emit(currentState.copyWith(conversations: updatedConversations));
    } catch (e) {
      emit(SummaryError('Failed to generate response: $e'));

      Future.delayed(const Duration(seconds: 3), () {
        if (state is SummaryError) {
          emit(currentState);
        }
      });
    }
  }
}
