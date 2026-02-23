import 'tile.dart';

class Board {
  final String id;
  final String name;
  final List<Tile> tiles;

  const Board({
    required this.id,
    required this.name,
    this.tiles = const [],
  });

  Board copyWith({
    String? id,
    String? name,
    List<Tile>? tiles,
  }) {
    return Board(
      id: id ?? this.id,
      name: name ?? this.name,
      tiles: tiles ?? this.tiles,
    );
  }
}