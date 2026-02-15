import 'package:aivio/core/constant/color.dart';
import 'package:aivio/core/services/quiz_firestore_service.dart';
import 'package:aivio/core/services/summary_firestore_service.dart';
import 'package:aivio/core/services/assignment_firestore_service.dart';
import 'package:aivio/cubit/auth/auth_cubit.dart';
import 'package:aivio/cubit/profile/profile_cubit.dart';
import 'package:aivio/cubit/theme/theme_cubit.dart';
import 'package:aivio/data/model/saved_quiz.dart';
import 'package:aivio/data/model/saved_summary.dart';
import 'package:aivio/data/model/saved_assignment.dart';
import 'package:aivio/presentation/widgets/settings/logout_button.dart';
import 'package:aivio/presentation/widgets/settings/profile_section.dart';
import 'package:aivio/presentation/widgets/settings/profile_skeleton.dart';
import 'package:aivio/presentation/widgets/settings/stats_section.dart';
import 'package:aivio/presentation/widgets/settings/theme_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final QuizFirestoreService _firestoreService = QuizFirestoreService();
  final SummaryFirestoreService _summaryService = SummaryFirestoreService();
  final AssignmentFirestoreService _assignmentService =
      AssignmentFirestoreService();

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      context.read<ProfileCubit>().loadProfile(currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Appcolor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: currentUser == null
          ? const Center(child: Text('Please login to view settings'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 32),
                  _buildThemeSection(),
                  const SizedBox(height: 32),
                  _buildStatsSection(),
                  const SizedBox(height: 40),
                  SettingsLogoutButton(
                    onLogout: () {
                      context.read<AuthCubit>().signOut();
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const SettingsProfileSkeleton();
        } else if (state is ProfileLoaded) {
          return SettingsProfileSection(
            profile: state.profile,
            onPickImage: () => _pickImage(context),
            onEditName: () =>
                _showEditNameDialog(context, state.profile.username),
          );
        } else if (state is ProfileError) {
          return Text('Error: ${state.message}');
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildThemeSection() {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SettingsThemeSection(
          isDark: isDark,
          onThemeChanged: (value) {
            context.read<ThemeCubit>().updateTheme(
              value ? ThemeMode.dark : ThemeMode.light,
            );
          },
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return StreamBuilder<List<SavedQuiz>>(
      stream: _firestoreService.getUserQuizzes(currentUser!.uid),
      builder: (context, quizSnapshot) {
        return StreamBuilder<List<SavedSummary>>(
          stream: _summaryService.getUserSummaries(currentUser!.uid),
          builder: (context, summarySnapshot) {
            return StreamBuilder<List<SavedAssignment>>(
              stream: _assignmentService.getUserAssignments(currentUser!.uid),
              builder: (context, assignmentSnapshot) {
                if (quizSnapshot.hasData &&
                    summarySnapshot.hasData &&
                    assignmentSnapshot.hasData) {
                  final quizzes = quizSnapshot.data!;
                  final summaries = summarySnapshot.data!;
                  final assignments = assignmentSnapshot.data!;

                  return SettingsStatsSection(
                    quizzesCreated: quizzes.length,
                    quizzesAttempted: quizzes
                        .where((q) => q.timesCompleted > 0)
                        .length,
                    summariesCreated: summaries.length,
                    totalSummaryViews: summaries.fold<int>(
                      0,
                      (sum, summary) => sum + summary.timesViewed,
                    ),
                    assignmentsCreated: assignments.length,
                    totalAssignmentViews: assignments.fold<int>(
                      0,
                      (sum, assignment) => sum + assignment.timesViewed,
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      context.read<ProfileCubit>().updateProfileImage(
        currentUser!.uid,
        pickedFile,
      );
    }
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Update Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your new username below.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'e.g. John Doe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<ProfileCubit>().updateUsername(
                  currentUser!.uid,
                  controller.text,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Appcolor.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
