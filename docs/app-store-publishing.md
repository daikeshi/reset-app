# App Store Publishing Checklist

Reset is prepared as a Flutter app with iOS and macOS targets. The iOS app
builds successfully with automatic signing for the SquirrelJet development
team. The remaining release steps require App Store Connect access.

## Current Readiness (July 21, 2026)

- `flutter analyze`: passes with no issues.
- `flutter test`: all 11 tests pass.
- Signed `flutter build ios --release`: passes.
- iOS marketing icon: valid 1024 x 1024 PNG with no alpha channel.
- Privacy manifest: declares local UserDefaults access, no tracking, and no
  collected data.
- Placeholder Rate/Share actions have been removed from the first release;
  restore them only after App Store Connect assigns the permanent Apple ID.
- Version/build: `1.0.0+2`.
- Bundle identifier: `com.squirreljet.reset`, registered to the SquirrelJet
  Apple Developer team.
- Signing: automatic signing is configured for Apple development team
  `8W832ZQ9F7`, and a signed device release build succeeds locally.
- Toolchain: verified on macOS 26.5.2 with Xcode 26.6 and the iOS 26.5 SDK. This
  satisfies Apple's current minimum upload requirement of Xcode 26 and the iOS
  26 SDK.

## 1. Prepare This Mac

1. macOS and Xcode are updated to supported versions.
2. In Xcode > Settings > Accounts, sign in with the Apple Account belonging to
   the developer team.
3. Confirm that the Apple Developer Program membership is active. Distribution
   requires the paid program; an individual membership lists the person's legal
   name as the App Store seller.

## 2. Choose the Permanent Bundle ID

Bundle IDs cannot be changed after a build is uploaded. Reset uses the permanent
publisher-owned identifier `com.squirreljet.reset`.

After registering the identifier in the Apple Developer account, update
`PRODUCT_BUNDLE_IDENTIFIER` for the Runner target in
`ios/Runner.xcodeproj`, and keep the test target as the same ID plus
`.RunnerTests`.

## 3. Configure Signing

1. Open `ios/Runner.xcworkspace` (not the `.xcodeproj`).
2. Select Runner > Signing & Capabilities.
3. Enable Automatically manage signing.
4. Select the Apple Developer team that will own the App Store listing.
5. Confirm that Xcode creates or selects the required Apple Development and
   Apple Distribution certificates and provisioning profiles.

## 4. Validate the Release

Run these checks after upgrading Xcode and after every release change:

```sh
flutter analyze
flutter test
env LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
  flutter build ios --release --no-codesign
```

The explicit UTF-8 locale avoids a CocoaPods encoding error on the current
shell setup. The unsigned build only proves that release compilation succeeds;
the App Store archive must be signed by the selected Apple team.

Test the release on at least one physical iPhone. In particular, verify that:

- notification permission is requested only after enabling notifications;
- a break reminder is delivered while the app is in the background;
- changing focus time, break duration, sound, and notification settings works;
- layouts work on both iPhone and iPad, because the target supports both.

## 5. Create the App Store Connect Record

The Account Holder must accept any pending agreements first. In App Store
Connect, choose Apps > + > New App and enter:

- Platforms: iOS (add macOS later unless it is ready for the same launch).
- Name: `SquirrelJet Reset`.
- Primary language: your listing language.
- Bundle ID: the exact permanent ID configured in Xcode.
- SKU: an internal immutable value such as `reset-ios-001`.
- User access: Full Access unless the team needs restrictions.

The app record must exist before uploading the first build.

## 6. Prepare Product-Page Information

Provide the app name, subtitle, description, keywords, primary and secondary
categories, copyright, age rating, support URL, and App Review contact details.
The current app has no accounts, purchases, or server dependency, so review
notes should say that no login is required and explain how to enable and test
local break reminders.

A public privacy policy URL is required even though Reset does not collect
data. In App Privacy, choose "No, we do not collect data from this app" only if
the shipped app and every included third-party SDK still match that statement.
The policy should explain that settings and break history remain on the device
and how users can contact the publisher.

Complete the current age-rating questionnaire and export-compliance questions.
Reset does not appear to implement custom encryption, but the publisher is
responsible for confirming the final export-compliance answer.

## 7. Capture Valid Screenshots

App Store screenshots must be PNG or JPEG files without transparency. The repo's
current `docs/screenshots/iphone-home-real.png` (500 x 844) and
`ipad-home-real.png` (834 x 1194) are reference images, not accepted App Store
sizes. Capture new screenshots from current simulators after the Xcode upgrade.

For the iPhone listing, provide one to ten screenshots using an accepted 6.9-inch
portrait size such as 1320 x 2868, 1290 x 2796, or 1260 x 2736. Because the app
also supports iPad, upload accepted iPad screenshots shown by App Store Connect.
Show the Home, active break, Stats, and Settings/reminders experiences without
debug banners or placeholder data.

## 8. Archive and Upload

The least error-prone first upload is through Xcode:

1. Open `ios/Runner.xcworkspace`.
2. Select the Runner scheme and `Any iOS Device (arm64)`.
3. Choose Product > Archive.
4. In Organizer, select the archive, then Distribute App > App Store Connect >
   Upload.
5. Resolve every validation error before uploading.

Alternatively, after signing is configured:

```sh
env LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 flutter build ipa --release
```

Upload the generated IPA with Transporter or Xcode. Every new upload for the
same marketing version needs a larger build number, for example `1.0.0+2`.

## 9. TestFlight and App Review

Wait for Apple to process the build, then select it under TestFlight. Complete
beta compliance information and test the processed build on a physical device.
When ready, select the build on the `1.0` App Store version, complete every
required metadata section, choose Add for Review, then Submit for Review.

Release manually for the first version unless a deliberate scheduled or
automatic release is preferred.

## macOS

Treat macOS as a separate submission even when it shares the same App Store
record. Do not add the macOS platform to the first launch until its signing,
sandbox behavior, screenshots, metadata, archive, and TestFlight build have
been validated separately.
