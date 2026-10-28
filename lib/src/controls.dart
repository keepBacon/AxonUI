import 'package:flutter/material.dart';
import 'common.dart';
import 'theme.dart';

class AxonSwitchTile extends StatelessWidget {
  const AxonSwitchTile({super.key, required this.title, this.subtitle,
    required this.value, required this.onChanged, this.icon});
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => AxonSettingTile(
    title: title, subtitle: subtitle,
    leading: icon == null ? null : Icon(icon, color: Theme.of(context).colorScheme.primary),
    onTap: onChanged == null ? null : () => onChanged!(!value),
    trailing: Switch.adaptive(value: value, onChanged: onChanged),
  );
}

class AxonSegmentedControl extends StatelessWidget {
  const AxonSegmentedControl({super.key, required this.labels, required this.selected,
    required this.onChanged, this.icons = const []});
  final List<String> labels;
  final int selected;
  final ValueChanged<int>? onChanged;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(scrollDirection: Axis.horizontal,
      child: SegmentedButton<int>(
        showSelectedIcon: false,
        style: ButtonStyle(visualDensity: VisualDensity.compact,
          side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)))),
        segments: [for (var i = 0; i < labels.length; i++) ButtonSegment<int>(
          value: i, label: Text(labels[i]), icon: i < icons.length ? Icon(icons[i], size: 16) : null)],
        selected: {if (selected >= 0 && selected < labels.length) selected},
        emptySelectionAllowed: true,
        onSelectionChanged: onChanged == null ? null : (v) {
          if (v.isNotEmpty) onChanged!(v.first);
        },
      ),
    );
  }
}

class AxonChipSelector extends StatelessWidget {
  const AxonChipSelector({super.key, required this.options, required this.selected,
    required this.onChanged, this.multiSelect = true});
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 3,
    children: options.map((text) => FilterChip(
      label: Text(text), selected: selected.contains(text),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
      onSelected: (value) {
        final next = multiSelect ? {...selected} : <String>{};
        if (value) {next.add(text);} else {next.remove(text);}
        onChanged(next);
      },
    )).toList(),
  );
}

class AxonSliderTile extends StatelessWidget {
  const AxonSliderTile({super.key, required this.title, required this.value,
    required this.min, required this.max, required this.onChanged, this.subtitle,
    this.divisions, this.suffix = '', this.decimals = 0});
  final String title;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String suffix;
  final int decimals;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final safeMax = max > min ? max : min + 1;
    final clamped = value.clamp(min, safeMax).toDouble();
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
        Text('${clamped.toStringAsFixed(decimals)}$suffix',
          style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
      ]),
      if (subtitle != null) ...[const SizedBox(height: 3), Text(subtitle!,
        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))],
      Slider(value: clamped, min: min, max: safeMax, divisions: divisions,
        label: '${clamped.toStringAsFixed(decimals)}$suffix', onChanged: onChanged),
    ]);
  }
}

class AxonNumberField extends StatelessWidget {
  const AxonNumberField({super.key, required this.label, required this.value,
    required this.onChanged, this.step = 1, this.min, this.max});
  final String label;
  final int value;
  final int step;
  final int? min;
  final int? max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    void update(int next) => onChanged(next.clamp(min ?? -2147483648, max ?? 2147483647).toInt());
    return Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
      IconButton.filledTonal(onPressed: min != null && value <= min! ? null : () => update(value - step),
        icon: const Icon(Icons.remove_rounded), tooltip: '减少'),
      SizedBox(width: 56, child: Text('$value', textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700))),
      IconButton.filledTonal(onPressed: max != null && value >= max! ? null : () => update(value + step),
        icon: const Icon(Icons.add_rounded), tooltip: '增加'),
    ]);
  }
}

class AxonDropdown<T> extends StatelessWidget {
  const AxonDropdown({super.key, required this.label, required this.value,
    required this.entries, required this.onChanged});
  final String label;
  final T value;
  final Map<T, String> entries;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    key: ValueKey<T>(value),
    initialValue: entries.containsKey(value) ? value : null,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: entries.entries.map((entry) => DropdownMenuItem<T>(
      value: entry.key, child: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
    onChanged: onChanged,
  );
}

class AxonTextInput extends StatelessWidget {
  const AxonTextInput({super.key, required this.controller, this.label,
    this.hint, this.onChanged, this.maxLines = 1, this.prefix});
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final IconData? prefix;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, maxLines: maxLines, onChanged: onChanged,
    decoration: InputDecoration(labelText: label, hintText: hint,
      prefixIcon: prefix == null ? null : Icon(prefix)),
  );
}

class AxonSearchInput extends StatelessWidget {
  const AxonSearchInput({super.key, required this.controller, this.onChanged, this.hint = '搜索控件'});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) => TextField(controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(hintText: hint,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: IconButton(tooltip: '清除', icon: const Icon(Icons.close_rounded),
        onPressed: () {controller.clear(); onChanged('');})),
  );
}

class AxonColorGrid extends StatelessWidget {
  const AxonColorGrid({super.key, required this.colors, required this.value,
    required this.onChanged});
  final List<Color> colors;
  final Color value;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 11, runSpacing: 10,
    children: colors.map((color) {
      final chosen = color.toARGB32() == value.toARGB32();
      return Semantics(button: true, selected: chosen, label: '选择颜色 ${color.toARGB32()}',
        child: InkWell(borderRadius: BorderRadius.circular(999), onTap: () => onChanged(color),
          child: AnimatedContainer(duration: axonDuration(context), width: 43, height: 43,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle,
              border: Border.all(color: chosen ? Theme.of(context).colorScheme.onSurface :
                Theme.of(context).colorScheme.outlineVariant, width: chosen ? 3 : 1)),
            child: chosen ? const Icon(Icons.check_rounded, color: Colors.white, size: 22) : null)),
      );
    }).toList());
}

class AxonActionRow extends StatelessWidget {
  const AxonActionRow({super.key, required this.primaryLabel, required this.onPrimary,
    this.secondaryLabel, this.onSecondary, this.primaryIcon = Icons.check_rounded});
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final IconData primaryIcon;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 10, runSpacing: 10, children: [
    FilledButton.icon(onPressed: onPrimary, icon: Icon(primaryIcon), label: Text(primaryLabel)),
    if (secondaryLabel != null)
      OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
  ]);
}

/// A bottom sheet consistent with the FlClash-like tonal surface hierarchy.
Future<T?> showAxonSheet<T>(BuildContext context, {required String title,
  required Widget child}) {
  return showModalBottomSheet<T>(context: context, isScrollControlled: true,
    showDragHandle: true, useSafeArea: true,
    backgroundColor: axonCardColor(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(20, 2, 20,
        MediaQuery.viewInsetsOf(sheetContext).bottom + 20),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
          const SizedBox(height: 18), child,
        ])),
    ));
}

class AxonReorderList extends StatefulWidget {
  const AxonReorderList({super.key, required this.items, required this.onReorder});
  final List<String> items;
  final void Function(int oldIndex, int newIndex) onReorder;
  @override
  State<AxonReorderList> createState() => _AxonReorderListState();
}

class _AxonReorderListState extends State<AxonReorderList> {
  @override
  Widget build(BuildContext context) => ReorderableListView.builder(
    buildDefaultDragHandles: false,
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    itemCount: widget.items.length,
    onReorder: widget.onReorder,
    itemBuilder: (context, i) => ListTile(
      key: ValueKey(widget.items[i]),
      dense: true,
      title: Text(widget.items[i]),
      leading: const Icon(Icons.layers_rounded),
      trailing: ReorderableDragStartListener(index: i, child: const SizedBox(
        width: 48, height: 44, child: Icon(Icons.drag_handle_rounded))),
    ),
  );
}
