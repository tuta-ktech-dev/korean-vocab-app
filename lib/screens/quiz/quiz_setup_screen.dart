import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/quiz_cubit.dart';
import 'quiz_screen.dart';

enum QuizSetupMode { learn, review }

class QuizSetupScreen extends StatefulWidget {
  final String? categoryId;
  final QuizSetupMode mode;

  const QuizSetupScreen({
    super.key,
    this.categoryId,
    this.mode = QuizSetupMode.review,
  });

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int _wordCount = 10;

  bool get _isLearnMode => widget.mode == QuizSetupMode.learn;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isLearnMode ? 'Học từ mới' : 'Ôn tập'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      (_isLearnMode
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.systemBlue)
                          .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLearnMode
                          ? CupertinoIcons.book_fill
                          : CupertinoIcons.bolt_fill,
                      size: 16,
                      color: _isLearnMode
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isLearnMode
                          ? 'Học từ chưa học bao giờ'
                          : 'Ôn tập từ đã học',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isLearnMode
                            ? CupertinoColors.systemGreen
                            : CupertinoColors.systemBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Số từ mỗi lần ${_isLearnMode ? 'học' : 'ôn'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLearnMode
                    ? 'Nên học 5-10 từ mới mỗi lần để nhớ tốt hơn'
                    : 'Nên ôn 5-15 từ mỗi lần để đạt hiệu quả tốt nhất',
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              _buildWordCountSelector(),
              const SizedBox(height: 48),
              _buildStartButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordCountSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$_wordCount từ',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemBlue,
            ),
          ),
          const SizedBox(height: 24),
          CupertinoSlider(
            value: _wordCount.toDouble(),
            min: 5,
            max: 20,
            divisions: 15,
            onChanged: (value) {
              setState(() {
                _wordCount = value.round();
              });
            },
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('5', style: TextStyle(color: CupertinoColors.systemGrey)),
              Text('10', style: TextStyle(color: CupertinoColors.systemGrey)),
              Text('15', style: TextStyle(color: CupertinoColors.systemGrey)),
              Text('20', style: TextStyle(color: CupertinoColors.systemGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(vertical: 16),
        onPressed: () {
          // Bắt đầu session phù hợp
          if (_isLearnMode) {
            context.read<QuizCubit>().startLearnSession(
              categoryId: widget.categoryId,
              limit: _wordCount,
            );
          } else {
            context.read<QuizCubit>().startSession(
              categoryId: widget.categoryId,
              limit: _wordCount,
            );
          }
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => QuizScreen(
                categoryId: widget.categoryId,
                wordCount: _wordCount,
                isLearnMode: _isLearnMode,
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isLearnMode
                  ? CupertinoIcons.book_fill
                  : CupertinoIcons.play_fill,
            ),
            const SizedBox(width: 8),
            Text('${_isLearnMode ? 'Học' : 'Ôn'} $_wordCount từ'),
          ],
        ),
      ),
    );
  }
}
