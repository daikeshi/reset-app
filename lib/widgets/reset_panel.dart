import 'package:flutter/material.dart';

import '../theme/reset_theme.dart';

class ResetPanel extends StatelessWidget {
  const ResetPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 20,
    this.opacity = 0.82,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: ResetDecorations.panel(radius: radius, opacity: opacity),
      child: Padding(padding: padding, child: child),
    );
  }
}
