import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reset/main.dart';
import 'package:reset/models/activity_type.dart';
import 'package:reset/models/break_log.dart';
import 'package:reset/models/user_settings.dart';
import 'package:reset/state/reset_app_state.dart';
import 'package:reset/widgets/countdown_ring.dart';

void main() {
  void setSurfaceSize(WidgetTester tester, Size size) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('polished shell renders home stats and settings', (tester) async {
    setSurfaceSize(tester, const Size(390, 844));
    final now = DateTime(2026, 5, 10, 12);
    final state = ResetAppState.test(
      now: () => now,
      settings: const UserSettings(notificationsEnabled: false),
      logs: [
        BreakLog(
          id: '1',
          timestamp: now,
          activityType: ActivityType.walk,
          durationSeconds: 300,
          completed: true,
        ),
      ],
    );

    await tester.pumpWidget(ResetApp(appState: state));

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CountdownRing &&
            widget.semanticsLabel == 'Break countdown timer',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('reset-bottom-navigation')),
      findsOneWidget,
    );
    expect(
      tester
          .getRect(find.byKey(const ValueKey('reset-bottom-navigation')))
          .right,
      lessThanOrEqualTo(390),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('home-primary-action'))).right,
      lessThanOrEqualTo(390),
    );
    expect(
      tester.getRect(find.text('mins moved')).right,
      lessThanOrEqualTo(390),
    );
    expect(find.text('Reset'), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Activity Breakdown'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Focus Time'), findsOneWidget);
  });

  testWidgets('settings can adjust focus time in one minute increments', (
    tester,
  ) async {
    final state = ResetAppState.test(
      now: () => DateTime(2026, 5, 10, 12),
      settings: const UserSettings(notificationsEnabled: false),
    );

    await tester.pumpWidget(ResetApp(appState: state));

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Focus Time'), findsOneWidget);
    expect(state.settings.reminderIntervalMinutes, 55);

    await tester.tap(find.byKey(const ValueKey('focus-time-decrement')));
    await tester.pumpAndSettle();
    expect(state.settings.reminderIntervalMinutes, 54);

    await tester.tap(find.byKey(const ValueKey('focus-time-increment')));
    await tester.pumpAndSettle();
    expect(state.settings.reminderIntervalMinutes, 55);
  });

  testWidgets('settings can adjust break duration in one minute increments', (
    tester,
  ) async {
    final state = ResetAppState.test(
      now: () => DateTime(2026, 5, 10, 12),
      settings: const UserSettings(notificationsEnabled: false),
    );

    await tester.pumpWidget(ResetApp(appState: state));

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Break Duration'), findsOneWidget);
    expect(state.settings.breakDurationMinutes, 5);

    await tester.tap(find.byKey(const ValueKey('break-duration-decrement')));
    await tester.pumpAndSettle();
    expect(state.settings.breakDurationMinutes, 4);

    await tester.tap(find.byKey(const ValueKey('break-duration-increment')));
    await tester.pumpAndSettle();
    expect(state.settings.breakDurationMinutes, 5);
  });

  testWidgets('settings can type focus time and break duration minutes', (
    tester,
  ) async {
    final state = ResetAppState.test(
      now: () => DateTime(2026, 5, 10, 12),
      settings: const UserSettings(notificationsEnabled: false),
    );

    await tester.pumpWidget(ResetApp(appState: state));

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('focus-time-input')), '72');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(state.settings.reminderIntervalMinutes, 72);

    await tester.enterText(
      find.byKey(const ValueKey('break-duration-input')),
      '7',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(state.settings.breakDurationMinutes, 7);
  });

  testWidgets('polished break flow opens without changing behavior', (
    tester,
  ) async {
    final state = ResetAppState.test(
      now: () => DateTime(2026, 5, 10, 12),
      settings: const UserSettings(notificationsEnabled: false),
    );

    await tester.pumpWidget(ResetApp(appState: state));
    await tester.tap(find.byKey(const ValueKey('home-primary-action')));
    await tester.pumpAndSettle();

    expect(find.text('Break Time'), findsOneWidget);
    expect(find.byKey(const ValueKey('break-countdown-ring')), findsOneWidget);
    expect(find.byKey(const ValueKey('break-primary-action')), findsOneWidget);
    expect(state.totalBreaks, 0);
  });

  testWidgets('shell adapts navigation for phone tablet and desktop widths', (
    tester,
  ) async {
    Future<void> pumpAt(Size size) async {
      setSurfaceSize(tester, size);
      final state = ResetAppState.test(
        now: () => DateTime(2026, 5, 10, 12),
        settings: const UserSettings(notificationsEnabled: false),
      );
      await tester.pumpWidget(ResetApp(appState: state));
      await tester.pumpAndSettle();
    }

    await pumpAt(const Size(390, 844));
    expect(find.byKey(const ValueKey('reset-bottom-navigation')), findsOneWidget);
    expect(find.byKey(const ValueKey('reset-navigation-rail')), findsNothing);

    await pumpAt(const Size(834, 1194));
    expect(find.byKey(const ValueKey('reset-navigation-rail')), findsOneWidget);
    expect(find.byKey(const ValueKey('reset-bottom-navigation')), findsNothing);

    await pumpAt(const Size(1440, 900));
    expect(find.byKey(const ValueKey('reset-navigation-rail')), findsOneWidget);
    expect(find.byKey(const ValueKey('reset-bottom-navigation')), findsNothing);
  });
}
