import 'tile.dart';

class Board {
  final String id;
  final String name;
  final int rows;
  final int columns;

  /// Slots. Length should be rows * columns.
  final List<Tile?> tiles;

  const Board({
    required this.id,
    required this.name,
    required this.rows,
    required this.columns,
    required this.tiles,
  });

  int get totalSlots => rows * columns;

  Board copyWith({
    String? id,
    String? name,
    int? rows,
    int? columns,
    List<Tile?>? tiles,
  }) {
    return Board(
      id: id ?? this.id,
      name: name ?? this.name,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      tiles: tiles ?? this.tiles,
    );
  }
}