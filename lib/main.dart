import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'axon_flclash_ui.dart';
import 'src/coverage_gallery.dart';

void main() => runApp(const AxonDemoApp());

/// Launchable gallery. To embed in Axon, supply an AxonMethodChannelStore and
/// register its MethodChannel on the native Java side (see docs).
class AxonDemoApp extends StatefulWidget {
  const AxonDemoApp({super.key, this.store});
  final AxonUiStore? store;
  @override
  State<AxonDemoApp> createState() => _AxonDemoAppState();
}

class _AxonDemoAppState extends State<AxonDemoApp> {
  late final AxonUiStore _persistentStore = widget.store ??
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? const AxonMethodChannelStore()
          : AxonMemoryStore());
  ThemeMode _mode = ThemeMode.system;
  Color _seed = AxonPalette.seed;

  @override
  void initState() {
    super.initState();
    _loadAppearance();
  }

  Future<void> _loadAppearance() async {
    try {
      final data = await _persistentStore.load();
      if (!mounted) return;
      setState(() {
        final mode = data['theme_mode']?.toString();
        if (mode != null) {
          for (final candidate in ThemeMode.values) {
            if (candidate.name == mode) _mode = candidate;
          }
        }
        final seed = data['theme_seed'];
        if (seed is int) _seed = Color(seed);
      });
    } catch (e) {
      debugPrint('Appearance storage not connected: $e');
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Axon × FlClash UI',
    theme: axonTheme(seed: _seed),
    darkTheme: axonTheme(brightness: Brightness.dark, seed: _seed),
    themeMode: _mode,
    home: AxonGalleryHome(
      store: _persistentStore,
      mode: _mode, seed: _seed,
      onThemeChanged: (v) {
        setState(() => _mode = v);
        _persistentStore.setValue('theme_mode', v.name);
      },
      onSeedChanged: (v) {
        setState(() => _seed = v);
        _persistentStore.setValue('theme_seed', v.toARGB32());
      },
    ),
  );
}

class AxonGalleryHome extends StatefulWidget {
  const AxonGalleryHome({super.key, required this.store, required this.mode,
    required this.seed, required this.onThemeChanged, required this.onSeedChanged});
  final AxonUiStore store;
  final ThemeMode mode;
  final Color seed;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Color> onSeedChanged;
  @override
  State<AxonGalleryHome> createState() => _AxonGalleryHomeState();
}

class _AxonGalleryHomeState extends State<AxonGalleryHome> {
  int _page = 0;
  bool _enabled = true;
  bool _quickToggle = false;
  bool _lowLatency = true;
  bool _gesture = false;
  double _sensitivity = 65;
  double _deadZone = 12;
  double _opacity = .88;
  double _progress = .72;
  int _pollRate = 125;
  int _segment = 1;
  int _quality = 1;
  String _mappingKey = 'F';
  String _connectionMode = '稳定';
  Map<String, dynamic> _dynamicValues = {'overlay_toggle': true, 'overlay_fps': 60.0, 'control_mode': '均衡'};
  Set<String> _selectedChips = {'触控', '手柄'};
  final List<String> _layers = ['顶部状态信息', '虚拟键盘', '触控区域', '手柄响应提示'];
  List<Offset> _curve = const [Offset(0, 0), Offset(.5, .55), Offset(1, 1)];
  final _search = TextEditingController();
  final _input = TextEditingController(text: 'Axon UI Profile');
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await widget.store.load();
      if (!mounted) return;
      setState(() {
        _enabled = data['enabled'] as bool? ?? _enabled;
        _lowLatency = data['low_latency'] as bool? ?? _lowLatency;
        _sensitivity = (data['sensitivity'] as num?)?.toDouble() ?? _sensitivity;
        _opacity = (data['opacity'] as num?)?.toDouble() ?? _opacity;
        _mappingKey = data['key_binding']?.toString() ?? _mappingKey;
      });
    } catch (e) {
      // No host channel in standalone preview; keep interactive local state.
      debugPrint('Axon store not connected: $e');
    }
  }

  void _save(String key, Object? value) {
    widget.store.setValue(key, value).catchError((Object e) {
      debugPrint('Axon settings not persisted: $e');
    });
  }

  @override
  void dispose() {_search.dispose(); _input.dispose(); super.dispose();}

  static const _destinations = [
    (Icons.dashboard_rounded, '总览'),
    (Icons.tune_rounded, '基础控件'),
    (Icons.gamepad_rounded, '输入映射'),
    (Icons.palette_rounded, '外观与布局'),
    (Icons.widgets_outlined, '覆盖实验室'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 780;
    final cs = Theme.of(context).colorScheme;
    final content = KeyedSubtree(key: ValueKey(_page), child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(wide ? 26 : 18, 20, wide ? 26 : 18, 36),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 920),
        child: switch (_page) {
          0 => _overview(),
          1 => _controls(),
          2 => _mappings(),
          3 => _appearance(),
          _ => AxonCoverageGallery(store: widget.store),
        })),
    ));
    return Scaffold(
      appBar: AppBar(titleSpacing: 20, title: Row(children: [
        Icon(Icons.grid_view_rounded, color: cs.primary, size: 23),
        const SizedBox(width: 10),
        const Expanded(child: Text('Axon / UI Studio', maxLines: 1,
          overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700))),
      ]),
        actions: [
          if (wide) const AxonTag('Flutter · Dart', icon: Icons.code_rounded, selected: true),
          IconButton(tooltip: '说明', onPressed: () => showAxonSheet<void>(context,
            title: '关于 UI 组件库', child: const Text(
              '基于 Flutter Material 3 重新实现的 Axon UI 控件。FlClash 原始界面源码在源代码包的 flclash_original_ui_reference/ 目录。此演示不控制真实键盘、鼠标或游戏。')),
            icon: const Icon(Icons.info_outline_rounded)),
          const SizedBox(width: 8),
        ]),
      body: wide ? Row(children: [
        NavigationRail(extended: MediaQuery.sizeOf(context).width >= 1050,
          backgroundColor: cs.surface,
          selectedIndex: _page,
          onDestinationSelected: (i) => setState(() => _page = i),
          destinations: [for (final d in _destinations)
            NavigationRailDestination(icon: Icon(d.$1), label: Text(d.$2))]),
        VerticalDivider(width: 1, thickness: 1, color: cs.outlineVariant),
        Expanded(child: content),
      ]) : content,
      bottomNavigationBar: wide ? null : NavigationBar(
        height: 72, selectedIndex: _page,
        onDestinationSelected: (i) => setState(() => _page = i),
        destinations: [for (final d in _destinations)
          NavigationDestination(icon: Icon(d.$1), label: d.$2)]),
    );
  }

  Widget _heading(String title, String description) =>
      AxonSectionHeader(title, subtitle: description);
  Widget _space([double height = 12]) => SizedBox(height: height);
  Widget _stack(List<Widget> widgets) => Column(crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [for (var i = 0; i < widgets.length; i++) ...[
      widgets[i], if (i < widgets.length - 1) _space(),
    ]]);

  Widget _overview() => _stack([
    AxonCard(padding: const EdgeInsets.all(22), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AxonTag('独立 UI 控件库 · v3', icon: Icons.auto_awesome_rounded, selected: true),
      _space(14),
      Text('精简、柔和、可扩展。', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800)),
      _space(8),
      Text('以 FlClash 的 Material 设计语言为参考，用 Dart/Flutter 实现 Axon 的设置控件，底层输入引擎不受影响。',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5)),
      _space(18),
      AxonActionRow(primaryLabel: '浏览基础控件', onPrimary: () => setState(() => _page = 1),
        secondaryLabel: '查看映射组件', onSecondary: () => setState(() => _page = 2)),
    ])),
    _heading('运行状态', '卡片、指标、进度显示'),
    LayoutBuilder(builder: (context, box) {
      final narrow = box.maxWidth < 480;
      Widget metric(String label, String value, IconData icon) => AxonMetricCard(
        label: label, value: value, icon: icon, detail: '演示数据');
      return narrow ? Column(children: [metric('触控映射', '12', Icons.touch_app_rounded),
        _space(), metric('交互延迟', '8 ms', Icons.speed_rounded)])
        : Row(children: [Expanded(child: metric('触控映射', '12', Icons.touch_app_rounded)),
          _spaceHorizontal(), Expanded(child: metric('交互延迟', '8 ms', Icons.speed_rounded))]);
    }),
    AxonProgressCard(label: 'UI 功能覆盖示意', value: _progress,
      detail: '仅供界面展示，不代表 Axon 代码覆盖率'),
    _heading('快捷功能', '开关、状态项与交互反馈'),
    AxonCard(child: Column(children: [
      AxonSwitchTile(title: '启用 Axon UI', subtitle: '本页面模拟状态，不启动输入引擎',
        value: _enabled, icon: Icons.power_settings_new_rounded,
        onChanged: (v) {setState(() => _enabled = v); _save('enabled', v);}),
      const Divider(height: 1),
      AxonSwitchTile(title: '低延迟模式', subtitle: '轻量、无阻塞动画过渡',
        value: _lowLatency, icon: Icons.bolt_rounded,
        onChanged: (v) {setState(() => _lowLatency = v); _save('low_latency', v);}),
      const Divider(height: 1),
      AxonSettingTile(title: '所有控件', subtitle: '查看更完整的组件目录',
        leading: const Icon(Icons.widgets_rounded),
        onTap: () => setState(() => _page = 1)),
    ])),
  ]);

  Widget _spaceHorizontal() => const SizedBox(width: 12);

  Widget _controls() => _stack([
    Text('基础控件', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
    AxonSearchInput(controller: _search, onChanged: (v) => setState(() => _query = v)),
    if (_include('开关 选择')) ...[
      _heading('开关与分段选择', 'Axon 原有基础控件 · Flutter 重写'),
      AxonCard(child: Column(children: [
        AxonSwitchTile(title: '快速启动', subtitle: '演示 Switch.adaptive',
          icon: Icons.rocket_launch_outlined, value: _quickToggle,
          onChanged: (v) => setState(() => _quickToggle = v)),
        const Divider(height: 1),
        const AxonSettingTile(title: '手柄检测', subtitle: '独立状态交互',
          leading: Icon(Icons.sports_esports_outlined),
          trailing: AxonTag('正常', icon: Icons.check_circle_outline, selected: true)),
        _space(),
        AxonSegmentedControl(labels: const ['舒适', '均衡', '真实'], selected: _segment,
          onChanged: (v) => setState(() => _segment = v)),
      ])),
    ],
    if (_include('滑块 数字')) ...[
      _heading('数值调节', '滑块 + 整数步进器'),
      AxonCard(child: Column(children: [
        AxonSliderTile(title: '指针灵敏度', value: _sensitivity, min: 0, max: 100,
          suffix: '%', divisions: 100,
          onChanged: (v) {setState(() => _sensitivity = v); _save('sensitivity', v);}),
        _space(),
        AxonNumberField(label: '轮询预设 (Hz)', value: _pollRate, step: 25,
          min: 25, max: 1000, onChanged: (v) => setState(() => _pollRate = v)),
      ])),
    ],
    if (_include('输入 下拉')) ...[
      _heading('输入与选择', '输入框、下拉列表与多个过滤项'),
      AxonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AxonTextInput(controller: _input, label: '配置名称',
          prefix: Icons.edit_note_rounded),
        _space(14),
        AxonDropdown<String>(label: '连接模式', value: _connectionMode,
          entries: const {'稳定': '稳定优先', '高速': '性能优先', '智能': '智能自适应'},
          onChanged: (v) {if (v != null) setState(() => _connectionMode = v);}),
        _space(14),
        AxonChipSelector(options: const ['触控', '手柄', '键盘', '鼠标'],
          selected: _selectedChips, onChanged: (v) => setState(() => _selectedChips = v)),
      ])),
    ],
    if (_include('动态配置 JSON')) ...[
      _heading('动态配置表单', '使用 JSON Schema 描述控件，Java 宿主可扩展'),
      AxonDynamicForm(
        controls: const [
          AxonControlSpec(id: 'overlay_toggle', label: '显示状态提示', type: 'toggle',
            description: '示范由控件描述自动生成开关'),
          AxonControlSpec(id: 'overlay_fps', label: '绘制更新率', type: 'slider',
            min: 15, max: 120),
          AxonControlSpec(id: 'control_mode', label: '控制模式', type: 'choice',
            options: ['舒适', '均衡', '精确']),
        ],
        values: _dynamicValues,
        onChanged: (id, value) => setState(() => _dynamicValues = {..._dynamicValues, id: value}),
      ),
    ],
    if (_include('按钮 弹窗')) ...[
      _heading('操作与信息', '按钮、底部弹层、提示'),
      AxonCard(child: Column(children: [
        AxonActionRow(primaryLabel: '保存配置', primaryIcon: Icons.save_rounded,
          onPrimary: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('配置操作已触发（演示）'))),
          secondaryLabel: '打开弹层', onSecondary: () => showAxonSheet<void>(context,
            title: '高级设置', child: const Text('这里可以承载 Axon 的配置菜单、说明与更多表单。'))),
        _space(),
        const AxonExpandableCard(title: '高级设置', subtitle: '点击展开带动画的内容',
          child: Text('支持嵌入更多表单元素；布局与点击区域同步过渡。')),
      ])),
    ],
  ]);

  bool _include(String terms) => _query.trim().isEmpty ||
    terms.contains(_query.trim()) || _query.trim().contains(terms.split(' ').first);

  Widget _mappings() => _stack([
    Text('输入映射', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
    _heading('绑定与触控', 'Axon 特有场景的 UI 控件'),
    AxonCard(child: Column(children: [
      AxonKeyBindField(label: '打开快捷面板', subtitle: '点击后按下实体键盘按键',
        binding: _mappingKey,
        onChanged: (v) {setState(() => _mappingKey = v); _save('key_binding', v);}),
      const Divider(height: 1),
      AxonSwitchTile(title: '手势识别', subtitle: '切换 UI 状态，不注入触控',
        value: _gesture, icon: Icons.gesture_rounded,
        onChanged: (v) => setState(() => _gesture = v)),
    ])),
    AxonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('虚拟方向键', style: TextStyle(fontWeight: FontWeight.w700)),
      _space(12),
      AxonVirtualPad(onPressed: (direction) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(duration: const Duration(milliseconds: 500), content: Text('按下方向：$direction（演示）')))),
    ])),
    _heading('触控映射列表', '可用于映射配置页的卡片结构'),
    AxonMappingCard(name: '主操作键', mode: '点击映射', binding: _mappingKey,
      onTap: () => showAxonSheet<void>(context, title: '主操作键',
        child: const Text('在这里接入原生触控映射编辑器。')),
      onDelete: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除操作（演示）')))),
    AxonMappingCard(name: '视角控制', mode: '滑动映射', binding: '右摇杆',
      onTap: () => showAxonSheet<void>(context, title: '视角控制',
        child: const Text('此组件只负责展示；底层输入仍由 Axon 原生层执行。'))),
    _heading('精细调校', '可交互的死区滑块与三点响应曲线'),
    AxonCard(child: Column(children: [
      AxonSliderTile(title: '死区范围', value: _deadZone, min: 0, max: 40,
        divisions: 40, suffix: '%',
        onChanged: (v) => setState(() => _deadZone = v)),
      _space(10),
      AxonResponseCurve(points: _curve,
        onChanged: (v) => setState(() => _curve = v)),
    ])),
  ]);

  Widget _appearance() => _stack([
    Text('外观与布局', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
    _heading('主题', '系统 / 浅色 / 深色，Material 3 动态取色风格'),
    AxonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('主题模式', style: TextStyle(fontWeight: FontWeight.w700)),
      _space(12),
      AxonColorModePicker(selected: widget.mode, onChanged: widget.onThemeChanged),
      _space(18),
      const Text('强调色', style: TextStyle(fontWeight: FontWeight.w700)),
      _space(10),
      AxonColorGrid(colors: const [Color(0xFF2276D8), Color(0xFF00A67A),
        Color(0xFF705FD5), Color(0xFFD66792), Color(0xFFEF974D), Color(0xFF454D5C)],
        value: widget.seed, onChanged: widget.onSeedChanged),
      _space(17),
      AxonSliderTile(title: '悬浮窗不透明度', value: _opacity * 100,
        min: 0, max: 100, divisions: 20, suffix: '%',
        onChanged: (v) {setState(() => _opacity = v / 100); _save('opacity', _opacity);}),
    ])),
    _heading('动画与选择卡片', '卡片状态切换采用可中断动画'),
    AxonModeCard(title: '精致动效', description: '柔和过渡，减少动画时自动停用',
      icon: Icons.animation_rounded, selected: _quality == 1,
      onTap: () => setState(() => _quality = 1)),
    AxonModeCard(title: '低开销动效', description: '简化变化，降低无谓重绘',
      icon: Icons.speed_rounded, selected: _quality == 0,
      onTap: () => setState(() => _quality = 0)),
    _heading('控件顺序', '长按拖拽手柄以调整顺序'),
    AxonCard(child: AxonReorderList(items: _layers, onReorder: (oldIndex, newIndex) {
      setState(() {
        if (newIndex > oldIndex) newIndex -= 1;
        _layers.insert(newIndex, _layers.removeAt(oldIndex));
      });
    })),
    _heading('进度预览', '用于配置完成度等场景'),
    AxonProgressCard(label: 'UI 配置完成度（模拟）', value: _progress),
    AxonSliderTile(title: '演示进度', value: _progress * 100, min: 0, max: 100,
      divisions: 100, suffix: '%', onChanged: (v) => setState(() => _progress = v / 100)),
  ]);
}
