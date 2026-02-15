import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';
import 'package:aivio/data/model/quiz_settings.dart';
import 'package:aivio/presentation/widgets/quiz/quiz_utils.dart';

class QuizProgressHeader extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final QuizDifficulty? difficulty;

  const QuizProgressHeader({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (currentIndex + 1) / totalQuestions;
    final difficultyColor = getDifficultyColor(difficulty);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${currentIndex + 1}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Appcolor.tertiaryColor,
                ),
              ),
              Text(
                '${currentIndex + 1}/$totalQuestions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(difficultyColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
