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
dart test
```

`flutter test` may also be used in environments where the local Flutter test
host is available.

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
