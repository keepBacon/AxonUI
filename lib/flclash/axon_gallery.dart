import 'package:flutter/material.dart';
import 'controls.dart';
import 'theme.dart';
import 'motion.dart';
import 'advanced_controls.dart';

/// Axon component catalogue using FlClash's existing Material components.
/// No networking, key capture, mouse injection or input actions are present.
class FlAxonCatalogueScreen extends StatefulWidget {
  const FlAxonCatalogueScreen({
    super.key, required this.onControls,
    required this.onSchema, required this.onTheme,
  });
  final VoidCallback onControls, onSchema, onTheme;
  @override
  State<FlAxonCatalogueScreen> createState() => _FlAxonCatalogueScreenState();
}

class _FlAxonCatalogueScreenState extends State<FlAxonCatalogueScreen> {
  String query = '';
  bool previewEnabled = true;

  @override
  Widget build(BuildContext context) {
    final categories = <(String, String, IconData, VoidCallback)>[
      ('基础控件', '按钮 · 开关 · 分段 · 数值 · 滑块',
        Icons.widgets_outlined, widget.onControls),
      ('键鼠与手柄', '键帽 · 鼠标按键 · 手柄按钮',
        Icons.sports_esports_outlined, widget.onControls),
      ('触控布局', '拖动 · 位置 · 尺寸',
        Icons.touch_app_outlined, widget.onControls),
      ('摇杆与方向', '双摇杆 · 十字键 · 触控板',
        Icons.gamepad_outlined, widget.onControls),
      ('外观参数', '边框 · 圆角 · 渐变 · 进度',
        Icons.style_outlined, widget.onControls),
      ('参数编辑', '开关 · 选择 · 键位 · 列表',
        Icons.account_tree_outlined, widget.onSchema),
      ('材质与动效', '液态玻璃 · 配色 · 页面动画',
        Icons.water_drop_outlined, widget.onTheme),
    ].where((item) => (item.$1 + item.$2).toLowerCase()
        .contains(query.toLowerCase().trim())).toList();

    return ListView(
      key: const PageStorageKey('axon-catalogue'),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 138),
      children: [
        const Text('组件库', style: TextStyle(
          fontSize: 29, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const FlSection(title: '控件目录', icon: Icons.grid_view_rounded),
        TextField(
          key: const ValueKey('axon-category-search'),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: '搜索控件分类',
          ),
          onChanged: (text) => setState(() => query = text),
        ),
        const SizedBox(height: 13),
        if (categories.isEmpty)
          const FlPanel(child: Text('没有匹配的组件分类'))
        else
          FlGroup(children: [
            for (final item in categories)
              FlSettingRow(
                title: item.$1,
                subtitle: item.$2,
                leading: Icon(item.$3, size: 29,
                  color: Theme.of(context).colorScheme.primary),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: item.$4,
              ),
          ]),
        const FlSection(title: '基础控件', icon: Icons.tune_rounded),
        FlGroup(children: [
          FlToggleRow(
            title: '开关',
            icon: Icons.toggle_on_outlined,
            value: previewEnabled,
            onChanged: (value) => setState(() => previewEnabled = value),
          ),
          FlSettingRow(
            title: '更多控件',
            leading: const Icon(Icons.touch_app_outlined),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: widget.onControls,
          ),
        ]),
      ],
    );
  }
}

/// The original Axon control families expressed using FlClash widgets.
class FlAxonControlsScreen extends StatefulWidget {
  const FlAxonControlsScreen({super.key});
  @override
  State<FlAxonControlsScreen> createState() => _FlAxonControlsScreenState();
}

class _FlAxonControlsScreenState extends State<FlAxonControlsScreen> {
  bool enabled = true, labels = false;
  int count = 3;
  double opacity = 76, size = 53;
  String mode = '切换', selectedKey = 'Space';
  Color selectedColor = FlTokens.blue;
  Offset position = const Offset(.46, .50);
  bool pressed = false;
  final fieldController = TextEditingController(text: '文本');

  @override
  void dispose() {
    fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      key: const PageStorageKey('axon-controls'),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 138),
      children: [
        const Text('控件', style: TextStyle(
          fontSize: 29, fontWeight: FontWeight.w700)),
        const FlSection(title: '基础组件', icon: Icons.widgets_outlined),
        FlGroup(children: [
          FlToggleRow(
            title: '开关',
            icon: Icons.toggle_on_outlined,
            value: enabled,
            onChanged: (v) => setState(() => enabled = v),
          ),
          FlToggleRow(
            title: '文字标签',
            icon: Icons.text_fields_outlined,
            value: labels,
            onChanged: (v) => setState(() => labels = v),
          ),
          FlSettingRow(
            title: '数值步进器',
            leading: const Icon(Icons.exposure_plus_1_rounded),
            trailing: FlStepCounter(value: count, min: 0, max: 20,
              onChanged: (v) => setState(() => count = v)),
          ),
          FlSettingRow(
            title: '按钮',
            leading: const Icon(Icons.touch_app_outlined),
            trailing: FlPressScale(pressedScale: .92,
              child: FilledButton.tonal(
                key: const ValueKey('axon-demo-button'),
                onPressed: () => setState(() => pressed = !pressed),
                child: Text(pressed ? '已点击' : '点击'),
              ),
            ),
          ),
        ]),
        const FlSection(title: '选择与数值', icon: Icons.tune_rounded),
        FlSegmented<String>(
          values: const ['按下', '切换', '长按'],
          label: (v) => v,
          value: mode,
          onChanged: (v) => setState(() => mode = v),
        ),
        const SizedBox(height: 12),
        FlSliderPanel(
          title: '透明度',
          value: opacity,
          onChanged: (v) => setState(() => opacity = v),
        ),
        const SizedBox(height: 12),
        FlSliderPanel(
          title: '控件大小',
          value: size,
          min: 24, max: 96, suffix: 'dp',
          onChanged: (v) => setState(() => size = v),
        ),
        const FlSection(title: '键鼠和手柄', icon: Icons.sports_esports_outlined),
        FlPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('键帽', style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 17)),
            const SizedBox(height: 16),
            Wrap(spacing: 9, runSpacing: 9, children: [
              for (final key in const [
                'W', 'A', 'S', 'D', 'Space', 'LMB', 'RMB', 'Shift',
                '↑', '←', '↓', '→', 'A', 'B', 'X', 'Y',
              ])
                _AxonKeyButton(
                  label: key,
                  selected: key == selectedKey,
                  onTap: () => setState(() => selectedKey = key),
                ),
            ]),
          ],
        )),
        const FlSection(title: '虚拟触控布局', icon: Icons.pan_tool_alt_outlined),
        FlPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('按键位置', style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 17)),
            const SizedBox(height: 14),
            AspectRatio(
              aspectRatio: 1.65,
              child: LayoutBuilder(builder: (context, c) {
                const buttonWidth = 78.0, buttonHeight = 52.0;
                final limitX = (c.maxWidth - buttonWidth).clamp(0.0, double.infinity);
                final limitY = (c.maxHeight - buttonHeight).clamp(0.0, double.infinity);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Stack(children: [
                    Positioned(
                      left: position.dx * limitX,
                      top: position.dy * limitY,
                      child: GestureDetector(
                        key: const ValueKey('axon-drag-preview'),
                        onPanUpdate: (event) => setState(() {
                          final x = limitX == 0 ? position.dx :
                            position.dx + event.delta.dx / limitX;
                          final y = limitY == 0 ? position.dy :
                            position.dy + event.delta.dy / limitY;
                          position = Offset(x.clamp(0, 1).toDouble(),
                            y.clamp(0, 1).toDouble());
                        }),
                        child: Container(
                          width: buttonWidth, height: buttonHeight,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: .85),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text('SPACE', style: TextStyle(
                            fontWeight: FontWeight.w700, color: cs.onPrimary)),
                        ),
                      ),
                    ),
                  ]),
                );
              }),
            ),
          ],
        )),
        const FlSection(title: '输入与颜色', icon: Icons.palette_outlined),
        FlPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: fieldController,
              decoration: const InputDecoration(
                labelText: '文本控件', prefixIcon: Icon(Icons.edit_outlined)),
            ),
            const SizedBox(height: 18),
            FlColorSwatches(
              colors: const [
                FlTokens.blue, Color(0xFF3FB6A4), Color(0xFFD98D7A),
                Color(0xFF987BC8), Color(0xFF698CBE),
              ],
              value: selectedColor,
              onChanged: (v) => setState(() => selectedColor = v),
            ),
          ],
        )),
        const FlAdditionalControls(),
        const FlSection(title: '参数控件', icon: Icons.account_tree_outlined),
        FlPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('参数控件', style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 17)),
            const SizedBox(height: 11),
            const Text('开关 · 按钮 · 滑块 · 数值 · 选择 · 文本 · 键位 · 颜色 · 绑定 · 列表'),
          ],
        )),
      ],
    );
  }
}

class _AxonKeyButton extends StatelessWidget {
  const _AxonKeyButton({required this.label,required this.selected,required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FlPressScale(
      pressedScale: .91,
      child: AnimatedContainer(
        duration: FlMotion.effective(context, FlMotion.short),
        curve: FlMotion.curve,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: ValueKey('axon-key-$label'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 46, minHeight: 44),
              child: Center(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 9),
                child: AnimatedDefaultTextStyle(
                  duration: FlMotion.effective(context, FlMotion.short),
                  style: TextStyle(fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: selected ? scheme.onPrimary : scheme.onSurface),
                  child: Text(label),
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
