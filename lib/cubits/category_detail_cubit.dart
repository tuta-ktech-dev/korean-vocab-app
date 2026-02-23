import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/vocab.dart';
import '../repositories/vocab_repository.dart';

part 'category_detail_state.dart';

/// Cubit dành riêng cho CategoryDetailScreen.
/// Quản lý CRUD vocab của 1 category cụ thể.
class CategoryDetailCubit extends Cubit<CategoryDetailState> {
  final VocabRepository _repository;
  final String categoryId;

  CategoryDetailCubit(this._repository, {required this.categoryId})
    : super(CategoryDetailInitial());

  Future<void> loadVocabs() async {
    emit(CategoryDetailLoading());
    try {
      final vocabs = await _repository.getVocabsByCategory(categoryId);
      emit(CategoryDetailLoaded(vocabs));
    } catch (e) {
      emit(CategoryDetailError(e.toString()));
    }
  }

  Future<void> addVocab({
    required String word,
    String? pronunciation,
    required String meaning,
    String? example,
    String? exampleMeaning,
    String? note,
    File? imageFile,
  }) async {
    try {
      String? imagePath;
      if (imageFile != null) {
        imagePath = await _saveImage(imageFile);
      }

      final vocab = Vocab(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        word: word,
        pronunciation: pronunciation,
        meaning: meaning,
        example: example,
        exampleMeaning: exampleMeaning,
        note: note,
        categoryId: categoryId,
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );
      await _repository.insertVocab(vocab);
      await loadVocabs();
    } catch (e) {
      emit(CategoryDetailError(e.toString()));
    }
  }

  Future<void> deleteVocab(String id) async {
    try {
      await _repository.deleteVocab(id);
      await loadVocabs();
    } catch (e) {
      emit(CategoryDetailError(e.toString()));
    }
  }

  Future<void> updateVocab(Vocab vocab) async {
    try {
      await _repository.updateVocab(vocab);
      await loadVocabs();
    } catch (e) {
      emit(CategoryDetailError(e.toString()));
    }
  }

  Future<String> _saveImage(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await imageFile.copy(path.join(appDir.path, fileName));
    return savedImage.path;
  }
}
