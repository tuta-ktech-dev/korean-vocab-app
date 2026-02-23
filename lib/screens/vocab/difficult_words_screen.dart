import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/vocab_cubit.dart';
import '../../models/vocab.dart';
import '../quiz/quiz_screen.dart';

class DifficultWordsScreen extends StatelessWidget {
  const DifficultWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Từ cần ôn lại'),
      ),
      child: SafeArea(
        child: BlocBuilder<VocabCubit, VocabState>(
          builder: (context, state) {
            if (state is VocabLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state is VocabLoaded) {
              final difficultWords = _getDifficultWords(state.vocabs);

              if (difficultWords.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        size: 64,
                        color: CupertinoColors.systemGreen,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tuyệt vời!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Không có từ nào cần ôn lại',
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  _buildHeader(difficultWords.length),
                  Expanded(
                    child: ListView.builder(
                      itemCount: difficultWords.length,
                      itemBuilder: (context, index) {
                        return _buildWordItem(context, difficultWords[index]);
                      },
                    ),
                  ),
                  _buildPracticeButton(context, difficultWords),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemRed.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            color: CupertinoColors.systemRed,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            '$count từ',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemRed,
            ),
          ),
          const Text(
            'cần ôn lại',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildWordItem(BuildContext context, Vocab vocab) {
    return CupertinoListTile(
      title: Text(vocab.word),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(vocab.meaning),
          const SizedBox(height: 4),
          Text(
            'Độ chính xác: ${(vocab.accuracy * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: vocab.accuracy < 0.5
                  ? CupertinoColors.systemRed
                  : CupertinoColors.systemOrange,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getDifficultyColor(vocab.accuracy).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _getDifficultyLabel(vocab.accuracy),
          style: TextStyle(
            fontSize: 12,
            color: _getDifficultyColor(vocab.accuracy),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(double accuracy) {
    if (accuracy < 0.3) return CupertinoColors.systemRed;
    if (accuracy < 0.5) return CupertinoColors.systemOrange;
    return CupertinoColors.systemYellow;
  }

  String _getDifficultyLabel(double accuracy) {
    if (accuracy < 0.3) return 'Khó';
    if (accuracy < 0.5) return 'Trung bình';
    return 'Cần củng cố';
  }

  Widget _buildPracticeButton(BuildContext context, List<Vocab> words) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton.filled(
          padding: const EdgeInsets.symmetric(vertical: 16),
          onPressed: () {
            // Start quiz with difficult words only
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    QuizScreen(wordCount: words.length.clamp(5, 20)),
              ),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.bolt_fill),
              SizedBox(width: 8),
              Text('Ôn ngay'),
            ],
          ),
        ),
      ),
    );
  }

  List<Vocab> _getDifficultWords(List<Vocab> vocabs) {
    return vocabs.where((v) => v.totalReviews > 0 && v.accuracy < 0.7).toList()
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));
  }
}
