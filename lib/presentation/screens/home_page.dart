import 'package:aivio/core/routes/app_route.dart';
import 'package:aivio/cubit/assignment/assignment_cubit.dart';
import 'package:aivio/cubit/quiz/quiz_cubit.dart';
import 'package:aivio/cubit/summary/summary_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/home/assignment_list.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/home_fab.dart';
import '../widgets/home/home_loading_state.dart';
import '../widgets/home/home_login_state.dart';
import '../widgets/home/quiz_list.dart';
import '../widgets/home/summary_list.dart';
import '../widgets/home/quiz_settings_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _tabController = TabController(length: 3, vsync: this);
    _fabController.forward(); // Start the animation
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<QuizCubit>().setUserId(userId);
      context.read<SummaryCubit>().setUserId(userId);
      context.read<AssignmentCubit>().setUserId(userId);
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HomeAppBar(tabController: _tabController),
      body: MultiBlocListener(
        listeners: [
          BlocListener<QuizCubit, QuizState>(
            listener: (context, state) {
              if (state is QuizLoaded) {
                if (ModalRoute.of(context)?.isCurrent == true) {
                  Navigator.pushNamed(context, AppRoute.quizPage);
                }
              } else if (state is QuizError) {
                _showErrorSnackBar(context, state.message);
              }
            },
          ),
          BlocListener<SummaryCubit, SummaryState>(
            listener: (context, state) {
              if (state is SummaryLoaded) {
                if (ModalRoute.of(context)?.isCurrent == true) {
                  Navigator.pushNamed(context, AppRoute.summaryPage);
                }
              } else if (state is SummaryError) {
                _showErrorSnackBar(context, state.message);
              }
            },
          ),
          BlocListener<AssignmentCubit, AssignmentState>(
            listener: (context, state) {
              if (state is AssignmentLoaded) {
                if (ModalRoute.of(context)?.isCurrent == true) {
                  Navigator.pushNamed(context, AppRoute.assignmentPage);
                }
              } else if (state is AssignmentError) {
                _showErrorSnackBar(context, state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<QuizCubit, QuizState>(
          builder: (context, quizState) {
            return BlocBuilder<SummaryCubit, SummaryState>(
              builder: (context, summaryState) {
                return BlocBuilder<AssignmentCubit, AssignmentState>(
                  builder: (context, assignmentState) {
                    if (quizState is QuizLoading ||
                        summaryState is SummaryLoading ||
                        assignmentState is AssignmentLoading) {
                      final message = quizState is QuizLoading
                          ? quizState.message
                          : summaryState is SummaryLoading
                          ? summaryState.message
                          : (assignmentState as AssignmentLoading).message;
                      return HomeLoadingState(message: message);
                    }

                    if (userId == null) {
                      return const HomeLoginState();
                    }

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        QuizList(
                          userId: userId,
                          onFabPressed: () => _handleFabPressed(context),
                        ),
                        SummaryList(
                          userId: userId,
                          onFabPressed: () => _handleFabPressed(context),
                        ),
                        AssignmentList(
                          userId: userId,
                          onFabPressed: () => _handleFabPressed(context),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: HomeFab(
        controller: _fabController,
        onPressed: () => _handleFabPressed(context),
      ),
    );
  }

  Future<void> _handleFabPressed(BuildContext context) async {
    // Determine the initial generation type based on current tab
    GenerationType initialType;
    switch (_tabController.index) {
      case 0:
        initialType = GenerationType.quiz;
        break;
      case 1:
        initialType = GenerationType.summary;
        break;
      case 2:
        initialType = GenerationType.assignment;
        break;
      default:
        initialType = GenerationType.quiz;
    }

    final result = await showQuizSettingsDialog(
      context,
      initialType: initialType,
    );
    if (result != null && context.mounted) {
      if (result.type == GenerationType.quiz && result.quizSettings != null) {
        context.read<QuizCubit>().pickAndProcessPdf(
          settings: result.quizSettings!,
        );
      } else if (result.type == GenerationType.summary &&
          result.summarySettings != null) {
        context.read<SummaryCubit>().pickAndProcessPdfForSummary(
          settings: result.summarySettings!,
        );
      } else if (result.type == GenerationType.assignment &&
          result.assignmentSettings != null) {
        context.read<AssignmentCubit>().pickAndProcessDocumentForAssignment(
          settings: result.assignmentSettings!,
        );
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
