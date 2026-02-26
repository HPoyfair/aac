import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aac/core/providers/sentence_provider.dart';
import 'package:aac/core/providers/tts_provider.dart';
import 'package:aac/core/providers/edit_mode_provider.dart';

class SentenceBar extends ConsumerWidget {
  const SentenceBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(sentenceProvider);
    final sentence = words.join(' ');
    final isEditMode = ref.watch(editModeProvider);

    return Material(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            // Text area
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    sentence.isEmpty
                        ? 'Tap tiles to build a sentence…'
                        : sentence,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Backspace
            IconButton(
              tooltip: 'Backspace',
              onPressed: words.isEmpty
                  ? null
                  : () => ref.read(sentenceProvider.notifier).backspace(),
              icon: const Icon(Icons.backspace_outlined),
            ),

            // Clear
            IconButton(
              tooltip: 'Clear',
              onPressed: words.isEmpty
                  ? null
                  : () => ref.read(sentenceProvider.notifier).clear(),
              icon: const Icon(Icons.clear),
            ),

            // Edit Mode toggle
            IconButton(
              tooltip: isEditMode ? 'Exit edit mode' : 'Edit board',
              onPressed: () => ref.read(editModeProvider.notifier).toggle(),
              icon: Icon(isEditMode ? Icons.check : Icons.edit),
            ),

            // Speak
            FilledButton.icon(
              onPressed: words.isEmpty
                  ? null
                  : () async {
                      await ref.read(ttsProvider).speak(sentence);
                    },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Speak'),
            ),
          ],
        ),
      ),
    );
  }
}