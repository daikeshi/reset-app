import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/activity_type.dart';
import '../state/reset_app_state.dart';
import '../theme/reset_theme.dart';
import '../widgets/reset_panel.dart';
import '../widgets/stat_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.appState});

  final ResetAppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: DecoratedBox(
        decoration: ResetDecorations.screen(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1000;
            final maxContentWidth = wide ? 980.0 : 760.0;
            final topCards = Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Today',
                    value: appState.breaksToday.toString(),
                    subtitle: 'breaks',
                    icon: Icons.wb_sunny_rounded,
                    color: ResetColors.warmAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'This Week',
                    value: appState.breaksThisWeek.toString(),
                    subtitle: 'breaks',
                    icon: Icons.calendar_month_rounded,
                    color: ResetColors.accentBlue,
                  ),
                ),
              ],
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              children: [
                Center(
                  child: SizedBox(
                    width: maxContentWidth,
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    topCards,
                                    const SizedBox(height: 18),
                                    _StreakCard(
                                      streak: appState.currentStreak,
                                    ),
                                    const SizedBox(height: 18),
                                    _TotalCard(appState: appState),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: _ActivityChart(
                                  breakdown: appState.activityBreakdown,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              topCards,
                              const SizedBox(height: 18),
                              _StreakCard(streak: appState.currentStreak),
                              const SizedBox(height: 18),
                              _TotalCard(appState: appState),
                              const SizedBox(height: 18),
                              _ActivityChart(
                                breakdown: appState.activityBreakdown,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: ResetColors.warmAccent,
                size: 34,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak.toString(),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: ResetColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'day streak',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ResetColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: ResetColors.muted,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Maintain 3+ breaks per day',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ResetColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.appState});

  final ResetAppState appState;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TotalMetric(value: appState.totalBreaks, label: 'total breaks'),
          Container(
            width: 1,
            height: 52,
            color: Colors.black.withValues(alpha: 0.10),
          ),
          _TotalMetric(value: appState.totalMinutes, label: 'mins moved'),
        ],
      ),
    );
  }
}

class _TotalMetric extends StatelessWidget {
  const _TotalMetric({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: ResetColors.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ResetColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({required this.breakdown});

  final Map<ActivityType, int> breakdown;

  @override
  Widget build(BuildContext context) {
    final entries = ActivityType.values
        .where((type) => (breakdown[type] ?? 0) > 0)
        .map((type) => MapEntry(type, breakdown[type]!))
        .toList();

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ResetColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            SizedBox(
              height: 190,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 44,
                      color: ResetColors.muted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No data yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ResetColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Complete your first break to see stats',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ResetColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 230,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: false),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: ResetColors.border, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: ResetColors.muted),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: 58,
                              child: Text(
                                entries[index].key.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: ResetColors.muted,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var index = 0; index < entries.length; index++)
                      BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: entries[index].value.toDouble(),
                            width: 20,
                            borderRadius: BorderRadius.circular(5),
                            color: _colorFor(entries[index].key),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _colorFor(ActivityType type) {
    switch (type) {
      case ActivityType.stretch:
        return ResetColors.primary;
      case ActivityType.walk:
        return ResetColors.accentBlue;
      case ActivityType.eyes:
        return ResetColors.success;
      case ActivityType.hydrate:
        return const Color(0xFF16A3D8);
      case ActivityType.workout:
        return ResetColors.warmAccent;
      case ActivityType.meditation:
        return const Color(0xFFB75CE5);
    }
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResetPanel(padding: const EdgeInsets.all(16), child: child);
  }
}
