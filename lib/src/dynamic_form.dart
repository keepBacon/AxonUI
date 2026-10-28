import 'package:flutter/material.dart';
import 'bridge.dart';
import 'common.dart';
import 'controls.dart';

/// Builds a settings screen from Axon's JSON control descriptors.
///
/// This component does not execute native actions or interpret arbitrary
/// schema fields; supported types are explicitly enumerated.
class AxonDynamicForm extends StatelessWidget {
  const AxonDynamicForm({super.key, required this.controls, required this.values,
    required this.onChanged});

  final List<AxonControlSpec> controls;
  final Map<String, dynamic> values;
  final void Function(String id, Object? newValue) onChanged;

  @override
  Widget build(BuildContext context) {
    return AxonCard(child: Column(children: [
      for (final spec in controls) ...[
        if (spec.type == 'toggle')
          AxonSwitchTile(title: spec.label, subtitle: spec.description,
            value: values[spec.id] == true,
            onChanged: (v) => onChanged(spec.id, v))
        else if (spec.type == 'slider')
          Padding(padding: const EdgeInsets.symmetric(vertical: 10),
            child: AxonSliderTile(title: spec.label, subtitle: spec.description,
              value: (values[spec.id] as num?)?.toDouble() ?? spec.min,
              min: spec.min, max: spec.max,
              onChanged: (v) => onChanged(spec.id, v)))
        else if (spec.type == 'choice' && spec.options.isNotEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(spec.label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              AxonSegmentedControl(labels: spec.options,
                selected: spec.options.indexOf(values[spec.id]?.toString() ?? spec.options.first),
                onChanged: (i) => onChanged(spec.id, spec.options[i])),
            ]))
        else if (spec.type == 'text')
          Padding(padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
              key: ValueKey('axon-field-${spec.id}'),
              initialValue: values[spec.id]?.toString() ?? '',
              decoration: InputDecoration(labelText: spec.label,
                helperText: spec.description),
              onChanged: (v) => onChanged(spec.id, v),
            ))
        else
          Padding(padding: const EdgeInsets.all(8),
            child: Text('不支持的控件类型：${spec.type}',
              style: TextStyle(color: Theme.of(context).colorScheme.error))),
        if (spec != controls.last) const Divider(height: 2),
      ],
    ]));
  }
}
