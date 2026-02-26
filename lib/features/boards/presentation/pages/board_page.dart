import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/boards_provider.dart';
import '../widgets/tile_card.dart';
import '../widgets/sentence_bar.dart';

import 'package:aac/core/providers/sentence_provider.dart';
import 'package:aac/core/providers/edit_mode_provider.dart';

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

    final isEditMode = ref.watch(editModeProvider);

    final totalSlots = board.rows * board.columns;
    final isFull = board.tiles.indexWhere((t) => t == null) == -1;

    return Scaffold(
      appBar: AppBar(
        title: Text(board.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SentenceBar(),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;

                  final maxW = constraints.maxWidth;
                  final maxH = constraints.maxHeight;

                  final cellW =
                      (maxW - spacing * (board.columns - 1)) / board.columns;
                  final cellH =
                      (maxH - spacing * (board.rows - 1)) / board.rows;

                  final childAspectRatio = cellW / cellH;

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: board.columns,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: totalSlots,
                    itemBuilder: (context, index) {
                      final tile = board.tiles[index]; // Tile? (nullable)

                      return DragTarget<int>(
                        onWillAccept: (fromIndex) =>
                            isEditMode && fromIndex != null && fromIndex != index,
                        onAccept: (fromIndex) {
                          ref.read(boardsProvider.notifier).swapTiles(
                                boardId: boardId,
                                fromIndex: fromIndex,
                                toIndex: index,
                              );
                        },
                        builder: (context, candidate, rejected) {
                          final isHover = candidate.isNotEmpty;

                          // Empty slot
                          if (tile == null) {
                            return _EmptySlot(
                              showPlus: !isEditMode,
                              highlight: isEditMode && isHover,
                            );
                          }

                          // Tile exists
                          Future<void> handleTap() async {
                            if (isEditMode) {
                              final updated = await _showEditTileDialog(
                                context: context,
                                initialLabel: tile.label,
                                initialColorValue:
                                    tile.colorValue ?? Colors.lightBlue.value,
                              );
                              if (updated == null) return;

                              final newTile = tile.copyWith(
                                label: updated.label,
                                colorValue: updated.colorValue,
                              );

                              ref.read(boardsProvider.notifier).updateTileAt(
                                    boardId: boardId,
                                    index: index,
                                    updated: newTile,
                                  );
                              return;
                            }

                            // Normal mode: add word to sentence bar
                            final word = tile.speakText ?? tile.label;
                            ref.read(sentenceProvider.notifier).addWord(word);

                            // If you want tap-to-navigate still in normal mode:
                            final targetId = tile.goToBoardId;
                            if (targetId != null) {
                              context.go('/board/$targetId');
                            }
                          }

                          final card = TileCard(
                            tile: tile,
                            onTap: handleTap,
                          );

                          // Not in edit mode: no dragging
                          if (!isEditMode) return card;

                          // Edit mode: drag enabled
                          final content = AnimatedScale(
                            scale: isHover ? 1.03 : 1.0,
                            duration: const Duration(milliseconds: 120),
                            child: card,
                          );

                         return Draggable<int>(
                                data: index,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: cellW,
                                    height: cellH,
                                    child: content,
                                  ),
                                ),
                                childWhenDragging: Opacity(opacity: 0.35, child: content),
                                child: content,
                              );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isEditMode
          ? null
          : FloatingActionButton(
              onPressed: () async {
                if (isFull) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Board is full (${board.rows}×${board.columns}).'),
                    ),
                  );
                  return;
                }

                final controller = TextEditingController();
                int selectedColorValue = Colors.lightBlue.value;

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
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final colorValue in palette)
                                    _ColorSwatch(
                                      colorValue: colorValue,
                                      isSelected:
                                          selectedColorValue == colorValue,
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

class _EmptySlot extends StatelessWidget {
  final bool showPlus;
  final bool highlight;

  const _EmptySlot({
    required this.showPlus,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: highlight
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surface,
      elevation: 1,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Center(
          child: Icon(
            showPlus ? Icons.add : Icons.circle_outlined,
            size: 30,
            color: theme.colorScheme.onSurface.withOpacity(0.18),
          ),
        ),
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

class _EditTileResult {
  final String label;
  final int colorValue;

  const _EditTileResult({
    required this.label,
    required this.colorValue,
  });
}

Future<_EditTileResult?> _showEditTileDialog({
  required BuildContext context,
  required String initialLabel,
  required int initialColorValue,
}) async {
  final controller = TextEditingController(text: initialLabel);
  int selectedColorValue = initialColorValue;

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

  return showDialog<_EditTileResult?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Tile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Tile label',
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

                  Navigator.of(context).pop(
                    _EditTileResult(
                      label: label,
                      colorValue: selectedColorValue,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}