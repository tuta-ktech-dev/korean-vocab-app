import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home/home_screen.dart';
import '../screens/vocab/difficult_words_screen.dart';
import '../screens/statistics/statistics_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../cubits/difficult_words_cubit.dart';
import '../cubits/statistics_cubit.dart';
import '../repositories/vocab_repository.dart';

class MainTabScreen extends StatelessWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(CupertinoIcons.house_fill),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(CupertinoIcons.exclamationmark_triangle_fill),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(CupertinoIcons.chart_bar_fill),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(CupertinoIcons.settings),
            ),
            label: '',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) => const HomeScreen());
          case 1:
            return CupertinoTabView(
              builder: (context) => BlocProvider(
                create: (ctx) =>
                    DifficultWordsCubit(ctx.read<VocabRepository>())
                      ..loadDifficultWords(),
                child: const DifficultWordsScreen(),
              ),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => BlocProvider(
                create: (ctx) =>
                    StatisticsCubit(ctx.read<VocabRepository>())
                      ..loadStatistics(),
                child: const StatisticsScreen(),
              ),
            );
          case 3:
            return CupertinoTabView(
              builder: (context) => const SettingsScreen(),
            );
          default:
            return CupertinoTabView(builder: (context) => const HomeScreen());
        }
      },
    );
  }
}
