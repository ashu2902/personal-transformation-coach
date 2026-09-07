import 'package:flutter/material.dart';
import '../models/user_profile.dart';

/// Semantic and core color palette for AURA.
class AuraColors {
  AuraColors._();

  // Canonical Design Direction Tokens
  static const Color background = Color(0xFF0B0C0D); // Near-black charcoal canvas
  static const Color surface1 = Color(0xFF121416); // Surface 1
  static const Color surface2 = Color(0xFF191C1F); // Surface 2
  static const Color actionGreen = Color(0xFF39E6A3); // Action Green (Recommended CTA / Completed)
  static const Color auraPurple = Color(0xFFA779FF); // AURA Purple (Presence / Intelligence)
  static const Color warningAmber = Color(0xFFF59E0B); // Muted amber
  static const Color concernCoral = Color(0xFFF87171); // Muted coral

  // Functional / Data Accents
  static const Color energy = Color(0xFF39E6A3); // Action Green (Calories / Energy)
  static const Color protein = Color(0xFF38BDF8); // Sky Blue (Protein)
  static const Color carbs = Color(0xFFFBBF24); // Amber (Carbs)
  static const Color fat = Color(0xFFF87171); // Rose (Fats)
  static const Color water = Color(0xFF38BDF8); // Water / Hydration
  static const Color recovery = Color(0xFFA78BFA); // Purple (Sleep / Recovery)

  // Status & Utility Accents
  static const Color success = Color(0xFF39E6A3); // Action Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Crimson
  static const Color info = Color(0xFF3B82F6); // Blue

  // Neutrals & Text
  static const Color textPrimary = Color(0xFFF5F6F4); // Warm white
  static const Color textSecondary = Color(0xFF929797); // Muted gray
  static const Color textTertiary = Color(0xFF6B7280); // Zinc 500
  static const Color textDisabled = Color(0xFF4B5563); // Zinc 600

  // Standard Border & Dividers (Subtle, non-neon)
  static const Color border = Color(0x1FFFFFFF); // 12% White
  static const Color borderSubtle = Color(0x0FFFFFFF); // 6% White
  static const Color borderHighlight = Color(0x26FFFFFF); // 15% White

  // Coach Soul Palettes
  static const SoulPalette supporter = SoulPalette(
    primary: Color(0xFFA779FF), // Luminous Purple
    secondary: Color(0xFFE0B0FF), // Warm Lavender
    scaffoldBackground: Color(0xFF0B0C0D),
    surfaceCard: Color(0xFF121416),
    surfaceLight: Color(0xFF191C1F),
    accentGlow: Color(0x26A779FF),
  );

  static const SoulPalette pro = SoulPalette(
    primary: Color(0xFF00E5FF), // Electric Cyan
    secondary: Color(0xFF2979FF), // Deep Indigo
    scaffoldBackground: Color(0xFF0B0C0D),
    surfaceCard: Color(0xFF121416),
    surfaceLight: Color(0xFF191C1F),
    accentGlow: Color(0x2600E5FF),
  );

  static const SoulPalette teacher = SoulPalette(
    primary: Color(0xFF00BFA5), // Vivid Teal
    secondary: Color(0xFFB0BEC5), // Cool Metallic Silver
    scaffoldBackground: Color(0xFF0B0C0D),
    surfaceCard: Color(0xFF121416),
    surfaceLight: Color(0xFF191C1F),
    accentGlow: Color(0x2600BFA5),
  );

  /// Helper to get soul palette by enum
  static SoulPalette getSoulPalette(CoachSoul soul) {
    switch (soul) {
      case CoachSoul.supporter:
        return supporter;
      case CoachSoul.pro:
        return pro;
      case CoachSoul.teacher:
        return teacher;
    }
  }

  /// Helper returning primary & secondary pair for quick lookups (e.g. Orb)
  static ({Color primary, Color secondary}) getSoulColors(CoachSoul soul) {
    final palette = getSoulPalette(soul);
    return (primary: palette.primary, secondary: palette.secondary);
  }
}

class SoulPalette {
  final Color primary;
  final Color secondary;
  final Color scaffoldBackground;
  final Color surfaceCard;
  final Color surfaceLight;
  final Color accentGlow;

  const SoulPalette({
    required this.primary,
    required this.secondary,
    required this.scaffoldBackground,
    required this.surfaceCard,
    required this.surfaceLight,
    required this.accentGlow,
  });
}
