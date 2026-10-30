import 'package:flutter/material.dart';
import 'controls.dart';
import 'theme.dart';

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
      ('键鼠与手柄', '虚拟键帽 · 鼠标 · 手柄反馈',
        Icons.sports_esports_outlined, widget.onControls),
      ('触控布局', '拖动与位置调整 · 仅视觉预览',
        Icons.touch_app_outlined, widget.onControls),
      ('插件 Schema', 'toggle · select · binding · list 等',
        Icons.account_tree_outlined, widget.onSchema),
      ('材质与动效', 'FlClash 液态玻璃 · 颜色 · 页面动画',
        Icons.water_drop_outlined, widget.onTheme),
    ].where((item) => (item.$1 + item.$2).toLowerCase()
        .contains(query.toLowerCase().trim())).toList();

    return ListView(
      key: const PageStorageKey('axon-catalogue'),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 138),
      children: [
        const Text('组件库', style: TextStyle(
          fontSize: 29, fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        Text('Axon Input · Flutter UI 预览',
          style: TextStyle(color: flMuted(context), fontSize: 14)),
        const SizedBox(height: 17),
        FlPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.auto_awesome_motion_rounded,
                color: Theme.of(context).colorScheme.primary, size: 23),
              const SizedBox(width: 10),
              const Expanded(child: Text('Axon 控件工作台',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20))),
            ]),
            const SizedBox(height: 9),
            const Text('保留 FlClash UI 材质、布局质感和动画组件；'
              '将展示内容换为 Axon 控件，不接入实际输入功能。'),
            const SizedBox(height: 12),
            Wrap(spacing: 7, runSpacing: 8, children: [
              _AxonToken('UI ONLY'),
              _AxonToken('FLUTTER'),
              _AxonToken('AXON CONTROLS'),
            ]),
          ],
        )),
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
        const FlSection(title: '交互预览', icon: Icons.tune_rounded),
        FlGroup(children: [
          FlToggleRow(
            title: '组件启用状态',
            subtitle: '只更新本地 UI',
            icon: Icons.toggle_on_outlined,
            value: previewEnabled,
            onChanged: (value) => setState(() => previewEnabled = value),
          ),
          FlSettingRow(
            title: '查看 Axon 控件',
            subtitle: '进入完整的可交互预览',
            leading: const Icon(Icons.touch_app_outlined),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: widget.onControls,
          ),
        ]),
      ],
    );
  }
}

class _AxonToken extends StatelessWidget {
  const _AxonToken(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Text(label, style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: scheme.primary,
        )),
      ),
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
  final fieldController = TextEditingController(text: '预览控件');

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
        const Text('Axon 控件', style: TextStyle(
          fontSize: 29, fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        Text('组件外观采用 FlClash UI，交互仅更改演示状态。',
          style: TextStyle(color: flMuted(context))),
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
            title: '交互反馈按钮',
            subtitle: pressed ? '已触发视觉反馈' : '点击查看按钮状态',
            leading: const Icon(Icons.touch_app_outlined),
            trailing: FilledButton.tonal(
              key: const ValueKey('axon-demo-button'),
              onPressed: () => setState(() => pressed = !pressed),
              child: Text(pressed ? '已点击' : '预览'),
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
            const Text('虚拟键帽与按钮', style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 17)),
            const SizedBox(height: 8),
            Text('点击仅改变预览状态，不捕获或发送按键。',
              style: TextStyle(color: flMuted(context), fontSize: 12)),
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
            const Text('按键位置预览', style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 17)),
            const SizedBox(height: 7),
            Text('拖动 SPACE 按钮，仅更新本页面位置。',
              style: TextStyle(color: flMuted(context), fontSize: 12)),
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
        const FlSection(title: 'Schema 覆盖', icon: Icons.account_tree_outlined),
        FlPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Axon 插件声明控件', style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 17)),
            const SizedBox(height: 11),
            const Text('toggle、button、slider、number、select、text、'
              'key、color、binding、list 的演示由「配置」页提供。'),
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
    return Material(
      color: selected ? scheme.primary : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: ValueKey('axon-key-$label'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 46, minHeight: 44),
          child: Center(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 9),
            child: Text(label,
              style: TextStyle(fontWeight: FontWeight.w700,
                fontSize: 12,
                color: selected ? scheme.onPrimary : scheme.onSurface)),
          )),
        ),
      ),
    );
  }
}
