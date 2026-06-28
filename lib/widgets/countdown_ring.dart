import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/reset_theme.dart';

class CountdownRing extends StatelessWidget {
  const CountdownRing({
    super.key,
    required this.progress,
    required this.label,
    required this.caption,
    this.size = 230,
    this.semanticsLabel = 'Break countdown timer',
  });

  final double progress;
  final String label;
  final String caption;
  final double size;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Semantics(
      label: semanticsLabel,
      value: '$label $caption',
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ResetColors.primary.withValues(alpha: 0.18),
                    ResetColors.accentBlue.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.56, 1],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ResetColors.primary.withValues(alpha: 0.10),
                    blurRadius: 36,
                    spreadRadius: -10,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: SizedBox.square(dimension: size),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.58),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.86),
                  width: 1.2,
                ),
                boxShadow: ResetShadows.panel,
              ),
              child: SizedBox.square(dimension: size - 46),
            ),
            CustomPaint(
              size: Size.square(size - 40),
              painter: _RingPainter(progress: clampedProgress),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: ResetColors.ink,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  caption,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ResetColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = ResetColors.track;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [ResetColors.primary, ResetColors.accentBlue],
      ).createShader(rect);

    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
