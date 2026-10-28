# v3 Validation Record — Source-side checks

- Compared components against `AxonFlClashKit.java` and `PluginUiSpec.java` from the user's prior Axon BuildFix190 source.
- No engine, overlay, driver, input injection, controller polling or external game API added.
- UI gallery includes plugin schema preview, mapping editor preview, appearance, settings debug preview, and general UI control extras.
- New UI-only widgets are exported through `lib/axon_flclash_ui.dart`.
- Corrected the unbalanced `InkWell(...)` closure in `showAxonArgbDialog` (pre-existing WIP source).
- Added UI-only widget tests and schema normalization tests.
- CI configured to run Flutter analyzer and tests before Android ARM64 release build, uploading APK via GitHub Artifacts.
- Flutter SDK unavailable locally: Dart analyzer, Flutter test runtime and APK compilation **not executed** here; must be verified by GitHub Actions.
