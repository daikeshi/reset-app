# Reset UI Refinement Design

## Goal

Refine the Flutter app UI while preserving the current design direction. The existing soft lavender/blue atmosphere, purple accent, rounded cards, and calm wellness tone should remain the baseline. The work should make the app feel more polished and intentional without changing core behavior or replacing the palette.

## Current Context

Reset is a Flutter app with three main tabs:

- Home: countdown, streak, daily totals, and primary break action.
- Stats: summary cards, streak, total metrics, and activity chart.
- Settings: notification toggles, interval controls, quiet hours, and app actions.

The current UI already has the right emotional tone. The main opportunity is to reduce the default Flutter feel through better surfaces, typography, spacing, navigation treatment, and consistent component styling.

## Visual Direction

Use a conservative polish pass:

- Keep the current lavender/blue gradient background and deep purple accent.
- Add a more mature neutral text system for readability and contrast.
- Use subtle surface borders and shadows to separate cards from the gradient.
- Keep cards rounded but avoid making the app feel overly bubbly.
- Make the primary action feel premium through clearer elevation, stronger disabled states, and consistent icon/text alignment.
- Improve the bottom navigation treatment so it feels integrated with the app instead of default.

Avoid:

- Replacing the palette with green/coral/mineral palettes.
- Adding busy decorative backgrounds.
- Using a landing-page or marketing-style layout.
- Changing the app's data model, navigation structure, or reminder behavior.

## Screen Design

### Home

The home screen remains centered around the countdown ring. Refinements should make the hierarchy clearer:

- Header: keep `Reset` prominent, but add a concise status line such as next-break context if it improves clarity.
- Countdown ring: preserve the circular timer, improve contrast and ring depth, and keep the timer readable on small screens.
- Streak and totals: unify them into consistent surfaces with the same radius, border, and shadow language.
- Primary action: keep it full-width near the bottom, with more polished gradient/elevation and a pressed/disabled state.

### Break

The break screen should feel calm and focused:

- Keep the activity icon and suggestion as the center of attention.
- Improve the suggestion card and timer spacing so the screen breathes better.
- Preserve the start, complete, and skip flows exactly.
- Make the completion state feel affirmative but not loud.

### Stats

Stats should become more scannable:

- Use consistent section spacing and card surfaces.
- Keep the existing chart but tune colors to match the app palette.
- Improve empty state styling so it feels designed rather than placeholder-like.
- Ensure chart labels do not crowd or overflow.

### Settings

Settings should feel more app-specific while staying familiar:

- Group settings into subtle sections.
- Keep native-style switches and dropdowns.
- Improve tile spacing and trailing controls.
- Keep all existing actions and copy.

## Components

Introduce or refine shared UI styling where it reduces duplication:

- A small app color/token layer for background, primary accent, secondary accent, text, muted text, surface, border, and shadow.
- Reusable panel/card styling used by Home, Stats, and Settings.
- Polished `GradientActionButton` states.
- Refined `CountdownRing` visuals without changing its public API unless needed.

Do not add a large design system abstraction. Keep changes easy to read and close to the current app structure.

## Behavior

No behavior changes are in scope:

- Break scheduling remains unchanged.
- Break logging remains unchanged.
- Settings persistence remains unchanged.
- Notification behavior remains unchanged.
- Navigation remains Home, Stats, Settings.

## Accessibility And Responsiveness

- Maintain readable contrast for timer, card text, button text, and muted labels.
- Keep tap targets at least 44px high.
- Prevent text overflow on small iPhone screens.
- Avoid viewport-scaled fonts.
- Preserve safe-area handling.

## Verification

Run:

- `flutter analyze`
- `flutter test`
- iOS simulator launch on iPhone 15 Pro

Visually inspect:

- Home screen at launch.
- Break screen before timer starts, while running, and completion state.
- Stats empty/data states where possible.
- Settings screen with notifications on and off.

## Open Decisions

The approved direction is to preserve the current palette and refine polish only. No further palette exploration is needed before implementation.
