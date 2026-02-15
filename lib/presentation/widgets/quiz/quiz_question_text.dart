import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class QuizQuestionText extends StatelessWidget {
  final String questionText;

  const QuizQuestionText({super.key, required this.questionText});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        questionText,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Appcolor.tertiaryColor,
          height: 1.4,
        ),
      ),
    );
  }
}
