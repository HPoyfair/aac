import 'package:flutter/material.dart';

class TileCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  /// Use an int so the model can stay plain Dart (not Flutter Color).
  /// If null, we use theme color.
  final int? backgroundColorValue;

  /// Optional icon for now (later we can switch to images).
  final IconData? icon;

  const TileCard({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColorValue,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = backgroundColorValue != null
        ? Color(backgroundColorValue!)
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
              if (icon != null) ...[
                Icon(icon, size: 34, color: fg),
                const SizedBox(height: 10),
              ],
              Text(
                label,
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