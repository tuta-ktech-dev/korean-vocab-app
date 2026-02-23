import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../cubits/vocab_cubit.dart';
import '../../models/category.dart';
import '../../models/vocab.dart';

class EditVocabScreen extends StatefulWidget {
  final Vocab vocab;
  final Category category;

  const EditVocabScreen({
    super.key,
    required this.vocab,
    required this.category,
  });

  @override
  State<EditVocabScreen> createState() => _EditVocabScreenState();
}

class _EditVocabScreenState extends State<EditVocabScreen> {
  late final _wordController = TextEditingController(text: widget.vocab.word);
  late final _pronunciationController = TextEditingController(
    text: widget.vocab.pronunciation ?? '',
  );
  late final _meaningController = TextEditingController(
    text: widget.vocab.meaning,
  );
  late final _exampleController = TextEditingController(
    text: widget.vocab.example ?? '',
  );
  late final _exampleMeaningController = TextEditingController(
    text: widget.vocab.exampleMeaning ?? '',
  );
  late final _noteController = TextEditingController(
    text: widget.vocab.note ?? '',
  );
  File? _selectedImage;
  bool _deleteImage = false;

  @override
  void dispose() {
    _wordController.dispose();
    _pronunciationController.dispose();
    _meaningController.dispose();
    _exampleController.dispose();
    _exampleMeaningController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Chỉnh sửa từ vựng'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveVocab,
          child: const Text('Lưu'),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(),
              const SizedBox(height: 24),
              const Text(
                'Thông tin từ vựng',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _wordController,
                placeholder: 'Từ tiếng Hàn (vd: 사과)',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _pronunciationController,
                placeholder: 'Phiên âm (vd: sa-gwa)',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _meaningController,
                placeholder: 'Nghĩa (vd: Quả táo)',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ví dụ:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _exampleController,
                placeholder: 'Câu ví dụ tiếng Hàn',
                padding: const EdgeInsets.all(12),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _exampleMeaningController,
                placeholder: 'Nghĩa câu ví dụ (Tiếng Việt)',
                padding: const EdgeInsets.all(12),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              const Text(
                'Ghi chú (Markdown):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _noteController,
                placeholder: 'Ghi chú, cách nhớ, tips...',
                padding: const EdgeInsets.all(12),
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              const Text(
                'Ảnh minh họa:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildImageSection(),
              const SizedBox(height: 32),
              _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Trạng thái:', widget.vocab.studyStatus),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Độ thuộc:',
            '${(widget.vocab.accuracy * 100).toInt()}%',
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Đã ôn:', '${widget.vocab.totalReviews} lần'),
          if (widget.vocab.lastReviewed != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Lần cuối:', _formatDate(widget.vocab.lastReviewed!)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildImageSection() {
    if (_selectedImage != null) {
      return _buildImagePreview(_selectedImage!.path, isFile: true);
    }

    if (!_deleteImage && widget.vocab.imagePath != null) {
      return _buildImagePreview(widget.vocab.imagePath!, isFile: true);
    }

    return CupertinoButton(
      onPressed: _pickImage,
      child: const Icon(CupertinoIcons.camera, size: 50),
    );
  }

  Widget _buildImagePreview(String path, {required bool isFile}) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(path),
            height: 150,
            width: 150,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _pickImage,
              child: const Text('Đổi ảnh'),
            ),
            const SizedBox(width: 16),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _deleteImage = true;
                });
              },
              child: const Text(
                'Xóa ảnh',
                style: TextStyle(color: CupertinoColors.destructiveRed),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return CupertinoButton(
      color: CupertinoColors.systemRed.withValues(alpha: 0.2),
      onPressed: () => _confirmDelete(context),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.delete, color: CupertinoColors.systemRed),
          SizedBox(width: 8),
          Text(
            'Xóa từ vựng',
            style: TextStyle(color: CupertinoColors.systemRed),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _deleteImage = false;
      });
    }
  }

  void _saveVocab() {
    final word = _wordController.text.trim();
    final meaning = _meaningController.text.trim();

    if (word.isEmpty || meaning.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Thiếu thông tin'),
          content: const Text('Vui lòng nhập từ và nghĩa'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    String? imagePath;
    if (_deleteImage) {
      imagePath = null;
    } else if (_selectedImage != null) {
      // Save new image
      // Note: Would need to implement async image saving
      imagePath = widget.vocab.imagePath; // Keep old for now
    } else {
      imagePath = widget.vocab.imagePath;
    }

    final updatedVocab = widget.vocab.copyWith(
      word: word,
      pronunciation: _pronunciationController.text.trim().isEmpty
          ? null
          : _pronunciationController.text.trim(),
      meaning: meaning,
      example: _exampleController.text.trim().isEmpty
          ? null
          : _exampleController.text.trim(),
      exampleMeaning: _exampleMeaningController.text.trim().isEmpty
          ? null
          : _exampleMeaningController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      imagePath: imagePath,
    );

    // TODO: Add updateVocab method to cubit
    context.read<VocabCubit>().updateVocab(updatedVocab);
    Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Xóa từ vựng?'),
        content: Text('Bạn có chắc muốn xóa "${widget.vocab.word}"?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context.read<VocabCubit>().deleteVocab(
                widget.vocab.id,
                categoryId: widget.category.id,
              );
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
