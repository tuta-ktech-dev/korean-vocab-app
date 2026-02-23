import 'package:flutter/cupertino.dart';
import 'quiz_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  final String? categoryId;

  const QuizSetupScreen({super.key, this.categoryId});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int _wordCount = 10;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Thiết lập luyện tập'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Số từ mỗi lần học',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nên học 5-10 từ mỗi lần để đạt hiệu quả tốt nhất',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              _buildWordCountSelector(),
              const SizedBox(height: 48),
              _buildStartButton(),
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

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(vertical: 16),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => QuizScreen(
                categoryId: widget.categoryId,
                wordCount: _wordCount,
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.play_fill),
            const SizedBox(width: 8),
            Text('Bắt đầu học $_wordCount từ'),
          ],
        ),
      ),
    );
  }
}
