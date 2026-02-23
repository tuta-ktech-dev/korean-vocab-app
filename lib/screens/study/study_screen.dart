import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flip_card/flip_card.dart';
import '../../cubits/vocab_cubit.dart';
import '../../models/vocab.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
    context.read<VocabCubit>().loadVocabs();
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
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Học flashcard'),
      ),
      child: SafeArea(
        child: BlocBuilder<VocabCubit, VocabState>(
          builder: (context, state) {
            if (state is VocabLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state is VocabLoaded) {
              if (state.vocabs.isEmpty) {
                return const Center(child: Text('Chưa có từ vựng nào để học!'));
              }

              return _buildFlashcardView(state.vocabs);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFlashcardView(List<Vocab> vocabs) {
    final currentVocab = vocabs[_currentIndex];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${_currentIndex + 1} / ${vocabs.length}',
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FlipCard(
              direction: FlipDirection.HORIZONTAL,
              front: _buildCardFront(currentVocab),
              back: _buildCardBack(currentVocab),
            ),
          ),
        ),
        _buildControls(vocabs),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCardFront(Vocab vocab) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              vocab.word,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            if (vocab.pronunciation != null) ...[
              const SizedBox(height: 8),
              Text(
                '[${vocab.pronunciation}]',
                style: const TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.systemBlue,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: () => _speak(vocab.word),
              child: const Icon(CupertinoIcons.volume_up, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chạm để lật',
              style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(Vocab vocab) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vocab.meaning,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (vocab.example != null) ...[
                const SizedBox(height: 16),
                Text(
                  vocab.example!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (vocab.exampleMeaning != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    vocab.exampleMeaning!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey2,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(List<Vocab> vocabs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            onPressed: _currentIndex > 0
                ? () => setState(() => _currentIndex--)
                : null,
            child: const Icon(CupertinoIcons.arrow_left_circle_fill, size: 48),
          ),
          CupertinoButton(
            onPressed: _currentIndex < vocabs.length - 1
                ? () => setState(() => _currentIndex++)
                : null,
            child: const Icon(CupertinoIcons.arrow_right_circle_fill, size: 48),
          ),
        ],
      ),
    );
  }
}
