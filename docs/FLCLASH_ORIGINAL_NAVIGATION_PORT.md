# Direct FlClash navigation source integration (2026-10-30)

Source: user-provided `FlClash-main.zip`, `lib/ui/navigation_dock.dart`, GPL-3.0.
Compiled integration: `lib/flclash/original_navigation_dock.dart`.

This is the upstream full ~2,112-line navigation engine, **not** a rewritten
AnimatedPositioned approximation. It retains upstream spring simulations,
finger-following lens, press/lift, rubber-band overdrag, lens clipping,
glass/content refraction and custom render objects. The existing upstream
`liquid_glass.dart`, capture layer and GLSL shader remain active.

**Necessary host adapters** (upstream's business/UI packages do not exist in
the UI-only Axon shell): `material_ui` -> Flutter Material imports;
`AppShape.full` -> same Flutter `RoundedSuperellipseBorder`;
`AppTextStyle.custom` -> equivalent native `TextStyle`;
`SurfaceLevel` -> Flutter `ColorScheme` surface roles;
`Glyph/GlyphIcon` -> `IconData/Icon`; `context.colorScheme` ->
`Theme.of(context).colorScheme`; focus border -> `BorderSide`.
These are interface adapters, not reimplementations of dock physics.

The app now mounts upstream `NavigationDock` directly. Legacy
`dock.dart` remains only for gallery/backward compatibility and is no longer
used by the main navigation shell. Network/input features are not ported.

Original source is GPL-3.0, consistent with this repository. APK visual parity
still requires an Android device run; widget tests cannot verify refraction
pixels or Impeller shader output.
