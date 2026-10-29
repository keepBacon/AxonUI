import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'theme.dart';

/// A Flutter-native glass approximation. FlClash's own implementation also
/// performs scene capture and fragment-shader refraction, which is not included.
class FlGlassScope extends InheritedWidget {
  const FlGlassScope({super.key, required this.level, required super.child});
  final int level;
  static int of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FlGlassScope>()?.level ?? 0;
  @override
  bool updateShouldNotify(FlGlassScope oldWidget) => level != oldWidget.level;
}

/// A restrained ambient scene gives transparent surfaces a real background
/// from which BackdropFilter can sample. Off mode leaves the old theme intact.
class FlAmbientBackdrop extends StatelessWidget {
  const FlAmbientBackdrop({super.key, required this.level, required this.child});
  final int level;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (level == 0) return child;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final seed = Theme.of(context).colorScheme.primary;
    final base = dark ? const Color(0xFF151720) : FlTokens.backgroundLight;
    final soft = Color.lerp(base, seed, dark ? .13 : .09)!;
    return Stack(fit: StackFit.expand, children: [
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [soft, base, soft.withValues(alpha: 1)])))),
      Positioned(top: -160, right: -155, child: IgnorePointer(child: Container(
        width: 390, height: 390,
        decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            seed.withValues(alpha: dark ? .20 : .14), Colors.transparent,
          ]))))),
      Positioned(bottom: -175, left: -155, child: IgnorePointer(child: Container(
        width: 440, height: 440,
        decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            seed.withValues(alpha: dark ? .12 : .08), Colors.transparent,
          ]))))),
      Positioned.fill(child: child),
    ]);
  }
}

/// Native frost + tint + specular rim. NOT the upstream refraction shader.
/// Tier 1 is lighter frost, tier 2 uses a stronger filter and a brighter rim.
class FlGlassSurface extends StatelessWidget {
  const FlGlassSurface({super.key, required this.child, this.radius = 30,
    this.level, this.shadow = false});
  final Widget child;
  final double radius;
  final int? level;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final tier = (level ?? FlGlassScope.of(context)).clamp(0, 2);
    final borderRadius = BorderRadius.circular(radius);
    if (tier == 0) {
      return Material(
        color: flSurface(context), borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias, child: child,
      );
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final sigma = tier == 1 ? 9.0 : 19.0;
    final tint = dark
      ? (tier == 1 ? .58 : .41) : (tier == 1 ? .75 : .53);
    final base = dark ? const Color(0xFF333844) : Colors.white;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadow ? [BoxShadow(
          color: Colors.black.withValues(alpha: dark ? .24 : .10),
          blurRadius: 24, offset: const Offset(0, 9),
        )] : const [],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(fit: StackFit.passthrough, children: [
          Positioned.fill(child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: const SizedBox.expand(),
          )),
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [
                base.withValues(alpha: tint),
                Color.lerp(base, primary, dark ? .12 : .045)!
                    .withValues(alpha: tint * .81),
                base.withValues(alpha: tint * .91),
              ],
              stops: const [0, .53, 1],
            ),
          ))),
          Positioned.fill(child: IgnorePointer(child: CustomPaint(
            painter: _FlGlassRimPainter(
              radius: radius, tier: tier, dark: dark, primary: primary,
            ),
          ))),
          Material(type: MaterialType.transparency, child: child),
        ]),
      ),
    );
  }
}

class _FlGlassRimPainter extends CustomPainter {
  const _FlGlassRimPainter({
    required this.radius, required this.tier,
    required this.dark, required this.primary,
  });
  final double radius;
  final int tier;
  final bool dark;
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 3 || size.height <= 3) return;
    final bounds = Offset.zero & size;
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    final rrect = RRect.fromRectAndRadius(
      rect, Radius.circular((radius - 1).clamp(0.0, 1000.0)),
    );
    final rim = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: dark ? .56 : .95),
          Colors.white.withValues(alpha: tier == 2 ? .40 : .18),
          primary.withValues(alpha: .10),
          Colors.white.withValues(alpha: dark ? .16 : .44),
        ],
        stops: const [0, .32, .72, 1],
      ).createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = tier == 2 ? 1.55 : 1.0;
    canvas.drawRRect(rrect, rim);
    final gleamRect = Rect.fromLTWH(size.width * .17, 1,
      size.width * .66, 2.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(gleamRect, const Radius.circular(2)),
      Paint()
        ..shader = LinearGradient(colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: dark ? .25 : .60),
          Colors.transparent,
        ]).createShader(gleamRect),
    );
  }

  @override
  bool shouldRepaint(covariant _FlGlassRimPainter old) =>
    radius != old.radius || tier != old.tier ||
    dark != old.dark || primary != old.primary;
}
