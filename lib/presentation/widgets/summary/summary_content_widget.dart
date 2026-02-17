import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aivio/presentation/widgets/summary/json_summary_widget.dart';
import 'package:aivio/presentation/widgets/summary/text_summary_widget.dart';

class SummaryContentWidget extends StatelessWidget {
  final String content;

  const SummaryContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    try {
      final jsonContent = json.decode(content);
      if (jsonContent is Map<String, dynamic>) {
        return JsonSummaryWidget(data: jsonContent);
      }
    } catch (e) {
      // Not JSON, fall back to text parsing
    }

    return TextSummaryWidget(content: content);
  }
}
