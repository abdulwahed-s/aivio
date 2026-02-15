import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class QuizNavigationButtons extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final bool hasAnswer;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const QuizNavigationButtons({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.hasAnswer,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastQuestion = currentQuestionIndex == totalQuestions - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentQuestionIndex > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.arrow_back, size: 20),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Appcolor.primaryColor, width: 2),
                    foregroundColor: Appcolor.primaryColor,
                  ),
                ),
              ),
            if (currentQuestionIndex > 0) const SizedBox(width: 12),
            Expanded(
              flex: currentQuestionIndex > 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: hasAnswer ? onNext : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Appcolor.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  elevation: hasAnswer ? 4 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastQuestion ? 'Submit Quiz' : 'Next Question',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isLastQuestion ? Icons.check_circle : Icons.arrow_forward,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
