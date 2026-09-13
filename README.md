# Reset — Flutter App

A break reminder app for remote workers.

## Features

- Configurable break reminders
- Random break activities with suggestions
- Guided break timer
- Streak tracking
- Local statistics and activity breakdown
- Quiet hours display

## Setup

Install Flutter, then fetch dependencies:

```bash
flutter pub get
```

## Run

Run on an available simulator, device, browser, or desktop target:

```bash
flutter run
```

To list available targets:

```bash
flutter devices
```

## Test

```bash
flutter analyze
flutter test
```

Use `flutter test` for both unit and widget tests; plain `dart test` cannot run
the Flutter widget tests. Run `TZ=America/New_York flutter test` to also exercise
streak calculations across daylight-saving transitions.

Quiet hours are currently displayed as a reference only; reminders continue
overnight. Local notifications are supported on iOS, macOS, and Android.

## Project Structure

```text
lib/
├── main.dart
├── models/
├── screens/
├── services/
├── state/
└── widgets/
```

## Requirements

- Flutter 3.41+
- Dart 3.11+
