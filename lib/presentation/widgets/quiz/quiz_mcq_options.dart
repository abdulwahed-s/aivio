import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';
import 'package:aivio/data/model/quiz_settings.dart';
import 'package:aivio/presentation/widgets/quiz/quiz_utils.dart';

class QuizMCQOptions extends StatelessWidget {
  final List<String> options;
  final int? selectedAnswerIndex;
  final QuizDifficulty? difficulty;
  final ValueChanged<int> onOptionSelected;

  const QuizMCQOptions({
    super.key,
    required this.options,
    required this.selectedAnswerIndex,
    required this.difficulty,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final difficultyColor = getDifficultyColor(difficulty);

    return Column(
      children: List.generate(
        options.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOptionCard(
            context,
            options[index],
            index,
            selectedAnswerIndex == index,
            difficultyColor,
            () => onOptionSelected(index),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String option,
    int index,
    bool isSelected,
    Color difficultyColor,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final letters = ['A', 'B', 'C', 'D'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      difficultyColor.withValues(alpha: 0.1),
                      difficultyColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected
                ? null
                : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
            border: Border.all(
              color: isSelected
                  ? difficultyColor
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              width: isSelected ? 2.5 : 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? difficultyColor.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: isSelected ? 8 : 4,
                offset: Offset(0, isSelected ? 4 : 2),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            difficultyColor,
                            difficultyColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    letters[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? (isDark ? Colors.white : Appcolor.tertiaryColor)
                        : (isDark ? Colors.grey.shade300 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: difficultyColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
