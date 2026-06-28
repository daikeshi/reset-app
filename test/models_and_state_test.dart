import 'package:test/test.dart';
import 'package:reset/models/activity_type.dart';
import 'package:reset/models/break_log.dart';
import 'package:reset/models/user_settings.dart';
import 'package:reset/state/reset_app_state.dart';

void main() {
  test('every activity type has suggestions', () {
    for (final type in ActivityType.values) {
      expect(type.icon, isNotEmpty);
      expect(type.suggestions, isNotEmpty);
    }
  });

  test('break log round trips through json', () {
    final timestamp = DateTime(2026, 5, 10, 9, 30);
    final log = BreakLog(
      id: 'log-1',
      timestamp: timestamp,
      activityType: ActivityType.walk,
      durationSeconds: 300,
      completed: true,
    );

    expect(BreakLog.fromJson(log.toJson()), log);
  });

  test('default focus time is fifty five minutes', () {
    expect(const UserSettings().reminderIntervalMinutes, 55);
    expect(UserSettings.fromJson(const {}).reminderIntervalMinutes, 55);
  });

  test('stats count completed breaks only', () {
    final now = DateTime(2026, 5, 10, 12);
    final state = ResetAppState.test(
      now: () => now,
      logs: [
        BreakLog(
          id: '1',
          timestamp: now,
          activityType: ActivityType.walk,
          durationSeconds: 300,
          completed: true,
        ),
        BreakLog(
          id: '2',
          timestamp: now,
          activityType: ActivityType.stretch,
          durationSeconds: 0,
          completed: false,
        ),
      ],
    );

    expect(state.breaksToday, 1);
    expect(state.totalBreaks, 2);
    expect(state.totalMinutes, 5);
  });

  test('streak increments after three completed breaks in a day', () {
    final day = DateTime(2026, 5, 10, 12);
    final state = ResetAppState.test(now: () => day);

    state
      ..logCompletedBreak(ActivityType.walk, durationSeconds: 60)
      ..logCompletedBreak(ActivityType.eyes, durationSeconds: 60)
      ..logCompletedBreak(ActivityType.hydrate, durationSeconds: 60);

    expect(state.currentStreak, 1);
  });
}
