import 'package:flutter/cupertino.dart';
import '../../models/quiz.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizSession session;

  const QuizResultScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final accuracy = session.accuracy;

    String title;
    String subtitle;
    IconData icon;
    Color color;

    if (accuracy >= 0.9) {
      title = 'Xuất sắc!';
      subtitle = 'Bạn đã thuộc gần hết!';
      icon = CupertinoIcons.star_fill;
      color = CupertinoColors.systemYellow;
    } else if (accuracy >= 0.7) {
      title = 'Rất tốt!';
      subtitle = 'Tiếp tục phát huy!';
      icon = CupertinoIcons.hand_thumbsup_fill;
      color = CupertinoColors.systemGreen;
    } else if (accuracy >= 0.5) {
      title = 'Khá tốt!';
      subtitle = 'Cần ôn thêm một chút';
      icon = CupertinoIcons.rocket_fill;
      color = CupertinoColors.systemOrange;
    } else {
      title = 'Cố lên!';
      subtitle = 'Luyện tập thêm để cải thiện';
      icon = CupertinoIcons.arrow_counterclockwise;
      color = CupertinoColors.systemRed;
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Kết quả'),
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: color),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 32),
              _buildStatsCard(),
              const SizedBox(height: 32),
              _buildDetailStats(),
              const Spacer(),
              CupertinoButton.filled(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Hoàn thành'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${(session.accuracy * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemBlue,
            ),
          ),
          const Text(
            'Độ chính xác',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          icon: CupertinoIcons.checkmark_circle_fill,
          color: CupertinoColors.systemGreen,
          value: session.correctCount.toString(),
          label: 'Đúng',
        ),
        _buildStatItem(
          icon: CupertinoIcons.xmark_circle_fill,
          color: CupertinoColors.systemRed,
          value: session.incorrectCount.toString(),
          label: 'Sai',
        ),
        _buildStatItem(
          icon: CupertinoIcons.arrow_right_circle_fill,
          color: CupertinoColors.systemGrey,
          value: session.skippedCount.toString(),
          label: 'Bỏ qua',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
