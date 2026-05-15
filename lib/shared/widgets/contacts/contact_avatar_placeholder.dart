import 'package:flutter/material.dart';

class ContactAvatarPlaceholder extends StatelessWidget {
  final String seed;
  final String displayName;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final double fontSize;

  const ContactAvatarPlaceholder({
    super.key,
    required this.seed,
    required this.displayName,
    this.borderRadius,
    this.shape = BoxShape.circle,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final variant = _variants[_stableIndex(seed)];
    final initials = _initialsFromName(displayName);

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : borderRadius,
          gradient: LinearGradient(
            begin: variant.begin,
            end: variant.end,
            colors: variant.colors,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -18,
              right: -10,
              child: _AccentBubble(
                diameter: 54,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              bottom: -12,
              left: -10,
              child: _AccentBubble(
                diameter: 42,
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ),
            if (variant.showStripe)
              Positioned(
                bottom: 10,
                right: -8,
                child: Transform.rotate(
                  angle: -0.28,
                  child: Container(
                    width: 42,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            Center(
              child: Text(
                initials,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentBubble extends StatelessWidget {
  final double diameter;
  final Color color;

  const _AccentBubble({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _AvatarVariant {
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;
  final bool showStripe;

  const _AvatarVariant({
    required this.colors,
    required this.begin,
    required this.end,
    required this.showStripe,
  });
}

const List<_AvatarVariant> _variants = [
  _AvatarVariant(
    colors: [Color(0xFFFF8A65), Color(0xFFE85D5D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    showStripe: true,
  ),
  _AvatarVariant(
    colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomRight,
    showStripe: false,
  ),
  _AvatarVariant(
    colors: [Color(0xFFF06292), Color(0xFFAB47BC)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    showStripe: true,
  ),
  _AvatarVariant(
    colors: [Color(0xFFFFB74D), Color(0xFFFB8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomCenter,
    showStripe: false,
  ),
  _AvatarVariant(
    colors: [Color(0xFF4DB6AC), Color(0xFF00897B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomLeft,
    showStripe: true,
  ),
];

int _stableIndex(String seed) {
  if (seed.isEmpty) return 0;

  var hash = 17;
  for (final unit in seed.codeUnits) {
    hash = 37 * hash + unit;
  }
  return hash.abs() % _variants.length;
}

String _initialsFromName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) return 'PS';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();

  final first = parts.first.substring(0, 1).toUpperCase();
  final second = parts.last.substring(0, 1).toUpperCase();
  return '$first$second';
}
