import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common.dart';
import 'controls.dart';

/// Captures Flutter key events when Flutter itself has focus. It does not
/// intercept system-wide hardware input and does not modify Axon's key engine.
class AxonKeyBindField extends StatefulWidget {
  const AxonKeyBindField({super.key, required this.label, required this.binding,
    required this.onChanged, this.subtitle});
  final String label;
  final String binding;
  final String? subtitle;
  final ValueChanged<String> onChanged;
  @override
  State<AxonKeyBindField> createState() => _AxonKeyBindFieldState();
}

class _AxonKeyBindFieldState extends State<AxonKeyBindField> {
  final _focus = FocusNode();
  bool _listening = false;
  @override
  void dispose() { _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return KeyboardListener(focusNode: _focus, autofocus: false,
      onKeyEvent: (event) {
        if (!_listening || event is! KeyDownEvent) return;
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          setState(() => _listening = false); return;
        }
        widget.onChanged(event.logicalKey.keyLabel.isEmpty
          ? event.logicalKey.debugName ?? 'Unknown' : event.logicalKey.keyLabel);
        setState(() => _listening = false);
      },
      child: AxonSettingTile(title: widget.label, subtitle: widget.subtitle,
        leading: Icon(Icons.keyboard_alt_outlined, color: cs.primary),
        trailing: OutlinedButton.icon(
          onPressed: () {setState(() => _listening = true); _focus.requestFocus();},
          icon: Icon(_listening ? Icons.radio_button_checked : Icons.edit_rounded, size: 16),
          label: Text(_listening ? '按下按键…' : widget.binding),
        )),
    );
  }
}

/// Visual/test control only; pass onPress to Axon's authorized controller.
class AxonVirtualPad extends StatelessWidget {
  const AxonVirtualPad({super.key, required this.onPressed});
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    Widget key(String label, IconData icon) => Semantics(label: label, button: true,
      child: SizedBox(width: 57, height: 54, child: FilledButton.tonal(
        style: FilledButton.styleFrom(padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        onPressed: () => onPressed(label), child: Icon(icon, size: 26))));
    return Column(children: [
      key('上', Icons.keyboard_arrow_up_rounded),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        key('左', Icons.keyboard_arrow_left_rounded),
        const SizedBox(width: 7),
        key('下', Icons.keyboard_arrow_down_rounded),
        const SizedBox(width: 7),
        key('右', Icons.keyboard_arrow_right_rounded),
      ]),
    ]);
  }
}

class AxonMappingCard extends StatelessWidget {
  const AxonMappingCard({super.key, required this.name, required this.binding,
    required this.mode, this.onTap, this.onDelete});
  final String name;
  final String binding;
  final String mode;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AxonCard(onTap: onTap, padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(13)),
          child: Icon(Icons.gamepad_rounded, color: cs.onPrimaryContainer)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text('$mode  ·  $binding', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ])),
        IconButton(tooltip: '删除映射', icon: const Icon(Icons.delete_outline_rounded), onPressed: onDelete),
      ]));
  }
}

/// 0..1 normalized control points. Drag one point to update the response curve.
/// This is a visual editor, not an Axon input engine replacement.
class AxonResponseCurve extends StatelessWidget {
  const AxonResponseCurve({super.key, required this.points, required this.onChanged,
    this.height = 168});
  final List<Offset> points;
  final ValueChanged<List<Offset>> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 280.0;
      final areaWidth = math.max(1, width - 24);
      final areaHeight = math.max(1, height - 24);
      void update(Offset local) {
        if (points.length < 3) return;
        final normalized = Offset(((local.dx - 12) / areaWidth).clamp(0.0, 1.0).toDouble(),
          (1 - (local.dy - 12) / areaHeight).clamp(0.0, 1.0).toDouble());
        // Lock the endpoints; edit only the middle anchor.
        final next = [...points];
        next[1] = normalized;
        onChanged(next);
      }
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => update(details.localPosition),
        onTapDown: (details) => update(details.localPosition),
        child: SizedBox(height: height, width: double.infinity,
          child: CustomPaint(painter: _AxonCurvePainter(points, cs.primary, cs.outlineVariant))),
      );
    });
  }
}

class _AxonCurvePainter extends CustomPainter {
  _AxonCurvePainter(this.points, this.primary, this.line);
  final List<Offset> points;
  final Color primary;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(12, 12, math.max(1, size.width - 24), math.max(1, size.height - 24));
    final axis = Paint()..color = line..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final dx = rect.left + rect.width * i / 4;
      final dy = rect.top + rect.height * i / 4;
      canvas.drawLine(Offset(dx, rect.top), Offset(dx, rect.bottom), axis);
      canvas.drawLine(Offset(rect.left, dy), Offset(rect.right, dy), axis);
    }
    if (points.isEmpty) return;
    Offset p(Offset point) => Offset(rect.left + point.dx * rect.width,
      rect.bottom - point.dy * rect.height);
    final ordered = [...points]..sort((a, b) => a.dx.compareTo(b.dx));
    final path = Path()..moveTo(p(ordered.first).dx, p(ordered.first).dy);
    for (final pt in ordered.skip(1)) { path.lineTo(p(pt).dx, p(pt).dy); }
    canvas.drawPath(path, Paint()..color = primary..strokeWidth = 3.2
      ..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round..style = PaintingStyle.stroke);
    for (final point in points) {
      canvas.drawCircle(p(point), 5.2, Paint()..color = primary);
      canvas.drawCircle(p(point), 2.2, Paint()..color = Colors.white);
    }
  }
  @override
  bool shouldRepaint(covariant _AxonCurvePainter old) =>
    old.primary != primary || old.line != line || !_samePoints(old.points, points);

  bool _samePoints(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) { if (a[i] != b[i]) return false; }
    return true;
  }
}

class AxonOpacityTile extends StatelessWidget {
  const AxonOpacityTile({super.key, required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => AxonSliderTile(title: '悬浮界面透明度',
    subtitle: '仅用于 UI 样式预览；实际悬浮窗由 Axon 原生层控制。',
    value: value * 100, min: 0, max: 100, divisions: 20, decimals: 0,
    suffix: '%', onChanged: (v) => onChanged(v / 100));
}

class AxonColorModePicker extends StatelessWidget {
  const AxonColorModePicker({super.key, required this.selected,
    required this.onChanged});
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;
  @override
  Widget build(BuildContext context) => AxonSegmentedControl(
    labels: const ['系统', '浅色', '深色'],
    icons: const [Icons.brightness_auto_rounded, Icons.light_mode_rounded, Icons.dark_mode_rounded],
    selected: ThemeMode.values.indexOf(selected),
    onChanged: (index) => onChanged(ThemeMode.values[index]));
}

class AxonModeCard extends StatelessWidget {
  const AxonModeCard({super.key, required this.title, required this.description,
    required this.icon, required this.selected, this.onTap});
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AxonCard(selected: selected, onTap: onTap, child: Row(children: [
      Icon(icon, color: selected ? cs.primary : cs.onSurfaceVariant),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(description, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      ])),
      if (selected) Icon(Icons.check_circle_rounded, color: cs.primary),
    ]));
  }
}
