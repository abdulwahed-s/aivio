import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class EmptyQAStateWidget extends StatelessWidget {
  const EmptyQAStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Appcolor.primaryColor.withValues(alpha: 0.1),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 48,
            color: Appcolor.primaryColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Ask me anything about this summary!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Type your question below to get more details, clarifications, or explore specific topics further.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
