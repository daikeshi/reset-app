import 'package:flutter/material.dart';

abstract final class ResetColors {
  static const Color backgroundTop = Color(0xFFF4ECFF);
  static const Color backgroundBottom = Color(0xFFF7FBFF);
  static const Color backgroundGlow = Color(0xFFFFF7FB);

  static const Color primary = Color(0xFF6D4CFF);
  static const Color primaryDeep = Color(0xFF49339D);
  static const Color accentBlue = Color(0xFF4F86F7);
  static const Color warmAccent = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22A06B);

  static const Color ink = Color(0xFF1D1A24);
  static const Color muted = Color(0xFF746D80);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0x1A1D1A24);
  static const Color track = Color(0x171D1A24);
  static const Color disabled = Color(0xFFBDB7C9);
}

abstract final class ResetGradients {
  static const LinearGradient screen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      ResetColors.backgroundTop,
      ResetColors.backgroundGlow,
      ResetColors.backgroundBottom,
    ],
    stops: [0, 0.48, 1],
  );

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ResetColors.primary, ResetColors.accentBlue],
  );

  static const LinearGradient complete = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ResetColors.success, Color(0xFF16A3A6)],
  );
}

abstract final class ResetShadows {
  static List<BoxShadow> get panel => [
    BoxShadow(
      color: ResetColors.primaryDeep.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 14),
    ),
  ];

  static List<BoxShadow> action(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.28),
      blurRadius: 22,
      offset: const Offset(0, 12),
    ),
  ];
}

abstract final class ResetDecorations {
  static BoxDecoration screen() {
    return const BoxDecoration(gradient: ResetGradients.screen);
  }

  static BoxDecoration panel({
    double radius = 20,
    double opacity = 0.82,
    Color borderColor = ResetColors.border,
  }) {
    return BoxDecoration(
      color: ResetColors.surface.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
      boxShadow: ResetShadows.panel,
    );
  }

  static BoxDecoration iconSurface(Color color) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.12)),
    );
  }
}
