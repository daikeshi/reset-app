import 'dart:async';

import 'package:flutter/material.dart';

import '../screens/break_screen.dart';
import '../state/reset_app_state.dart';
import '../theme/reset_theme.dart';
import '../widgets/countdown_ring.dart';
import '../widgets/gradient_action_button.dart';
import '../widgets/reset_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.appState,
    required this.onChanged,
  });

  final ResetAppState appState;
  final VoidCallback onChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  late DateTime _nextBreakDate;

  @override
  void initState() {
    super.initState();
    _scheduleNextBreak();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appState.settings.reminderIntervalMinutes !=
        widget.appState.settings.reminderIntervalMinutes) {
      _scheduleNextBreak();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) {
      return;
    }

    if (_nextBreakDate.difference(DateTime.now()).isNegative) {
      _scheduleNextBreak();
      _openBreak();
    } else {
      setState(() {});
    }
  }

  void _scheduleNextBreak() {
    _nextBreakDate = DateTime.now().add(
      Duration(minutes: widget.appState.settings.reminderIntervalMinutes),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openBreak() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BreakScreen(
          appState: widget.appState,
          onChanged: () {
            widget.onChanged();
            setState(() {});
          },
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ResetDecorations.screen(),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 670;
            final ringSize = compact ? 206.0 : 236.0;
            const horizontalPadding = 20.0;
            final availableWidth =
                constraints.maxWidth - (horizontalPadding * 2);
            final contentWidth = constraints.maxWidth >= 720
                ? 560.0
                : availableWidth.clamp(0.0, double.infinity);

            return SingleChildScrollView(
              physics: compact
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                24,
              ),
              child: Center(
                child: SizedBox(
                  width: contentWidth,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Header(appState: widget.appState),
                        SizedBox(height: compact ? 22 : 34),
                        CountdownRing(
                          progress: _progress,
                          label: _timeRemaining,
                          caption: 'until break',
                          size: ringSize,
                        ),
                        SizedBox(height: compact ? 18 : 24),
                        _HomeSummary(appState: widget.appState),
                        SizedBox(height: compact ? 18 : 28),
                        SizedBox(
                          width: double.infinity,
                          child: GradientActionButton(
                            key: const ValueKey('home-primary-action'),
                            label: 'Take Break Now',
                            semanticLabel: 'Take a break now',
                            icon: Icons.play_arrow_rounded,
                            onPressed: _openBreak,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double get _progress {
    final interval = widget.appState.settings.reminderIntervalMinutes * 60;
    final remaining = _nextBreakDate.difference(DateTime.now()).inSeconds;
    return 1 - (remaining / interval);
  }

  String get _timeRemaining {
    final remaining = _nextBreakDate.difference(DateTime.now());
    final seconds = remaining.isNegative ? 0 : remaining.inSeconds;
    final minutesPart = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsPart = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesPart:$secondsPart';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.appState});

  final ResetAppState appState;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: ResetColors.ink,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'A calm rhythm for your workday',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ResetColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!appState.settings.notificationsEnabled) const _AlertChip(),
      ],
    );
  }
}

class _AlertChip extends StatelessWidget {
  const _AlertChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ResetColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 17,
              color: ResetColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              'Alerts off',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: ResetColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSummary extends StatelessWidget {
  const _HomeSummary({required this.appState});

  final ResetAppState appState;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ResetPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: _SummaryMetric(
                value: appState.currentStreak.toString(),
                label: 'day streak',
                icon: Icons.local_fire_department_rounded,
                color: ResetColors.warmAccent,
              ),
            ),
            const _SummaryDivider(),
            Expanded(
              child: _SummaryMetric(
                value: appState.breaksToday.toString(),
                label: 'breaks today',
                icon: Icons.wb_sunny_rounded,
                color: ResetColors.primary,
              ),
            ),
            const _SummaryDivider(),
            Expanded(
              child: _SummaryMetric(
                value: appState.totalMinutes.toString(),
                label: 'mins moved',
                icon: Icons.directions_walk_rounded,
                color: ResetColors.accentBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: ResetDecorations.iconSurface(color),
          child: SizedBox.square(
            dimension: 34,
            child: Icon(icon, size: 19, color: color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: ResetColors.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ResetColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: ResetColors.border,
    );
  }
}
