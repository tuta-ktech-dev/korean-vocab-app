import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/vocab.dart';

class FlashcardView extends StatefulWidget {
  final Vocab vocab;
  final Function(bool isCorrect) onSelfAssess;

  const FlashcardView({
    super.key,
    required this.vocab,
    required this.onSelfAssess,
  });

  @override
  State<FlashcardView> createState() => FlashcardViewState();
}

class FlashcardViewState extends State<FlashcardView> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ko-KR');
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showAnswer = !_showAnswer),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _showAnswer ? _buildBack() : _buildFront(),
                ),
              ),
            ),
            if (_showAnswer) _buildSelfAssessButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Column(
      key: const ValueKey('front'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.vocab.word,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        CupertinoButton(
          onPressed: () => _speak(widget.vocab.word),
          child: const Icon(CupertinoIcons.volume_up, size: 40),
        ),
        const SizedBox(height: 32),
        const Text(
          'Chạm để xem đáp án',
          style: TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBack() {
    return Column(
      key: const ValueKey('back'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.vocab.meaning,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.systemGreen,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.vocab.example != null) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.vocab.example!,
              style: const TextStyle(
                fontSize: 18,
                color: CupertinoColors.systemGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        if (widget.vocab.imagePath != null) ...[
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.vocab.imagePath!),
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelfAssessButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              color: CupertinoColors.systemRed.withValues(alpha: 0.2),
              onPressed: () => widget.onSelfAssess(false),
              child: const Text(
                'Chưa nhớ',
                style: TextStyle(color: CupertinoColors.systemRed),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CupertinoButton.filled(
              onPressed: () => widget.onSelfAssess(true),
              child: const Text('Đã nhớ'),
            ),
          ),
        ],
      ),
    );
  }
}

class MCQView extends StatelessWidget {
  final Vocab vocab;
  final List<String> options;
  final Function(bool isCorrect) onAnswer;

  const MCQView({
    super.key,
    required this.vocab,
    required this.options,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            vocab.word,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'nghĩa là gì?',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 32),
          ...options.map((option) => _buildOption(option)),
        ],
      ),
    );
  }

  Widget _buildOption(String option) {
    final isCorrect = option == vocab.meaning;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: CupertinoButton(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        onPressed: () => onAnswer(isCorrect),
        child: Text(
          option,
          style: const TextStyle(
            fontSize: 18,
            color: CupertinoColors.label,
          ),
        ),
      ),
    );
  }
}

class TypingView extends StatefulWidget {
  final Vocab vocab;
  final bool isReverse;
  final Function(bool isCorrect) onAnswer;

  const TypingView({
    super.key,
    required this.vocab,
    required this.isReverse,
    required this.onAnswer,
  });

  @override
  State<TypingView> createState() => TypingViewState();
}

class TypingViewState extends State<TypingView> {
  final _controller = TextEditingController();
  bool _showHint = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final input = _controller.text.trim().toLowerCase();
    final correct = widget.isReverse 
        ? widget.vocab.word.toLowerCase()
        : widget.vocab.meaning.toLowerCase();
    
    // Check exact match hoặc contains
    final isCorrect = input == correct || 
        correct.contains(input) || 
        input.contains(correct);
    
    widget.onAnswer(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.isReverse ? widget.vocab.meaning : widget.vocab.word,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.isReverse ? 'Gõ từ tiếng Hàn' : 'Gõ nghĩa tiếng Việt',
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 32),
          CupertinoTextField(
            controller: _controller,
            placeholder: widget.isReverse ? '사과...' : 'Quả táo...',
            padding: const EdgeInsets.all(16),
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_showHint)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Gợi ý: ${widget.isReverse ? widget.vocab.word : widget.vocab.meaning}',
                style: const TextStyle(
                  color: CupertinoColors.systemBrown,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: () => setState(() => _showHint = true),
                  child: const Text('Gợi ý'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CupertinoButton.filled(
                  onPressed: _checkAnswer,
                  child: const Text('Kiểm tra'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
