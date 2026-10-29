# AxonUI · FlClash-style Flutter UI (v5)

A **complete UI-layer rewrite**, using FlClash's grouping, generous rounded surfaces, preview-choice lists, motion patterns and a floating navigation bar as design references. This is an independent Dart/Flutter component system for Axon Input interface prototypes; it is **not** FlClash's network client.

## Architecture

- `lib/flclash/theme.dart` — design tokens, Material 3 themes, motion timings.
- `lib/flclash/controls.dart` — grouped settings, preview choices, switches, segmented controls, color swatches, sliders, bottom sheets, local reorder.
- `lib/flclash/preview.dart` — self-drawn miniature UI preview and interactive phone motion demo.
- `lib/flclash/schema.dart` — Axon-style declarative UI schema rendered with the *new* FlClash components; no feature execution.
- `lib/flclash/screens.dart` — rebuilt theme, overview, controls and profile interfaces.
- `lib/flclash/app.dart` — animation-aware application shell and bottom navigation.
- `lib/flclash/store.dart` — optional display-preference storage only.

**All legacy Axon widget implementations and earlier v1–v4 galleries were removed from the active source tree.** No input injection, interception, overlay engine, native gamepad logic or key execution is included.

## Build

GitHub Actions → **Build AxonUI FlClash v5 APK** → workflow push/dispatch; artifact contains `AxonUI-FlClash-v5-arm64.apk` and SHA256SUMS. Or run:

```bash
flutter create --platforms=android --org com.axon --project-name axon_flclash_flutter --no-pub .
bash scripts/prepare_android.sh
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release --target-platform android-arm64
```

`Flutter 3.47.7` and `Java 17` are pinned in CI.

## Licensing

UI design references: FlClash by chen08209 (`https://github.com/chen08209/FlClash`), GPL-3.0. This repository retains its GPL-3.0 license and original source attribution. Widgets were separately implemented for this UI-only prototype; no proxy/network functionality is bundled.
