import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class QuizQuestionTypeChip extends StatelessWidget {
  final bool isMCQ;

  const QuizQuestionTypeChip({super.key, required this.isMCQ});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMCQ
              ? [
                  Appcolor.primaryColor.withValues(alpha: 0.1),
                  Appcolor.primaryColor.withValues(alpha: 0.2),
                ]
              : [Colors.purple.shade100, Colors.purple.shade200],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMCQ
              ? Appcolor.primaryColor.withValues(alpha: 0.3)
              : Colors.purple.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMCQ ? Icons.check_circle_outline : Icons.edit_outlined,
            size: 18,
            color: isMCQ ? Appcolor.primaryColor : Colors.purple.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            isMCQ ? 'Multiple Choice' : 'Essay Question',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isMCQ ? Appcolor.primaryColor : Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
