import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';
import 'package:aivio/data/model/question.dart';

class QuizReviewCard extends StatelessWidget {
  final Question question;
  final dynamic userAnswer;
  final int index;

  const QuizReviewCard({
    super.key,
    required this.question,
    required this.userAnswer,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    if (question.isMCQ) {
      return _MCQReviewCard(
        question: question,
        userAnswer: userAnswer as int?,
        index: index,
      );
    } else {
      return _EssayReviewCard(
        question: question,
        userAnswer: userAnswer as String? ?? 'No answer provided',
        index: index,
      );
    }
  }
}

class _MCQReviewCard extends StatelessWidget {
  final Question question;
  final int? userAnswer;
  final int index;

  const _MCQReviewCard({
    required this.question,
    required this.userAnswer,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCorrect = userAnswer == question.correctAnswerIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? (isDark ? Colors.green.shade900 : Colors.green.shade200)
              : (isDark ? Colors.red.shade900 : Colors.red.shade200),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? (isDark
                              ? Colors.green.shade900
                              : Colors.green.shade50)
                        : (isDark ? Colors.red.shade900 : Colors.red.shade50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect
                        ? (isDark
                              ? Colors.green.shade300
                              : Colors.green.shade600)
                        : (isDark ? Colors.red.shade300 : Colors.red.shade600),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Appcolor.tertiaryColor,
                        ),
                      ),
                      Text(
                        'Multiple Choice',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.question,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            if (userAnswer != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? (isDark ? Colors.green.shade900 : Colors.green.shade50)
                      : (isDark ? Colors.red.shade900 : Colors.red.shade50),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect
                        ? (isDark
                              ? Colors.green.shade700
                              : Colors.green.shade200)
                        : (isDark ? Colors.red.shade700 : Colors.red.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check : Icons.close,
                      color: isCorrect
                          ? (isDark
                                ? Colors.green.shade300
                                : Colors.green.shade700)
                          : (isDark
                                ? Colors.red.shade300
                                : Colors.red.shade700),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your answer: ${question.options![userAnswer!]}',
                        style: TextStyle(
                          color: isCorrect
                              ? (isDark
                                    ? Colors.green.shade100
                                    : Colors.green.shade900)
                              : (isDark
                                    ? Colors.red.shade100
                                    : Colors.red.shade900),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.green.shade900 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.green.shade700 : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: isDark
                        ? Colors.green.shade300
                        : Colors.green.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Correct answer: ${question.options![question.correctAnswerIndex!]}',
                      style: TextStyle(
                        color: isDark
                            ? Colors.green.shade100
                            : Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (question.explanation != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Appcolor.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Appcolor.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Appcolor.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Explanation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Appcolor.primaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Appcolor.tertiaryColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EssayReviewCard extends StatelessWidget {
  final Question question;
  final String userAnswer;
  final int index;

  const _EssayReviewCard({
    required this.question,
    required this.userAnswer,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.purple.shade900 : Colors.purple.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.purple.shade900
                        : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_note,
                    color: isDark
                        ? Colors.purple.shade300
                        : Colors.purple.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Appcolor.tertiaryColor,
                        ),
                      ),
                      Text(
                        'Essay Question',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.question,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.4,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Your Answer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userAnswer,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            if (question.sampleAnswer != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? Colors.green.shade900 : Colors.green.shade50,
                      isDark
                          ? Colors.green.shade800
                          : Colors.green.shade100.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.green.shade700
                        : Colors.green.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sample Answer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.green.shade300
                                : Colors.green.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.sampleAnswer!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.green.shade100
                            : Colors.green.shade900,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
