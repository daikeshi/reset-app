import 'dart:async';

import 'package:flutter/material.dart';

import '../models/activity_type.dart';
import '../state/reset_app_state.dart';
import '../theme/reset_theme.dart';
import '../widgets/countdown_ring.dart';
import '../widgets/gradient_action_button.dart';
import '../widgets/reset_panel.dart';

class BreakScreen extends StatefulWidget {
  const BreakScreen({
    super.key,
    required this.appState,
    required this.onChanged,
  });

  final ResetAppState appState;
  final VoidCallback onChanged;

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> with WidgetsBindingObserver {
  late ({ActivityType type, String suggestion}) _activity;
  Timer? _timer;
  late int _timeRemaining;
  late int _totalSeconds;
  DateTime? _deadline;
  bool _isRunning = false;
  bool _isComplete = false;
  bool _isSaving = false;
  bool _didSave = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activity = ActivityType.randomSuggestion();
    _totalSeconds = widget.appState.settings.breakDurationMinutes * 60;
    _timeRemaining = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning || _isComplete) return;
    _deadline = widget.appState.now.add(Duration(seconds: _totalSeconds));
    setState(() => _isRunning = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimer());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _updateTimer();
  }

  void _updateTimer() {
    if (!mounted || _deadline == null || _isComplete) return;
    final seconds =
        (_deadline!.difference(widget.appState.now).inMilliseconds / 1000)
            .ceil()
            .clamp(0, _totalSeconds);
    setState(() {
      _timeRemaining = seconds;
      _isComplete = seconds == 0;
      if (_isComplete) _isRunning = false;
    });
    if (_isComplete) _timer?.cancel();
  }

  Future<void> _finishBreak({required bool completed}) async {
    if (_isSaving || _didSave) return;
    setState(() => _isSaving = true);
    try {
      if (completed) {
        await widget.appState.logCompletedBreak(
          _activity.type,
          durationSeconds: _totalSeconds,
        );
      } else {
        await widget.appState.logSkippedBreak(_activity.type);
      }
      if (!mounted) return;
      _didSave = true;
      widget.onChanged();
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this break. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _totalSeconds;

    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Break Time'),
          leading: TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          leadingWidth: 88,
        ),
        body: DecoratedBox(
          decoration: ResetDecorations.screen(),
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 650;
                final maxContentWidth = constraints.maxWidth >= 720
                    ? 560.0
                    : double.infinity;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  child: Center(
                    child: SizedBox(
                      width: maxContentWidth,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: compact ? 10 : 24),
                            _ActivityHeader(activity: _activity),
                            SizedBox(height: compact ? 18 : 24),
                            Opacity(
                              opacity: _isRunning || _isComplete ? 1 : 0.42,
                              child: CountdownRing(
                                key: const ValueKey('break-countdown-ring'),
                                size: compact ? 160 : 178,
                                progress: totalSeconds == 0
                                    ? 1
                                    : 1 - (_timeRemaining / totalSeconds),
                                label: _formatTime(_timeRemaining),
                                caption: 'break timer',
                              ),
                            ),
                            SizedBox(height: compact ? 18 : 26),
                            if (_isComplete)
                              GradientActionButton(
                                key: const ValueKey('break-primary-action'),
                                label: 'Complete!',
                                semanticLabel: 'Complete break',
                                icon: Icons.check_circle_rounded,
                                colors: const [
                                  ResetColors.success,
                                  Color(0xFF16A3A6),
                                ],
                                onPressed: _isSaving
                                    ? null
                                    : () => _finishBreak(completed: true),
                              )
                            else ...[
                              GradientActionButton(
                                key: const ValueKey('break-primary-action'),
                                label: _isRunning
                                    ? 'Timer Running'
                                    : 'Start Timer',
                                semanticLabel: _isRunning
                                    ? 'Timer running'
                                    : 'Start break timer',
                                icon: Icons.play_arrow_rounded,
                                onPressed: _isRunning || _isSaving
                                    ? null
                                    : _startTimer,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => _finishBreak(completed: false),
                                child: const Text('Skip this break'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({required this.activity});

  final ({ActivityType type, String suggestion}) activity;

  @override
  Widget build(BuildContext context) {
    return ResetPanel(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ResetColors.primary.withValues(alpha: 0.18),
                  ResetColors.primary.withValues(alpha: 0.06),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.72),
                width: 1.2,
              ),
            ),
            child: SizedBox.square(
              dimension: 108,
              child: Center(
                child: Text(
                  activity.type.icon,
                  style: const TextStyle(fontSize: 52),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            activity.type.label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: ResetColors.primaryDeep,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            activity.suggestion,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ResetColors.ink,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
