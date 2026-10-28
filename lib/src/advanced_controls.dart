import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'axon_schema.dart';
import 'common.dart';
import 'controls.dart';
import 'theme.dart';

/// Precision slider + editable numeric value. Values are quantized to Axon's step.
class AxonPrecisionSlider extends StatefulWidget {
  const AxonPrecisionSlider({super.key, required this.label, required this.value,
    required this.min, required this.max, required this.step,
    required this.onChanged, this.unit = ''});
  final String label, unit;
  final double value, min, max, step;
  final ValueChanged<double> onChanged;
  @override
  State<AxonPrecisionSlider> createState() => _AxonPrecisionSliderState();
}

class _AxonPrecisionSliderState extends State<AxonPrecisionSlider> {
  late final TextEditingController _text = TextEditingController();
  final _focus = FocusNode();
  @override
  void initState() { super.initState(); _sync(); }
  void _sync() { _text.text = widget.value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), ''); }
  @override
  void didUpdateWidget(covariant AxonPrecisionSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && oldWidget.value != widget.value) _sync();
  }
  @override
  void dispose() { _text.dispose(); _focus.dispose(); super.dispose(); }
  void _change(double v) => widget.onChanged(normalizeAxonNumber(v, widget.min, widget.max, widget.step));
  @override
  Widget build(BuildContext context) {
    final value = widget.value.clamp(widget.min, widget.max).toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 5),
      Row(children: [
        IconButton.filledTonal(onPressed: value <= widget.min ? null : () => _change(value - widget.step),
          icon: const Icon(Icons.remove, size: 18)),
        Expanded(child: Slider(min: widget.min, max: widget.max, value: value,
          onChanged: _change)),
        IconButton.filledTonal(onPressed: value >= widget.max ? null : () => _change(value + widget.step),
          icon: const Icon(Icons.add, size: 18)),
        const SizedBox(width: 6),
        SizedBox(width: 74, child: TextField(controller: _text, focusNode: _focus,
          textAlign: TextAlign.center, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
          onSubmitted: (s) { final parsed = double.tryParse(s); if (parsed != null) _change(parsed); _focus.unfocus(); _sync(); },
          decoration: InputDecoration(isDense: true, suffixText: widget.unit.isEmpty ? null : widget.unit,
            contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12)))),
      ]),
    ]);
  }
}

class AxonRangeEditor extends StatelessWidget {
  const AxonRangeEditor({super.key, required this.label, required this.values,
    required this.min, required this.max, required this.onChanged});
  final String label;
  final RangeValues values;
  final double min, max;
  final ValueChanged<RangeValues> onChanged;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('$label  ${values.start.toStringAsFixed(0)}–${values.end.toStringAsFixed(0)}',
      style: const TextStyle(fontWeight: FontWeight.w600)),
    RangeSlider(values: values, min: min, max: max, onChanged: onChanged),
  ]);
}

/// Exact #AARRGGBB colors, compatible with PluginUiSpec.DEBUG_COLOR.
class AxonArgbEditor extends StatelessWidget {
  const AxonArgbEditor({super.key, required this.label, required this.colors,
    required this.onChanged, this.maxColors = 8});
  final String label;
  final List<String> colors;
  final int maxColors;
  final ValueChanged<List<String>> onChanged;
  static const presets = ['#FF2676D2', '#FF22A684', '#FFE0A23B', '#FF945BD6',
    '#FFE86474', '#FFFFFFFF', '#FF202631', '#80000000'];
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 9),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (var i = 0; i < colors.length; i++)
          InkWell(key: ValueKey('color-$i'), borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final picked = await showAxonArgbDialog(context, colors[i]);
              if (picked != null) {
                final copy = [...colors]; copy[i] = picked; onChanged(copy);
              }
            },
            child: Container(width: 62, height: 51, decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant), borderRadius: BorderRadius.circular(12)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 30, height: 24, decoration: BoxDecoration(
                  color: Color(int.parse(colors[i].substring(1), radix: 16)),
                  borderRadius: BorderRadius.circular(7), border: Border.all(color: cs.outlineVariant))),
                Text('${i + 1}', style: const TextStyle(fontSize: 10)),
              ]))),
        if (colors.length < maxColors)
          IconButton.filledTonal(tooltip: '增加颜色', onPressed: () => onChanged([...colors, '#FFFFFFFF']),
            icon: const Icon(Icons.add_rounded)),
        if (colors.length > 1)
          IconButton(tooltip: '移除最后一个颜色', onPressed: () => onChanged(colors.sublist(0, colors.length - 1)),
            icon: const Icon(Icons.remove_circle_outline)),
      ]),
      if (colors.length >= 2) ...[
        const SizedBox(height: 10),
        Container(height: 26, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(colors: [for (final s in colors) Color(int.parse(s.substring(1), radix: 16))])),
        ),
      ],
    ]);
  }
}

Future<String?> showAxonArgbDialog(BuildContext context, String current) async {
  final controller = TextEditingController(text: current);
  try {
    return await showDialog<String>(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setLocal) => AlertDialog(
        title: const Text('颜色 · ARGB'),
        content: SizedBox(width: 320, child: Column(mainAxisSize: MainAxisSize.min, children: [
          Wrap(spacing: 8, runSpacing: 8, children: [for (final hex in AxonArgbEditor.presets)
            InkWell(onTap: () => setLocal(() { controller.text = hex; }),
              child: Container(width: 33, height: 33, decoration: BoxDecoration(
                shape: BoxShape.circle, color: Color(int.parse(hex.substring(1), radix: 16)),
                border: Border.all(color: Theme.of(dialogContext).colorScheme.outline)))),
          ]),
          const SizedBox(height: 16),
          TextField(controller: controller, maxLength: 9,
            decoration: const InputDecoration(labelText: '#AARRGGBB', counterText: ''),
            onChanged: (v) => setLocal(() {})),
          const SizedBox(height: 10),
          const Text('支持 8 位 ARGB 或 6 位 RGB 十六进制颜色', style: TextStyle(fontSize: 12)),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('取消')),
          FilledButton(onPressed: normalizeAxonColor(controller.text) == null ? null :
            () => Navigator.pop(dialogContext, normalizeAxonColor(controller.text)), child: const Text('确定')),
        ],
      )));
  } finally {
    // Dialog owns its text input while open; disposal after its route is gone.
    controller.dispose();
  }
}

/// Interactive, pixel-independent touch viewport editor. No privileged input.
class AxonTouchRegionEditor extends StatefulWidget {
  const AxonTouchRegionEditor({super.key, required this.region, required this.onChanged,
    this.aspectRatio = 16 / 9});
  final AxonTouchRegion region;
  final ValueChanged<AxonTouchRegion> onChanged;
  final double aspectRatio;
  @override
  State<AxonTouchRegionEditor> createState() => _AxonTouchRegionEditorState();
}

class _AxonTouchRegionEditorState extends State<AxonTouchRegionEditor> {
  bool _resizing = false;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(builder: (context, constraints) {
      final width = math.min(constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0, 560.0);
      final height = width / widget.aspectRatio;
      final r = widget.region;
      final target = Rect.fromLTWH(width * r.x, height * r.y, width * r.width, height * r.height);
      void drag(DragUpdateDetails details) {
        if (_resizing) {
          widget.onChanged(r.resize(details.delta.dx / width, details.delta.dy / height));
        } else {
          widget.onChanged(r.move(details.delta.dx / width, details.delta.dy / height));
        }
      }
      return Align(alignment: Alignment.centerLeft, child: GestureDetector(
        onPanStart: (details) {
          final p = details.localPosition;
          _resizing = (p - target.bottomRight).distance < 36;
        },
        onPanUpdate: drag,
        child: Semantics(label: '拖动区域移动，拖动右下角调整范围',
          child: Container(width: width, height: height,
            decoration: BoxDecoration(color: cs.surfaceContainerHigh,
              border: Border.all(color: cs.outlineVariant), borderRadius: BorderRadius.circular(14)),
            child: Stack(children: [
              Positioned.fill(child: CustomPaint(painter: _AxonGridPainter(cs.outlineVariant))),
              Positioned.fromRect(rect: target, child: Container(
                decoration: BoxDecoration(color: cs.primary.withValues(alpha: .22),
                  border: Border.all(color: cs.primary, width: 2), borderRadius: BorderRadius.circular(8)),
                child: Stack(children: [
                  Center(child: Icon(Icons.open_with_rounded, color: cs.primary, size: 22)),
                  Positioned(right: 0, bottom: 0, child: Icon(Icons.open_in_full_rounded, color: cs.primary, size: 17)),
                ]))),
            ]))),
      ));
    });
  }
}

class _AxonGridPainter extends CustomPainter {
  const _AxonGridPainter(this.line);
  final Color line;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = line..strokeWidth = .7;
    for (var i = 1; i < 8; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override
  bool shouldRepaint(covariant _AxonGridPainter old) => old.line != line;
}

/// Edits source, Android keyCode and touch rectangle with Axon's JSON shape.
class AxonBindingEditor extends StatelessWidget {
  const AxonBindingEditor({super.key, required this.value, required this.onChanged});
  final Map<String, dynamic> value;
  final ValueChanged<Map<String, dynamic>> onChanged;
  @override
  Widget build(BuildContext context) {
    final normalized = normalizeAxonBinding(value);
    final touch = normalized['source'] == 'touch';
    final keyCode = normalized['keyCode'] as int;
    final region = AxonTouchRegion.fromJson(Map<String, dynamic>.from(normalized['region'] as Map));
    void write(String field, Object data) => onChanged({...normalized, field: data});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AxonSegmentedControl(labels: const ['外部按键', '屏幕触控'], selected: touch ? 1 : 0,
        onChanged: (i) => write('source', i == 1 ? 'touch' : 'external')),
      const SizedBox(height: 12),
      if (!touch) ...[
        AxonKeyCodeInput(value: keyCode, onChanged: (v) => write('keyCode', v)),
        const Text('这里使用 Android/Axon 输入码；Flutter LogicalKeyboardKey 不能直接充当原生键码。',
          style: TextStyle(fontSize: 11)),
      ] else ...[
        AxonTouchRegionEditor(region: region, onChanged: (v) => write('region', v.toJson())),
        const SizedBox(height: 8),
        Text('X ${(region.x * 100).toStringAsFixed(1)}% · Y ${(region.y * 100).toStringAsFixed(1)}% · '
          'W ${(region.width * 100).toStringAsFixed(1)}% · H ${(region.height * 100).toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 11)),
      ],
    ]);
  }
}

class AxonKeyCodeInput extends StatelessWidget {
  const AxonKeyCodeInput({super.key, required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text('Android 按键码: $value')),
    IconButton.filledTonal(tooltip: '减小', onPressed: value <= -1 ? null : () => onChanged(value - 1),
      icon: const Icon(Icons.remove)),
    const SizedBox(width: 7),
    IconButton.filledTonal(tooltip: '增加', onPressed: value >= 1000 ? null : () => onChanged(value + 1),
      icon: const Icon(Icons.add)),
  ]);
}

/// Generic gamepad preview: callbacks are UI-only and do not inject input.
class AxonGamepadTester extends StatelessWidget {
  const AxonGamepadTester({super.key, required this.onKey});
  final ValueChanged<String> onKey;
  @override
  Widget build(BuildContext context) {
    Widget key(String text) => SizedBox(width: 45, height: 43,
      child: FilledButton.tonal(onPressed: () => onKey(text),
        style: FilledButton.styleFrom(padding: EdgeInsets.zero), child: Text(text)));
    return AxonCard(child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [key('LB'), key('LT'), key('RT'), key('RB')]),
      const SizedBox(height: 12),
      Wrap(alignment: WrapAlignment.center, spacing: 7, runSpacing: 10, children: [
        for (final item in ['↑', '←', '↓', '→', 'L3', 'R3', 'X', 'Y', 'A', 'B']) key(item),
      ]),
    ]));
  }
}

class AxonLogConsole extends StatelessWidget {
  const AxonLogConsole({super.key, required this.lines, this.onClear});
  final List<String> lines;
  final VoidCallback? onClear;
  @override
  Widget build(BuildContext context) => AxonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [const Icon(Icons.terminal, size: 19), const SizedBox(width: 9),
        const Expanded(child: Text('日志输出', style: TextStyle(fontWeight: FontWeight.w600))),
        IconButton(tooltip: '清空日志', onPressed: onClear, icon: const Icon(Icons.delete_outline))]),
      ConstrainedBox(constraints: const BoxConstraints(maxHeight: 160), child: SingleChildScrollView(
        child: SelectableText(lines.isEmpty ? '暂无日志' : lines.join('\n'),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.7)))),
    ]));
}

class AxonStatusBadge extends StatelessWidget {
  const AxonStatusBadge(this.label, {super.key, this.isActive = false});
  final String label;
  final bool isActive;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(avatar: Icon(isActive ? Icons.check_circle : Icons.info_outline,
      size: 16, color: isActive ? scheme.primary : scheme.onSurfaceVariant),
      label: Text(label), visualDensity: VisualDensity.compact);
  }
}

class AxonPresetCard extends StatelessWidget {
  const AxonPresetCard({super.key, required this.title, required this.description,
    this.selected = false, this.onApply, this.onEdit});
  final String title, description;
  final bool selected;
  final VoidCallback? onApply, onEdit;
  @override
  Widget build(BuildContext context) => AxonCard(selected: selected, child: Row(children: [
    const Icon(Icons.dashboard_customize_outlined), const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      Text(description, style: Theme.of(context).textTheme.bodySmall),
    ])),
    IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), tooltip: '编辑预设'),
    FilledButton.tonal(onPressed: onApply, child: const Text('应用')),
  ]));
}

class AxonSparkline extends StatelessWidget {
  const AxonSparkline({super.key, required this.values, this.height = 84});
  final List<double> values;
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(height: height,
    child: CustomPaint(painter: _SparklinePainter(values, Theme.of(context).colorScheme.primary),
      child: const SizedBox.expand()));
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.values, this.color);
  final List<double> values;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final valid = values.where((v) => v.isFinite).toList();
    if (valid.length < 2) return;
    final min = valid.reduce(math.min);
    final max = valid.reduce(math.max);
    final span = math.max(.00001, max - min);
    final path = Path();
    for (var i = 0; i < valid.length; i++) {
      final point = Offset(4 + (size.width - 8) * i / (valid.length - 1),
        size.height - 4 - (size.height - 8) * (valid[i] - min) / span);
      if (i == 0) {path.moveTo(point.dx, point.dy);} else {path.lineTo(point.dx, point.dy);}
    }
    canvas.drawPath(path, Paint()..color = color..strokeWidth = 2.5
      ..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round);
  }
  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.values != values || old.color != color;
}
