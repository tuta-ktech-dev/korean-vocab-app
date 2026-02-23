import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/vocab.dart';
import '../repositories/vocab_repository.dart';

part 'vocab_state.dart';

class VocabCubit extends Cubit<VocabState> {
  final VocabRepository _repository;

  VocabCubit(this._repository) : super(VocabInitial());

  Future<void> loadVocabs({String? categoryId}) async {
    emit(VocabLoading());
    try {
      final vocabs = categoryId != null
          ? await _repository.getVocabsByCategory(categoryId)
          : await _repository.getAllVocabs();
      emit(VocabLoaded(vocabs));
    } catch (e) {
      emit(VocabError(e.toString()));
    }
  }

  Future<void> addVocab({
    required String word,
    String? pronunciation,
    required String meaning,
    String? example,
    String? exampleMeaning,
    String? note,
    required String categoryId,
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
      await loadVocabs(); // Reload all để không corrupt global state
    } catch (e) {
      emit(VocabError(e.toString()));
    }
  }

  Future<void> deleteVocab(String id, {String? categoryId}) async {
    try {
      await _repository.deleteVocab(id);
      await loadVocabs(); // Reload all
    } catch (e) {
      emit(VocabError(e.toString()));
    }
  }

  Future<void> updateVocab(Vocab vocab) async {
    try {
      await _repository.updateVocab(vocab);
      await loadVocabs(); // Reload all
    } catch (e) {
      emit(VocabError(e.toString()));
    }
  }

  Future<String> _saveImage(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await imageFile.copy(path.join(appDir.path, fileName));
    return savedImage.path;
  }
}
