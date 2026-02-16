import 'package:flutter/material.dart';

class QuizResultSummary extends StatelessWidget {
  final int percentage;

  const QuizResultSummary({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: percentage >= 70
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (percentage >= 70 ? Colors.green : Colors.orange).withValues(
              alpha: 0.3,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            percentage >= 70 ? Icons.emoji_events : Icons.military_tech,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Quiz Completed!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            percentage >= 70 ? 'Great job!' : 'Keep practicing!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
