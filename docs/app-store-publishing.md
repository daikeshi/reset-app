# App Store Publishing Checklist

Reset is prepared as a Flutter app with iOS and macOS targets. The remaining
steps require an Apple Developer account and App Store Connect access.

## Local Validation

Run these before every App Store upload:

```sh
flutter analyze
flutter test
flutter build ios --release --no-codesign
flutter build macos --release
```

The iOS `--no-codesign` build proves the release app compiles locally. The final
App Store `.ipa` still needs Apple Distribution signing.

## Signing Setup

In Xcode, sign both targets with the Apple Developer team that owns the App
Store Connect app:

- `ios/Runner.xcworkspace`
- `macos/Runner.xcworkspace`

Use the bundle identifier `com.reset.reset`, or change both targets and the App
Store Connect app record together if you choose a different final identifier.

## Upload

For iOS:

```sh
flutter build ipa --release
```

Upload the generated `.ipa` using Xcode Organizer, Transporter, or App Store
Connect API tooling.

For macOS:

1. Open `macos/Runner.xcworkspace`.
2. Select the `Runner` scheme and `Any Mac`.
3. Choose Product > Archive.
4. Validate the archive.
5. Distribute to App Store Connect.

## App Store Connect

Create or update the app record with iOS and macOS platforms, then provide:

- App name, subtitle, description, keywords, category, and age rating.
- Support URL and privacy policy URL.
- iPhone and Mac screenshots.
- App privacy answers matching the privacy manifests.
- Export compliance answers.
- TestFlight review, if you want beta testing before App Review.

## Privacy

The app bundles include `PrivacyInfo.xcprivacy` files for iOS and macOS. They
declare app-local UserDefaults access for saved Reset settings and no tracking
or collected data.
