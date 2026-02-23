import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/statistics_cubit.dart';
import '../../widgets/cupertino_progress.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Thống kê')),
      child: SafeArea(
        child: BlocBuilder<StatisticsCubit, StatisticsState>(
          builder: (context, state) {
            if (state is StatisticsLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state is StatisticsLoaded) {
              final stats = state.stats;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildOverviewCard(stats),
                    const SizedBox(height: 16),
                    _buildProgressCard(stats),
                    const SizedBox(height: 16),
                    _buildStatusDistribution(stats),
                    const SizedBox(height: 16),
                    _buildStreakCard(stats),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOverviewCard(Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CupertinoColors.systemBlue, CupertinoColors.systemPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                value: '${stats['total']}',
                label: 'Tổng từ',
                icon: CupertinoIcons.book_fill,
              ),
              _buildStatItem(
                value: '${stats['mastered']}',
                label: 'Đã thuộc',
                icon: CupertinoIcons.checkmark_circle_fill,
              ),
              _buildStatItem(
                value: '${stats['learning']}',
                label: 'Đang học',
                icon: CupertinoIcons.clock_fill,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: CupertinoColors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: CupertinoColors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> stats) {
    final double percentageValue = stats['total'] > 0
        ? (stats['mastered'] / stats['total'])
        : 0.0;
    final percentage = (percentageValue * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiến độ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.activeGreen,
                  ),
                ),
                const Text(
                  'Đã hoàn thành',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Còn ${stats['total'] - stats['mastered']} từ nữa để hoàn thành',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: CupertinoCircularProgress(
              value: percentageValue,
              strokeWidth: 10,
              color: CupertinoColors.activeGreen,
              backgroundColor: CupertinoColors.systemGrey4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution(Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.systemGrey5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân bố trạng thái',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildStatusBar(
            label: 'Chưa học',
            count: stats['notStarted'],
            total: stats['total'],
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 12),
          _buildStatusBar(
            label: 'Mới',
            count: stats['new'],
            total: stats['total'],
            color: CupertinoColors.systemBlue,
          ),
          const SizedBox(height: 12),
          _buildStatusBar(
            label: 'Đang học',
            count: stats['learning'],
            total: stats['total'],
            color: CupertinoColors.systemOrange,
          ),
          const SizedBox(height: 12),
          _buildStatusBar(
            label: 'Ôn tập',
            count: stats['reviewing'],
            total: stats['total'],
            color: CupertinoColors.systemGreen,
          ),
          const SizedBox(height: 12),
          _buildStatusBar(
            label: 'Đã thuộc',
            count: stats['mastered'],
            total: stats['total'],
            color: CupertinoColors.systemPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? (count / total).toDouble() : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$count', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        CupertinoProgressBar(value: percentage, color: color, height: 8),
      ],
    );
  }

  Widget _buildStreakCard(Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemYellow.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.flame_fill,
                color: CupertinoColors.systemOrange,
              ),
              SizedBox(width: 8),
              Text(
                'Thống kê học tập',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStreakItem(
            icon: CupertinoIcons.checkmark_circle,
            label: 'Tổng số lần ôn tập',
            value: '${stats['totalReviews']}',
          ),
          const SizedBox(height: 12),
          _buildStreakItem(
            icon: CupertinoIcons.star_fill,
            label: 'Độ chính xác trung bình',
            value: '${stats['averageAccuracy']}%',
          ),
          const SizedBox(height: 12),
          _buildStreakItem(
            icon: CupertinoIcons.clock,
            label: 'Từ cần ôn hôm nay',
            value: '${stats['dueToday']}',
          ),
        ],
      ),
    );
  }

  Widget _buildStreakItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: CupertinoColors.systemOrange, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: CupertinoColors.systemGrey),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
