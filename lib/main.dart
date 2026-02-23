import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repositories/category_repository.dart';
import 'repositories/vocab_repository.dart';
import 'cubits/category_cubit.dart';
import 'cubits/vocab_cubit.dart';
import 'cubits/quiz_cubit.dart';
import 'screens/main_tab_screen.dart';
import 'screens/onboarding/auth_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => CategoryRepository()),
        RepositoryProvider(create: (_) => VocabRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                CategoryCubit(context.read<CategoryRepository>())
                  ..loadCategories(),
          ),
          BlocProvider(
            create: (context) =>
                VocabCubit(context.read<VocabRepository>())
                  ..loadVocabs(), // Load all vocabs globally on startup
          ),
          BlocProvider(
            create: (context) => QuizCubit(context.read<VocabRepository>()),
          ),
        ],
        child: CupertinoApp(
          title: 'Từ vựng tiếng Hàn',
          theme: const CupertinoThemeData(
            primaryColor: CupertinoColors.systemBlue,
            brightness: Brightness.light,
          ),
          home: const AuthWrapper(),
          routes: {
            '/home': (context) => const MainTabScreen(),
          },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
