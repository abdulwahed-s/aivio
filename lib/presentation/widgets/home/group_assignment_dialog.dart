import 'package:aivio/data/model/quiz_group.dart';
import 'package:aivio/data/model/summary_group.dart';
import 'package:aivio/data/model/assignment_group.dart';
import 'package:flutter/material.dart';

Future<String?> showGroupAssignmentDialog(
  BuildContext context, {
  required String type,
  required List<dynamic> groups,
  String? currentGroupId,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _GroupAssignmentDialog(
      type: type,
      groups: groups,
      currentGroupId: currentGroupId,
    ),
  );
}

class _GroupAssignmentDialog extends StatelessWidget {
  final String type;
  final List<dynamic> groups;
  final String? currentGroupId;

  const _GroupAssignmentDialog({
    required this.type,
    required this.groups,
    this.currentGroupId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.folder_outlined, color: Colors.blue),
          const SizedBox(width: 12),
          Text('Move to Group'),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentGroupId != null)
              _GroupOption(
                name: 'No Group',
                subtitle: 'Remove from current group',
                color: Colors.grey.shade400,
                isSelected: false,
                icon: Icons.remove_circle_outline,
                onTap: () => Navigator.pop(context, 'REMOVE'),
              ),

            if (currentGroupId != null && groups.isNotEmpty)
              const Divider(height: 1),

            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_off_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No groups yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    late final String id;
                    late final String name;
                    late final int color;
                    late final int count;

                    if (type == 'quiz') {
                      final quizGroup = group as QuizGroup;
                      id = quizGroup.id;
                      name = quizGroup.name;
                      color = quizGroup.color;
                      count = quizGroup.quizCount;
                    } else if (type == 'summary') {
                      final summaryGroup = group as SummaryGroup;
                      id = summaryGroup.id;
                      name = summaryGroup.name;
                      color = summaryGroup.color;
                      count = summaryGroup.summaryCount;
                    } else {
                      final assignmentGroup = group as AssignmentGroup;
                      id = assignmentGroup.id;
                      name = assignmentGroup.name;
                      color = assignmentGroup.color;
                      count = 0;
                    }

                    final isSelected = id == currentGroupId;

                    return _GroupOption(
                      name: name,
                      subtitle: type == 'assignment'
                          ? 'Assignment group'
                          : '$count ${type == 'quiz' ? 'quizzes' : 'summaries'}',
                      color: Color(color),
                      isSelected: isSelected,
                      onTap: isSelected
                          ? null
                          : () => Navigator.pop(context, id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'CREATE_NEW'),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 4),
              Text('Create New Group'),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupOption extends StatelessWidget {
  final String name;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const _GroupOption({
    required this.name,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon ?? Icons.folder, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
