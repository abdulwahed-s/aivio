import 'package:aivio/core/routes/app_route.dart';
import 'package:aivio/cubit/auth/auth_cubit.dart';
import 'package:aivio/cubit/quiz/quiz_cubit.dart';
import 'package:aivio/cubit/summary/summary_cubit.dart';
import 'package:aivio/cubit/assignment/assignment_cubit.dart';
import 'package:aivio/presentation/screens/auth_gate.dart';
import 'package:aivio/presentation/screens/login_page.dart';
import 'package:aivio/presentation/screens/quiz_page.dart';
import 'package:aivio/presentation/screens/sign_up_page.dart';
import 'package:aivio/presentation/screens/summary_page.dart';
import 'package:aivio/presentation/screens/assignment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PageRouter {
  static final AuthCubit _authCubit = AuthCubit();
  static final QuizCubit _quizCubit = QuizCubit();
  static final SummaryCubit _summaryCubit = SummaryCubit();
  static final AssignmentCubit _assignmentCubit = AssignmentCubit();

  static AuthCubit get authCubit => _authCubit;
  static QuizCubit get quizCubit => _quizCubit;
  static SummaryCubit get summaryCubit => _summaryCubit;
  static AssignmentCubit get assignmentCubit => _assignmentCubit;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Check if this is the initial route (no animation needed)
    final isInitialRoute =
        settings.name == AppRoute.home && settings.arguments == null;

    switch (settings.name) {
      case AppRoute.home:
        return _buildRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _authCubit),
              BlocProvider.value(value: _quizCubit),
              BlocProvider.value(value: _summaryCubit),
              BlocProvider.value(value: _assignmentCubit),
            ],
            child: const AuthGate(),
          ),
          animate: !isInitialRoute,
        );

      case AppRoute.login:
        return _buildRoute(
          BlocProvider.value(value: _authCubit, child: const LoginPage()),
        );

      case AppRoute.authGate:
        return _buildRoute(
          BlocProvider.value(value: _authCubit, child: const LoginPage()),
        );

      case AppRoute.signUp:
        return _buildRoute(
          BlocProvider.value(value: _authCubit, child: const SignUpPage()),
        );

      case AppRoute.quizPage:
        return _buildRoute(
          BlocProvider.value(value: _quizCubit, child: const QuizPage()),
          animate: false,
        );

      case AppRoute.summaryPage:
        return _buildRoute(
          BlocProvider.value(value: _summaryCubit, child: const SummaryPage()),
          animate: true,
        );

      case AppRoute.assignmentPage:
        return _buildRoute(
          BlocProvider.value(
            value: _assignmentCubit,
            child: const AssignmentPage(),
          ),
          animate: true,
        );

      default:
        return _buildRoute(
          BlocProvider.value(value: _authCubit, child: const LoginPage()),
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, {bool animate = true}) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        if (!animate) {
          return child; // No animation
        }

        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: animate
          ? const Duration(milliseconds: 400)
          : Duration.zero,
    );
  }

  // Cleanup method if needed
  static void dispose() {
    _authCubit.close();
    _quizCubit.close();
    _summaryCubit.close();
    _assignmentCubit.close();
  }
}
