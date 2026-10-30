import 'package:flutter/material.dart';
import 'glass.dart';
import 'theme.dart';
import 'upstream_liquid_glass.dart';

/// A FlClash-inspired dock: the selection lens is separate from its icons,
/// follows touch continuously and lifts into a shader-rendered optical pane.
/// This widget only updates UI navigation state.
class FlDockDestination {
  const FlDockDestination(this.icon, this.label);
  final IconData icon;
  final String label;
}

class FlLiquidNavigationDock extends StatefulWidget {
  const FlLiquidNavigationDock({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<FlDockDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<FlLiquidNavigationDock> createState() => _FlLiquidNavigationDockState();
}

class _FlLiquidNavigationDockState extends State<FlLiquidNavigationDock> {
  bool _pressed = false;
  double? _dragX;
  int? _dragIndex;

  int _indexAt(double x, double width) {
    final count = widget.destinations.length;
    return (x / (width / count)).floor().clamp(0, count - 1);
  }

  void _release() {
    if (!_pressed && _dragX == null) return;
    setState(() {
      _dragX = null;
      _dragIndex = null;
      _pressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.destinations.length;
    if (count == 0) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final glass = FlGlassScope.of(context) > 0;
    final selection = (_dragIndex ?? widget.selectedIndex).clamp(0, count - 1);
    final shortMotion = FlMotion.effective(context, FlMotion.short);
    final travel = FlMotion.effective(context, const Duration(milliseconds: 320));

    return FlGlassSurface(
      radius: 34, pill: true, shadow: true,
      child: SizedBox(
        height: 68,
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final pitch = width / count;
          final lensWidth = (pitch - 9).clamp(24.0, 125.0);
          final left = _dragX == null
            ? selection * pitch + (pitch - lensWidth) / 2
            : (_dragX! - lensWidth / 2).clamp(4.0, width - lensWidth - 4);
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (details) => setState(() {
              _pressed = true;
              _dragX = details.localPosition.dx;
              _dragIndex = _indexAt(_dragX!, width);
            }),
            onHorizontalDragUpdate: (details) => setState(() {
              _dragX = details.localPosition.dx.clamp(0.0, width);
              _dragIndex = _indexAt(_dragX!, width);
            }),
            onHorizontalDragEnd: (_) {
              final commit = _dragIndex;
              _release();
              if (commit != null) widget.onSelected(commit);
            },
            onHorizontalDragCancel: _release,
            child: Stack(children: [
              AnimatedPositioned(
                duration: _dragX == null ? travel : Duration.zero,
                curve: Curves.easeOutCubic,
                left: left,
                top: 5,
                width: lensWidth,
                height: 58,
                child: IgnorePointer(child: AnimatedScale(
                  scale: _pressed ? 1.07 : 1,
                  duration: shortMotion,
                  curve: Curves.easeOutBack,
                  child: glass && _pressed
                    ? LiquidGlass(
                        style: LiquidGlassStyle.lens(colors).scale(.9),
                        borderRadius: BorderRadius.circular(29),
                        child: const SizedBox.expand(),
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: glass
                            ? colors.secondary.withValues(alpha: .16)
                            : colors.primaryContainer,
                          borderRadius: BorderRadius.circular(29),
                        ),
                      ),
                )),
              ),
              Row(children: [
                for (var i = 0; i < count; i++)
                  Expanded(child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      key: ValueKey('tab-$i'),
                      borderRadius: BorderRadius.circular(29),
                      onTap: () => widget.onSelected(i),
                      onTapDown: (_) => setState(() => _pressed = true),
                      onTapUp: (_) => setState(() => _pressed = false),
                      onTapCancel: _release,
                      child: SizedBox(height: 68, child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            duration: shortMotion,
                            scale: i == selection ? 1.09 : 1,
                            child: Icon(widget.destinations[i].icon,
                              size: 24, color: i == selection
                                ? colors.primary : flMuted(context)),
                          ),
                          const SizedBox(height: 3),
                          Text(widget.destinations[i].label,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: i == selection
                                ? FontWeight.w700 : FontWeight.w500,
                              color: i == selection
                                ? colors.primary : flMuted(context)),
                          ),
                        ],
                      )),
                    ),
                  )),
              ]),
            ]),
          );
        }),
      ),
    );
  }
}

/// Actual shader glass over high-contrast details; no screenshot substitute.
class FlGlassMaterialPreview extends StatelessWidget {
  const FlGlassMaterialPreview({super.key, required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: '液态玻璃材质预览',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(height: 142, child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(primary, Colors.white, dark ? .2 : .7)!,
                  Color.lerp(primary, Colors.black, dark ? .45 : .08)!,
                ],
              ),
            )),
            Positioned(top: -30, left: -16, child: Icon(
              Icons.blur_circular_rounded, size: 215,
              color: Colors.white.withValues(alpha: .36))),
            Positioned(bottom: -68, right: 5, child: Icon(
              Icons.blur_on_rounded, size: 205,
              color: Colors.black.withValues(alpha: .16))),
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FlGlassSurface(
                level: level, radius: 34, pill: true, shadow: true,
                child: SizedBox(height: 66, child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final icon in const [
                      Icons.dashboard_rounded,
                      Icons.tune_rounded,
                      Icons.folder_outlined,
                      Icons.palette_outlined,
                    ]) Icon(icon,
                      size: 24,
                      color: dark ? Colors.white : const Color(0xFF273248)),
                  ],
                )),
              ),
            )),
          ],
        )),
      ),
    );
  }
}
