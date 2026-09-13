import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reset/main.dart';
import 'package:reset/models/user_settings.dart';
import 'package:reset/screens/break_screen.dart';
import 'package:reset/state/reset_app_state.dart';
import 'package:reset/widgets/countdown_ring.dart';
import 'package:reset/widgets/gradient_action_button.dart';

import 'regression_test.dart' show MemoryStorage, FakeNotifications;

void main() {
  test('reminders only run during a manually started focus session', () async {
    var now = DateTime(2026, 9, 13, 12);
    final notifications = FakeNotifications();
    final state = ResetAppState(
      storage: MemoryStorage(),
      notifications: notifications,
      now: () => now,
    );
    await state.initialize();
    expect(state.isFocusing, isFalse);
    expect(notifications.schedules, 0);
    await state.setReminderInterval(30);
    await state.setSoundEnabled(false);
    await state.setNotificationsEnabled(true);
    expect(notifications.schedules, 0);

    await state.startFocus();
    final deadline = state.focusDeadline;
    expect(deadline, now.add(const Duration(minutes: 30)));
    expect(notifications.schedules, 1);
    now = now.add(const Duration(minutes: 5));
    await state.startFocus();
    expect(state.focusDeadline, deadline);
    expect(notifications.schedules, 1);

    await state.stopFocus();
    expect(state.focusDeadline, isNull);
    expect(notifications.cancellations, greaterThan(0));
    await state.setReminderInterval(45);
    expect(notifications.schedules, 1);
  });

  testWidgets('focus stays idle until Start Focus is tapped', (tester) async {
    var now = DateTime(2026, 9, 13, 12);
    final state = ResetAppState.test(
      now: () => now,
      settings: const UserSettings(notificationsEnabled: false),
    );
    await tester.pumpWidget(ResetApp(appState: state));
    expect(find.text('Start Focus'), findsOneWidget);
    expect(find.text('ready to focus'), findsOneWidget);
    now = now.add(const Duration(hours: 2));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(BreakScreen), findsNothing);
    expect(
      tester.widget<CountdownRing>(find.byType(CountdownRing)).label,
      '55:00',
    );

    await tester.tap(find.byKey(const ValueKey('home-focus-action')));
    await tester.pumpAndSettle();
    expect(find.text('Focus Running'), findsOneWidget);
    expect(
      tester
          .widget<GradientActionButton>(
            find.byKey(const ValueKey('home-focus-action')),
          )
          .onPressed,
      isNull,
    );
    now = now.add(const Duration(minutes: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(
      tester.widget<CountdownRing>(find.byType(CountdownRing)).label,
      '54:00',
    );
    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Focus Running'), findsOneWidget);
  });

  testWidgets('finishing a break returns to idle until the next Start Focus', (
    tester,
  ) async {
    var now = DateTime(2026, 9, 13, 12);
    final state = ResetAppState.test(
      now: () => now,
      settings: const UserSettings(notificationsEnabled: false),
    );
    await tester.pumpWidget(ResetApp(appState: state));
    await tester.tap(find.byKey(const ValueKey('home-focus-action')));
    await tester.pumpAndSettle();
    now = now.add(const Duration(minutes: 55));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(BreakScreen), findsOneWidget);
    expect(state.isFocusing, isFalse);
    await tester.ensureVisible(find.text('Skip this break'));
    await tester.tap(find.text('Skip this break'));
    await tester.pumpAndSettle();
    now = now.add(const Duration(hours: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(BreakScreen), findsNothing);
    expect(find.text('Start Focus'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('home-focus-action')));
    await tester.tap(find.byKey(const ValueKey('home-focus-action')));
    await tester.pumpAndSettle();
    expect(state.isFocusing, isTrue);
    expect(
      tester.widget<CountdownRing>(find.byType(CountdownRing)).label,
      '55:00',
    );
  });
}
