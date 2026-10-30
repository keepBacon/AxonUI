import 'package:flutter/material.dart';
import 'theme.dart';
import 'upstream_liquid_glass.dart';

class FlGlassScope extends InheritedWidget {
  const FlGlassScope({super.key, required this.level, required super.child});
  final int level;
  static int of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FlGlassScope>()?.level ?? 0;
  @override
  bool updateShouldNotify(FlGlassScope old) => level != old.level;
}

class FlAmbientBackdrop extends StatelessWidget {
  const FlAmbientBackdrop({super.key, required this.level, required this.child});
  final int level;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (level == 0) return child;
    final seed = Theme.of(context).colorScheme.primary;
    final base = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF151720) : FlTokens.backgroundLight;
    return Stack(fit: StackFit.expand, children: [
      DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color.lerp(base, seed, .08)!, base],
      ))),
      Positioned.fill(child: child),
    ]);
  }
}

/// FlClash upstream optical shader/capture pane. Off mode uses solid Material.
class FlGlassSurface extends StatelessWidget {
  const FlGlassSurface({super.key, required this.child, this.radius = 30,
    this.level, this.shadow = false, this.pill = false});
  final Widget child;
  final double radius;
  final int? level;
  final bool shadow, pill;
  @override
  Widget build(BuildContext context) {
    final tier = (level ?? FlGlassScope.of(context)).clamp(0, 2);
    final corners = BorderRadius.circular(radius);
    if (tier == 0) {
      return Material(color: flSurface(context),
        borderRadius: corners, clipBehavior: Clip.antiAlias, child: child);
    }
    final scheme = Theme.of(context).colorScheme;
    return LiquidGlass(
      style: pill ? LiquidGlassStyle.pill(scheme) : LiquidGlassStyle.regular(scheme),
      borderRadius: corners,
      shadows: shadow ? [
        BoxShadow(color: Colors.black.withValues(alpha:.13),
          blurRadius:27,offset:const Offset(0,9)),
      ] : const [],
      child: Material(type: MaterialType.transparency, child:child),
    );
  }
}
