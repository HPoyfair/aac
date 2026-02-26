
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sentenceProvider =
    NotifierProvider<SentenceNotifier, List<String>>(SentenceNotifier.new);

class SentenceNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  void addWord(String word) {
    final w = word.trim();
    if (w.isEmpty) return;
    state = [...state, w];
  }

  void backspace() {
    if (state.isEmpty) return;
    state = state.sublist(0, state.length - 1);
  }

  void clear() {
    state = const [];
  }

  String asText() => state.join(' ');
}