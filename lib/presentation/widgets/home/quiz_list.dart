import 'package:aivio/core/constant/color.dart';
import 'package:aivio/core/services/quiz_firestore_service.dart';
import 'package:aivio/core/services/quiz_group_firestore_service.dart';
import 'package:aivio/cubit/quiz/quiz_cubit.dart';
import 'package:aivio/data/model/quiz_group.dart';
import 'package:aivio/data/model/saved_quiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'group_assignment_dialog.dart';
import 'group_creation_dialog.dart';
import 'group_section.dart';
import 'home_empty_state.dart';
import 'home_error_state.dart';
import 'quiz_card.dart';

class QuizList extends StatefulWidget {
  final String userId;
  final VoidCallback onFabPressed;

  const QuizList({super.key, required this.userId, required this.onFabPressed});

  @override
  State<QuizList> createState() => _QuizListState();
}

class _QuizListState extends State<QuizList> {
  final QuizFirestoreService _quizFirestoreService = QuizFirestoreService();
  final QuizGroupFirestoreService _quizGroupService =
      QuizGroupFirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QuizGroup>>(
      stream: _quizGroupService.getUserQuizGroups(widget.userId),
      builder: (context, groupSnapshot) {
        return StreamBuilder<List<SavedQuiz>>(
          stream: _quizFirestoreService.getUserQuizzes(widget.userId),
          builder: (context, quizSnapshot) {
            if (quizSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (quizSnapshot.hasError) {
              return HomeErrorState(message: quizSnapshot.error.toString());
            }

            final quizzes = quizSnapshot.data ?? [];
            final groups = groupSnapshot.data ?? [];

            if (quizzes.isEmpty && groups.isEmpty) {
              return HomeEmptyState(
                title: 'No Quizzes Yet',
                subtitle: 'Upload a material to generate your first quiz',
                icon: Icons.quiz,
                onAction: widget.onFabPressed,
              );
            }

            Map<String?, List<SavedQuiz>> quizzesByGroup = {};
            for (var quiz in quizzes) {
              if (!quizzesByGroup.containsKey(quiz.groupId)) {
                quizzesByGroup[quiz.groupId] = [];
              }
              quizzesByGroup[quiz.groupId]!.add(quiz);
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: OutlinedButton.icon(
                      onPressed: () => _createQuizGroup(context),
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: const Text('Create Quiz Group'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Appcolor.primaryColor,
                        side: BorderSide(color: Appcolor.primaryColor),
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
                    itemCount: (quizzesByGroup[group.id] ?? []).length,
                    isExpanded: true,
                    onRename: () => _renameQuizGroup(context, group),
                    onDelete: () => _deleteQuizGroup(context, group),
                    children: (quizzesByGroup[group.id] ?? [])
                        .map(
                          (quiz) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: QuizCard(
                              quiz: quiz,
                              onDelete: (q) => _showDeleteDialog(context, q),
                              onRename: (q) =>
                                  _showRenameQuizDialog(context, q),
                              onMoveToGroup: (q) =>
                                  _handleQuizGroupAssignment(context, q),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                if (quizzesByGroup[null]?.isNotEmpty ?? false)
                  GroupSection(
                    groupName: 'Ungrouped Quizzes',
                    groupColor: Colors.grey,
                    itemCount: quizzesByGroup[null]!.length,
                    isExpanded: true,
                    children: quizzesByGroup[null]!
                        .map(
                          (quiz) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: QuizCard(
                              quiz: quiz,
                              onDelete: (q) => _showDeleteDialog(context, q),
                              onRename: (q) =>
                                  _showRenameQuizDialog(context, q),
                              onMoveToGroup: (q) =>
                                  _handleQuizGroupAssignment(context, q),
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

  Future<void> _createQuizGroup(BuildContext context) async {
    final result = await showGroupCreationDialog(context, type: 'quiz');
    if (result != null && mounted) {
      try {
        await _quizGroupService.createGroup(
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
                  Text('Quiz group created'),
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

  Future<void> _handleQuizGroupAssignment(
    BuildContext context,
    SavedQuiz quiz,
  ) async {
    final groupsSnapshot = await _quizGroupService
        .getUserQuizGroups(widget.userId)
        .first;

    if (!context.mounted) return;
    final result = await showGroupAssignmentDialog(
      context,
      type: 'quiz',
      groups: groupsSnapshot,
      currentGroupId: quiz.groupId,
    );

    if (result != null && mounted) {
      try {
        if (result == 'REMOVE') {
          await _quizFirestoreService.removeQuizFromGroup(
            userId: widget.userId,
            quizId: quiz.id,
          );
        } else if (result == 'CREATE_NEW' && context.mounted) {
          await _createQuizGroup(context);
          if (context.mounted) {
            await _handleQuizGroupAssignment(context, quiz);
          }
        } else {
          await _quizFirestoreService.assignQuizToGroup(
            userId: widget.userId,
            quizId: quiz.id,
            groupId: result,
          );
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Quiz updated'),
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
          _showErrorSnackBar(context, 'Failed to update quiz');
        }
      }
    }
  }

  Future<void> _renameQuizGroup(BuildContext context, QuizGroup group) async {
    final result = await showGroupCreationDialog(
      context,
      type: 'quiz',
      initialName: group.name,
    );
    if (result != null && mounted) {
      try {
        await _quizGroupService.updateGroupName(
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

  Future<void> _deleteQuizGroup(BuildContext context, QuizGroup group) async {
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
        content: Text('Delete "${group.name}"? Quizzes will become ungrouped.'),
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
        await _quizGroupService.deleteGroup(
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

  void _showDeleteDialog(BuildContext context, SavedQuiz quiz) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Delete Quiz'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${quiz.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<QuizCubit>().deleteQuiz(quiz.id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Quiz deleted successfully'),
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

  void _showRenameQuizDialog(BuildContext context, SavedQuiz quiz) {
    final controller = TextEditingController(text: quiz.title);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_outlined, color: Colors.blue),
            SizedBox(width: 12),
            Text('Rename Quiz'),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Quiz Name',
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
                context.read<QuizCubit>().renameQuiz(quiz.id, controller.text);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Quiz renamed successfully'),
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
