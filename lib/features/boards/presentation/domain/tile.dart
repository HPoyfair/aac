class Tile {
  final String id;
  final String label;

  /// If set, tapping the tile speaks this text.
  final String? speakText;

  /// If set, tapping the tile navigates to another board.
  final String? goToBoardId;

  const Tile({
    required this.id,
    required this.label,
    this.speakText,
    this.goToBoardId,
  });
}