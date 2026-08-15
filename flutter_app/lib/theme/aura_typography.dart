import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'aura_colors.dart';

/// Centralized Typography system for AURA.
/// - Syne: Bold, futuristic headings and display figures.
/// - Plus Jakarta Sans: Highly legible body text and sub-labels.
class AuraTypography {
  AuraTypography._();

  // Headings & Brand Text (Syne)
  static TextStyle displayLarge = GoogleFonts.syne(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.02,
    color: AuraColors.textPrimary,
  );

  static TextStyle displayMedium = GoogleFonts.syne(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.02,
    color: AuraColors.textPrimary,
  );

  static TextStyle displaySmall = GoogleFonts.syne(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.01,
    color: AuraColors.textPrimary,
  );

  static TextStyle titleLarge = GoogleFonts.syne(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.01,
    color: AuraColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.syne(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.01,
    color: AuraColors.textPrimary,
  );

  static TextStyle sectionHeader = GoogleFonts.syne(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.4,
  );

  // Body & Labels (Plus Jakarta Sans)
  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.45,
    color: AuraColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AuraColors.textSecondary,
  );

  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.35,
    color: AuraColors.textTertiary,
  );

  static TextStyle labelBold = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AuraColors.textPrimary,
  );

  static TextStyle statNumber = GoogleFonts.syne(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.02,
    color: AuraColors.textPrimary,
  );

  static TextStyle buttonText = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
  );
}
