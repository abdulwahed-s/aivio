enum QuizDifficulty {
  easy('Easy', 'Simple questions with straightforward answers'),
  medium('Medium', 'Moderate difficulty with some complexity'),
  hard('Hard', 'Challenging questions requiring deep understanding');

  const QuizDifficulty(this.label, this.description);
  final String label;
  final String description;
}

enum QuestionTypeOption {
  mcq('Multiple Choice', 'All questions will be MCQ with 4 options'),
  essay('Essay Questions', 'All questions will be open-ended essay type'),
  mixed('Mixed', 'A combination of MCQ and essay questions');

  const QuestionTypeOption(this.label, this.description);
  final String label;
  final String description;
}

class QuizSettings {
  final QuizDifficulty difficulty;
  final int numberOfQuestions;
  final QuestionTypeOption questionType;

  const QuizSettings({
    this.difficulty = QuizDifficulty.medium,
    this.numberOfQuestions = 10,
    this.questionType = QuestionTypeOption.mcq,
  });

  QuizSettings copyWith({
    QuizDifficulty? difficulty,
    int? numberOfQuestions,
    QuestionTypeOption? questionType,
  }) {
    return QuizSettings(
      difficulty: difficulty ?? this.difficulty,
      numberOfQuestions: numberOfQuestions ?? this.numberOfQuestions,
      questionType: questionType ?? this.questionType,
    );
  }
}