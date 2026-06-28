# Reset Flutter Conversion Design

## Decision

Replace the existing native SwiftUI/Xcode implementation with a Flutter app that preserves the current product behavior: a break reminder app for remote workers with countdown reminders, guided break activities, local statistics, streaks, and configurable settings.

The conversion will remove the Swift source files, `Reset.xcodeproj`, and XcodeGen config after the Flutter scaffold is created. The repository root will become a standard Flutter project.

## Goals

- Rebuild feature parity for the current app in Flutter.
- Keep the user-facing structure: Home, Break, Stats, and Settings tabs/screens.
- Store settings and break logs locally on device.
- Schedule local reminder notifications for break prompts.
- Keep the implementation simple and suitable for a small app.

## Non-Goals

- Account sync, cloud storage, analytics, or backend services.
- Redesigning the product beyond matching the current app experience.
- Advanced quiet-hours editing beyond the current displayed default values, unless needed to make notification scheduling correct.
- Publishing, app signing, or App Store setup.

## Architecture

The Flutter app will use a small layered structure:

- `lib/main.dart`: app entry point, theme, root navigation.
- `lib/models/`: `ActivityType`, `BreakLog`, and `UserSettings`.
- `lib/services/`: persistence and local notification scheduling.
- `lib/state/`: app state controller for settings, break logs, totals, and streak calculations.
- `lib/screens/`: Home, Break, Stats, and Settings screens.
- `lib/widgets/`: reusable stat cards, countdown ring, and shared controls.

State management will use Flutter primitives (`ChangeNotifier`, `ValueListenableBuilder`, or `AnimatedBuilder`) rather than a larger framework. This keeps the conversion easy to inspect and close to the existing singleton-style Swift implementation.

## Packages

Expected dependencies:

- `shared_preferences`: local settings and log persistence.
- `flutter_local_notifications`: reminder notifications.
- `fl_chart`: activity breakdown chart.
- `intl`: date/time formatting where helpful.

If a package is unavailable in the local environment, the implementation can fall back to a simpler equivalent while preserving app behavior.

## Feature Mapping

Home screen:

- Shows a circular countdown until the next break.
- Shows current streak, breaks completed today, and total minutes moved.
- Provides a "Take Break Now" action that opens the break flow.

Break screen:

- Picks a random activity category and suggestion.
- Shows the activity icon, title, suggestion, and configured timer.
- Lets the user start the timer, complete the break, cancel, or skip.
- Logs completed breaks with duration and skipped breaks with zero duration.

Stats screen:

- Shows today and weekly break counts.
- Shows current streak and total break/minute counts.
- Shows activity breakdown for completed breaks.
- Shows an empty state before any completed break exists.

Settings screen:

- Toggles notifications and sound.
- Lets users choose reminder interval and break duration from the current options.
- Shows quiet hours start and end values.
- Shows version/about links that match the current app's App Store link behavior.

## Data Flow

On app startup, the state controller loads settings and break logs from local storage. Screens read from the controller and call controller methods for mutations. The controller persists updates immediately after settings changes or break log changes.

Notification scheduling is triggered when notifications are enabled or the reminder interval changes. Disabling notifications cancels pending reminders.

Streaks continue to use the current rule: a day counts toward the streak after at least three completed breaks. During implementation, the existing Swift streak bug will be corrected so the streak can actually increment when a new qualifying day is reached.

## Error Handling

- If persisted data cannot be decoded, the app falls back to defaults rather than crashing.
- If notification permission is denied, the notifications toggle is reset and the app continues without reminders.
- If notification scheduling fails, the app logs/debug-prints the failure and keeps local app state usable.

## Testing And Verification

Verification should include:

- `flutter analyze`
- `flutter test`
- Manual launch on an available simulator or local target if Flutter tooling is installed.
- Smoke testing Home countdown, Break completion, skipped break logging, Settings persistence, and Stats updates.

Focused widget/unit tests should cover:

- Activity suggestion availability.
- Break log persistence serialization.
- Break totals for today and this week.
- Streak calculation for qualifying and non-qualifying days.

## Migration Steps

1. Confirm Flutter is installed or install/use the available local Flutter SDK.
2. Scaffold a Flutter project in the repository root.
3. Add dependencies and platform notification permissions.
4. Implement models, services, state controller, screens, and widgets.
5. Remove Swift/Xcode/XcodeGen files once Flutter files exist.
6. Run analysis/tests and fix issues.
7. Summarize remaining limitations, especially around local notification behavior on simulators.
