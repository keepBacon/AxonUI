import 'package:flutter/material.dart';

/// Minimal high-contrast hierarchy, restrained tonal backgrounds and clear
/// touch targets. These colors are original values, not FlClash app assets.
abstract final class AxonPalette {
  static const seed = Color(0xFF2276D8);
  static const canvasLight = Color(0xFFF7F9FC);
  static const canvasDark = Color(0xFF10141B);
  static const corner = 22.0;
  static const gap = 12.0;
}

ThemeData axonTheme({
  Brightness brightness = Brightness.light,
  Color seed = AxonPalette.seed,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    surface: brightness == Brightness.dark
        ? AxonPalette.canvasDark
        : AxonPalette.canvasLight,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.standard,
    dividerColor: scheme.outlineVariant.withValues(alpha: .55),
    inputDecorationTheme: InputDecorationThemeData(
      isDense: true,
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: .50),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: scheme.primary, width: 1.6)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(80, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}

/// Honors OS Reduce Motion. Every custom animation in this kit goes through
/// [axonDuration] so animations can be disabled in accessibility settings.
Duration axonDuration(BuildContext context, [int milliseconds = 220]) {
  return MediaQuery.maybeOf(context)?.disableAnimations == true
      ? Duration.zero
      : Duration(milliseconds: milliseconds);
}

Color axonCardColor(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return scheme.brightness == Brightness.dark
      ? scheme.surfaceContainerLow
      : scheme.surfaceContainerLowest;
}
