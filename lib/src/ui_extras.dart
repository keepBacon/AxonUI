import 'package:flutter/material.dart';
import 'common.dart';
import 'theme.dart';

/// Additional **UI-only** building blocks for the Axon settings surface.
/// No gamepad polling, hardware key injection, overlay rendering or permissions.

class AxonCheckboxTile extends StatelessWidget {
  const AxonCheckboxTile({super.key, required this.title, required this.value,
    required this.onChanged, this.subtitle, this.icon});
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => AxonSettingTile(
    title: title, subtitle: subtitle,
    leading: icon == null ? null : Icon(icon),
    trailing: Checkbox(value: value, onChanged: onChanged == null
      ? null : (v) => onChanged!(v ?? false)),
    onTap: onChanged == null ? null : () => onChanged!(!value),
  );
}

class AxonRadioChoiceGroup<T> extends StatelessWidget {
  const AxonRadioChoiceGroup({super.key, required this.options,
    required this.selected, required this.onChanged, this.title});
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final String? title;

  @override
  Widget build(BuildContext context) => AxonCard(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title != null) ...[
        Text(title!, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
      ],
      for (final entry in options.entries) AxonSettingTile(
        title: entry.value,
        leading: Icon(entry.key == selected
          ? Icons.radio_button_checked_rounded
          : Icons.radio_button_unchecked_rounded,
          color: entry.key == selected
            ? Theme.of(context).colorScheme.primary : null),
        onTap: () => onChanged(entry.key),
      ),
    ],
  ));
}

class AxonStepperField extends StatelessWidget {
  const AxonStepperField({super.key, required this.label, required this.value,
    required this.onChanged, this.min = 0, this.max = 100, this.step = 1,
    this.unit = ''});
  final String label, unit;
  final int value, min, max, step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => AxonCard(child: Row(children: [
    Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
    IconButton.filledTonal(onPressed: value <= min ? null : () => onChanged(
      (value - step).clamp(min, max).toInt()),
      tooltip: '减少$label', icon: const Icon(Icons.remove_rounded)),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Text('$value$unit', style: const TextStyle(fontWeight: FontWeight.w700))),
    IconButton.filledTonal(onPressed: value >= max ? null : () => onChanged(
      (value + step).clamp(min, max).toInt()),
      tooltip: '增加$label', icon: const Icon(Icons.add_rounded)),
  ]));
}

class AxonOptionGrid<T> extends StatelessWidget {
  const AxonOptionGrid({super.key, required this.entries, required this.selected,
    required this.onChanged, this.icons = const <Never, IconData>{}, this.columns = 2});
  final Map<T, String> entries;
  final T selected;
  final ValueChanged<T> onChanged;
  final Map<T, IconData> icons;
  final int columns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    const gap = 9.0;
    final count = columns.clamp(1, 4).toInt();
    final cell = (constraints.maxWidth - gap * (count - 1)) / count;
    return Wrap(spacing: gap, runSpacing: gap, children: [
      for (final entry in entries.entries) SizedBox(width: cell, child: AxonCard(
        selected: selected == entry.key, onTap: () => onChanged(entry.key),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Row(children: [
          if (icons[entry.key] != null) ...[
            Icon(icons[entry.key], size: 19), const SizedBox(width: 8),
          ],
          Expanded(child: Text(entry.value, maxLines: 2, overflow: TextOverflow.ellipsis)),
          if (selected == entry.key) const Icon(Icons.check_circle_rounded, size: 18),
        ]),
      )),
    ]);
  });
}

class AxonSearchPicker<T> extends StatelessWidget {
  const AxonSearchPicker({super.key, required this.title, required this.options,
    required this.selected, required this.onChanged});
  final String title;
  final Map<T, String> options;
  final T? selected;
  final ValueChanged<T> onChanged;

  Future<void> _show(BuildContext context) async {
    final query = TextEditingController();
    try {
      await showModalBottomSheet<void>(context: context, isScrollControlled: true,
        showDragHandle: true, useSafeArea: true, builder: (sheetContext) => StatefulBuilder(
          builder: (sheetContext, repaint) {
            final filtered = options.entries.where((e) => e.value
              .toLowerCase().contains(query.text.trim().toLowerCase())).toList();
            return Padding(padding: EdgeInsets.fromLTRB(16, 0, 16,
              MediaQuery.viewInsetsOf(sheetContext).bottom + 14),
              child: SizedBox(height: 390, child: Column(children: [
                Align(alignment: Alignment.centerLeft, child: Text(title,
                  style: Theme.of(sheetContext).textTheme.titleLarge)),
                const SizedBox(height: 10),
                TextField(controller: query, autofocus: false,
                  onChanged: (_) => repaint(() {}),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded),
                    hintText: '搜索选项')),
                const SizedBox(height: 8),
                Expanded(child: filtered.isEmpty ? const AxonEmptyState(
                  title: '没有匹配选项', icon: Icons.search_off_rounded)
                  : ListView.builder(itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      return AxonSettingTile(title: entry.value,
                        trailing: entry.key == selected
                          ? const Icon(Icons.check_circle_rounded) : null,
                        onTap: () {
                          onChanged(entry.key);
                          Navigator.of(sheetContext).pop();
                        });
                    })),
              ])));
          }));
    } finally {
      query.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => AxonSettingTile(title: title,
    subtitle: selected == null ? '请选择' : options[selected] ?? '请选择',
    trailing: const Icon(Icons.unfold_more_rounded), onTap: () => _show(context));
}

class AxonMultiSelectChips<T> extends StatelessWidget {
  const AxonMultiSelectChips({super.key, required this.options,
    required this.selected, required this.onChanged});
  final Map<T, String> options;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 4,
    children: [for (final entry in options.entries) FilterChip(
      label: Text(entry.value), selected: selected.contains(entry.key),
      onSelected: (active) {
        final result = Set<T>.of(selected);
        if (active) { result.add(entry.key); } else { result.remove(entry.key); }
        onChanged(result);
      })]);
}

enum AxonBannerTone { info, success, caution, error }

class AxonInfoBanner extends StatelessWidget {
  const AxonInfoBanner({super.key, required this.title, required this.message,
    this.tone = AxonBannerTone.info, this.actionText, this.onAction});
  final String title, message;
  final AxonBannerTone tone;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (color, icon) = switch (tone) {
      AxonBannerTone.success => (cs.tertiary, Icons.check_circle_outline_rounded),
      AxonBannerTone.caution => (cs.secondary, Icons.warning_amber_rounded),
      AxonBannerTone.error => (cs.error, Icons.error_outline_rounded),
      AxonBannerTone.info => (cs.primary, Icons.info_outline_rounded),
    };
    return Semantics(container: true, child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .25))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color), const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 3), Text(message,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 5),
            TextButton(onPressed: onAction, child: Text(actionText!)),
          ],
        ])),
      ]),
    ));
  }
}

class AxonEmptyState extends StatelessWidget {
  const AxonEmptyState({super.key, required this.title, this.subtitle,
    this.icon = Icons.inbox_outlined, this.actionLabel, this.onAction});
  final String title;
  final String? subtitle, actionLabel;
  final IconData icon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 43, color: cs.primary.withValues(alpha: .72)),
        const SizedBox(height: 10),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 5),
          Text(subtitle!, textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ]));
  }
}

class AxonAnimatedTabStrip extends StatelessWidget {
  const AxonAnimatedTabStrip({super.key, required this.tabs,
    required this.selected, required this.onChanged});
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal, child: Row(children: [
      for (var i = 0; i < tabs.length; i++) Padding(
        padding: const EdgeInsets.only(right: 7),
        child: InkWell(borderRadius: BorderRadius.circular(15),
          onTap: () => onChanged(i),
          child: AnimatedContainer(duration: axonDuration(context, 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: i == selected ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(15)),
            child: Text(tabs[i], style: TextStyle(fontWeight: i == selected
              ? FontWeight.w700 : FontWeight.w500))),
        )),
    ]));
}

class AxonLoadingAction extends StatefulWidget {
  const AxonLoadingAction({super.key, required this.label, required this.onPressed,
    this.icon = Icons.check_rounded});
  final String label;
  final IconData icon;
  final Future<void> Function()? onPressed;
  @override
  State<AxonLoadingAction> createState() => _AxonLoadingActionState();
}

class _AxonLoadingActionState extends State<AxonLoadingAction> {
  bool _loading = false;
  Future<void> _trigger() async {
    if (_loading || widget.onPressed == null) return;
    setState(() => _loading = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: _loading || widget.onPressed == null ? null : _trigger,
    icon: _loading ? const SizedBox.square(dimension: 16,
      child: CircularProgressIndicator(strokeWidth: 2)) : Icon(widget.icon),
    label: Text(_loading ? '处理中…' : widget.label));
}

class AxonLabeledValue extends StatelessWidget {
  const AxonLabeledValue({super.key, required this.label, required this.value,
    this.copyable = false});
  final String label, value;
  final bool copyable;
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(label, style: TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant))),
    Flexible(child: SelectableText(value, textAlign: TextAlign.right,
      style: const TextStyle(fontWeight: FontWeight.w600))),
    if (copyable) const Padding(padding: EdgeInsets.only(left: 6),
      child: Icon(Icons.content_copy_outlined, size: 14)),
  ]);
}
