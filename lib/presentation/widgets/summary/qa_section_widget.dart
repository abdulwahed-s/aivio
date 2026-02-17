import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';
import 'package:aivio/data/model/conversation_message.dart';
import 'package:aivio/presentation/widgets/summary/conversation_bubble_widget.dart';
import 'package:aivio/presentation/widgets/summary/empty_qa_state_widget.dart';

class QASectionWidget extends StatelessWidget {
  final List<ConversationMessage> conversations;

  const QASectionWidget({super.key, required this.conversations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Appcolor.primaryColor.withValues(alpha: 0.15),
                Appcolor.primaryColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Appcolor.primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: Appcolor.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ask Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Appcolor.primaryColor,
                  ),
                ),
              ),
              if (conversations.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Appcolor.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${conversations.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (conversations.isEmpty)
          Center(child: const EmptyQAStateWidget())
        else
          ...conversations.map((conversation) {
            return ConversationBubbleWidget(conversation: conversation);
          }),
      ],
    );
  }
}
