part of 'quiz_cubit.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {
  final String message;

  const QuizLoading({this.message = 'Processing...'});

  @override
  List<Object?> get props => [message];
}

class QuizLoaded extends QuizState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final List<int?> userMCQAnswers;
  final List<String?> userEssayAnswers;
  final bool isCompleted;
  final String? quizId;
  final String? quizTitle;
  final QuizDifficulty? difficulty;

  const QuizLoaded({
    required this.questions,
    this.currentQuestionIndex = 0,
    required this.userMCQAnswers,
    required this.userEssayAnswers,
    this.isCompleted = false,
    this.quizId,
    this.quizTitle,
    this.difficulty,
  });

  QuizLoaded copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    List<int?>? userMCQAnswers,
    List<String?>? userEssayAnswers,
    bool? isCompleted,
    String? quizId,
    String? quizTitle,
    QuizDifficulty? difficulty,
  }) {
    return QuizLoaded(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userMCQAnswers: userMCQAnswers ?? this.userMCQAnswers,
      userEssayAnswers: userEssayAnswers ?? this.userEssayAnswers,
      isCompleted: isCompleted ?? this.isCompleted,
      quizId: quizId ?? this.quizId,
      quizTitle: quizTitle ?? this.quizTitle,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  int get score {
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].isMCQ &&
          userMCQAnswers[i] == questions[i].correctAnswerIndex) {
        correct++;
      }
    }
    return correct;
  }

  int get mcqCount => questions.where((q) => q.isMCQ).length;
  int get essayCount => questions.where((q) => q.isEssay).length;

  @override
  List<Object?> get props => [
    questions,
    currentQuestionIndex,
    userMCQAnswers,
    userEssayAnswers,
    isCompleted,
    quizId,
    quizTitle,
    difficulty,
  ];
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}
