import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/category_cubit.dart';
import '../models/category.dart';
import 'category_detail_screen.dart';
import 'add_category_screen.dart';
import 'study_screen.dart';
import 'quiz_setup_screen.dart';

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
            _buildLogo(),
            _buildStudyButton(context),
            const SizedBox(height: 16),
            Expanded(
              child: _buildCategoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 80,
            width: 80,
          ),
          const SizedBox(height: 8),
          const Text(
            'Từ vựng tiếng Hàn',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Học thông minh với SRS',
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CupertinoButton.filled(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const QuizSetupScreen(),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.bolt_fill),
                SizedBox(width: 8),
                Text('Luyện tập thông minh'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const StudyScreen(),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.book),
                SizedBox(width: 8),
                Text('Học flashcard'),
              ],
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
          ? Text(category.nameKorean!, style: const TextStyle(color: CupertinoColors.systemGrey))
          : null,
      trailing: const CupertinoListTileChevron(),
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => CategoryDetailScreen(category: category),
          ),
        );
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
      CupertinoPageRoute(
        builder: (context) => const AddCategoryScreen(),
      ),
    );
  }
}
