import 'package:flutter/material.dart';

/// Original Axon UI Lab design tokens, independent of FlClash layouts.
abstract final class AxonLab {
  static const ink = Color(0xFF19233B);
  static const muted = Color(0xFF71809A);
  static const canvas = Color(0xFFF2F5FA);
  static const blue = Color(0xFF447CF6);
  static const mint = Color(0xFF47C9B0);
  static const border = Color(0xFFE7EBF2);
  static const radius = 23.0;
}

class AxonSurface extends StatelessWidget {
  const AxonSurface({super.key, required this.child, this.padding = const EdgeInsets.all(17),
    this.color, this.outline = false});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool outline;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color ?? Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AxonLab.radius),
      border: Border.all(color: outline ? AxonLab.blue.withValues(alpha:.33)
        : Theme.of(context).dividerColor.withValues(alpha:.55)),
    ),
    child: Padding(padding: padding, child: child),
  );
}

class AxonSectionHeading extends StatelessWidget {
  const AxonSectionHeading({super.key, required this.title, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
      if (subtitle != null) ...[
        const SizedBox(height: 3),
        Text(subtitle!, style: TextStyle(fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    ])),
    if (trailing != null) trailing!,
  ]);
}

class AxonTag extends StatelessWidget {
  const AxonTag({super.key, required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: active ? AxonLab.blue.withValues(alpha: .10)
        : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10)),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
        color: active ? AxonLab.blue : Theme.of(context).colorScheme.onSurfaceVariant))),
  );
}

class AxonSegmented<T> extends StatelessWidget {
  const AxonSegmented({super.key, required this.options, required this.value,
    required this.label, required this.onChanged});
  final List<T> options;
  final T value;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15)),
      child: Padding(padding: const EdgeInsets.all(4), child: Row(children: [
        for (final option in options)
          Expanded(child: InkWell(
            key: ValueKey('segment-${label(option)}'),
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChanged(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 190),
              curve: Curves.easeOutCubic,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 3),
              decoration: BoxDecoration(
                color: value == option ? cs.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: value == option ? [BoxShadow(
                  color: Colors.black.withValues(alpha:.065),
                  blurRadius: 7, offset: const Offset(0, 2))] : null),
              child: Text(label(option), textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: value == option
                  ? FontWeight.w700 : FontWeight.w500,
                  color: value == option ? cs.primary : cs.onSurfaceVariant)),
            ),
          )),
      ])),
    );
  }
}

class AxonSetting extends StatelessWidget {
  const AxonSetting({super.key, required this.title, this.subtitle,
    required this.icon, this.trailing, this.onTap});
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          SizedBox(width: 38, height: 38, child: DecoratedBox(
            decoration: BoxDecoration(color: cs.primary.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, size: 19, color: cs.primary))),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14,
                fontWeight: FontWeight.w600)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: TextStyle(fontSize: 11,
                  color: cs.onSurfaceVariant)),
              ]
            ])),
          if (trailing != null) trailing!,
        ])),
    );
  }
}

class AxonValueSlider extends StatelessWidget {
  const AxonValueSlider({super.key, required this.label, required this.value,
    required this.onChanged, this.min = 0, this.max = 100, this.suffix = '%'});
  final String label;
  final double value, min, max;
  final String suffix;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Expanded(child: Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600))),
        AxonTag(label: '${value.round()}$suffix', active: true),
      ]),
      Slider(key: ValueKey('slider-$label'), value: value.clamp(min,max).toDouble(),
        min: min, max: max, onChanged: onChanged),
    ],
  );
}

class AxonStepper extends StatelessWidget {
  const AxonStepper({super.key, required this.value, required this.onChanged,
    this.min = 0, this.max = 100});
  final int value, min, max;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    IconButton.filledTonal(
      key: const ValueKey('step-minus'),
      iconSize: 18, icon: const Icon(Icons.remove_rounded),
      onPressed: value > min ? () => onChanged(value - 1) : null),
    SizedBox(width: 32, child: Text('$value', textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.w700))),
    IconButton.filledTonal(
      key: const ValueKey('step-plus'),
      iconSize: 18, icon: const Icon(Icons.add_rounded),
      onPressed: value < max ? () => onChanged(value + 1) : null),
  ]);
}

class AxonKeycap extends StatelessWidget {
  const AxonKeycap({super.key, required this.label, this.selected = false,
    this.onTap});
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AxonLab.blue.withValues(alpha:.16)
      : Theme.of(context).colorScheme.surfaceContainerHigh,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      key: ValueKey('keycap-$label'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(alignment: Alignment.center,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 43),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: selected ? AxonLab.blue : Theme.of(context).colorScheme.onSurface))),
    ),
  );
}
