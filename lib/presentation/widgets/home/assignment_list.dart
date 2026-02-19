import 'package:aivio/core/services/assignment_firestore_service.dart';
import 'package:aivio/core/services/assignment_group_firestore_service.dart';
import 'package:aivio/cubit/assignment/assignment_cubit.dart';
import 'package:aivio/data/model/assignment_group.dart';
import 'package:aivio/data/model/saved_assignment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'group_assignment_dialog.dart';
import 'group_creation_dialog.dart';
import 'assignment_card.dart';
import 'group_section.dart';
import 'home_empty_state.dart';
import 'home_error_state.dart';

class AssignmentList extends StatefulWidget {
  final String userId;
  final VoidCallback onFabPressed;

  const AssignmentList({
    super.key,
    required this.userId,
    required this.onFabPressed,
  });

  @override
  State<AssignmentList> createState() => _AssignmentListState();
}

class _AssignmentListState extends State<AssignmentList> {
  final AssignmentFirestoreService _assignmentFirestoreService =
      AssignmentFirestoreService();
  final AssignmentGroupFirestoreService _assignmentGroupService =
      AssignmentGroupFirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AssignmentGroup>>(
      stream: _assignmentGroupService.getUserAssignmentGroups(widget.userId),
      builder: (context, groupSnapshot) {
        return StreamBuilder<List<SavedAssignment>>(
          stream: _assignmentFirestoreService.getUserAssignments(widget.userId),
          builder: (context, assignmentSnapshot) {
            if (assignmentSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (assignmentSnapshot.hasError) {
              return HomeErrorState(
                message: assignmentSnapshot.error.toString(),
              );
            }

            final assignments = assignmentSnapshot.data ?? [];
            final groups = groupSnapshot.data ?? [];

            if (assignments.isEmpty && groups.isEmpty) {
              return HomeEmptyState(
                title: 'No Assignment Help Yet',
                subtitle: 'Upload a material with an assignment to get help',
                icon: Icons.assignment,
                onAction: widget.onFabPressed,
              );
            }

            Map<String?, List<SavedAssignment>> assignmentsByGroup = {};
            for (var assignment in assignments) {
              if (!assignmentsByGroup.containsKey(assignment.groupId)) {
                assignmentsByGroup[assignment.groupId] = [];
              }
              assignmentsByGroup[assignment.groupId]!.add(assignment);
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: OutlinedButton.icon(
                      onPressed: () => _createAssignmentGroup(context),
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: const Text('Create Assignment Group'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF9800),
                        side: const BorderSide(color: Color(0xFFFF9800)),
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
                    itemCount: (assignmentsByGroup[group.id] ?? []).length,
                    isExpanded: true,
                    onRename: () => _renameAssignmentGroup(context, group),
                    onDelete: () => _deleteAssignmentGroup(context, group),
                    children: (assignmentsByGroup[group.id] ?? [])
                        .map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AssignmentCard(
                              assignment: a,
                              onDelete: (s) => _deleteAssignment(context, s),
                              onRename: (s) => _renameAssignment(context, s),
                              onMoveToGroup: (s) =>
                                  _handleAssignmentGroupAssignment(context, s),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                if (assignmentsByGroup[null]?.isNotEmpty ?? false)
                  GroupSection(
                    groupName: 'Ungrouped Assignments',
                    groupColor: Colors.grey,
                    itemCount: assignmentsByGroup[null]!.length,
                    isExpanded: true,
                    children: assignmentsByGroup[null]!
                        .map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AssignmentCard(
                              assignment: a,
                              onDelete: (s) => _deleteAssignment(context, s),
                              onRename: (s) => _renameAssignment(context, s),
                              onMoveToGroup: (s) =>
                                  _handleAssignmentGroupAssignment(context, s),
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

  Future<void> _createAssignmentGroup(BuildContext context) async {
    final result = await showGroupCreationDialog(context, type: 'assignment');
    if (result != null && mounted) {
      try {
        await _assignmentGroupService.createAssignmentGroup(
          userId: widget.userId,
          groupName: result['name'],
          color: result['color'],
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Assignment group created'),
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

  Future<void> _handleAssignmentGroupAssignment(
    BuildContext context,
    SavedAssignment assignment,
  ) async {
    final groupsSnapshot = await _assignmentGroupService
        .getUserAssignmentGroups(widget.userId)
        .first;
    if (!context.mounted) return;
    final result = await showGroupAssignmentDialog(
      context,
      type: 'assignment',
      groups: groupsSnapshot,
      currentGroupId: assignment.groupId,
    );
    if (result != null && mounted) {
      try {
        if (result == 'REMOVE') {
          await _assignmentFirestoreService.updateAssignmentGroup(
            userId: widget.userId,
            assignmentId: assignment.id,
            groupId: null,
          );
        } else if (result == 'CREATE_NEW' && context.mounted) {
          await _createAssignmentGroup(context);
          if (context.mounted) {
            await _handleAssignmentGroupAssignment(context, assignment);
          }
        } else {
          await _assignmentFirestoreService.updateAssignmentGroup(
            userId: widget.userId,
            assignmentId: assignment.id,
            groupId: result,
          );
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Assignment updated'),
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
          _showErrorSnackBar(context, 'Failed to update assignment');
        }
      }
    }
  }

  Future<void> _renameAssignmentGroup(
    BuildContext context,
    AssignmentGroup group,
  ) async {
    final result = await showGroupCreationDialog(
      context,
      type: 'assignment',
      initialName: group.name,
    );
    if (result != null && mounted) {
      try {
        await _assignmentGroupService.renameAssignmentGroup(
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

  Future<void> _deleteAssignmentGroup(
    BuildContext context,
    AssignmentGroup group,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Delete Group?'),
          ],
        ),
        content: const Text(
          'This will not delete the assignments, they will be moved to ungrouped.',
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
        await _assignmentGroupService.deleteAssignmentGroup(
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

  Future<void> _renameAssignment(
    BuildContext context,
    SavedAssignment assignment,
  ) async {
    final cubit = context.read<AssignmentCubit>();
    final controller = TextEditingController(text: assignment.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rename Assignment'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && mounted) {
      try {
        await cubit.renameAssignment(assignment.id, result);
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Failed to rename assignment');
        }
      }
    }
  }

  Future<void> _deleteAssignment(
    BuildContext context,
    SavedAssignment assignment,
  ) async {
    final cubit = context.read<AssignmentCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Assignment?'),
          ],
        ),
        content: const Text('This action cannot be undone.'),
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
        await cubit.deleteAssignment(assignment.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Assignment deleted'),
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
          _showErrorSnackBar(context, 'Failed to delete assignment');
        }
      }
    }
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
