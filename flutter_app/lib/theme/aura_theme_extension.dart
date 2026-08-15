import 'package:flutter/material.dart';
import '../models/models.dart';
import 'aura_colors.dart';

/// Flutter ThemeExtension for typed, dynamic access to AURA styling tokens.
@immutable
class AuraThemeExtension extends ThemeExtension<AuraThemeExtension> {
  final CoachSoul soul;
  final Color primary;
  final Color secondary;
  final Color scaffoldBackground;
  final Color surfaceCard;
  final Color surfaceLight;
  final Color accentGlow;
  final Color borderSubtle;
  final Color textMuted;
  final Color energyAccent;
  final Color proteinAccent;
  final Color waterAccent;

  const AuraThemeExtension({
    required this.soul,
    required this.primary,
    required this.secondary,
    required this.scaffoldBackground,
    required this.surfaceCard,
    required this.surfaceLight,
    required this.accentGlow,
    required this.borderSubtle,
    required this.textMuted,
    required this.energyAccent,
    required this.proteinAccent,
    required this.waterAccent,
  });

  factory AuraThemeExtension.fromSoul(CoachSoul soul) {
    final palette = AuraColors.getSoulPalette(soul);
    return AuraThemeExtension(
      soul: soul,
      primary: palette.primary,
      secondary: palette.secondary,
      scaffoldBackground: palette.scaffoldBackground,
      surfaceCard: palette.surfaceCard,
      surfaceLight: palette.surfaceLight,
      accentGlow: palette.accentGlow,
      borderSubtle: AuraColors.borderSubtle,
      textMuted: AuraColors.textSecondary,
      energyAccent: AuraColors.energy,
      proteinAccent: AuraColors.protein,
      waterAccent: AuraColors.water,
    );
  }

  @override
  AuraThemeExtension copyWith({
    CoachSoul? soul,
    Color? primary,
    Color? secondary,
    Color? scaffoldBackground,
    Color? surfaceCard,
    Color? surfaceLight,
    Color? accentGlow,
    Color? borderSubtle,
    Color? textMuted,
    Color? energyAccent,
    Color? proteinAccent,
    Color? waterAccent,
  }) {
    return AuraThemeExtension(
      soul: soul ?? this.soul,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      accentGlow: accentGlow ?? this.accentGlow,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textMuted: textMuted ?? this.textMuted,
      energyAccent: energyAccent ?? this.energyAccent,
      proteinAccent: proteinAccent ?? this.proteinAccent,
      waterAccent: waterAccent ?? this.waterAccent,
    );
  }

  @override
  AuraThemeExtension lerp(ThemeExtension<AuraThemeExtension>? other, double t) {
    if (other is! AuraThemeExtension) return this;
    return AuraThemeExtension(
      soul: t < 0.5 ? soul : other.soul,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      scaffoldBackground: Color.lerp(scaffoldBackground, other.scaffoldBackground, t) ?? scaffoldBackground,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t) ?? surfaceCard,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t) ?? surfaceLight,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t) ?? accentGlow,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t) ?? borderSubtle,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      energyAccent: Color.lerp(energyAccent, other.energyAccent, t) ?? energyAccent,
      proteinAccent: Color.lerp(proteinAccent, other.proteinAccent, t) ?? proteinAccent,
      waterAccent: Color.lerp(waterAccent, other.waterAccent, t) ?? waterAccent,
    );
  }
}

/// Convenience BuildContext extension for swift UI token consumption
extension AuraThemeContext on BuildContext {
  AuraThemeExtension get auraTheme =>
      Theme.of(this).extension<AuraThemeExtension>() ?? AuraThemeExtension.fromSoul(CoachSoul.supporter);
}
