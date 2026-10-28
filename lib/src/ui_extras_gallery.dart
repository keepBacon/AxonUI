import 'package:flutter/material.dart';
import 'common.dart';
import 'ui_extras.dart';

/// Pure Flutter widget showcase; changing a value only changes the gallery.
class AxonUiExtrasGallery extends StatefulWidget {
  const AxonUiExtrasGallery({super.key});
  @override
  State<AxonUiExtrasGallery> createState() => _AxonUiExtrasGalleryState();
}

class _AxonUiExtrasGalleryState extends State<AxonUiExtrasGallery> {
  bool _check = true;
  String _radio = 'balanced';
  String _grid = 'comfortable';
  String? _choice = 'balanced';
  Set<String> _multi = {'keyboard', 'touch'};
  int _step = 16;
  int _tab = 0;
  String _last = '无';

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const AxonSectionHeader('纯 UI 控件扩展', subtitle: '全部采用 Dart/Flutter；没有原生键鼠、手柄或系统输入逻辑'),
      const AxonInfoBanner(title: '范围限定', message: '以下控件只改变页面本地状态，不控制 Axon Input 的实际功能。'),
      const SizedBox(height: 12),
      AxonCard(child: Column(children: [
        AxonCheckboxTile(title: '复选设置行', subtitle: '适用于多开关场景',
          value: _check, onChanged: (v) => setState(() => _check = v)),
        const Divider(height: 14),
        AxonSearchPicker<String>(title: '可搜索的单项选择',
          selected: _choice, options: const {
            'comfortable': '舒适', 'balanced': '均衡', 'fast': '快速',
            'custom': '自定义', 'low': '低开销',
          }, onChanged: (v) => setState(() => _choice = v)),
      ])),
      const SizedBox(height: 12),
      AxonRadioChoiceGroup<String>(title: '单选列表', selected: _radio,
        options: const {'comfortable': '舒适', 'balanced': '均衡', 'fast': '快速'},
        onChanged: (v) => setState(() => _radio = v)),
      const AxonSectionHeader('网格模式选择', subtitle: '自动换行，选中状态由外部数据控制'),
      AxonOptionGrid<String>(selected: _grid, columns: 2,
        entries: const {'comfortable': '舒适', 'balanced': '均衡', 'fast': '快速', 'custom': '自定义'},
        icons: const {'comfortable': Icons.spa_outlined, 'balanced': Icons.bolt_outlined,
          'fast': Icons.speed_rounded, 'custom': Icons.tune_rounded},
        onChanged: (v) => setState(() => _grid = v)),
      const AxonSectionHeader('多选与精调', subtitle: 'Chips 多选、整数步进调节'),
      AxonCard(child: AxonMultiSelectChips<String>(
        options: const {'keyboard': '键盘 UI', 'touch': '触控 UI',
          'controller': '手柄 UI', 'stats': '状态面板'},
        selected: _multi, onChanged: (v) => setState(() => _multi = v))),
      const SizedBox(height: 12),
      AxonStepperField(label: '圆角半径', value: _step, unit: ' dp',
        min: 8, max: 40, step: 2, onChanged: (v) => setState(() => _step = v)),
      const AxonSectionHeader('导航与提示', subtitle: '滚动标签、横幅、状态展示与操作状态'),
      AxonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AxonAnimatedTabStrip(tabs: const ['总览', '常规', '高级配置', '视觉', '调试', '关于'],
          selected: _tab, onChanged: (v) => setState(() => _tab = v)),
        const SizedBox(height: 12),
        AxonLabeledValue(label: '当前页签', value: '${_tab + 1}'),
        const SizedBox(height: 9),
        AxonLabeledValue(label: '最后 UI 操作', value: _last),
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerLeft,
          child: AxonLoadingAction(label: '展示载入状态', onPressed: () async {
            // No timer or simulated input engine; just an immediate UI state.
            if (mounted) setState(() => _last = '按下了 UI 按钮');
          })),
      ])),
      const SizedBox(height: 10),
      const AxonInfoBanner(tone: AxonBannerTone.success,
        title: '已就绪', message: '控件仅负责数据显示与交互状态。'),
      const SizedBox(height: 9),
      const AxonInfoBanner(tone: AxonBannerTone.caution,
        title: '演示数据', message: '不显示真实输入设备或应用性能。'),
      const SizedBox(height: 9),
      const AxonInfoBanner(tone: AxonBannerTone.error,
        title: '错误态样式', message: '供宿主界面传入错误信息时使用。'),
      const AxonSectionHeader('空状态', subtitle: '列表无内容、搜索无结果、未配置页面'),
      const AxonCard(child: AxonEmptyState(title: '还没有 UI 配置',
        subtitle: '点击下方按钮仅切换预览提示，不会创建真实映射。')),
    ]);
}
