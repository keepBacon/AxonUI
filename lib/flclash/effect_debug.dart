import 'package:flutter/material.dart';
import 'controls.dart';
import 'color_debug.dart';
import 'theme.dart';

/// Locally simulated press transformations, never connected to input services.
class FlPressDebug extends StatefulWidget {
  const FlPressDebug({super.key});

  @override
  State<FlPressDebug> createState() => _FlPressDebugState();
}

class _FlPressDebugState extends State<FlPressDebug> {
  bool scaleEnabled = true;
  bool rippleEnabled = true;
  bool opacityEnabled = true;
  bool pressed = false;
  int rippleSerial = 0;
  double scaleAmount = 5;
  double pressDuration = 125;
  double opacityAmount = 22;
  double rippleSpeed = 100;

  void _press() => setState(() {
    pressed = true;
    rippleSerial++;
  });

  void _release() {
    if (pressed) setState(() => pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final motion = FlMotion.effective(
      context, Duration(milliseconds: pressDuration.round()));
    final rippleDuration = FlMotion.effective(context,
      Duration(milliseconds: (440 * 100 / rippleSpeed).round()));

    return FlPanel(child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('按压动效调试', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(23),
          child: SizedBox(height: 136,
            child: Stack(alignment: Alignment.center, children: [
              Positioned.fill(child: ColoredBox(
                color: cs.surfaceContainerHigh)),
              if (rippleEnabled && rippleSerial > 0)
                IgnorePointer(child: TweenAnimationBuilder<double>(
                  key: ValueKey('press-ripple-$rippleSerial'),
                  tween: Tween(begin: 0, end: 1),
                  duration: rippleDuration,
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) => Container(
                    width: 30 + 175 * t, height: 30 + 175 * t,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: cs.primary.withValues(
                        alpha: .22 * (1 - t))),
                  ),
                )),
              AnimatedScale(
                key: const ValueKey('press-debug-scale'),
                duration: motion,
                curve: pressed ? Curves.easeOutCubic : FlMotion.rebound,
                scale: pressed && scaleEnabled ? 1 - scaleAmount / 100 : 1,
                child: AnimatedOpacity(
                  duration: motion,
                  opacity: pressed && opacityEnabled
                    ? 1 - opacityAmount / 100 : 1,
                  child: Material(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      key: const ValueKey('press-debug-target'),
                      onTap: () {},
                      onTapDown: (_) => _press(),
                      onTapUp: (_) => _release(),
                      onTapCancel: _release,
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: 140, height: 62,
                        child: Center(child: Text('按压预览',
                          style: TextStyle(color: cs.onPrimary,
                            fontWeight: FontWeight.w700))),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 11),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero, dense: true,
          title: const Text('缩放反馈'), value: scaleEnabled,
          onChanged: (v) => setState(() => scaleEnabled = v)),
        FlDebugSlider(label: '缩放幅度', value: scaleAmount,
          min: 0, max: 20, suffix: '%',
          onChanged: (v) => setState(() => scaleAmount = v)),
        FlDebugSlider(label: '按压时长', value: pressDuration,
          min: 40, max: 400, suffix: 'ms',
          onChanged: (v) => setState(() => pressDuration = v)),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero, dense: true,
          title: const Text('波纹反馈'), value: rippleEnabled,
          onChanged: (v) => setState(() => rippleEnabled = v)),
        FlDebugSlider(label: '波纹速度', value: rippleSpeed,
          min: 25, max: 200, suffix: '%',
          onChanged: (v) => setState(() => rippleSpeed = v)),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero, dense: true,
          title: const Text('透明度反馈'), value: opacityEnabled,
          onChanged: (v) => setState(() => opacityEnabled = v)),
        FlDebugSlider(label: '透明度幅度', value: opacityAmount,
          min: 0, max: 75, suffix: '%',
          onChanged: (v) => setState(() => opacityAmount = v)),
      ],
    ));
  }
}

/// Four independently editable color layers for one sample button.
class FlLayerColorDebug extends StatefulWidget {
  const FlLayerColorDebug({super.key});

  @override
  State<FlLayerColorDebug> createState() => _FlLayerColorDebugState();
}

class _FlLayerColorDebugState extends State<FlLayerColorDebug> {
  final List<Color> colors = [
    const Color(0xFF4489EF),
    const Color(0xFF254D9F),
    const Color(0xFFC9E0FF),
    const Color(0xFFFFFFFF),
  ];
  final List<double> alpha = [1, 1, .95, 1];
  int layer = 0;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const names = ['背景', '按下', '边框', '文字'];
    const palette = [
      Color(0xFF4489EF), Color(0xFF31509B),
      Color(0xFF51BDA8), Color(0xFFF0A56C),
      Color(0xFFDC74AB), Color(0xFFFFFFFF),
      Color(0xFF273047),
    ];
    Color layerColor(int index) =>
      colors[index].withValues(alpha: alpha[index]);

    return FlPanel(child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('图层颜色调试', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(22)),
          child: SizedBox(height: 116,
            child: Center(child: AnimatedContainer(
              key: const ValueKey('layer-color-preview'),
              duration: FlMotion.effective(context, FlMotion.short),
              curve: FlMotion.curve,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: pressed ? layerColor(1) : layerColor(0),
                border: Border.all(
                  color: layerColor(2), width: 3)),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  key: const ValueKey('layer-color-target'),
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {},
                  onTapDown: (_) => setState(() => pressed = true),
                  onTapUp: (_) => setState(() => pressed = false),
                  onTapCancel: () => setState(() => pressed = false),
                  child: SizedBox(width: 150, height: 70,
                    child: Center(child: Text(
                      pressed ? '按下状态' : '常规状态',
                      style: TextStyle(color: layerColor(3),
                        fontWeight: FontWeight.w700))),
                  ),
                ),
              ),
            )),
          ),
        ),
        const SizedBox(height: 14),
        FlSegmented<int>(
          values: const [0, 1, 2, 3],
          label: (index) => names[index],
          value: layer,
          onChanged: (index) => setState(() => layer = index)),
        const SizedBox(height: 13),
        FlColorSwatches(
          colors: palette,
          value: colors[layer],
          onChanged: (value) => setState(() => colors[layer] = value)),
        FlDebugSlider(label: '图层透明度',
          value: alpha[layer] * 100,
          min: 0, max: 100, suffix: '%',
          onChanged: (value) => setState(() =>
            alpha[layer] = value / 100)),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text('HEX #${colors[layer].toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
            style: TextStyle(color: cs.onSurfaceVariant,
              fontSize: 12)),
        ),
      ],
    ));
  }
}
