import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/category_cubit.dart';
import '../../cubits/vocab_cubit.dart';
import '../../models/category.dart';
import '../../repositories/vocab_repository.dart';
import '../vocab/category_detail_screen.dart';
import '../vocab/add_category_screen.dart';
import '../quiz/quiz_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Từ vựng tiếng Hàn'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showAddCategory(context),
              child: const Icon(CupertinoIcons.add),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildStudyButtons(context),
            const SizedBox(height: 16),
            Expanded(child: _buildCategoryList()),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) =>
                        const QuizSetupScreen(mode: QuizSetupMode.learn),
                  ),
                );
              },
              child: const Column(
                children: [
                  Icon(CupertinoIcons.book_fill, size: 24),
                  SizedBox(height: 4),
                  Text('Học từ mới', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) =>
                        const QuizSetupScreen(mode: QuizSetupMode.review),
                  ),
                );
              },
              child: const Column(
                children: [
                  Icon(CupertinoIcons.bolt_fill, size: 24),
                  SizedBox(height: 4),
                  Text('Ôn tập', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (state is CategoryLoaded) {
          if (state.categories.isEmpty) {
            return const Center(
              child: Text('Chưa có chủ đề nào. Hãy thêm mới!'),
            );
          }

          return ListView.builder(
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return _buildCategoryItem(context, category);
            },
          );
        }

        if (state is CategoryError) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category) {
    return CupertinoListTile(
      leading: _buildCategoryImage(category),
      title: Text(category.name),
      subtitle: category.nameKorean != null
          ? Text(
              category.nameKorean!,
              style: const TextStyle(color: CupertinoColors.systemGrey),
            )
          : null,
      trailing: const CupertinoListTileChevron(),
      onTap: () {
        final globalVocabCubit = context.read<VocabCubit>();
        final repo = context.read<VocabRepository>();

        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (ctx) => BlocProvider(
              // Tạo LOCAL VocabCubit scoped cho category này
              create: (_) =>
                  VocabCubit(repo, scopedCategoryId: category.id)..loadVocabs(),
              child: CategoryDetailScreen(category: category),
            ),
          ),
        ).then((_) {
          // Sau khi pop, refresh global cubit để sync DifficultWordsScreen,
          // StatisticsScreen với bất kỳ thay đổi nào đã xảy ra
          globalVocabCubit.loadVocabs();
        });
      },
    );
  }

  Widget _buildCategoryImage(Category category) {
    if (category.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(category.imagePath!),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(CupertinoIcons.folder, size: 20),
    );
  }

  void _showAddCategory(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const AddCategoryScreen()),
    );
  }
}
