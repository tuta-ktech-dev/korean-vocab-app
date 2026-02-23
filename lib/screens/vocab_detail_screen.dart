import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/vocab.dart';

class VocabDetailScreen extends StatefulWidget {
  final Vocab vocab;

  const VocabDetailScreen({super.key, required this.vocab});

  @override
  State<VocabDetailScreen> createState() => _VocabDetailScreenState();
}

class _VocabDetailScreenState extends State<VocabDetailScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ko-KR');
    await _flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Chi tiết từ vựng'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWordSection(),
              const SizedBox(height: 24),
              if (widget.vocab.imagePath != null) _buildImageSection(),
              if (widget.vocab.imagePath != null) const SizedBox(height: 24),
              if (widget.vocab.example != null) _buildExampleSection(),
              if (widget.vocab.example != null) const SizedBox(height: 24),
              if (widget.vocab.note != null) _buildNoteSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.vocab.word,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.vocab.pronunciation != null) ...[
            const SizedBox(height: 8),
            Text(
              '[${widget.vocab.pronunciation}]',
              style: const TextStyle(
                fontSize: 20,
                color: CupertinoColors.systemBlue,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            widget.vocab.meaning,
            style: const TextStyle(
              fontSize: 24,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            onPressed: () => _speak(widget.vocab.word),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.volume_up),
                SizedBox(width: 8),
                Text('Phát âm'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(widget.vocab.imagePath!),
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildExampleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ví dụ:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.vocab.example!,
            style: const TextStyle(fontSize: 18),
          ),
          if (widget.vocab.exampleMeaning != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.vocab.exampleMeaning!,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _speak(widget.vocab.example!),
            child: const Icon(CupertinoIcons.volume_up, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.doc_text, size: 18),
              SizedBox(width: 8),
              Text(
                'Ghi chú:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.vocab.note!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
