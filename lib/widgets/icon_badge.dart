import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A small branded, gradient-filled circular icon badge used throughout the
/// app for category and list markers — gives a consistent, premium look
/// instead of mismatched default-colored platform emoji.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  const IconBadge(this.icon, {super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.chrome, c.accent],
        ),
        boxShadow: [
          BoxShadow(color: c.chrome.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.5),
    );
  }
}

/// A gradient-filled circular badge showing an English-numeral index —
/// used to give numbered lists (composer sections, stotra lists) a
/// consistent, universally-readable ordinal marker alongside the
/// localized-script title.
class NumberBadge extends StatelessWidget {
  final int number;
  final double size;
  const NumberBadge(this.number, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.chrome, c.accent],
        ),
        boxShadow: [
          BoxShadow(color: c.chrome.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: size * 0.42),
      ),
    );
  }
}
