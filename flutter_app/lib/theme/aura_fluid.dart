import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Fluid design curves and spring physics for natural tactile micro-interactions.
class AuraCurves {
  AuraCurves._();

  /// Snappy fluid spring curve for buttons and interactive press states.
  static const Curve fluidSpring = Cubic(0.175, 0.885, 0.32, 1.15);

  /// Smooth fluid ease out curve for page transitions, sheet reveals, and modals.
  static const Curve fluidEaseOut = Cubic(0.16, 1.0, 0.3, 1.0);

  /// Elastic organic curve for Orb pulsing and fluid gauge fill animations.
  static const Curve fluidOrganic = Cubic(0.25, 0.1, 0.25, 1.0);
}

/// Centralized Fluid UI scaling and responsive layout engine for AURA.
/// Smoothly clamps and interpolates typography, spacing, and dimensions
/// across mobile (375px), tablet (768px), and desktop/wide (1200px+) displays.
class AuraFluid {
  AuraFluid._();

  static const double minScreenWidth = 375.0;
  static const double maxScreenWidth = 1200.0;
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  /// Calculates a fluidly interpolated value between [min] and [max]
  /// according to current screen width.
  static double scale(
    BuildContext context,
    double min,
    double max, {
    double minWidth = minScreenWidth,
    double maxWidth = maxScreenWidth,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width <= minWidth) return min;
    if (width >= maxWidth) return max;
    final progress = (width - minWidth) / (maxWidth - minWidth);
    return min + (max - min) * progress;
  }

  /// Calculates a fluid font size with strict legibility clamping.
  static double fontSize(BuildContext context, double min, double max) {
    return scale(context, min, max, minWidth: 360, maxWidth: 1080);
  }

  /// Calculates fluid symmetrical horizontal padding.
  static EdgeInsets horizontalPadding(
    BuildContext context, {
    double min = 16.0,
    double max = 32.0,
  }) {
    final pad = scale(context, min, max);
    return EdgeInsets.symmetric(horizontal: pad);
  }

  /// Returns recommended grid column count based on available width.
  static int gridColumns(BuildContext context, {double minItemWidth = 260.0}) {
    final width = MediaQuery.of(context).size.width;
    final count = (width / minItemWidth).floor();
    return math.max(1, math.min(count, 4));
  }
}

/// Extension on [BuildContext] providing intuitive, fluid layout helpers.
extension AuraFluidExtension on BuildContext {
  /// Screen size dimensions
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// Responsive Breakpoints
  bool get isMobile => screenWidth < AuraFluid.mobileBreakpoint;
  bool get isTablet => screenWidth >= AuraFluid.mobileBreakpoint && screenWidth < AuraFluid.tabletBreakpoint;
  bool get isDesktop => screenWidth >= AuraFluid.tabletBreakpoint;
  bool get isWide => screenWidth >= AuraFluid.desktopBreakpoint;

  /// Fluid scaling helper
  double fluid(double min, double max) => AuraFluid.scale(this, min, max);
  double fluidFont(double min, double max) => AuraFluid.fontSize(this, min, max);
  double fluidSpace(double min, double max) => AuraFluid.scale(this, min, max);

  /// Fluid horizontal page padding
  EdgeInsets get fluidPagePadding => AuraFluid.horizontalPadding(this, min: 16.0, max: 32.0);

  /// Optimal content constraint width (prevents overstretched UI on widescreen web)
  double get maxFluidContentWidth {
    if (isDesktop) return 760.0;
    if (isTablet) return 640.0;
    return double.infinity;
  }
}
