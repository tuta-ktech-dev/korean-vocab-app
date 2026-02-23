import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/quiz_cubit.dart';
import '../../models/quiz.dart';
import 'quiz_result_screen.dart';
import 'widgets/quiz_components.dart';

class QuizScreen extends StatelessWidget {
  final String? categoryId;
  final int wordCount;
  final bool isLearnMode;

  const QuizScreen({
    super.key,
    this.categoryId,
    this.wordCount = 10,
    this.isLearnMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isLearnMode ? 'Học từ mới' : 'Ôn tập'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _confirmExit(context),
          child: const Icon(CupertinoIcons.xmark),
        ),
      ),
      child: SafeArea(
        child: BlocConsumer<QuizCubit, QuizState>(
          listener: (context, state) {
            if (state is QuizComplete) {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (_) => QuizResultScreen(session: state.session),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is QuizInitial || state is QuizLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state is QuizNoVocabs) {
              return _buildNoVocabsView(state.message);
            }

            if (state is QuizQuestion) {
              return _buildQuestionView(context, state);
            }

            if (state is QuizFeedback) {
              return _buildFeedbackView(context, state);
            }

            if (state is QuizError) {
              return Center(child: Text('Lỗi: ${state.message}'));
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNoVocabsView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.checkmark_circle_fill,
            size: 64,
            color: CupertinoColors.systemGreen,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn đã hoàn thành tất cả từ vựng! 🎉',
            style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView(BuildContext context, QuizQuestion state) {
    return Column(
      children: [
        // Progress bar
        _buildProgressBar(state.progress),

        // Mode indicator
        _buildModeIndicator(state.mode),

        Expanded(child: _buildQuizContent(context, state)),
      ],
    );
  }

  Widget _buildProgressBar(QuizProgress progress) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${progress.current}/${progress.total}'),
              Text('${((progress.current / progress.total) * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              color: CupertinoColors.systemGrey5,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.current / progress.total,
                child: Container(color: CupertinoColors.systemBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeIndicator(QuizMode mode) {
    String label;
    IconData icon;
    Color color;

    switch (mode) {
      case QuizMode.flashcard:
        label = 'Flashcard - Xem và nhớ';
        icon = CupertinoIcons.eye;
        color = CupertinoColors.systemBlue;
        break;
      case QuizMode.mcq:
        label = 'Trắc nghiệm - Chọn đáp án';
        icon = CupertinoIcons.list_bullet;
        color = CupertinoColors.systemGreen;
        break;
      case QuizMode.typing:
        label = 'Tự luận - Gõ đáp án';
        icon = CupertinoIcons.pencil;
        color = CupertinoColors.systemOrange;
        break;
      case QuizMode.reverseTyping:
        label = 'Ngược - Xem nghĩa, gõ từ';
        icon = CupertinoIcons.arrow_2_circlepath;
        color = CupertinoColors.systemPurple;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, QuizQuestion state) {
    switch (state.mode) {
      case QuizMode.flashcard:
        return FlashcardView(
          vocab: state.vocab,
          onSelfAssess: (isCorrect) {
            context.read<QuizCubit>().submitAnswer(
              isCorrect ? QuizResult.correct : QuizResult.incorrect,
            );
          },
        );
      case QuizMode.mcq:
        return MCQView(
          vocab: state.vocab,
          options: state.options!,
          onAnswer: (isCorrect) {
            context.read<QuizCubit>().submitAnswer(
              isCorrect ? QuizResult.correct : QuizResult.incorrect,
            );
          },
        );
      case QuizMode.typing:
      case QuizMode.reverseTyping:
        return TypingView(
          vocab: state.vocab,
          isReverse: state.mode == QuizMode.reverseTyping,
          onAnswer: (isCorrect) {
            context.read<QuizCubit>().submitAnswer(
              isCorrect ? QuizResult.correct : QuizResult.incorrect,
            );
          },
        );
    }
  }

  Widget _buildFeedbackView(BuildContext context, QuizFeedback state) {
    final isCorrect = state.result == QuizResult.correct;
    final nextReviewText = _formatNextReview(state.nextReview);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isCorrect
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.xmark_circle_fill,
            size: 80,
            color: isCorrect
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemRed,
          ),
          const SizedBox(height: 24),
          Text(
            isCorrect ? 'Chính xác! 🎉' : 'Chưa chính xác',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isCorrect
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemRed,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  state.vocab.word,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.vocab.meaning,
                  style: const TextStyle(
                    fontSize: 20,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ôn tập tiếp theo: $nextReviewText',
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: () => context.read<QuizCubit>().nextQuestion(),
              child: const Text('Tiếp theo'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNextReview(DateTime nextReview) {
    final now = DateTime.now();
    final diff = nextReview.difference(now);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút nữa';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ nữa';
    } else {
      return '${diff.inDays} ngày nữa';
    }
  }

  void _confirmExit(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Dừng luyện tập?'),
        content: const Text('Tiến độ sẽ không được lưu.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.read<QuizCubit>().reset(); // Reset cubit first
              Navigator.pop(context); // Then exit screen
            },
            child: const Text('Dừng'),
          ),
        ],
      ),
    );
  }
}
