import 'package:flutter/material.dart';

class Tile {
  final String id;
  final String label;

  /// If set, tapping the tile speaks this text.
  final String? speakText;

  /// If set, tapping the tile navigates to another board.
  final String? goToBoardId;

  /// Background color stored as an int so it can be saved easily later.
  /// Example: 0xFF4CAF50
  final int? colorValue;

  /// Optional icon for now. (Later we can switch to images.)
  final IconData? icon;

  const Tile({
    required this.id,
    required this.label,
    this.speakText,
    this.goToBoardId,
    this.colorValue,
    this.icon,
  });

  Tile copyWith({
    String? id,
    String? label,
    String? speakText,
    String? goToBoardId,
    int? colorValue,
    IconData? icon,
  }) {
    return Tile(
      id: id ?? this.id,
      label: label ?? this.label,
      speakText: speakText ?? this.speakText,
      goToBoardId: goToBoardId ?? this.goToBoardId,
      colorValue: colorValue ?? this.colorValue,
      icon: icon ?? this.icon,
    );
  }
}