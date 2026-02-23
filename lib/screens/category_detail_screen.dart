import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/vocab_cubit.dart';
import '../models/category.dart';
import '../models/vocab.dart';
import 'add_vocab_screen.dart';
import 'vocab_detail_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(category.name),
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
                  .where((v) => v.categoryId == category.id)
                  .toList();
              
              if (vocabs.isEmpty) {
                return const Center(
                  child: Text('Chưa có từ vựng nào. Hãy thêm mới!'),
                );
              }

              return ListView.builder(
                itemCount: vocabs.length,
                itemBuilder: (context, index) {
                  return _buildVocabItem(context, vocabs[index]);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildVocabItem(BuildContext context, Vocab vocab) {
    return CupertinoListTile(
      leading: _buildVocabImage(vocab),
      title: Text(vocab.word),
      subtitle: Text(vocab.meaning),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _deleteVocab(context, vocab),
        child: const Icon(
          CupertinoIcons.delete,
          color: CupertinoColors.destructiveRed,
        ),
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
        builder: (context) => AddVocabScreen(category: category),
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
              context.read<VocabCubit>().deleteVocab(vocab.id, categoryId: category.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
