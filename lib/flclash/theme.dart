import 'package:flutter/material.dart';

/// Spacing, surfaces, shapes and animation tokens modeled on FlClash's UI.
abstract final class FlTokens {
  static const backgroundLight = Color(0xFFF0EEF2);
  static const cardLight = Color(0xFFFFFBFE);
  static const inkLight = Color(0xFF232631);
  static const mutedLight = Color(0xFF6A7081);
  static const blue = Color(0xFF0787FA);
  static const radius = 30.0;
  static const sectionGap = 34.0;
}

abstract final class FlMotion {
  static const short = Duration(milliseconds: 170);
  static const regular = Duration(milliseconds: 285);
  static const page = Duration(milliseconds: 330);
  static const curve = Curves.easeOutCubic;
  static Duration effective(BuildContext context, [Duration preferred = regular]) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : preferred;
}

ThemeData flTheme({required Brightness brightness, required Color seed}) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  final bg = dark ? const Color(0xFF14151B) : FlTokens.backgroundLight;
  final card = dark ? const Color(0xFF24252E) : FlTokens.cardLight;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    canvasColor: bg,
    cardColor: card,
    splashFactory: InkRipple.splashFactory,
    textTheme: Typography.material2021().black.apply(
      bodyColor: dark ? const Color(0xFFEEEFF5) : FlTokens.inkLight,
      displayColor: dark ? const Color(0xFFEEEFF5) : FlTokens.inkLight,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: dark ? Colors.white : FlTokens.inkLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.surfaceContainerHighest,
      trackHeight: 10,
      valueIndicatorColor: scheme.primary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? scheme.onPrimary : null),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: card,
      modalBackgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    ),
  );
}

Color flSurface(BuildContext context) => Theme.of(context).cardColor;
Color flMuted(BuildContext context) => Theme.of(context).colorScheme.onSurfaceVariant;
