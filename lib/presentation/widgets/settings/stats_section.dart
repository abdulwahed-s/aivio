import 'package:aivio/presentation/widgets/settings/stat_card.dart';
import 'package:flutter/material.dart';

class SettingsStatsSection extends StatelessWidget {
  final int quizzesCreated;
  final int quizzesAttempted;
  final int summariesCreated;
  final int totalSummaryViews;
  final int assignmentsCreated;
  final int totalAssignmentViews;

  const SettingsStatsSection({
    super.key,
    required this.quizzesCreated,
    required this.quizzesAttempted,
    required this.summariesCreated,
    required this.totalSummaryViews,
    required this.assignmentsCreated,
    required this.totalAssignmentViews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Quizzes Created',
                    value: quizzesCreated.toString(),
                    icon: Icons.quiz_outlined,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    label: 'Quizzes Attempted',
                    value: quizzesAttempted.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Summaries Created',
                    value: summariesCreated.toString(),
                    icon: Icons.summarize_outlined,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    label: 'Total Summary Views',
                    value: totalSummaryViews.toString(),
                    icon: Icons.visibility_outlined,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Assignments Created',
                    value: assignmentsCreated.toString(),
                    icon: Icons.assignment_outlined,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    label: 'Total Assignment Views',
                    value: totalAssignmentViews.toString(),
                    icon: Icons.visibility_outlined,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
