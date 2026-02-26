import 'package:flutter/material.dart';

import '../domain/tile.dart';

class TileCard extends StatelessWidget {
  final Tile tile;
  final VoidCallback onTap;

  const TileCard({
    super.key,
    required this.tile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = tile.colorValue != null
        ? Color(tile.colorValue!)
        : theme.colorScheme.surface;

    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Material(
      color: bg,
      elevation: 2,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (tile.icon != null) ...[
                Icon(tile.icon, size: 34, color: fg),
                const SizedBox(height: 10),
              ],
              Text(
                tile.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}