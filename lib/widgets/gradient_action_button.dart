import 'package:flutter/material.dart';

import '../theme/reset_theme.dart';

class GradientActionButton extends StatelessWidget {
  const GradientActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.colors = const [ResetColors.primary, ResetColors.accentBlue],
    this.semanticLabel,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final List<Color> colors;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final effectiveColors = enabled
        ? colors
        : [
            ResetColors.disabled.withValues(alpha: 0.78),
            ResetColors.disabled.withValues(alpha: 0.62),
          ];

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel ?? label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: effectiveColors,
          ),
          boxShadow: enabled ? ResetShadows.action(effectiveColors.first) : [],
        ),
        child: ExcludeSemantics(
          child: FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 22),
            label: Text(label, overflow: TextOverflow.ellipsis),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withValues(alpha: 0.76),
              iconColor: Colors.white,
              textStyle: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
