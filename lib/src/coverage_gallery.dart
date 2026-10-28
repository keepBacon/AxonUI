import 'dart:convert';
import 'package:flutter/material.dart';
import 'advanced_controls.dart';
import 'axon_schema.dart';
import 'bridge.dart';
import 'common.dart';
import 'controls.dart';
import 'plugin_schema_ui.dart';
import 'ui_extras_gallery.dart';

/// Real Axon PluginUiSpec-compatible sample. No fake plugin execution.
final axonPluginDemoDocument = AxonPluginDocument.fromJson({
  'features': [
    {
      'id': 'cursor', 'type': 'toggle', 'name': '指针与按键参数 UI',
      'description': '完整插件动态表单 · 开关 / 滑块 / 数值 / 选择 / 文本 / 键码',
      'default': true,
      'debug': [
        {'id': 'sensitivity', 'type': 'slider', 'name': '指针灵敏度', 'min': 0, 'max': 200, 'step': .5, 'default': 55, 'suffix': '%'},
        {'id': 'frequency', 'type': 'number', 'name': '更新频率', 'min': 30, 'max': 240, 'step': 5, 'default': 120, 'suffix': 'Hz'},
        {'id': 'mode', 'type': 'select', 'name': '响应模式', 'options': ['舒适', '均衡', '快速'], 'default': '均衡'},
        {'id': 'name', 'type': 'text', 'name': '配置名称', 'default': '默认配置'},
        {'id': 'key', 'type': 'key', 'name': '唤起按键', 'default': 62},
        {'id': 'lock', 'type': 'toggle', 'name': '锁定横屏坐标', 'default': false},
      ],
    },
    {
      'id': 'visual', 'type': 'toggle', 'name': '显示与触控样式', 'default': true,
      'description': 'ARGB 多色渐变、键位/触控绑定、映射列表',
      'debug': [
        {'id': 'colors', 'type': 'color', 'name': '按键渐变色',
          'default': ['#FF2676D2', '#FF43A6D5', '#FF00BFA5']},
        {'id': 'binding', 'type': 'binding', 'name': '映射区域',
          'default': {'source': 'touch', 'keyCode': -1,
            'region': {'x': .30, 'y': .38, 'width': .24, 'height': .25}}},
        {'id': 'mappings', 'type': 'list', 'name': '映射规则', 'minItems': 0, 'maxItems': 12,
          'addText': '新建映射', 'fields': [
            {'id': 'name', 'type': 'text', 'name': '规则名称', 'default': '新规则'},
            {'id': 'enabled', 'type': 'toggle', 'name': '启用规则', 'default': true},
            {'id': 'action', 'type': 'select', 'name': '触发动作',
              'options': ['轻触', '长按', '连击'], 'default': '轻触'},
            {'id': 'bind', 'type': 'binding', 'name': '按键来源'},
          ],
          'default': [
            {'name': '跳跃', 'enabled': true, 'action': '轻触',
              'bind': {'source': 'external', 'keyCode': 62}},
          ],
        },
      ],
    },
    {'id': 'apply', 'type': 'button', 'name': '按钮状态（UI 演示）',
      'description': '此按钮只生成 UI 回调事件，不会修改真实 Axon 输入引擎。',
      'buttonText': '预览回调'},
  ],
});

class AxonCoverageGallery extends StatefulWidget {
  const AxonCoverageGallery({super.key, required this.store});
  final AxonUiStore store;
  @override
  State<AxonCoverageGallery> createState() => _AxonCoverageGalleryState();
}

class _AxonCoverageGalleryState extends State<AxonCoverageGallery> {
  int _tab = 0;
  final Map<String, Object?> _values = {};
  List<String> _logs = ['[INFO] Axon UI Control Coverage v3 · 本地演示'];
  AxonTouchRegion _region = const AxonTouchRegion(.32, .28, .24, .3);
  double _minPressure = 10, _maxPressure = 80;
  List<String> _palette = ['#FF2276D8', '#FF17B99B', '#FF9B77DE'];
  String _gamepadKey = '无';
  final List<String> _layers = ['键盘显示', '鼠标轨迹', '手柄状态', '触控热点'];
  List<double> _stats = [12, 16, 13, 18, 16, 22, 15, 19, 18, 20, 18, 14, 16];
  String _profile = '均衡';
  bool _active = true;

  @override
  void initState() {super.initState(); _load();}
  Future<void> _load() async {
    try {
      final all = await widget.store.load();
      final raw = all['coverage_document_v3'];
      if (raw is! String || !mounted) return;
      final data = jsonDecode(raw);
      if (data is Map) setState(() => _values.addAll(Map<String, Object?>.from(data)));
    } catch (_) { /* Standalone preview works without persistence. */ }
  }
  void _update(String id, Object? value) {
    setState(() => _values[id] = value);
    widget.store.setValue('coverage_document_v3', jsonEncode(_values)).catchError((Object error) {
      if (mounted) _log('设置保存失败: $error');
    });
  }
  void _log(String msg) {
    setState(() => _logs = [..._logs.take(35), '[UI] $msg']);
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const AxonSectionHeader('Axon 全控件覆盖实验室',
      subtitle: '对照原生 AxonFlClashKit + PluginUiSpec · 仅演示 UI，不调用真实输入后端'),
    AxonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('控件分类', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 4, children: [
        for (var i = 0; i < 5; i++) ChoiceChip(
          label: Text(const ['插件表单', '输入映射', '外观显示', '配置调试', 'UI 扩展'][i]),
          selected: _tab == i,
          onSelected: (_) => setState(() => _tab = i)),
      ]),
    ])),
    const SizedBox(height: 12),
    if (_tab == 0) _pluginUi(),
    if (_tab == 1) _inputUi(),
    if (_tab == 2) _displayUi(),
    if (_tab == 3) _configUi(),
    if (_tab == 4) const AxonUiExtrasGallery(),
  ]);

  Widget _pluginUi() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const AxonSectionHeader('完整插件 UI Schema', subtitle: '2 类 feature + 9 类 debug；全部可交互'),
    AxonPluginSchemaUi(document: axonPluginDemoDocument, values: _values,
      onChanged: _update, onAction: (id) => _log('收到按钮回调：$id（未执行原生动作）')),
    const AxonSectionHeader('Schema 调试', subtitle: '应用层只读取/编辑声明式状态'),
    AxonExpandableCard(title: 'JSON 状态', child: SelectableText(
      const JsonEncoder.withIndent('  ').convert(_values),
      style: const TextStyle(fontFamily: 'monospace', fontSize: 11))),
  ]);

  Widget _inputUi() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const AxonSectionHeader('触控区域编辑', subtitle: '归一化坐标，与 Axon native binding.region 结构一致'),
    AxonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AxonTouchRegionEditor(region: _region, onChanged: (v) => setState(() => _region = v)),
      const SizedBox(height: 6),
      Text('x=${_region.x.toStringAsFixed(2)}  y=${_region.y.toStringAsFixed(2)}  '
        'w=${_region.width.toStringAsFixed(2)}  h=${_region.height.toStringAsFixed(2)}'),
      const SizedBox(height: 8),
      OutlinedButton(onPressed: () => setState(() => _region = const AxonTouchRegion(.4, .4, .2, .2)),
        child: const Text('重置区域')),
    ])),
    const AxonSectionHeader('手柄图形按钮预览', subtitle: '仅展示 ABXY / D-Pad / 肩键等 UI 控件反馈，不监听真实手柄'),
    AxonGamepadTester(onKey: (key) {setState(() => _gamepadKey = key); _log('手柄 UI：$key');}),
    AxonSettingTile(title: '最后操作', subtitle: '当前控件为 UI 事件演示', trailing: AxonStatusBadge(_gamepadKey)),
    const AxonSectionHeader('压力区间与阈值', subtitle: '上下界拖拽调节'),
    AxonCard(child: AxonRangeEditor(label: '触控触发阈值', min: 0, max: 100,
      values: RangeValues(_minPressure, _maxPressure),
      onChanged: (v) => setState(() {_minPressure = v.start; _maxPressure = v.end;}))),
  ]);

  Widget _displayUi() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const AxonSectionHeader('ARGB 颜色与多段渐变', subtitle: '支持颜色编辑、添加、删除和渐变实时预览'),
    AxonCard(child: AxonArgbEditor(label: '显示材质颜色', colors: _palette,
      onChanged: (v) => setState(() => _palette = v))),
    const AxonSectionHeader('分层渲染排序', subtitle: '按住拖拽柄重排显示层；与原生层分离'),
    AxonCard(child: AxonReorderList(items: _layers, onReorder: (from, to) {
      setState(() {
        if (to > from) to--;
        final layer = _layers.removeAt(from); _layers.insert(to, layer);
      });
    })),
    const AxonSectionHeader('显示组件状态', subtitle: '状态标签、预设卡片与操作'),
    AxonCard(child: AxonSwitchTile(title: '显示浮窗（模拟）', value: _active,
      icon: Icons.visibility_rounded, onChanged: (v) => setState(() => _active = v))),
    const SizedBox(height: 10),
    const Wrap(spacing: 8, runSpacing: 8, children: [
      AxonStatusBadge('键盘模型', isActive: true), AxonStatusBadge('手柄响应', isActive: true),
      AxonStatusBadge('Live2D 接口未接入'),
    ]),
  ]);

  Widget _configUi() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const AxonSectionHeader('配置与工作区', subtitle: '配置卡片、参数状态、搜索与进度显示'),
    for (final preset in ['舒适', '均衡', '性能']) ...[
      AxonPresetCard(title: '$preset 预设', description: '应用 UI 参数集（仅演示）',
        selected: _profile == preset,
        onApply: () { setState(() => _profile = preset); _log('已选 UI 预设: $preset'); },
        onEdit: () => showAxonSheet<void>(context, title: '编辑 $preset',
          child: const Text('配置编辑器通过 JSON Schema 驱动；真实导入导出需连接宿主。'))),
      const SizedBox(height: 8),
    ],
    const AxonSectionHeader('延迟趋势', subtitle: '折线控件及性能信息区（模拟数据）'),
    AxonCard(child: Column(children: [
      Row(children: [const Expanded(child: Text('刷新耗时变化')),
        IconButton(onPressed: () => setState(() => _stats = [..._stats.skip(1), (_stats.last + 7) % 25 + 5]),
          tooltip: '刷新模拟数据', icon: const Icon(Icons.refresh_rounded))]),
      AxonSparkline(values: _stats),
    ])),
    const SizedBox(height: 12),
    AxonLogConsole(lines: _logs, onClear: () => setState(() => _logs = [])),
    const SizedBox(height: 14),
    AxonActionRow(primaryLabel: '导出当前 JSON（预览）', onPrimary: () {
      showAxonSheet<void>(context, title: '当前配置 JSON',
        child: SelectableText(const JsonEncoder.withIndent('  ').convert(_values)));
    }, secondaryLabel: '重置', onSecondary: () => setState(() {
      _values.clear(); _region = const AxonTouchRegion(.32, .28, .24, .3);
      _logs = ['[INFO] 已清空内存里的实验室状态'];
      widget.store.setValue('coverage_document_v3', '{}');
    })),
  ]);
}
