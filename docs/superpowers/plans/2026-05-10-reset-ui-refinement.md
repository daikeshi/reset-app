# Reset UI Refinement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Polish the Reset Flutter UI while preserving the current soft lavender/blue/purple visual direction and all existing behavior.

**Architecture:** Add a small theme/token layer and one reusable panel component, then apply them to Home, Break, Stats, Settings, the countdown ring, the primary action button, and bottom navigation. Add widget smoke coverage for the main shell and break flow so rendering stays stable while visual code changes.

**Tech Stack:** Flutter, Material 3, `flutter_test`, existing `fl_chart` charting.

---

### Task 1: Add UI Smoke Coverage

**Files:**
- Create: `test/ui_smoke_test.dart`

- [ ] **Step 1: Write the failing widget tests**

Add tests that pump `ResetApp`, verify the polished countdown/navigation identifiers, switch tabs, and open the break screen. The tests should initially fail because the UI does not yet expose the new semantic labels and keys.

Run: `flutter test test/ui_smoke_test.dart`

Expected: FAIL with missing `Break countdown timer` semantics or missing polished widget keys.

### Task 2: Add Shared Visual Tokens

**Files:**
- Create: `lib/theme/reset_theme.dart`
- Create: `lib/widgets/reset_panel.dart`
- Modify: `.gitignore`
- Modify: `lib/main.dart`

- [ ] **Step 1: Add conservative design tokens**

Create `ResetColors`, `ResetGradients`, and `ResetDecorations` with the current lavender/blue/purple palette, neutral text colors, shared border color, and soft shadows.

- [ ] **Step 2: Add reusable panel surface**

Create `ResetPanel` for rounded translucent app surfaces used across Home, Stats, and Settings.

- [ ] **Step 3: Apply app theme**

Update `ResetApp` theme to use the new color scheme, transparent app bars, refined navigation styling, and consistent text weights.

- [ ] **Step 4: Ignore temporary brainstorming files**

Add `.superpowers/` to `.gitignore` so local visual mockups do not pollute future status output.

### Task 3: Polish Shared Widgets

**Files:**
- Modify: `lib/widgets/countdown_ring.dart`
- Modify: `lib/widgets/gradient_action_button.dart`
- Modify: `lib/widgets/stat_card.dart`

- [ ] **Step 1: Refine countdown ring**

Preserve the public API while improving depth, contrast, gradient track styling, and adding a stable semantics label for tests/accessibility.

- [ ] **Step 2: Refine primary action button**

Preserve the public API while improving height, radius, icon/text spacing, gradient, disabled state, shadow, and optional semantics/key support.

- [ ] **Step 3: Refine stat card surfaces**

Use `ResetPanel` and theme tokens for consistent stats card spacing, icon background, and text hierarchy.

### Task 4: Polish Screens

**Files:**
- Modify: `lib/screens/home_screen.dart`
- Modify: `lib/screens/break_screen.dart`
- Modify: `lib/screens/stats_screen.dart`
- Modify: `lib/screens/settings_screen.dart`

- [ ] **Step 1: Home**

Keep the current layout and palette while improving the header, countdown spacing, streak/totals surfaces, and primary button treatment.

- [ ] **Step 2: Break**

Keep the break flow unchanged while improving the activity icon surface, suggestion panel, timer spacing, and completion button styling.

- [ ] **Step 3: Stats**

Keep chart behavior unchanged while standardizing panels, section labels, empty state, and chart colors.

- [ ] **Step 4: Settings**

Group settings into subtle panels while preserving switches, dropdowns, quiet hours, version, rate, and share actions.

### Task 5: Verify And Relaunch

**Files:**
- No source files unless verification reveals a focused fix.

- [ ] **Step 1: Format**

Run: `dart format .`

Expected: source and test files formatted.

- [ ] **Step 2: Analyze**

Run: `flutter analyze`

Expected: no issues.

- [ ] **Step 3: Test**

Run: `flutter test`

Expected: all tests pass, including the new UI smoke tests.

- [ ] **Step 4: iOS simulator**

Run: `env LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 flutter run -d 24081365-FA4F-41A4-A017-AD1115A23A10`

Expected: app launches on iPhone 15 Pro simulator.
