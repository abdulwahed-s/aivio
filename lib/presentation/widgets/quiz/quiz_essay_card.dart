import 'package:flutter/material.dart';

class QuizEssayCard extends StatelessWidget {
  final int essayCount;

  const QuizEssayCard({super.key, required this.essayCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.purple.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit_note, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$essayCount Essay Question${essayCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review answers below',
                  style: TextStyle(fontSize: 13, color: Colors.purple.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
