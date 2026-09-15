# Breakstride branding

Selected on September 14, 2026.

## Names and positioning

- App display name: **Breakstride**
- Proposed App Store name: **Breakstride: Active Breaks**
- Subtitle and in-app tagline: **Focus. Move. Recharge.**
- Previous App Store name: **SquirrelJet Reset**

Breakstride pairs focus sessions with short workday activities. The name leaves
room to expand exercise breaks, including the proposed five push-ups or
one-minute plank.

The existing icon remains in use. The current supported activities are walking,
stretching, hydration, eye rest, workouts, and meditation. Workout suggestions
already include push-ups, squats, a 30-second plank, jumping jacks, lunges, and
wall sits. These are random prompts using the shared break timer, rather than
selectable exercises with repetition tracking or individual timers.

## Approved icon

The selected design is **Open Doorway**, using the original app's purple-and-blue
palette. Teal-and-mint and the earlier letter, ribbon, and spark studies were not
selected.

Final editable SVGs, rendered PNGs, and usage notes are in
[`output/breakstride-doorway-original-palette/`](../../output/breakstride-doorway-original-palette/).
The [download package](../../output/breakstride-doorway-original-palette.zip)
contains the same files. Use `app-icon.png` for the opaque 1024 × 1024 square
artwork and `logo-icon.png` for a rounded preview.

The design is approved but has not yet replaced the platform app-icon assets.
Apply it before capturing rebrand screenshots or creating the release build.

## Update continuity

Keep the existing App Store record (`6792412427`), Apple bundle identifier
(`com.squirreljet.reset`), storage keys, platform identifiers, and Dart package
name (`reset`). Internal source names and executable names can retain `reset`;
the rebrand changes the names users see without creating a separate app.

The marketing, support, and privacy URLs retain their existing `/reset/` paths.
Those pages need matching visible branding when the new name goes live.

## Release status and remaining work

The name and local metadata draft are prepared in this checkout. No new build
or metadata has been submitted for the rebrand. Version `1.0.1+3` identifies the
previously submitted Reset build; choose a fresh build number for the branded
upload and the appropriate version after checking the current review status.

1. Sign in to App Store Connect and inspect the current 1.0.1 review status.
2. Decide whether to include the rename in the pending update or the following
   release. Changing a pending review requires a deliberate release decision.
3. Save the proposed name and subtitle on the existing record and confirm Apple
   accepts the name. A public search does not reserve it.
4. Update the public marketing, support, and privacy page branding.
5. Prepare a new version/build, archive, and validate the renamed binary.
6. Capture replacement iPhone and iPad store screenshots with the new branding.
7. Upload the build, reuse the previous review contact information, and submit
   matching metadata and screenshots for review.

Use [the App Store metadata draft](../app-store-metadata.md) as the starting
point. Preserve `docs/submission/1.0.1/` and past release records as evidence of
what was previously submitted.

## Local validation — September 14, 2026

- `flutter analyze`: no issues.
- `flutter test`: all 29 tests pass, including small-screen and large-text
  coverage.
- `flutter build ios --simulator --debug --no-pub`: succeeds.
- Built bundle display name: `Breakstride`; bundle ID: `com.squirreljet.reset`.
- Interactive simulator verification and an in-place data-continuity check are
  pending because the Mac was locked. The current App Store Connect review
  status also needs verification after signing in again.
