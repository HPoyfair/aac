import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/boards_provider.dart';
import '../widgets/tile_card.dart';
import 'package:aac/core/providers/tts_provider.dart';

class BoardPage extends ConsumerWidget {
  final String boardId;

  const BoardPage({
    super.key,
    required this.boardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boards = ref.watch(boardsProvider);

    final board = boards.firstWhere(
      (b) => b.id == boardId,
      orElse: () => throw Exception('Board not found: $boardId'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(board.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: board.tiles.length,
          itemBuilder: (context, index) {
            final tile = board.tiles[index];

            return TileCard(
              label: tile.label,
              backgroundColorValue: tile.colorValue,
              icon: tile.icon,
              onTap: () {
              final targetId = tile.goToBoardId;
              if (targetId != null) {
                context.go('/board/$targetId');
                return;
              }

              final textToSpeak = tile.speakText ?? tile.label;
              ref.read(ttsProvider).speak(textToSpeak);
            },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final controller = TextEditingController();

    // Default selected color
    int selectedColorValue = Colors.lightBlue.value;

    // A simple, nice palette (AAC-friendly)
    final palette = <int>[
      Colors.lightBlue.value,
      Colors.lightGreen.value,
      Colors.amber.value,
      Colors.orange.value,
      Colors.pinkAccent.value,
      Colors.purpleAccent.value,
      Colors.teal.value,
      Colors.blueGrey.value,
    ];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Tile'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Tile label',
                      hintText: 'e.g., Drink',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Color',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Color palette grid
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final colorValue in palette)
                        _ColorSwatch(
                          colorValue: colorValue,
                          isSelected: selectedColorValue == colorValue,
                          onTap: () {
                            setState(() {
                              selectedColorValue = colorValue;
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final label = controller.text.trim();
                    if (label.isEmpty) return;

                    Navigator.of(context).pop({
                      'label': label,
                      'colorValue': selectedColorValue,
                    });
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    final label = result['label'] as String;
    final colorValue = result['colorValue'] as int;

    ref.read(boardsProvider.notifier).addTile(
          boardId: boardId,
          label: label,
          colorValue: colorValue,
        );
  },
  child: const Icon(Icons.add),
),
    );
  }
}



class _ColorSwatch extends StatelessWidget {
  final int colorValue;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.colorValue,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            width: isSelected ? 3 : 1,
            color: isSelected ? Colors.black : Colors.black26,
          ),
        ),
      ),
    );
  }
}