import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aivio/core/constant/color.dart';
import 'package:aivio/cubit/quiz/quiz_cubit.dart';
import 'package:aivio/presentation/widgets/quiz/quiz_progress_header.dart';
import 'package:aivio/presentation/widgets/quiz/quiz_question_type_chip.dart';
import 'package:aivio/presentation/widgets/quiz/quiz_question_text.dart';
import 'package:aivio/presentation/widgets/quiz/quiz_mcq_options.dart';
import 'package:aivio/presentation/widgets/quiz/quiz_essay_input.dart';
import 'package:aivio/presentation/widgets/quiz/quiz_navigation_buttons.dart';
import 'package:aivio/presentation/widgets/quiz/quiz_result_summary.dart';
import 'package:aivio/presentation/widgets/quiz/quiz_score_card.dart';
import 'package:aivio/presentation/widgets/quiz/quiz_essay_card.dart';
import 'package:aivio/presentation/widgets/quiz/quiz_review_card.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  late TextEditingController _essayController;
  late AnimationController _slideController;
  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    _essayController = TextEditingController();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _essayController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        final shouldPop = await _showExitDialog(context);
        if (shouldPop == true && context.mounted) {
          setState(() {
            _canPop = true;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pop('custom_result');
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'Quiz',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          backgroundColor: isDark
              ? const Color(0xFF1E1E1E)
              : Appcolor.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<QuizCubit, QuizState>(
          builder: (context, state) {
            if (state is QuizLoaded) {
              if (state.isCompleted) {
                return _buildResultScreen(context, state);
              }
              return _buildQuizContent(context, state);
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Appcolor.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Loading quiz...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, QuizLoaded state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentAnswer =
          state.userEssayAnswers[state.currentQuestionIndex] ?? '';
      if (_essayController.text != currentAnswer) {
        _essayController.text = currentAnswer;
        _essayController.selection = TextSelection.fromPosition(
          TextPosition(offset: _essayController.text.length),
        );
      }
    });

    return Column(
      children: [
        QuizProgressHeader(
          currentIndex: state.currentQuestionIndex,
          totalQuestions: state.questions.length,
          difficulty: state.difficulty,
        ),
        Expanded(child: _buildQuestionCard(context, state)),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _essayController,
          builder: (context, value, child) {
            final currentQuestion = state.questions[state.currentQuestionIndex];
            final hasAnswer = currentQuestion.isMCQ
                ? state.userMCQAnswers[state.currentQuestionIndex] != null
                : _essayController.text.trim().isNotEmpty;

            return QuizNavigationButtons(
              currentQuestionIndex: state.currentQuestionIndex,
              totalQuestions: state.questions.length,
              hasAnswer: hasAnswer,
              onPrevious: () {
                _saveEssayAnswer(state);
                context.read<QuizCubit>().previousQuestion();
              },
              onNext: () {
                _saveEssayAnswer(state);
                if (state.currentQuestionIndex < state.questions.length - 1) {
                  context.read<QuizCubit>().nextQuestion();
                } else {
                  context.read<QuizCubit>().submitQuiz();
                }
              },
            );
          },
        ),
      ],
    );
  }

  void _saveEssayAnswer(QuizLoaded state) {
    if (!state.questions[state.currentQuestionIndex].isMCQ) {
      context.read<QuizCubit>().answerEssayQuestion(_essayController.text);
    }
  }

  Widget _buildQuestionCard(BuildContext context, QuizLoaded state) {
    final question = state.questions[state.currentQuestionIndex];

    return SingleChildScrollView(
      key: ValueKey(state.currentQuestionIndex),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuizQuestionTypeChip(isMCQ: question.isMCQ),
          const SizedBox(height: 20),
          QuizQuestionText(questionText: question.question),
          const SizedBox(height: 24),
          if (question.isMCQ)
            QuizMCQOptions(
              options: question.options!,
              selectedAnswerIndex:
                  state.userMCQAnswers[state.currentQuestionIndex],
              difficulty: state.difficulty,
              onOptionSelected: (index) {
                context.read<QuizCubit>().answerMCQQuestion(index);
              },
            )
          else
            QuizEssayInput(controller: _essayController),
        ],
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, QuizLoaded state) {
    final mcqScore = state.score;
    final mcqTotal = state.mcqCount;
    final essayCount = state.essayCount;
    final percentage = mcqTotal > 0 ? (mcqScore / mcqTotal * 100).round() : 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          QuizResultSummary(percentage: percentage),
          if (mcqTotal > 0) ...[
            const SizedBox(height: 24),
            QuizScoreCard(
              score: mcqScore,
              total: mcqTotal,
              percentage: percentage,
            ),
          ],
          if (essayCount > 0) ...[
            const SizedBox(height: 16),
            QuizEssayCard(essayCount: essayCount),
          ],
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Appcolor.tertiaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Review Answers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(state.questions.length, (index) {
            final question = state.questions[index];
            final userAnswer = question.isMCQ
                ? state.userMCQAnswers[index]
                : state.userEssayAnswers[index];
            return QuizReviewCard(
              question: question,
              userAnswer: userAnswer,
              index: index,
            );
          }),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _canPop = true;
                });
                context.read<QuizCubit>().resetQuiz();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                });
              },
              icon: const Icon(Icons.refresh, size: 22),
              label: const Text(
                'Start New Quiz',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Appcolor.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600),
            const SizedBox(width: 12),
            const Text('Exit Quiz?'),
          ],
        ),
        content: const Text(
          'Your progress will be lost if you exit now. Are you sure you want to leave?',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<QuizCubit>().resetQuiz();
              Navigator.pop(dialogContext, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
