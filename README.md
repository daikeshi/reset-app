# Breakstride — Flutter App

Focus. Move. Recharge.

Breakstride is a break reminder app for remote workers, previously named
SquirrelJet Reset. It pairs focus sessions with guided workday breaks.

The rebrand is prepared locally for a future release. See
[the branding notes](docs/branding/breakstride.md) for the store copy and remaining
release work.

## Features

- Configurable focus time from 1 to 120 minutes
- Start Focus button to begin each focus session
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

The focus timer starts when you tap **Start Focus**. Taking a break ends the
session and cancels its reminders. After the break, tap **Start Focus** to begin
again. A fresh app launch starts idle; notification permission alone does not
start reminders.

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
