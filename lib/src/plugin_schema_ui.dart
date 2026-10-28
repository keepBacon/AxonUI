import 'package:flutter/material.dart';
import 'advanced_controls.dart';
import 'axon_schema.dart';
import 'common.dart';
import 'controls.dart';

/// Renders Axon's 2 feature types and all 9 debug item types.
/// Keys are namespaced as featureId.debugId to prevent collisions.
class AxonPluginSchemaUi extends StatelessWidget {
  const AxonPluginSchemaUi({super.key, required this.document, required this.values,
    required this.onChanged, this.onAction});
  final AxonPluginDocument document;
  final Map<String, Object?> values;
  final void Function(String key, Object? value) onChanged;
  final ValueChanged<String>? onAction;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [for (final f in document.features) Padding(
      padding: const EdgeInsets.only(bottom: 12), child: _feature(context, f))]);

  Widget _feature(BuildContext context, AxonPluginFeature feature) {
    if (feature.type == 'button') {
      return AxonCard(child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(feature.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (feature.description.isNotEmpty) Text(feature.description,
            style: Theme.of(context).textTheme.bodySmall),
        ])),
        FilledButton.tonal(onPressed: onAction == null ? null : () => onAction!(feature.id),
          child: Text(feature.buttonText)),
      ]));
    }
    final isEnabled = values[feature.id] is bool
        ? values[feature.id] == true : feature.defaultEnabled;
    return AxonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AxonSwitchTile(title: feature.name,
        subtitle: feature.description.isEmpty ? null : feature.description,
        value: isEnabled, onChanged: (v) => onChanged(feature.id, v)),
      if (feature.debug.isNotEmpty)
        AxonExpandableCard(title: '参数 · ${feature.debug.length} 项', initiallyExpanded: true,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final field in feature.debug) Padding(
              padding: const EdgeInsets.only(bottom: 16), child: AxonPluginFieldEditor(
                field: field, value: values['${feature.id}.${field.id}'] ?? field.newDefault(),
                onChanged: (v) => onChanged('${feature.id}.${field.id}', v))),
          ])),
    ]));
  }
}

class AxonPluginFieldEditor extends StatelessWidget {
  const AxonPluginFieldEditor({super.key, required this.field,
    required this.value, required this.onChanged});
  final AxonPluginField field;
  final Object? value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Public nullable fields are not type-promoted by Dart; use local variables.
    final currentValue = value;
    final defaultValue = field.defaultValue;
    switch (field.type) {
      case 'toggle':
        return AxonSwitchTile(title: field.name, value: value == true,
          onChanged: (v) => onChanged(v));
      case 'slider':
        return AxonPrecisionSlider(label: field.name,
          value: currentValue is num ? currentValue.toDouble() :
            defaultValue is num ? defaultValue.toDouble() : field.min,
          min: field.min, max: field.max, step: field.step, unit: field.suffix,
          onChanged: onChanged);
      case 'number':
        return AxonPrecisionSlider(label: field.name,
          value: currentValue is num ? currentValue.toDouble() :
            defaultValue is num ? defaultValue.toDouble() : field.min,
          min: field.min, max: field.max, step: field.step, unit: field.suffix,
          onChanged: onChanged);
      case 'select':
        final selected = value?.toString() ?? field.options.first;
        return AxonDropdown<String>(label: field.name,
          value: field.options.contains(selected) ? selected : field.options.first,
          entries: {for (final choice in field.options) choice: choice},
          onChanged: (v) {if (v != null) onChanged(v);});
      case 'text':
        return TextFormField(key: ValueKey('text-${field.id}'),
          initialValue: value?.toString() ?? '', maxLength: 8192,
          maxLines: null, minLines: 1,
          decoration: InputDecoration(labelText: field.name, counterText: ''),
          onChanged: onChanged);
      case 'key':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(field.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          AxonKeyCodeInput(value: currentValue is num ? currentValue.toInt() : -1,
            onChanged: (v) => onChanged(v)),
        ]);
      case 'binding':
        final raw = currentValue is Map ? Map<String, dynamic>.from(currentValue) :
          normalizeAxonBinding(field.defaultValue);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(field.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 9),
          AxonBindingEditor(value: raw, onChanged: onChanged),
        ]);
      case 'color':
        final colors = currentValue is List ? currentValue.map((e) => e.toString()).toList() :
          (field.newDefault() as List).cast<String>();
        return AxonArgbEditor(label: field.name, colors: colors, onChanged: (v) => onChanged(v));
      case 'list':
        final rows = currentValue is List
            ? currentValue.whereType<Map>().map((r) => Map<String, dynamic>.from(r)).toList()
            : <Map<String, dynamic>>[];
        return AxonPluginListEditor(field: field, rows: rows, onChanged: (v) => onChanged(v));
      default:
        return Text('未知类型 ${field.type}');
    }
  }
}

/// Recursive editor with bounded depth, item count, stable row identities,
/// add/remove, nested fields and drag reordering.
class AxonPluginListEditor extends StatefulWidget {
  const AxonPluginListEditor({super.key, required this.field,
    required this.rows, required this.onChanged});
  final AxonPluginField field;
  final List<Map<String, dynamic>> rows;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;
  @override
  State<AxonPluginListEditor> createState() => _AxonPluginListEditorState();
}

class _AxonPluginListEditorState extends State<AxonPluginListEditor> {
  final List<int> _rowIds = [];
  int _counter = 0;
  @override
  void initState() {super.initState(); _ensureIds();}
  void _ensureIds() {
    while (_rowIds.length < widget.rows.length) { _rowIds.add(++_counter); }
    if (_rowIds.length > widget.rows.length) _rowIds.removeRange(widget.rows.length, _rowIds.length);
  }
  @override
  void didUpdateWidget(covariant AxonPluginListEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureIds();
  }
  @override
  Widget build(BuildContext context) {
    final min = widget.field.minItems;
    final max = widget.field.maxItems;
    final rows = widget.rows;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text('${widget.field.name} · ${rows.length}/$max',
          style: const TextStyle(fontWeight: FontWeight.w600))),
        IconButton.filledTonal(tooltip: widget.field.addText,
          onPressed: rows.length >= max ? null : () {
            _rowIds.add(++_counter);
            widget.onChanged([...rows, widget.field.newRow()]);
          }, icon: const Icon(Icons.add_rounded)),
      ]),
      if (rows.isEmpty) Padding(padding: const EdgeInsets.all(10),
        child: Text('暂无条目', style: Theme.of(context).textTheme.bodySmall)),
      ReorderableListView.builder(
        buildDefaultDragHandles: false, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows.length,
        onReorderItem: (from, to) {
          final next = [...rows];
          final ids = _rowIds;
          final item = next.removeAt(from); next.insert(to, item);
          final id = ids.removeAt(from); ids.insert(to, id);
          widget.onChanged(next);
        },
        itemBuilder: (context, index) {
          final row = rows[index];
          return Padding(key: ValueKey('row-${_rowIds[index]}'),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: AxonExpandableCard(title: '条目 ${index + 1}', initiallyExpanded: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(tooltip: '移除条目 ${index + 1}',
                    onPressed: rows.length <= min ? null : () {
                      final next = [...rows]..removeAt(index);
                      _rowIds.removeAt(index);
                      widget.onChanged(next);
                    }, icon: const Icon(Icons.delete_outline_rounded)),
                  ReorderableDragStartListener(index: index,
                    child: const Padding(padding: EdgeInsets.all(10),
                      child: Icon(Icons.drag_handle_rounded))),
                ]),
                for (final subfield in widget.field.fields)
                  Padding(padding: const EdgeInsets.only(bottom: 12),
                    child: AxonPluginFieldEditor(
                      key: ValueKey('${_rowIds[index]}-${subfield.id}'), field: subfield,
                      value: row[subfield.id] ?? subfield.newDefault(),
                      onChanged: (nextValue) {
                        final next = [...rows];
                        next[index] = {...row, subfield.id: nextValue};
                        widget.onChanged(next);
                      })),
              ])));
        },
      ),
    ]);
  }
}
