import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reset/main.dart';
import 'package:reset/models/activity_type.dart';
import 'package:reset/models/break_log.dart';
import 'package:reset/models/user_settings.dart';
import 'package:reset/screens/break_screen.dart';
import 'package:reset/state/reset_app_state.dart';
import 'package:reset/widgets/countdown_ring.dart';

class MemoryStorage implements ResetStorage {
  UserSettings settings = const UserSettings();
  List<BreakLog> logs = [];
  bool failSave = false;
  bool failRead = false;

  @override
  Future<UserSettings> loadSettings() async => settings;
  @override
  Future<List<BreakLog>> loadBreakLogs() async {
    if (failRead) throw StateError('Storage read unavailable');
    return logs;
  }

  @override
  Future<void> saveSettings(UserSettings value) async {
    if (failSave) throw StateError('Storage unavailable');
    settings = value;
  }

  @override
  Future<void> saveBreakLogs(List<BreakLog> value) async {
    if (failSave) throw StateError('Storage unavailable');
    logs = List.of(value);
  }
}

class FakeNotifications implements ResetNotifications {
  bool granted = true;
  bool failInitialize = false;
  bool failSchedule = false;
  bool failAuthorization = false;
  int requests = 0;
  int schedules = 0;
  int cancellations = 0;

  @override
  Future<void> initialize() async {
    if (failInitialize) throw StateError('Notifications unavailable');
  }

  @override
  Future<bool> requestAuthorization({required bool sound}) async {
    if (failAuthorization) throw StateError('Authorization unavailable');
    requests++;
    return granted;
  }

  @override
  Future<void> scheduleBreakReminder(UserSettings settings) async {
    if (failSchedule) throw StateError('Scheduling unavailable');
    schedules++;
  }

  @override
  Future<void> cancelAll() async {
    cancellations++;
  }
}

void main() {
  test('sound authorization failure remains visible for retry', () async {
    final storage = MemoryStorage();
    final notifications = FakeNotifications();
    final state = ResetAppState(storage: storage, notifications: notifications);
    await state.initialize();
    notifications.failAuthorization = true;
    await state.setSoundEnabled(true);
    expect(state.notificationError, isNotNull);
    expect(state.settings.notificationsEnabled, isFalse);
  });

  testWidgets(
    'failed startup read offers retry without replacing saved history',
    (tester) async {
      final storage = MemoryStorage()
        ..settings = const UserSettings(notificationsEnabled: false)
        ..logs = [
          BreakLog(
            id: 'saved',
            timestamp: DateTime(2026, 9, 13),
            activityType: ActivityType.walk,
            durationSeconds: 60,
            completed: true,
          ),
        ]
        ..failRead = true;
      final state = ResetAppState(
        storage: storage,
        notifications: FakeNotifications(),
      );
      await tester.pumpWidget(ResetAppLoader(appState: state));
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-primary-action')), findsNothing);
      expect(storage.logs.single.id, 'saved');
      storage.failRead = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('home-primary-action')), findsOneWidget);
      expect(state.breakLogs.single.id, 'saved');
    },
  );

  test(
    'scheduling failure disables reminders without blocking settings',
    () async {
      final storage = MemoryStorage();
      final notifications = FakeNotifications();
      final state = ResetAppState(
        storage: storage,
        notifications: notifications,
      );
      await state.initialize();
      notifications.failSchedule = true;
      await state.setReminderInterval(30);
      expect(state.settings.reminderIntervalMinutes, 30);
      expect(state.settings.notificationsEnabled, isFalse);
      expect(state.notificationError, isNotNull);
      expect(storage.settings.notificationsEnabled, isFalse);
      notifications.failSchedule = false;
      expect(await state.setNotificationsEnabled(true), isTrue);
      expect(state.notificationError, isNull);
    },
  );

  testWidgets('automatic reminder opens once and only while foregrounded', (
    tester,
  ) async {
    var now = DateTime(2026, 9, 13, 12);
    final state = ResetAppState.test(
      now: () => now,
      settings: const UserSettings(notificationsEnabled: false),
    );
    await tester.pumpWidget(ResetApp(appState: state));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    now = now.add(const Duration(hours: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(BreakScreen), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(BreakScreen, skipOffstage: false), findsOneWidget);
    now = now.add(const Duration(hours: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(BreakScreen, skipOffstage: false), findsOneWidget);
    await tester.ensureVisible(find.text('Skip this break'));
    await tester.tap(find.text('Skip this break'));
    await tester.pumpAndSettle();
    expect(state.breakLogs.single.completed, isFalse);
    expect(state.breaksToday, 0);
  });

  testWidgets('break save can be retried without duplicate history', (
    tester,
  ) async {
    final storage = MemoryStorage()
      ..settings = const UserSettings(notificationsEnabled: false);
    final state = ResetAppState(
      storage: storage,
      notifications: FakeNotifications(),
    );
    await state.initialize();
    await tester.pumpWidget(ResetApp(appState: state));
    await tester.tap(find.byKey(const ValueKey('home-primary-action')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Skip this break'));
    storage.failSave = true;
    await tester.tap(find.text('Skip this break'));
    await tester.pumpAndSettle();
    expect(state.breakLogs, isEmpty);
    expect(
      find.text('Could not save this break. Please try again.'),
      findsOneWidget,
    );
    storage.failSave = false;
    // Let the failure message disappear before retrying the button beneath it.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip this break'));
    await tester.pump();
    // The outgoing route is still mounted during its dismissal animation.
    final button = find.text('Skip this break');
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button, warnIfMissed: false);
    }
    await tester.pumpAndSettle();
    expect(state.breakLogs, hasLength(1));
    expect(storage.logs, hasLength(1));
  });

  testWidgets('small screen keeps actions reachable with large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final state = ResetAppState.test(
      settings: const UserSettings(notificationsEnabled: false),
    );
    await tester.pumpWidget(ResetApp(appState: state));
    await tester.ensureVisible(
      find.byKey(const ValueKey('home-primary-action')),
    );
    await tester.tap(find.byKey(const ValueKey('home-primary-action')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Skip this break'));
    await tester.tap(find.text('Skip this break'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
  });

  test('startup verifies permission and persists denial', () async {
    final storage = MemoryStorage();
    final notifications = FakeNotifications()..granted = false;
    final state = ResetAppState(storage: storage, notifications: notifications);
    await state.initialize();
    expect(notifications.requests, 1);
    expect(notifications.schedules, 0);
    expect(state.settings.notificationsEnabled, isFalse);
    expect(storage.settings.notificationsEnabled, isFalse);
  });

  test(
    'notification initialization failure preserves usable local state',
    () async {
      final storage = MemoryStorage();
      final notifications = FakeNotifications()..failInitialize = true;
      final state = ResetAppState(
        storage: storage,
        notifications: notifications,
      );
      await state.initialize();
      expect(state.isLoaded, isTrue);
      expect(state.settings.notificationsEnabled, isFalse);
      await state.setBreakDuration(3);
      expect(state.settings.breakDurationMinutes, 3);
    },
  );

  test('stored timing settings are clamped to supported ranges', () {
    final settings = UserSettings.fromJson({
      'reminderIntervalMinutes': 0,
      'breakDurationMinutes': -3,
    });
    expect(
      settings.reminderIntervalMinutes,
      UserSettings.minReminderIntervalMinutes,
    );
    expect(settings.breakDurationMinutes, UserSettings.minBreakDurationMinutes);
  });

  test('streak uses calendar days through spring and fall daylight saving', () {
    for (final day in [DateTime(2026, 3, 9, 12), DateTime(2026, 11, 2, 12)]) {
      final logs = <BreakLog>[];
      for (var offset = 0; offset < 4; offset++) {
        for (var index = 0; index < 3; index++) {
          logs.add(
            BreakLog(
              id: '$offset-$index',
              timestamp: DateTime(day.year, day.month, day.day - offset, 12),
              activityType: ActivityType.walk,
              durationSeconds: 60,
              completed: true,
            ),
          );
        }
      }
      expect(ResetAppState.test(now: () => day, logs: logs).currentStreak, 4);
    }
  });

  testWidgets('changing focus time resets the visible countdown', (
    tester,
  ) async {
    final state = ResetAppState.test(
      now: () => DateTime(2026, 9, 13, 12),
      settings: const UserSettings(notificationsEnabled: false),
    );
    await tester.pumpWidget(ResetApp(appState: state));
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('focus-time-input')),
      '30',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    final ring = tester.widget<CountdownRing>(find.byType(CountdownRing));
    expect(ring.label, anyOf('30:00', '29:59'));
    expect(ring.progress, lessThan(0.01));
  });

  testWidgets('break completes by elapsed time after background suspension', (
    tester,
  ) async {
    var now = DateTime(2026, 9, 13, 12);
    final state = ResetAppState.test(
      now: () => now,
      settings: const UserSettings(
        notificationsEnabled: false,
        breakDurationMinutes: 1,
      ),
    );
    await tester.pumpWidget(ResetApp(appState: state));
    await tester.tap(find.byKey(const ValueKey('home-primary-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('break-primary-action')));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(const Duration(minutes: 2));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Complete!'), findsOneWidget);
    await tester.tap(find.text('Complete!'));
    await tester.pumpAndSettle();
    expect(state.breaksToday, 1);
    expect(state.totalMinutes, 1);
  });

  testWidgets('automatic focus deadline cannot stack break routes', (
    tester,
  ) async {
    var now = DateTime(2026, 9, 13, 12);
    final state = ResetAppState.test(
      now: () => now,
      settings: const UserSettings(notificationsEnabled: false),
    );
    await tester.pumpWidget(ResetApp(appState: state));
    now = now.add(const Duration(minutes: 54));
    await tester.tap(find.byKey(const ValueKey('home-primary-action')));
    await tester.pumpAndSettle();
    now = now.add(const Duration(minutes: 2));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(BreakScreen, skipOffstage: false), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    final ring = tester.widget<CountdownRing>(find.byType(CountdownRing));
    expect(ring.label, '55:00');
  });

  testWidgets('failed settings save releases controls for retry', (
    tester,
  ) async {
    final storage = MemoryStorage()
      ..settings = const UserSettings(notificationsEnabled: false);
    final state = ResetAppState(
      storage: storage,
      notifications: FakeNotifications(),
    );
    await state.initialize();
    storage.failSave = true;
    await tester.pumpWidget(ResetApp(appState: state));
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('focus-time-increment')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(state.settings.reminderIntervalMinutes, 55);
    storage.failSave = false;
    await tester.tap(find.byKey(const ValueKey('focus-time-increment')));
    await tester.pumpAndSettle();
    expect(state.settings.reminderIntervalMinutes, 56);
  });
}
