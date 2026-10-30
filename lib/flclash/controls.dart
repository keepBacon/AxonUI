import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';
import 'motion.dart';

/// Section caption outside of the raised group, matching FlClash settings.
class FlSection extends StatelessWidget {
  const FlSection({super.key, required this.title, required this.icon, this.trailing});
  final String title;
  final IconData icon;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 24, 4, 15),
    child: Row(children: [
      Icon(icon, size: 26, color: flMuted(context)),
      const SizedBox(width: 16),
      Expanded(child: Text(title, style: TextStyle(fontSize: 20, height: 1.2,
        fontWeight: FontWeight.w600, color: flMuted(context)))),
      if (trailing != null) trailing!,
    ]),
  );
}

/// Rounded, nearly white grouped list, including subtle insets and separators.
class FlGroup extends StatelessWidget {
  const FlGroup({super.key, required this.children, this.radius = FlTokens.radius});
  final List<Widget> children;
  final double radius;
  @override
  Widget build(BuildContext context) => Material(
    color: flSurface(context),
    borderRadius: BorderRadius.circular(radius),
    clipBehavior: Clip.antiAlias,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i != 0) Padding(
          padding: const EdgeInsets.only(left: 108, right: 20),
          child: Divider(height: 1, thickness: .7,
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .75))),
        children[i],
      ],
    ]),
  );
}

class FlPanel extends StatelessWidget {
  const FlPanel({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Material(
    color: flSurface(context),
    borderRadius: BorderRadius.circular(FlTokens.radius),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

/// Optional leading icon/miniature; selection uses a blue animated checkmark.
class FlSettingRow extends StatelessWidget {
  const FlSettingRow({super.key, required this.title, this.subtitle, this.leading,
    this.trailing, this.onTap, this.selected = false, this.height = 76});
  final String title;
  final String? subtitle;
  final Widget? leading, trailing;
  final VoidCallback? onTap;
  final bool selected;
  final double height;
  @override
  Widget build(BuildContext context) => FlPressScale(
    pressedScale: .988,
    child: InkWell(
    onTap: onTap,
    child: AnimatedContainer(
      duration: FlMotion.effective(context, FlMotion.short),
      curve: FlMotion.curve,
      decoration: BoxDecoration(
        color: selected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: .055)
          : Colors.transparent),
      child: ConstrainedBox(constraints: BoxConstraints(minHeight: height),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(children: [
          if (leading != null) ...[
            SizedBox(width: 57, child: Align(alignment: Alignment.centerLeft, child: leading!)),
            const SizedBox(width: 10),
          ],
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(title, style: const TextStyle(fontSize: 17,
                fontWeight: FontWeight.w500)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: TextStyle(fontSize: 12, color: flMuted(context))),
              ],
            ])),
          const SizedBox(width: 8),
          AnimatedSwitcher(duration: FlMotion.effective(context, FlMotion.short),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation, child: FadeTransition(opacity: animation, child: child)),
            child: selected
              ? Icon(Icons.check_rounded, key: const ValueKey('selected'),
                  color: Theme.of(context).colorScheme.primary, size: 29)
              : (trailing ?? const SizedBox.shrink(key: ValueKey('empty')))),
        ])),
      ),
    ),
  ));
}

class FlChoice<T> {
  const FlChoice(this.value, this.label, {this.preview, this.subtitle});
  final T value;
  final String label;
  final Widget? preview;
  final String? subtitle;
}

class FlChoiceGroup<T> extends StatelessWidget {
  const FlChoiceGroup({super.key, required this.value, required this.choices,
    required this.onChanged});
  final T value;
  final List<FlChoice<T>> choices;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) => FlGroup(children: [
    for (final choice in choices)
      FlSettingRow(
        key: ValueKey('choice-${choice.value}'),
        leading: choice.preview,
        title: choice.label,
        subtitle: choice.subtitle,
        selected: choice.value == value,
        onTap: () => onChanged(choice.value),
      ),
  ]);
}

class FlToggleRow extends StatelessWidget {
  const FlToggleRow({super.key, required this.title, required this.value,
    required this.onChanged, this.subtitle, this.icon});
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => FlSettingRow(
    title: title, subtitle: subtitle,
    leading: icon == null ? null : Icon(icon, color: flMuted(context)),
    onTap: () => onChanged(!value),
    trailing: Switch.adaptive(value: value, onChanged: onChanged),
  );
}

/// Full-width rounded segmented control with spring-like sliding thumb.
/// A single selection pill glides between tabs instead of cross-fading
/// separate colored backgrounds. An interrupted selection retargets in place.
class FlSegmented<T> extends StatelessWidget {
  const FlSegmented({super.key, required this.values, required this.label,
    required this.value, required this.onChanged});
  final List<T> values;
  final String Function(T) label;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final index = math.max(0, values.indexOf(value));
    return Material(
      color: flSurface(context),
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(height: 45,
          child: LayoutBuilder(builder: (context, constraints) {
            final cellWidth = constraints.maxWidth / values.length;
            return Stack(children: [
              AnimatedPositioned(
                key: const ValueKey('segmented-thumb'),
                duration: FlMotion.effective(context, FlMotion.selection),
                curve: FlMotion.curve,
                left: index * cellWidth, top: 0, bottom: 0, width: cellWidth,
                child: DecoratedBox(decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(27),
                )),
              ),
              Row(children: [
                for (final v in values)
                  Expanded(child: FlPressScale(
                    pressedScale: .95,
                    child: InkWell(
                      key: ValueKey('segment-$v'),
                      borderRadius: BorderRadius.circular(27),
                      onTap: () => onChanged(v),
                      child: SizedBox(height: 45,
                        child: Center(child: AnimatedDefaultTextStyle(
                          duration: FlMotion.effective(context, FlMotion.short),
                          curve: FlMotion.curve,
                          style: TextStyle(
                            color: v == value ? scheme.onPrimary : scheme.onSurface,
                            fontWeight: v == value ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 16,
                          ),
                          child: Text(label(v), maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        )),
                      ),
                    ),
                  )),
              ]),
            ]);
          }),
        ),
      ),
    );
  }
}

class FlColorSwatches extends StatelessWidget {
  const FlColorSwatches({super.key, required this.colors, required this.value,
    required this.onChanged});
  final List<Color> colors;
  final Color value;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(height: 66,
    child: ListView(scrollDirection: Axis.horizontal, children: [
      for (final color in colors) Padding(
        padding: const EdgeInsets.only(right: 12),
        child: FlPressScale(
          pressedScale: .92,
          child: InkWell(
            key: ValueKey('swatch-${color.toARGB32()}'),
            borderRadius: BorderRadius.circular(30),
            onTap: () => onChanged(color),
            child: AnimatedContainer(
              duration: FlMotion.effective(context, FlMotion.selection),
              curve: FlMotion.curve,
              width: 53, height: 53,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color == value
                    ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  width: 3,
                ),
              ),
              padding: const EdgeInsets.all(5),
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: AnimatedSwitcher(
                  duration: FlMotion.effective(context, FlMotion.short),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: color == value
                    ? const Icon(Icons.check_rounded,
                        key: ValueKey('swatch-check'), color: Colors.white)
                    : const SizedBox.shrink(key: ValueKey('swatch-empty')),
                ),
              ),
            ),
          ),
        ),
      ),
    ]),
  );
}

/// Slider value changes without animation lag; only its badge reacts to touch.
class FlSliderPanel extends StatefulWidget {
  const FlSliderPanel({super.key, required this.title, required this.value,
    required this.onChanged, this.min = 0, this.max = 100,
    this.suffix = '%', this.subtitle, this.divisions});
  final String title;
  final String? subtitle, suffix;
  final double min, max, value;
  final int? divisions;
  final ValueChanged<double> onChanged;
  @override
  State<FlSliderPanel> createState() => _FlSliderPanelState();
}

class _FlSliderPanelState extends State<FlSliderPanel> {
  int? _pointer;
  bool _active = false;

  void _begin(PointerDownEvent event) {
    if (_pointer != null) return;
    _pointer = event.pointer;
    setState(() => _active = true);
  }

  void _end(int pointer) {
    if (_pointer != pointer) return;
    _pointer = null;
    if (_active) setState(() => _active = false);
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.value.clamp(widget.min, widget.max).toDouble();
    final colors = Theme.of(context).colorScheme;
    return FlPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(widget.title, style: const TextStyle(fontSize: 17))),
        AnimatedScale(
          key: ValueKey('slider-value-${widget.title}'),
          scale: _active ? 1.085 : 1,
          duration: FlMotion.effective(context,
            _active ? FlMotion.press : FlMotion.release),
          curve: _active ? FlMotion.curve : FlMotion.rebound,
          child: AnimatedContainer(
            duration: FlMotion.effective(context, FlMotion.short),
            curve: FlMotion.curve,
            decoration: BoxDecoration(
              color: _active ? colors.primaryContainer : colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text('${v.round()}${widget.suffix ?? ''}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
      if (widget.subtitle != null) Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(widget.subtitle!, style: TextStyle(color: flMuted(context)))),
      const SizedBox(height: 12),
      Listener(
        onPointerDown: _begin,
        onPointerUp: (event) => _end(event.pointer),
        onPointerCancel: (event) => _end(event.pointer),
        child: Slider(value: v, min: widget.min, max: widget.max,
          divisions: widget.divisions, onChanged: widget.onChanged),
      ),
    ]));
  }
}

/// Touch-draggable discrete scale with painted ticks and a slim divider thumb.
class FlDiscreteScale extends StatelessWidget {
  const FlDiscreteScale({super.key, required this.value, required this.onChanged,
    this.min = .70, this.max = 1.40, this.step = .05});
  final double value, min, max, step;
  final ValueChanged<double> onChanged;
  void update(double dx, double width) {
    if (width <= 0) return;
    final t = (dx / width).clamp(0.0, 1.0).toDouble();
    final level = min + ((max - min) * t / step).round() * step;
    onChanged(level.clamp(min, max).toDouble());
  }
  @override
  Widget build(BuildContext context) => Semantics(
    slider: true, label: '文字缩放', value: '${(value * 100).round()}%',
    child: Row(children: [
      const Text('A', style: TextStyle(fontSize: 13)),
      const SizedBox(width: 14),
      Expanded(child: LayoutBuilder(builder: (context, c) {
        return GestureDetector(
          key: const ValueKey('scale-slider'),
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => update(d.localPosition.dx, c.maxWidth),
          onHorizontalDragUpdate: (d) => update(d.localPosition.dx, c.maxWidth),
          child: SizedBox(height: 52, child: CustomPaint(
            painter: _DiscreteTrackPainter(
              value: value, min: min, max: max, step: step,
              active: Theme.of(context).colorScheme.primary,
              muted: Theme.of(context).colorScheme.onSurfaceVariant),
          )),
        );
      })),
      const SizedBox(width: 14),
      const Text('A', style: TextStyle(fontSize: 26)),
    ]),
  );
}

class _DiscreteTrackPainter extends CustomPainter {
  _DiscreteTrackPainter({required this.value, required this.min, required this.max,
    required this.step, required this.active, required this.muted});
  final double value, min, max, step;
  final Color active, muted;
  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final x = size.width * ((value - min) / (max - min)).clamp(0, 1);
    final base = Paint()..color = muted.withValues(alpha: .18);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, y - 8, size.width, 16),
        const Radius.circular(12)), base);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, y - 8, x, 16),
        const Radius.circular(12)), Paint()..color = active.withValues(alpha: .30));
    final n = ((max - min) / step).round();
    for (var i = 0; i <= n; i++) {
      final tickX = size.width * i / n;
      canvas.drawCircle(Offset(tickX, y), 2.3,
        Paint()..color = tickX <= x ? Colors.white : muted);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 3, y - 25, 6, 50),
        const Radius.circular(4)), Paint()..color = flHandleColor(active));
  }
  Color flHandleColor(Color color) => Color.lerp(color, Colors.white, .1)!;
  @override
  bool shouldRepaint(covariant _DiscreteTrackPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.active != active || oldDelegate.muted != muted;
}

Future<T?> flShowSheet<T>(BuildContext context, {required String title,
  required Widget child}) => showModalBottomSheet<T>(
    context: context, isScrollControlled: true, useSafeArea: true,
    sheetAnimationStyle: AnimationStyle(
      duration: FlMotion.effective(context, FlMotion.sheet),
      reverseDuration: FlMotion.effective(context, FlMotion.release),
    ),
    backgroundColor: flSurface(context),
    showDragHandle: true,
    builder: (ctx) => Padding(padding: EdgeInsets.fromLTRB(24, 10, 24,
      MediaQuery.viewInsetsOf(ctx).bottom + 24),
      child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title, style: const TextStyle(fontSize: 23,
          fontWeight: FontWeight.w700)), const SizedBox(height: 20), child]))));

Future<T?> flPick<T>(BuildContext context, {required String title,
  required List<T> values, required String Function(T) label,
  required T selected}) => flShowSheet<T>(context, title: title,
    child: FlGroup(children: [for (final v in values)
      FlSettingRow(title: label(v), selected: v == selected,
        onTap: () => Navigator.pop(context, v))]));

class FlStepCounter extends StatelessWidget {
  const FlStepCounter({super.key, required this.value, required this.onChanged,
    this.min = 0, this.max = 100, this.step = 1});
  final int value, min, max, step;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    FlPressScale(pressedScale: .91,
      child: IconButton.filledTonal(
        onPressed: value <= min ? null : () => onChanged(math.max(min, value - step)),
        icon: const Icon(Icons.remove_rounded),
      )),
    SizedBox(width: 45, child: AnimatedSwitcher(
      duration: FlMotion.effective(context, FlMotion.short),
      switchInCurve: FlMotion.curve,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation, child: ScaleTransition(scale: animation, child: child)),
      child: Text('$value', key: ValueKey(value), textAlign: TextAlign.center),
    )),
    FlPressScale(pressedScale: .91,
      child: IconButton.filledTonal(
        onPressed: value >= max ? null : () => onChanged(math.min(max, value + step)),
        icon: const Icon(Icons.add_rounded),
      )),
  ]);
}

/// All panels remain UI-only; this list controls a local in-memory visual order.
class FlReorderPanel extends StatelessWidget {
  const FlReorderPanel({super.key, required this.items, required this.onReorder});
  final List<String> items;
  final void Function(int, int) onReorder;
  @override
  Widget build(BuildContext context) => FlGroup(children: [
    SizedBox(height: math.max(1, items.length) * 66.0,
      child: ReorderableListView.builder(
        shrinkWrap: true,
        buildDefaultDragHandles: false,
        itemCount: items.length,
        proxyDecorator: (child, index, animation) => AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) {
            final t = Curves.easeOutCubic.transform(animation.value);
            return Transform.scale(
              scale: 1 + .025 * t,
              child: Material(
                color: flSurface(context),
                borderRadius: BorderRadius.circular(18),
                elevation: 7 * t,
                child: child,
              ),
            );
          },
        ),
        onReorderItem: onReorder,
        itemBuilder: (context, index) => ListTile(
          key: ValueKey(items[index]),
          title: Text(items[index]),
          leading: Icon(Icons.layers_outlined, color: flMuted(context)),
          trailing: ReorderableDragStartListener(index: index,
            child: const Icon(Icons.drag_handle_rounded)),
        ),
      )),
  ]);
}
