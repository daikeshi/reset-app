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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _timer;
  bool _breakOpen = false;
  bool _isForeground = true;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    if (_isForeground) _tick();
  }

  void _tick() {
    final deadline = widget.appState.focusDeadline;
    if (!mounted ||
        !_isForeground ||
        _breakOpen ||
        _isStarting ||
        deadline == null) {
      return;
    }

    if (!widget.appState.now.isBefore(deadline)) {
      _openBreak();
    } else {
      setState(() {});
    }
  }

  Future<void> _startFocus() async {
    if (_isStarting || _breakOpen || widget.appState.isFocusing) return;
    setState(() => _isStarting = true);
    await widget.appState.startFocus();
    if (!mounted) return;
    setState(() => _isStarting = false);
    widget.onChanged();
    final error = widget.appState.notificationError;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _openBreak() async {
    if (_breakOpen || _isStarting || !mounted) return;
    _breakOpen = true;
    try {
      await widget.appState.stopFocus();
      if (!mounted) return;
      widget.onChanged();
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => BreakScreen(
            appState: widget.appState,
            onChanged: () {
              widget.onChanged();
              if (mounted) setState(() {});
            },
          ),
        ),
      );
    } finally {
      _breakOpen = false;
      if (mounted) {
        setState(() {});
        widget.onChanged();
      }
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
              physics: const BouncingScrollPhysics(),
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
                          caption: widget.appState.isFocusing
                              ? 'until break'
                              : 'ready to focus',
                          size: ringSize,
                        ),
                        SizedBox(height: compact ? 18 : 24),
                        _HomeSummary(appState: widget.appState),
                        SizedBox(height: compact ? 18 : 28),
                        SizedBox(
                          width: double.infinity,
                          child: GradientActionButton(
                            key: const ValueKey('home-focus-action'),
                            label: _isStarting
                                ? 'Starting…'
                                : widget.appState.isFocusing
                                ? 'Focus Running'
                                : 'Start Focus',
                            icon: widget.appState.isFocusing
                                ? Icons.timer_outlined
                                : Icons.play_arrow_rounded,
                            onPressed:
                                _isStarting ||
                                    widget.appState.isFocusing ||
                                    _breakOpen
                                ? null
                                : _startFocus,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            key: const ValueKey('home-primary-action'),
                            label: const Text('Take Break Now'),
                            icon: const Icon(Icons.free_breakfast_outlined),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: _isStarting || _breakOpen
                                ? null
                                : _openBreak,
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
    return widget.appState.isFocusing ? 1 - (_secondsRemaining / interval) : 0;
  }

  int get _secondsRemaining {
    final interval = widget.appState.settings.reminderIntervalMinutes * 60;
    final deadline = widget.appState.focusDeadline;
    if (deadline == null) return interval;
    return (deadline.difference(widget.appState.now).inMilliseconds / 1000)
        .ceil()
        .clamp(0, interval);
  }

  String get _timeRemaining {
    final seconds = _secondsRemaining;
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
                'Breakstride',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: ResetColors.ink,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Focus. Move. Recharge.',
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
