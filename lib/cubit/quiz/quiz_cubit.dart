import 'package:aivio/core/constant/api_keys.dart';
import 'package:aivio/core/services/gemini_service.dart';
import 'package:aivio/core/services/document_services.dart';
import 'package:aivio/core/services/quiz_firestore_service.dart';
import 'package:aivio/data/model/question.dart';
import 'package:aivio/data/model/quiz_settings.dart';
import 'package:aivio/data/model/saved_quiz.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  String? _currentUserId;

  QuizCubit() : super(QuizInitial());

  final DocumentService _pdfService = DocumentService();
  final GeminiService _geminiService = GeminiService(ApiKeys.geminiApiKey);
  final QuizFirestoreService _firestoreService = QuizFirestoreService();

  void setUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> pickAndProcessPdf({
    QuizSettings? settings,
    bool saveToFirestore = true,
  }) async {
    try {
      final quizSettings = settings ?? const QuizSettings();

      emit(const QuizLoading(message: 'Selecting PDF...'));

      final pdfFile = await _pdfService.pickDocumentFile();
      if (pdfFile == null) {
        emit(QuizInitial());
        return;
      }

      emit(const QuizLoading(message: 'Extracting text from PDF...'));
      final pdfText = await _pdfService.extractTextFromDocument(pdfFile);

      emit(const QuizLoading(message: 'Generating questions with AI...'));
      final questions = await _geminiService.generateQuestions(
        pdfText,
        numberOfQuestions: quizSettings.numberOfQuestions,
        difficulty: quizSettings.difficulty,
        questionType: quizSettings.questionType,
      );

      if (questions.isEmpty) {
        emit(const QuizError('No questions were generated. Please try again.'));
        return;
      }

      String? quizId;
      if (saveToFirestore && _currentUserId != null) {
        emit(const QuizLoading(message: 'Saving quiz...'));
        final fileName = pdfFile.name.replaceAll('.pdf', '');
        quizId = await _firestoreService.saveQuiz(
          userId: _currentUserId!,
          title: fileName,
          questions: questions,
          difficulty: quizSettings.difficulty,
        );
      }

      emit(
        QuizLoaded(
          questions: questions,
          userMCQAnswers: List.filled(questions.length, null),
          userEssayAnswers: List.filled(questions.length, null),
          quizId: quizId,
          quizTitle: quizId != null
              ? pdfFile.name.replaceAll('.pdf', '')
              : null,
          difficulty: quizSettings.difficulty,
        ),
      );
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> loadSavedQuiz(SavedQuiz savedQuiz) async {
    try {
      emit(const QuizLoading(message: 'Loading quiz...'));

      emit(
        QuizLoaded(
          questions: savedQuiz.questions,
          userMCQAnswers: List.filled(savedQuiz.questions.length, null),
          userEssayAnswers: List.filled(savedQuiz.questions.length, null),
          quizId: savedQuiz.id,
          quizTitle: savedQuiz.title,
          difficulty: savedQuiz.difficulty,
        ),
      );
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  void answerMCQQuestion(int answerIndex) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final newAnswers = List<int?>.from(currentState.userMCQAnswers);
      newAnswers[currentState.currentQuestionIndex] = answerIndex;

      emit(currentState.copyWith(userMCQAnswers: newAnswers));
    }
  }

  void answerEssayQuestion(String answer) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final newAnswers = List<String?>.from(currentState.userEssayAnswers);
      newAnswers[currentState.currentQuestionIndex] = answer;

      emit(currentState.copyWith(userEssayAnswers: newAnswers));
    }
  }

  void nextQuestion() {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      if (currentState.currentQuestionIndex <
          currentState.questions.length - 1) {
        emit(
          currentState.copyWith(
            currentQuestionIndex: currentState.currentQuestionIndex + 1,
          ),
        );
      }
    }
  }

  void previousQuestion() {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      if (currentState.currentQuestionIndex > 0) {
        emit(
          currentState.copyWith(
            currentQuestionIndex: currentState.currentQuestionIndex - 1,
          ),
        );
      }
    }
  }

  Future<void> submitQuiz() async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;

      if (currentState.quizId != null && _currentUserId != null) {
        try {
          await _firestoreService.updateQuizScore(
            userId: _currentUserId!,
            quizId: currentState.quizId!,
            score: currentState.score,
          );
        } catch (e) {
          if (kDebugMode) {
            print('Failed to update score: $e');
          }
        }
      }

      emit(currentState.copyWith(isCompleted: true));
    }
  }

  void resetQuiz() {
    emit(QuizInitial());
  }

  Future<void> deleteQuiz(String quizId) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.deleteQuiz(
        userId: _currentUserId!,
        quizId: quizId,
      );
    } catch (e) {
      emit(QuizError('Failed to delete quiz: $e'));
    }
  }

  Future<void> renameQuiz(String quizId, String newTitle) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.updateQuizTitle(
        userId: _currentUserId!,
        quizId: quizId,
        newTitle: newTitle,
      );
    } catch (e) {
      emit(QuizError('Failed to rename quiz: $e'));
    }
  }
}
