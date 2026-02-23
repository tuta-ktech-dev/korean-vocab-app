import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../cubits/category_cubit.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  final _nameKoreanController = TextEditingController();
  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _nameKoreanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Thêm chủ đề'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveCategory,
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
                controller: _nameController,
                placeholder: 'Tên chủ đề (Tiếng Việt)',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _nameKoreanController,
                placeholder: 'Tên tiếng Hàn (vd: 음식)',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 16),
              const Text('Ảnh chủ đề:'),
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

  Future<String?> _saveImage(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'cat_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await imageFile.copy(path.join(appDir.path, fileName));
    return savedImage.path;
  }

  void _saveCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    String? imagePath;
    if (_selectedImage != null) {
      imagePath = await _saveImage(_selectedImage!);
    }

    if (!mounted) return;

    context.read<CategoryCubit>().addCategory(
      name,
      nameKorean: _nameKoreanController.text.trim().isEmpty
          ? null
          : _nameKoreanController.text.trim(),
      imagePath: imagePath,
    );
    Navigator.pop(context);
  }
}
