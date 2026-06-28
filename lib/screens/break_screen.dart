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

class _BreakScreenState extends State<BreakScreen> {
  late ({ActivityType type, String suggestion}) _activity;
  Timer? _timer;
  late int _timeRemaining;
  bool _isRunning = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _activity = ActivityType.randomSuggestion();
    _timeRemaining = widget.appState.settings.breakDurationMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining <= 1) {
        timer.cancel();
        setState(() {
          _timeRemaining = 0;
          _isComplete = true;
        });
      } else {
        setState(() => _timeRemaining -= 1);
      }
    });
  }

  void _completeBreak() {
    widget.appState.logCompletedBreak(
      _activity.type,
      durationSeconds: widget.appState.settings.breakDurationMinutes * 60,
    );
    widget.onChanged();
    Navigator.of(context).pop();
  }

  void _skipBreak() {
    widget.appState.logSkippedBreak(_activity.type);
    widget.onChanged();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = widget.appState.settings.breakDurationMinutes * 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Break Time'),
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
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
                physics: compact
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
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
                              onPressed: _completeBreak,
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
                              onPressed: _isRunning ? null : _startTimer,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _skipBreak,
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
