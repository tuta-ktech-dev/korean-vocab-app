import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../cubits/vocab_cubit.dart';
import '../models/category.dart';

class AddVocabScreen extends StatefulWidget {
  final Category category;

  const AddVocabScreen({super.key, required this.category});

  @override
  State<AddVocabScreen> createState() => _AddVocabScreenState();
}

class _AddVocabScreenState extends State<AddVocabScreen> {
  final _wordController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _meaningController = TextEditingController();
  final _exampleController = TextEditingController();
  final _exampleMeaningController = TextEditingController();
  final _noteController = TextEditingController();
  File? _selectedImage;

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
        middle: const Text('Thêm từ vựng'),
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
              const SizedBox(height: 16),
              const Text('Ví dụ:', style: TextStyle(fontWeight: FontWeight.w600)),
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
              const SizedBox(height: 16),
              const Text('Ghi chú (Markdown):', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _noteController,
                placeholder: 'Ghi chú, cách nhớ, tips...\n\nHỗ trợ markdown: **bold**, *italic*, # heading',
                padding: const EdgeInsets.all(12),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              const Text('Ảnh minh họa:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildImagePicker(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _selectedImage!,
          height: 150,
          width: 150,
          fit: BoxFit.cover,
        ),
      );
    }
    return CupertinoButton(
      onPressed: _pickImage,
      child: const Icon(CupertinoIcons.camera, size: 50),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _saveVocab() {
    final word = _wordController.text.trim();
    final meaning = _meaningController.text.trim();
    
    if (word.isEmpty || meaning.isEmpty) return;

    context.read<VocabCubit>().addVocab(
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
      categoryId: widget.category.id,
      imageFile: _selectedImage,
    );
    Navigator.pop(context);
  }
}
