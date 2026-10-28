import 'package:flutter/material.dart';
import 'theme.dart';

class AxonCard extends StatelessWidget {
  const AxonCard({super.key, required this.child, this.padding = const EdgeInsets.all(16),
    this.onTap, this.selected = false, this.radius = AxonPalette.corner});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool selected;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: selected ? cs.primary.withValues(alpha: .72) : cs.outlineVariant.withValues(alpha: .38),
          width: selected ? 1.5 : .7),
    );
    return AnimatedContainer(
      duration: axonDuration(context),
      decoration: ShapeDecoration(
        color: selected ? cs.primaryContainer.withValues(alpha: .52) : axonCardColor(context),
        shape: shape,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class AxonSectionHeader extends StatelessWidget {
  const AxonSectionHeader(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 9),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
          ],
        ])),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class AxonSettingTile extends StatelessWidget {
  const AxonSettingTile({super.key, required this.title, this.subtitle, this.leading,
    this.trailing, this.onTap, this.isDestructive = false, this.dense = false});
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      dense: dense,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      minVerticalPadding: 8,
      minLeadingWidth: 26,
      leading: leading,
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600,
        color: isDestructive ? cs.error : cs.onSurface)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
      trailing: trailing ?? (onTap == null ? null : Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant)),
    );
  }
}

class AxonMetricCard extends StatelessWidget {
  const AxonMetricCard({super.key, required this.label, required this.value,
    this.detail, this.icon = Icons.insights_rounded});
  final String label;
  final String value;
  final String? detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AxonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 19, color: cs.primary), const Spacer(),
          Icon(Icons.more_horiz_rounded, size: 19, color: cs.onSurfaceVariant)]),
        const SizedBox(height: 17),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        if (detail != null) ...[const SizedBox(height: 6), Text(detail!, style: TextStyle(color: cs.primary, fontSize: 11))],
      ],
    ));
  }
}

class AxonProgressCard extends StatelessWidget {
  const AxonProgressCard({super.key, required this.label, required this.value,
    this.detail, this.icon = Icons.data_usage_rounded});
  final String label;
  final double value;
  final String? detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = value.clamp(0.0, 1.0).toDouble();
    return AxonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: cs.primary, size: 20), const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        Text('${(progress * 100).round()}%', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 13),
      ClipRRect(borderRadius: BorderRadius.circular(5), child: TweenAnimationBuilder<double>(
        duration: axonDuration(context, 350), tween: Tween<double>(end: progress),
        builder: (context, v, _) => LinearProgressIndicator(value: v, minHeight: 7),
      )),
      if (detail != null) ...[const SizedBox(height: 8), Text(detail!, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12))],
    ]));
  }
}

class AxonExpandableCard extends StatefulWidget {
  const AxonExpandableCard({super.key, required this.title, required this.child,
    this.subtitle, this.initiallyExpanded = false});
  final String title;
  final String? subtitle;
  final Widget child;
  final bool initiallyExpanded;
  @override
  State<AxonExpandableCard> createState() => _AxonExpandableCardState();
}

class _AxonExpandableCardState extends State<AxonExpandableCard> {
  late bool _expanded = widget.initiallyExpanded;
  @override
  Widget build(BuildContext context) {
    return AxonCard(padding: EdgeInsets.zero, child: Column(children: [
      AxonSettingTile(title: widget.title, subtitle: widget.subtitle,
        leading: const Icon(Icons.tune_rounded),
        trailing: AnimatedRotation(turns: _expanded ? .5 : 0,
          duration: axonDuration(context), child: const Icon(Icons.expand_more_rounded)),
        onTap: () => setState(() => _expanded = !_expanded)),
      AnimatedSize(duration: axonDuration(context), curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: _expanded ? Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: widget.child)
          : const SizedBox(width: double.infinity)),
    ]));
  }
}

class AxonTag extends StatelessWidget {
  const AxonTag(this.label, {super.key, this.icon, this.selected = false});
  final String label;
  final IconData? icon;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: selected ? cs.primaryContainer : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: cs.onSurfaceVariant), const SizedBox(width: 4)],
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant)),
      ]),
    );
  }
}
