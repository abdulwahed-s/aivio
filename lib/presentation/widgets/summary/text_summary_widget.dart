import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class TextSummaryWidget extends StatelessWidget {
  final String content;

  const TextSummaryWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(3),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Appcolor.primaryColor,
              ),
            ),
          ),
        );
      } else if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            child: Text(
              line.substring(2),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
        );
      } else if (line.startsWith('• ') || line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Appcolor.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
