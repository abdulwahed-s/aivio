import 'package:aivio/core/services/summary_firestore_service.dart';
import 'package:aivio/core/services/summary_group_firestore_service.dart';
import 'package:aivio/cubit/summary/summary_cubit.dart';
import 'package:aivio/data/model/saved_summary.dart';
import 'package:aivio/data/model/summary_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'group_assignment_dialog.dart';
import 'group_creation_dialog.dart';
import 'group_section.dart';
import 'home_empty_state.dart';
import 'home_error_state.dart';
import 'summary_card.dart';

class SummaryList extends StatefulWidget {
  final String userId;
  final VoidCallback onFabPressed;

  const SummaryList({
    super.key,
    required this.userId,
    required this.onFabPressed,
  });

  @override
  State<SummaryList> createState() => _SummaryListState();
}

class _SummaryListState extends State<SummaryList> {
  final SummaryFirestoreService _summaryFirestoreService =
      SummaryFirestoreService();
  final SummaryGroupFirestoreService _summaryGroupService =
      SummaryGroupFirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SummaryGroup>>(
      stream: _summaryGroupService.getUserSummaryGroups(widget.userId),
      builder: (context, groupSnapshot) {
        return StreamBuilder<List<SavedSummary>>(
          stream: _summaryFirestoreService.getUserSummaries(widget.userId),
          builder: (context, summarySnapshot) {
            if (summarySnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (summarySnapshot.hasError) {
              return HomeErrorState(message: summarySnapshot.error.toString());
            }

            final summaries = summarySnapshot.data ?? [];
            final groups = groupSnapshot.data ?? [];

            if (summaries.isEmpty && groups.isEmpty) {
              return HomeEmptyState(
                title: 'No Summaries Yet',
                subtitle: 'Upload a material to generate a lecture summary',
                icon: Icons.book,
                onAction: widget.onFabPressed,
              );
            }

            Map<String?, List<SavedSummary>> summariesByGroup = {};
            for (var summary in summaries) {
              if (!summariesByGroup.containsKey(summary.groupId)) {
                summariesByGroup[summary.groupId] = [];
              }
              summariesByGroup[summary.groupId]!.add(summary);
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: OutlinedButton.icon(
                      onPressed: () => _createSummaryGroup(context),
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: const Text('Create Summary Group'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff008080),
                        side: const BorderSide(color: Color(0xff008080)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                for (var group in groups)
                  GroupSection(
                    groupName: group.name,
                    groupColor: Color(group.color),
                    itemCount: (summariesByGroup[group.id] ?? []).length,
                    isExpanded: true,
                    onRename: () => _renameSummaryGroup(context, group),
                    onDelete: () => _deleteSummaryGroup(context, group),
                    children: (summariesByGroup[group.id] ?? [])
                        .map(
                          (summary) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SummaryCard(
                              summary: summary,
                              onDelete: (s) =>
                                  _showSummaryDeleteDialog(context, s),
                              onRename: (s) =>
                                  _showRenameSummaryDialog(context, s),
                              onMoveToGroup: (s) =>
                                  _handleSummaryGroupAssignment(context, s),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                if (summariesByGroup[null]?.isNotEmpty ?? false)
                  GroupSection(
                    groupName: 'Ungrouped Summaries',
                    groupColor: Colors.grey,
                    itemCount: summariesByGroup[null]!.length,
                    isExpanded: true,
                    children: summariesByGroup[null]!
                        .map(
                          (summary) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SummaryCard(
                              summary: summary,
                              onDelete: (s) =>
                                  _showSummaryDeleteDialog(context, s),
                              onRename: (s) =>
                                  _showRenameSummaryDialog(context, s),
                              onMoveToGroup: (s) =>
                                  _handleSummaryGroupAssignment(context, s),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createSummaryGroup(BuildContext context) async {
    final result = await showGroupCreationDialog(context, type: 'summary');
    if (result != null && mounted) {
      try {
        await _summaryGroupService.createGroup(
          userId: widget.userId,
          name: result['name'],
          color: result['color'],
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Summary group created'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Failed to create group');
        }
      }
    }
  }

  Future<void> _handleSummaryGroupAssignment(
    BuildContext context,
    SavedSummary summary,
  ) async {
    final groupsSnapshot = await _summaryGroupService
        .getUserSummaryGroups(widget.userId)
        .first;

    if (!context.mounted) return;
    final result = await showGroupAssignmentDialog(
      context,
      type: 'summary',
      groups: groupsSnapshot,
      currentGroupId: summary.groupId,
    );

    if (result != null && mounted) {
      try {
        if (result == 'REMOVE') {
          await _summaryFirestoreService.removeSummaryFromGroup(
            userId: widget.userId,
            summaryId: summary.id,
          );
        } else if (result == 'CREATE_NEW' && context.mounted) {
          await _createSummaryGroup(context);
          if (context.mounted) {
            await _handleSummaryGroupAssignment(context, summary);
          }
        } else {
          await _summaryFirestoreService.assignSummaryToGroup(
            userId: widget.userId,
            summaryId: summary.id,
            groupId: result,
          );
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Summary updated'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Failed to update summary');
        }
      }
    }
  }

  Future<void> _renameSummaryGroup(
    BuildContext context,
    SummaryGroup group,
  ) async {
    final result = await showGroupCreationDialog(
      context,
      type: 'summary',
      initialName: group.name,
    );
    if (result != null && mounted) {
      try {
        await _summaryGroupService.updateGroupName(
          userId: widget.userId,
          groupId: group.id,
          newName: result['name'],
        );
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Failed to rename group');
        }
      }
    }
  }

  Future<void> _deleteSummaryGroup(
    BuildContext context,
    SummaryGroup group,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Delete Group'),
          ],
        ),
        content: Text(
          'Delete "${group.name}"? Summaries will become ungrouped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _summaryGroupService.deleteGroup(
          userId: widget.userId,
          groupId: group.id,
        );
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Failed to delete group');
        }
      }
    }
  }

  void _showSummaryDeleteDialog(BuildContext context, SavedSummary summary) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Delete Summary'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${summary.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SummaryCubit>().deleteSummary(summary.id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Summary deleted successfully'),
                    ],
                  ),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRenameSummaryDialog(BuildContext context, SavedSummary summary) {
    final controller = TextEditingController(text: summary.title);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_outlined, color: Colors.blue),
            SizedBox(width: 12),
            Text('Rename Summary'),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Summary Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<SummaryCubit>().renameSummary(
                  summary.id,
                  controller.text,
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Summary renamed successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
