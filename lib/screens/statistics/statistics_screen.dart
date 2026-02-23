import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/statistics_cubit.dart';
import '../../widgets/cupertino_progress.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Thống kê'),
      ),
      child: SafeArea(
        child: BlocBuilder<StatisticsCubit, StatisticsState>(
          builder: (context, state) {
            if (state is StatisticsLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state is StatisticsLoaded) {
              final stats = state.stats;
              final double percentageValue = stats['total'] > 0
                  ? (stats['mastered'] / stats['total'])
                  : 0.0;
              final percentage = (percentageValue * 100).toInt();

              return ListView(
                children: [
                  // Progress Section
                  CupertinoListSection.insetGrouped(
                    header: const Text('TIẾN ĐỘ'),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$percentage%',
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Đã hoàn thành',
                                    style: TextStyle(
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Còn ${stats['total'] - stats['mastered']} từ',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: CupertinoCircularProgress(
                                value: percentageValue,
                                strokeWidth: 8,
                                color: CupertinoColors.activeGreen,
                                backgroundColor: CupertinoColors.systemGrey5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Overview Section
                  CupertinoListSection.insetGrouped(
                    header: const Text('TỔNG QUAN'),
                    children: [
                      CupertinoListTile(
                        leading: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            CupertinoIcons.book_fill,
                            color: CupertinoColors.white,
                            size: 16,
                          ),
                        ),
                        title: const Text('Tổng từ vựng'),
                        trailing: Text(
                          '${stats['total']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      CupertinoListTile(
                        leading: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            color: CupertinoColors.white,
                            size: 16,
                          ),
                        ),
                        title: const Text('Đã thuộc'),
                        trailing: Text(
                          '${stats['mastered']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      CupertinoListTile(
                        leading: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemOrange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            CupertinoIcons.clock_fill,
                            color: CupertinoColors.white,
                            size: 16,
                          ),
                        ),
                        title: const Text('Đang học'),
                        trailing: Text(
                          '${stats['learning']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Status Distribution
                  CupertinoListSection.insetGrouped(
                    header: const Text('PHÂN BỐ TRẠNG THÁI'),
                    children: [
                      _buildStatusTile(
                        label: 'Chưa học',
                        count: stats['notStarted'],
                        total: stats['total'],
                        color: CupertinoColors.systemGrey,
                      ),
                      _buildStatusTile(
                        label: 'Mới',
                        count: stats['new'],
                        total: stats['total'],
                        color: CupertinoColors.systemBlue,
                      ),
                      _buildStatusTile(
                        label: 'Đang học',
                        count: stats['learning'],
                        total: stats['total'],
                        color: CupertinoColors.systemOrange,
                      ),
                      _buildStatusTile(
                        label: 'Ôn tập',
                        count: stats['reviewing'],
                        total: stats['total'],
                        color: CupertinoColors.systemGreen,
                      ),
                      _buildStatusTile(
                        label: 'Đã thuộc',
                        count: stats['mastered'],
                        total: stats['total'],
                        color: CupertinoColors.systemPurple,
                      ),
                    ],
                  ),

                  // Study Stats
                  CupertinoListSection.insetGrouped(
                    header: const Text('THỐNG KÊ HỌC TẬP'),
                    footer: const Text('Dựa trên lịch sử ôn tập của bạn'),
                    children: [
                      CupertinoListTile(
                        leading: const Icon(
                          CupertinoIcons.checkmark_circle,
                          color: CupertinoColors.systemOrange,
                        ),
                        title: const Text('Tổng số lần ôn tập'),
                        trailing: Text(
                          '${stats['totalReviews']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      CupertinoListTile(
                        leading: const Icon(
                          CupertinoIcons.star_fill,
                          color: CupertinoColors.systemYellow,
                        ),
                        title: const Text('Độ chính xác trung bình'),
                        trailing: Text(
                          '${stats['averageAccuracy']}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      CupertinoListTile(
                        leading: const Icon(
                          CupertinoIcons.clock,
                          color: CupertinoColors.systemRed,
                        ),
                        title: const Text('Cần ôn hôm nay'),
                        trailing: Text(
                          '${stats['dueToday']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.systemRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStatusTile({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? (count / total).toDouble() : 0.0;

    return CupertinoListTile(
      title: Text(label),
      trailing: Text(
        '$count',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 4),
        child: CupertinoProgressBar(
          value: percentage,
          color: color,
          height: 6,
        ),
      ),
    );
  }
}
