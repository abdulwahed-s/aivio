import 'package:aivio/core/constant/color.dart';
import 'package:aivio/core/routes/page_router.dart';
import 'package:aivio/cubit/profile/profile_cubit.dart';
import 'package:aivio/cubit/theme/theme_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider.value(value: PageRouter.authCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Aivio',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Appcolor.primaryColor,
              ),
              useMaterial3: true,
              brightness: Brightness.light,
              fontFamily: 'Cairo',
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Appcolor.primaryColor,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
              fontFamily: 'Cairo',
            ),
            themeMode: themeMode,
            onGenerateRoute: PageRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
