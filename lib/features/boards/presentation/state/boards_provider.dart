import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/board.dart';
import '../domain/tile.dart';

final boardsProvider =
    NotifierProvider<BoardsNotifier, List<Board>>(BoardsNotifier.new);

class BoardsNotifier extends Notifier<List<Board>> {
  @override
  List<Board> build() {
    // Default Home board: 3x3 with 4 tiles placed into the first slots.
    const rows = 3;
    const columns = 3;

    final homeSlots = List<Tile?>.filled(rows * columns, null);

    homeSlots[0] = const Tile(id: 't1', label: 'Hello');
    homeSlots[1] = const Tile(id: 't2', label: 'Help');
    homeSlots[2] = const Tile(id: 't3', label: 'Drink');
    homeSlots[3] = const Tile(id: 't4', label: 'Bathroom');

    return [
      Board(
        id: 'home',
        name: 'Home',
        rows: rows,
        columns: columns,
        tiles: homeSlots,
      ),
    ];
  }

  void addBoard({
    required String name,
    required int rows,
    required int columns,
  }) {
    final newBoard = Board(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      rows: rows,
      columns: columns,
      tiles: List<Tile?>.filled(rows * columns, null),
    );

    state = [...state, newBoard];
  }

  void addTile({
    required String boardId,
    required String label,
    int? colorValue,
  }) {
    state = [
      for (final b in state)
        if (b.id == boardId)
          () {
            final tiles = [...b.tiles];
            final emptyIndex = tiles.indexWhere((t) => t == null);
            if (emptyIndex == -1) return b; // board full

            tiles[emptyIndex] = Tile(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              label: label,
              colorValue: colorValue,
            );

            return b.copyWith(tiles: tiles);
          }()
        else
          b
    ];
  }

  void swapTiles({
    required String boardId,
    required int fromIndex,
    required int toIndex,
  }) {
    if (fromIndex == toIndex) return;

    state = [
      for (final b in state)
        if (b.id == boardId)
          () {
            final tiles = [...b.tiles];

            final temp = tiles[fromIndex];
            tiles[fromIndex] = tiles[toIndex];
            tiles[toIndex] = temp;

            return b.copyWith(tiles: tiles);
          }()
        else
          b
    ];
  }

  void updateTileAt({
    required String boardId,
    required int index,
    required Tile updated,
  }) {
    state = [
      for (final b in state)
        if (b.id == boardId)
          () {
            final tiles = [...b.tiles];
            tiles[index] = updated;
            return b.copyWith(tiles: tiles);
          }()
        else
          b
    ];
  }

  // Optional helper if you want delete in edit mode later:
  void clearTileAt({
    required String boardId,
    required int index,
  }) {
    state = [
      for (final b in state)
        if (b.id == boardId)
          () {
            final tiles = [...b.tiles];
            tiles[index] = null;
            return b.copyWith(tiles: tiles);
          }()
        else
          b
    ];
  }
}