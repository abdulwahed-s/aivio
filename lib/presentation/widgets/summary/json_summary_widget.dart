import 'package:flutter/material.dart';
import 'package:aivio/presentation/widgets/summary/bullet_points_summary_widget.dart';
import 'package:aivio/presentation/widgets/summary/paragraphs_summary_widget.dart';
import 'package:aivio/presentation/widgets/summary/key_topics_summary_widget.dart';
import 'package:aivio/presentation/widgets/summary/generic_json_summary_widget.dart';

class JsonSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const JsonSummaryWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final format = data['format'] as String?;

    switch (format) {
      case 'bulletPoints':
        return BulletPointsSummaryWidget(data: data);
      case 'paragraphs':
        return ParagraphsSummaryWidget(data: data);
      case 'keyTopics':
        return KeyTopicsSummaryWidget(data: data);
      default:
        return GenericJsonSummaryWidget(data: data);
    }
  }
}
