# Reset functionality review — September 13, 2026

Reviewed the current Flutter codebase against the conversion/UI specs and exercised the app on iOS Simulator.

## Correctness and reliability fixes

- Focus-time changes now reset the Home countdown. Returning from a break starts a fresh focus interval and reschedules reminders.
- Break timers use an elapsed-time deadline and reconcile when the app resumes. Automatic prompts cannot stack over an active break or open while backgrounded.
- Completed/skipped breaks await persistence, prevent duplicate saves, and offer retry after a failed write. Cancel does not log a break.
- Notification initialization checks permission. Denial or scheduling failure leaves the app usable with reminders disabled; failed settings updates release controls and display an error.
- Startup storage failures show a retry screen rather than replacing saved history with empty data. A malformed individual record no longer hides valid history.
- Streaks traverse calendar days across daylight-saving changes, and persisted timing values are clamped to supported ranges.
- Android notification receivers, reboot restoration, and Java desugaring are configured. Separate sound/silent channels allow the sound preference to take effect.
- iOS installs its notification-center delegate for foreground presentation.

## UI/spec fixes

- Quiet Hours explicitly says it is display-only; existing documentation describes this limitation and no suppression feature was added.
- Home and Break remain scrollable on constrained screens. The countdown fits enlarged text; Quiet Hours no longer causes a narrow-screen layout failure.
- Settings and Stats reserve space above the floating bottom navigation so content remains reachable.
- Primary actions expose an accessibility tap action, and app-bar status icons remain dark against the light background.
- Activity charts use whole-number count labels instead of repeated truncated zeroes.
- README uses `flutter test`, which supports the app's unit and widget tests.

## Automated verification

- `flutter analyze`: no issues.
- `TZ=America/New_York flutter test --reporter expanded`: 26 tests passed.
- Regression cases include spring/fall DST, permission denial and service failures, settings retry, startup-read retry, corrupted history, background elapsed time, automatic-route guards, save retry/duplicate protection, and a 320×568 display at 150% text size.
- Widget smoke tests cover Home/Stats/Settings, editable timing controls, break navigation, and phone/tablet/desktop navigation widths.
- iOS simulator debug build succeeded.
- Public Support and Privacy Policy URLs both returned HTTP 200.

## iPhone simulator verification

Device: iPhone 17 Pro, iOS 26.5.

- Permission prompt appeared and authorization succeeded.
- Focus Time changed from 55 to 56 minutes and the visible countdown reset; break duration changed to one minute.
- Notification and sound switches changed state; disabling notifications displayed “Alerts off.”
- A one-minute break was backgrounded, returned completed, and saved as one completed break / one minute moved.
- Cancel preserved the history; skip added a zero-duration incomplete record without increasing completed counts. Existing simulator history was preserved.
- Settings and logs persisted through restart; Stats displayed the completed activity.
- Final Stats scrolling exposed whole-number chart labels above navigation, and Settings scrolling exposed both help links. Support opened Safari at the configured domain.
- A temporary one-minute probe using the production `NotificationService` confirmed exactly one pending native reminder (ID 1001). iOS delivered “Time for a break!” on the lock screen while backgrounded. See `iphone-reminder.png`.
- The temporary probe was removed and the normal app restored. The iPhone is back to 55-minute focus / 5-minute breaks with notifications and sound enabled.

## iPad simulator verification

Device: iPad Pro 11-inch (M5), iOS 26.5.

- App launched and remained usable after denying notification permission; Home showed “Alerts off” and Settings showed notifications off with Sound disabled.
- Home, empty Stats, and Settings rendered cleanly with the navigation rail. See `ipad-home.png`.

## Limits

- Android build/emulator verification could not run: this machine has no Android SDK. Android configuration changes were checked against the installed notification plugin's instructions.
- Quiet hours remain informational and do not suppress reminders.
- Physical-device power management and audible notification playback were not evaluated.
