import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/boards_provider.dart';

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

            return ElevatedButton(
              onPressed: () {
                // If this tile points to another board, navigate there
                final targetId = tile.goToBoardId;
                if (targetId != null) {
                  context.go('/board/$targetId');
                  return;
                }

                // Otherwise "speak" the tile (for now: snackbar)
                final textToSpeak = tile.speakText ?? tile.label;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Speak: $textToSpeak')),
                );
              },
              child: Text(
                tile.label,
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = TextEditingController();

          final label = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('New Tile'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Tile label',
                  hintText: 'e.g., Drink',
                ),
                onSubmitted: (_) =>
                    Navigator.of(context).pop(controller.text.trim()),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(controller.text.trim()),
                  child: const Text('Add'),
                ),
              ],
            ),
          );

          if (label == null || label.isEmpty) return;

          ref.read(boardsProvider.notifier).addTile(
                boardId: boardId,
                label: label,
              );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}