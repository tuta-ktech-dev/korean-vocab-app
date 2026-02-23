import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/vocab_cubit.dart';
import '../../models/category.dart';
import '../../models/vocab.dart';
import '../quiz/quiz_setup_screen.dart';
import '../study/study_screen.dart';
import 'add_vocab_screen.dart';
import 'edit_vocab_screen.dart';
import 'vocab_detail_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load vocabularies for this category when the screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VocabCubit>().loadVocabs(categoryId: widget.category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.category.name),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showAddVocab(context),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: BlocBuilder<VocabCubit, VocabState>(
          builder: (context, state) {
            if (state is VocabLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state is VocabLoaded) {
              final vocabs = state.vocabs
                  .where((v) => v.categoryId == widget.category.id)
                  .toList();

              if (vocabs.isEmpty) {
                return const Center(
                  child: Text('Chưa có từ vựng nào. Hãy thêm mới!'),
                );
              }

              return Column(
                children: [
                  _buildStudyButtons(context, vocabs.length),
                  Expanded(
                    child: ListView.builder(
                      itemCount: vocabs.length,
                      itemBuilder: (context, index) {
                        return _buildVocabItem(context, vocabs[index]);
                      },
                    ),
                  ),
                ],
              );
            }

            if (state is VocabError) {
              return Center(child: Text('Lỗi: ${state.message}'));
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStudyButtons(BuildContext context, int vocabCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$vocabCount từ vựng',
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => QuizSetupScreen(
                          categoryId: widget.category.id,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.bolt_fill, size: 18),
                      SizedBox(width: 6),
                      Text('Luyện tập'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => StudyScreen(
                          categoryId: widget.category.id,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.book, size: 18),
                      SizedBox(width: 6),
                      Text('Flashcard'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVocabItem(BuildContext context, Vocab vocab) {
    return CupertinoListTile(
      leading: _buildVocabImage(vocab),
      title: Row(
        children: [
          Expanded(child: Text(vocab.word)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Color(vocab.statusColor).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              vocab.studyStatus,
              style: TextStyle(
                fontSize: 11,
                color: Color(vocab.statusColor),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(vocab.meaning),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showOptions(context, vocab),
        child: const Icon(CupertinoIcons.ellipsis_vertical),
      ),
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => VocabDetailScreen(vocab: vocab),
          ),
        );
      },
    );
  }

  void _showOptions(BuildContext context, Vocab vocab) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(vocab.word),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) =>
                      EditVocabScreen(vocab: vocab, category: widget.category),
                ),
              );
            },
            child: const Text('Chỉnh sửa'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _deleteVocab(context, vocab);
            },
            child: const Text('Xóa'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
      ),
    );
  }

  Widget _buildVocabImage(Vocab vocab) {
    if (vocab.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(vocab.imagePath!),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }
    return const Icon(CupertinoIcons.book, size: 24);
  }

  void _showAddVocab(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddVocabScreen(category: widget.category),
      ),
    );
  }

  void _deleteVocab(BuildContext context, Vocab vocab) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Xóa từ vựng?'),
        content: Text('Bạn có chắc muốn xóa "${vocab.word}"?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context.read<VocabCubit>().deleteVocab(
                vocab.id,
                categoryId: widget.category.id,
              );
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
