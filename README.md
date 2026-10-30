# AxonUI — FlClash-styled UI component preview

This repository builds an **Axon Input UI library preview APK**. It **retains the FlClash Flutter UI appearance**, the original navigation dock, the official optical Liquid Glass shader and capture engine, rounded panels, grouped settings, selectors and animations. It is not a VPN client and does not execute keyboard, mouse, gamepad or touch operations.

## Preview structure

- **组件库** — searchable Axon component catalogue, all groups styled with FlClash `FlPanel`, `FlGroup`, `FlSettingRow`.
- **Axon控件** — toggles, buttons, segmented controls, sliders, value steppers, keycaps, gamepad visual preview, local-only draggable touch-button layout, text input and color palettes.
- **配置** — declarative Axon plugin schema renderer with local-only state.
- **主题** — FlClash theme and Liquid Glass settings, using `LiquidGlassHost`, original capture layer and shader.

App entry: `lib/main.dart` → `FlClashAxonApp`.

New gallery: `lib/flclash/axon_gallery.dart`.

Existing rendering components are retained under `lib/flclash/`, notably
`original_navigation_dock.dart`, `upstream_liquid_glass.dart`,
`upstream_liquid_glass_capture.dart` and `shaders/liquid_glass.frag`.

This change specifically rolls back the earlier *standalone Axon UI Lab application shell* and preserves the intended FlClash visual system. Axon-specific content uses that system's components rather than a separately styled application. Prior UI-only demonstration builds remain in Git history.

## Build

The GitHub Actions workflow runs Flutter static analysis, Widget tests and a release ARM64 APK build, then uploads the APK as an Artifact.

## License

GPL-3.0; upstream FlClash components are attributed in their respective source files. No FlClash networking engine is included.
