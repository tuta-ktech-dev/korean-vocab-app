import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repositories/category_repository.dart';
import 'repositories/vocab_repository.dart';
import 'cubits/category_cubit.dart';
import 'cubits/vocab_cubit.dart';
import 'cubits/quiz_cubit.dart';
import 'screens/main_tab_screen.dart';

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
            create: (context) => VocabCubit(context.read<VocabRepository>()),
          ),
          BlocProvider(
            create: (context) => QuizCubit(context.read<VocabRepository>()),
          ),
        ],
        child: const CupertinoApp(
          title: 'Từ vựng tiếng Hàn',
          theme: CupertinoThemeData(
            primaryColor: CupertinoColors.systemBlue,
            brightness: Brightness.light,
          ),
          home: MainTabScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
