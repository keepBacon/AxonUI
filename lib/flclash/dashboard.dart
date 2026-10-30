// AxonUI presentation-only dashboard adapted from the mobile layout hierarchy
// of the user's FlClash-main.zip (dashboard/layout.dart, style.dart, widgets/card.dart).
// No proxy engine, network telemetry or input behavior is implemented.
import 'package:flutter/material.dart';

const _demoBlue = Color(0xFF0787FA);

class FlOverviewScreen extends StatefulWidget {
  const FlOverviewScreen({super.key, required this.openTheme});
  final VoidCallback openTheme;
  @override
  State<FlOverviewScreen> createState() => _FlOverviewScreenState();
}

class _FlOverviewScreenState extends State<FlOverviewScreen> {
  bool _started = false;
  bool _vpn = true;
  bool _localProxy = true;
  int _mode = 0;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ink = colors.onSurface;
    return LayoutBuilder(builder: (context, bounds) {
      final side = ((bounds.maxWidth - 560) / 2).clamp(16.0, 48.0);
      return ListView(
        key: const PageStorageKey('fl-dashboard-scroll'),
        padding: EdgeInsets.fromLTRB(side, 12, side, 116),
        children: [
          Row(children: [
            Expanded(child: Text('仪表盘', style: TextStyle(
              fontSize: 29, fontWeight: FontWeight.w700, color: ink))),
            IconButton.filledTonal(
              key: const ValueKey('dashboard-edit'),
              tooltip: '编辑布局',
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: const Icon(Icons.edit_outlined),
            ),
          ]),
          const SizedBox(height: 14),
          _FlDashCard(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FlCardTitle(icon: Icons.verified_user_outlined, label: '状态',
                trailing: _FlChip(label: _started ? '预览已启动' : '未运行')),
              const SizedBox(height: 12),
              Row(children: [
                Container(width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('Ax', style: TextStyle(color: colors.primary,
                    fontSize: 16, fontWeight: FontWeight.w700))),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_started ? '预览正在运行' : '尚未开启演示',
                      style: const TextStyle(fontSize: 17,
                        fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('纯 UI 示例 · 不执行设备操作',
                      style: TextStyle(fontSize: 12,
                        color: colors.onSurfaceVariant)),
                  ],
                )),
                const SizedBox(width: 5),
                Material(
                  shape: const CircleBorder(),
                  color: _demoBlue,
                  child: InkWell(
                    key: const ValueKey('dashboard-power'),
                    customBorder: const CircleBorder(),
                    onTap: () => setState(() => _started = !_started),
                    child: SizedBox(width: 62, height: 62, child: Icon(
                      _started ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white, size: 34)),
                  ),
                ),
              ]),
            ],
          )),
          const SizedBox(height: 10),
          _FlDashCard(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FlCardTitle(icon: Icons.speed_outlined, label: '网络速度'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _FlMetricBlock(
                  label: '上传', icon: Icons.arrow_upward_rounded,
                  value: '0', suffix: 'B/s')),
                const SizedBox(width: 9),
                Expanded(child: _FlMetricBlock(
                  label: '下载', icon: Icons.arrow_downward_rounded,
                  value: '0', suffix: 'B/s')),
              ]),
            ],
          )),
          const SizedBox(height: 10),
          _FlDashCard(child: Column(children: [
            const _FlCardTitle(icon: Icons.alt_route_rounded, label: '出站模式'),
            const SizedBox(height: 11),
            Row(children: [
              for (var i = 0; i < 3; i++)
                Expanded(child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 3),
                  child: _FlConnectedButton(
                    key: ValueKey('dashboard-mode-$i'),
                    selected: i == _mode,
                    label: const ['规则','全局','直连'][i],
                    icon: const [
                      Icons.rule_rounded, Icons.language_rounded,
                      Icons.my_location_rounded,
                    ][i],
                    onTap: () => setState(() => _mode = i),
                  ),
                )),
            ]),
          ])),
          const SizedBox(height: 10),
          _FlDashCard(padding: const EdgeInsets.fromLTRB(18, 9, 18, 9),
            child: _FlServiceToggle(
              title: 'VPN', subtitle: '仅展示开关动画', icon: Icons.shield_outlined,
              value: _vpn, onChanged: (v) => setState(() => _vpn = v))),
          const SizedBox(height: 10),
          _FlDashCard(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _FlCardTitle(icon: Icons.devices_outlined, label: '内网 IP',
              trailing: Icon(Icons.copy_all_outlined, size: 19)),
            const SizedBox(height: 12),
            Text('192.0.2.1', style: TextStyle(
              color: ink, fontSize: 27,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: .25, fontWeight: FontWeight.w700)),
            const SizedBox(height: 13),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(21)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: _FlServiceToggle(
                title: '局域网代理', subtitle: '端口 7890 · 仅 UI 示例',
                icon: Icons.wifi_rounded, value: _localProxy,
                onChanged: (v) => setState(() => _localProxy = v)),
            ),
          ])),
          const SizedBox(height: 10),
          _FlDashCard(child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _FlCardTitle(icon: Icons.health_and_safety_outlined,
                label: '服务状态', trailing: _FlChip(
                  label: '示例数据', warning: true)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _FlServiceBlock(title: 'Google',
                  symbol: 'G', label: '未检测')),
                const SizedBox(width: 8),
                Expanded(child: _FlServiceBlock(title: 'GitHub',
                  symbol: '◉', label: '未检测')),
              ]),
            ],
          )),
          const SizedBox(height: 10),
          _FlDashCard(child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _FlCardTitle(icon: Icons.description_outlined, label: '配置',
              trailing: Icon(Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant)),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(22)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(children: [
                  const CircleAvatar(radius: 19,
                    child: Icon(Icons.layers_outlined, size: 20)),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Axon UI', style: TextStyle(
                        fontWeight: FontWeight.w600)),
                      Text('配置组件预览', style: TextStyle(fontSize: 11)),
                    ],
                  )),
                  IconButton(
                    tooltip: '外观设置',
                    onPressed: widget.openTheme,
                    icon: const Icon(Icons.chevron_right_rounded)),
                ]),
              ),
            ),
          ])),
          const SizedBox(height: 12),
          if (_expanded)
            _FlDashCard(
              child: const Text('布局编辑预览：只修改卡片显示状态，不修改设备功能。')),
        ],
      );
    });
  }
}

class _FlDashCard extends StatelessWidget {
  const _FlDashCard({required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .14 : .055),
            offset: const Offset(0, 5), blurRadius: 18),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _FlCardTitle extends StatelessWidget {
  const _FlCardTitle({required this.icon, required this.label, this.trailing});
  final IconData icon;
  final String label;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return SizedBox(height: 26, child: Row(children: [
      Icon(icon, size: 19, color: c.onSurfaceVariant),
      const SizedBox(width: 8),
      Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
          color: c.onSurface))),
      if (trailing != null) trailing!,
    ]));
  }
}
class _FlChip extends StatelessWidget {
  const _FlChip({required this.label, this.warning = false});
  final String label;
  final bool warning;
  @override
  Widget build(BuildContext context) {
    final bg = warning ? const Color(0xFFFFE1C6) :
      Theme.of(context).colorScheme.surfaceContainerHighest;
    return DecoratedBox(
      decoration: BoxDecoration(color: bg,
        borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(label, style: TextStyle(
          color: warning ? const Color(0xFF81501A) :
            Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 11, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
class _FlMetricBlock extends StatelessWidget {
  const _FlMetricBlock({required this.label,required this.icon,
    required this.value,required this.suffix});
  final String label, value, suffix;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: c.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13, 13, 13, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 15, color: c.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, color: c.onSurfaceVariant)),
          ]),
          const SizedBox(height: 18),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(value, style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()])),
            const SizedBox(width: 4),
            Padding(padding: const EdgeInsets.only(bottom: 4),
              child: Text(suffix, style: TextStyle(
                fontSize: 11, color: c.onSurfaceVariant))),
          ]),
        ]),
      ),
    );
  }
}
class _FlConnectedButton extends StatelessWidget {
  const _FlConnectedButton({super.key,
    required this.selected,required this.label,required this.icon,
    required this.onTap});
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return AnimatedContainer(duration: const Duration(milliseconds: 240),
      decoration: BoxDecoration(
        color: selected ? _demoBlue : c.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24)),
      child: Material(color: Colors.transparent,
        child: InkWell(onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(height: 53,
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: selected ?
                  Colors.white : c.onSurfaceVariant),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : c.onSurface)),
              ])))),
    );
  }
}
class _FlServiceToggle extends StatelessWidget {
  const _FlServiceToggle({required this.title,required this.subtitle,
    required this.icon,required this.value, required this.onChanged});
  final String title, subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Row(children: [
      DecoratedBox(
        decoration: BoxDecoration(color: _demoBlue,
          borderRadius: BorderRadius.circular(14)),
        child: SizedBox(width: 37, height: 37,
          child: Icon(icon, size: 20, color: Colors.white))),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14)),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: c.onSurfaceVariant)),
        ])),
      Transform.scale(scale: .85,
        child: Switch(value: value, onChanged: onChanged,
          activeTrackColor: _demoBlue)),
    ]);
  }
}
class _FlServiceBlock extends StatelessWidget {
  const _FlServiceBlock({required this.title,
    required this.symbol, required this.label});
  final String title,symbol,label;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: c.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(21)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          CircleAvatar(radius: 16, backgroundColor: c.surface,
            child: Text(symbol, style: TextStyle(
              color: c.onSurfaceVariant,fontSize: 16,
              fontWeight: FontWeight.w700))),
          const SizedBox(width: 7),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w600),
                maxLines: 1,overflow: TextOverflow.ellipsis),
              Text(label, style: TextStyle(fontSize: 10,
                color: c.onSurfaceVariant)),
            ])),
        ]),
      ),
    );
  }
}
