import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color chrome;
  final Color heading;
  final Color brandText;
  final Color accent;
  final Color mutedText;
  final Color divider;
  final Color iconCircleBg;
  final Color activeHighlight;

  const AppColors({
    required this.background,
    required this.surface,
    required this.chrome,
    required this.heading,
    required this.brandText,
    required this.accent,
    required this.mutedText,
    required this.divider,
    required this.iconCircleBg,
    required this.activeHighlight,
  });

  static const light = AppColors(
    background: Color(0xFFF3E7D6),
    surface: Color(0xFFFFFAF3),
    chrome: Color(0xFF7C5A3A),
    heading: Color(0xFF4A3B2C),
    brandText: Color(0xFF7C5A3A),
    accent: Color(0xFFE8863A),
    mutedText: Color(0xFF8B7355),
    divider: Color(0xFFE2D1C3),
    iconCircleBg: Color(0xFFDCC8B2),
    activeHighlight: Color(0xFFFFE0B2),
  );

  static const dark = AppColors(
    background: Color(0xFF1B140F),
    surface: Color(0xFF2A2119),
    chrome: Color(0xFF5C4330),
    heading: Color(0xFFEDE0D0),
    brandText: Color(0xFFD9A066),
    accent: Color(0xFFE8863A),
    mutedText: Color(0xFFB0987F),
    divider: Color(0xFF473A2C),
    iconCircleBg: Color(0xFF3E3122),
    activeHighlight: Color(0xFF4A3620),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? chrome,
    Color? heading,
    Color? brandText,
    Color? accent,
    Color? mutedText,
    Color? divider,
    Color? iconCircleBg,
    Color? activeHighlight,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      chrome: chrome ?? this.chrome,
      heading: heading ?? this.heading,
      brandText: brandText ?? this.brandText,
      accent: accent ?? this.accent,
      mutedText: mutedText ?? this.mutedText,
      divider: divider ?? this.divider,
      iconCircleBg: iconCircleBg ?? this.iconCircleBg,
      activeHighlight: activeHighlight ?? this.activeHighlight,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      chrome: Color.lerp(chrome, other.chrome, t)!,
      heading: Color.lerp(heading, other.heading, t)!,
      brandText: Color.lerp(brandText, other.brandText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      iconCircleBg: Color.lerp(iconCircleBg, other.iconCircleBg, t)!,
      activeHighlight: Color.lerp(activeHighlight, other.activeHighlight, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
