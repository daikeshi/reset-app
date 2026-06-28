# Reset Flutter Conversion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the existing SwiftUI/Xcode Reset app with a Flutter implementation that preserves the current break reminder behavior.

**Architecture:** Build a standard Flutter app at the repository root. Keep behavior in small Dart models/services/state classes, with feature screens for Home, Break, Stats, and Settings. Use local persistence and local notification services behind interfaces so core behavior can be unit-tested without platform channels.

**Tech Stack:** Flutter, Dart, `shared_preferences`, `flutter_local_notifications`, `fl_chart`, `intl`, `flutter_test`.

---

## File Structure

- Delete: `BreakView.swift`, `ContentView.swift`, `DataManager.swift`, `HomeView.swift`, `Models.swift`, `NotificationManager.swift`, `ResetApp.swift`, `SettingsView.swift`, `StatsView.swift`, `Reset.xcodeproj/`, `project.yml`.
- Modify: `README.md` to describe Flutter setup and run commands.
- Create: `pubspec.yaml` for Flutter dependencies and app metadata.
- Create: `lib/main.dart` for app startup, theme, and state injection.
- Create: `lib/models/activity_type.dart` for activity categories, icons, and suggestions.
- Create: `lib/models/break_log.dart` for persisted break records.
- Create: `lib/models/user_settings.dart` for settings defaults and allowed values.
- Create: `lib/services/storage_service.dart` for JSON-backed `SharedPreferences` persistence.
- Create: `lib/services/notification_service.dart` for permission, scheduling, and cancellation.
- Create: `lib/state/reset_app_state.dart` for settings, logs, totals, streaks, and scheduling coordination.
- Create: `lib/screens/home_screen.dart`, `lib/screens/break_screen.dart`, `lib/screens/stats_screen.dart`, `lib/screens/settings_screen.dart`.
- Create: `lib/widgets/countdown_ring.dart`, `lib/widgets/stat_card.dart`, `lib/widgets/gradient_action_button.dart`.
- Create: `test/models_and_state_test.dart` for unit tests covering activity data, serialization, stats, and streaks.
- Create or keep generated platform folders: `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`, depending on `flutter create` output.

## Task 1: Tooling And Scaffold

**Files:**
- Create/Modify generated Flutter files at repository root.
- Delete existing Swift/Xcode files only after the Flutter scaffold exists.

- [ ] **Step 1: Confirm Flutter availability**

Run: `flutter --version`

Expected: exit 0 and a Flutter version. If the command is missing, install Flutter with Homebrew or add an existing SDK to PATH.

- [ ] **Step 2: Scaffold the project**

Run: `flutter create --project-name reset --org com.reset .`

Expected: Flutter creates `pubspec.yaml`, `lib/main.dart`, `test/widget_test.dart`, and platform directories without deleting the approved design/spec docs.

- [ ] **Step 3: Replace generated dependencies**

Set `pubspec.yaml` dependencies to:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.3.5
  flutter_local_notifications: ^18.0.1
  fl_chart: ^0.69.2
  intl: ^0.20.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

- [ ] **Step 4: Fetch dependencies**

Run: `flutter pub get`

Expected: dependencies resolve and `pubspec.lock` is written.

## Task 2: Test Core Models And State First

**Files:**
- Create: `test/models_and_state_test.dart`

- [ ] **Step 1: Write failing tests**

Add tests that import the future model/state APIs and assert:

```dart
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

test('stats count completed breaks only', () {
  final now = DateTime(2026, 5, 10, 12);
  final state = ResetAppState.test(
    now: () => now,
    logs: [
      BreakLog(id: '1', timestamp: now, activityType: ActivityType.walk, durationSeconds: 300, completed: true),
      BreakLog(id: '2', timestamp: now, activityType: ActivityType.stretch, durationSeconds: 0, completed: false),
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
```

- [ ] **Step 2: Run tests and verify RED**

Run: `flutter test test/models_and_state_test.dart`

Expected: FAIL because model/state files and APIs do not exist yet.

## Task 3: Implement Models

**Files:**
- Create: `lib/models/activity_type.dart`
- Create: `lib/models/break_log.dart`
- Create: `lib/models/user_settings.dart`

- [ ] **Step 1: Implement model APIs**

Create enums/classes matching the test API:

```dart
enum ActivityType { stretch, walk, eyes, hydrate, workout, meditation }

class BreakLog {
  const BreakLog({
    required this.id,
    required this.timestamp,
    required this.activityType,
    required this.durationSeconds,
    required this.completed,
  });
}

class UserSettings {
  const UserSettings({
    this.reminderIntervalMinutes = 60,
    this.breakDurationMinutes = 5,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
  });
}
```

- [ ] **Step 2: Run tests**

Run: `flutter test test/models_and_state_test.dart`

Expected: model-related tests pass once JSON/equality are implemented; state tests still fail until Task 4.

## Task 4: Implement Services And App State

**Files:**
- Create: `lib/services/storage_service.dart`
- Create: `lib/services/notification_service.dart`
- Create: `lib/state/reset_app_state.dart`

- [ ] **Step 1: Implement testable state**

Create `ResetAppState` with:

```dart
class ResetAppState extends ChangeNotifier {
  ResetAppState({required StorageService storage, required NotificationService notifications})
      : _storage = storage,
        _notifications = notifications;

  ResetAppState.test({DateTime Function()? now, List<BreakLog> logs = const []});

  int get breaksToday;
  int get breaksThisWeek;
  int get totalBreaks;
  int get totalMinutes;
  int get currentStreak;
  Map<ActivityType, int> get activityBreakdown;
  void logCompletedBreak(ActivityType type, {required int durationSeconds});
  void logSkippedBreak(ActivityType type);
}
```

- [ ] **Step 2: Run tests and verify GREEN**

Run: `flutter test test/models_and_state_test.dart`

Expected: PASS.

## Task 5: Implement Screens And Widgets

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/screens/home_screen.dart`
- Create: `lib/screens/break_screen.dart`
- Create: `lib/screens/stats_screen.dart`
- Create: `lib/screens/settings_screen.dart`
- Create: `lib/widgets/countdown_ring.dart`
- Create: `lib/widgets/stat_card.dart`
- Create: `lib/widgets/gradient_action_button.dart`

- [ ] **Step 1: Build app shell**

Implement `MaterialApp` with a purple theme and a bottom navigation bar with Home, Stats, and Settings tabs.

- [ ] **Step 2: Build Home**

Show countdown ring, streak, today count, total minutes, and "Take Break Now".

- [ ] **Step 3: Build Break flow**

Show random activity, configured timer, start/skip/cancel/complete controls, and log into `ResetAppState`.

- [ ] **Step 4: Build Stats**

Show summary cards, streak card, totals, and an `fl_chart` bar chart for activity breakdown.

- [ ] **Step 5: Build Settings**

Show notification/sound toggles, interval/duration pickers, quiet hours display, version, rate, and share links.

## Task 6: Platform Notification Configuration

**Files:**
- Modify: `ios/Runner/Info.plist`
- Modify: `lib/services/notification_service.dart`

- [ ] **Step 1: Configure notification service**

Initialize `flutter_local_notifications` for iOS and Android. Request permissions before scheduling reminders. Schedule a repeating local notification based on `reminderIntervalMinutes`, using sound only when `soundEnabled` is true.

- [ ] **Step 2: Configure iOS permission copy**

Ensure the iOS project contains user-facing permission text for notifications where Flutter/iOS requires it.

## Task 7: Remove Native SwiftUI App And Update Docs

**Files:**
- Delete native Swift/Xcode files listed in File Structure.
- Modify: `README.md`

- [ ] **Step 1: Remove native app files**

Run: `rm -rf Reset.xcodeproj *.swift project.yml`

Expected: Swift/Xcode implementation is removed, Flutter project files remain.

- [ ] **Step 2: Update README**

Document:

```markdown
# Reset — Flutter App

A break reminder app for remote workers.

## Setup

flutter pub get

## Run

flutter run

## Test

flutter analyze
flutter test
```

## Task 8: Verify Conversion

**Files:**
- All changed files.

- [ ] **Step 1: Format**

Run: `dart format lib test`

Expected: files formatted.

- [ ] **Step 2: Static analysis**

Run: `flutter analyze`

Expected: no issues.

- [ ] **Step 3: Tests**

Run: `flutter test`

Expected: all tests pass.

- [ ] **Step 4: Final status check**

Run: `git status --short`

Expected: shows the intentional Flutter conversion diff only.
