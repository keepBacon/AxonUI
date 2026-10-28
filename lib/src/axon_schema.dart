import 'dart:convert';
import 'dart:math' as math;

/// Validated interpretation of Axon PluginUiSpec.java (BuildFix190).
/// This is UI state only; plugin execution remains the responsibility of Axon.
class AxonPluginDocument {
  const AxonPluginDocument(this.features);
  final List<AxonPluginFeature> features;

  factory AxonPluginDocument.fromJson(Map<String, dynamic> json) {
    final root = json['ui'] is Map ? Map<String, dynamic>.from(json['ui'] as Map) : json;
    final raw = root['features'];
    if (raw == null) return const AxonPluginDocument([]);
    final list = raw is List ? raw : [raw];
    if (list.length > 96) throw const FormatException('Too many features (max 96)');
    final used = <String>{};
    return AxonPluginDocument(list.map((entry) {
      final feature = AxonPluginFeature.fromJson(_object(entry));
      if (!used.add(feature.id)) throw FormatException('Duplicate feature: ${feature.id}');
      return feature;
    }).toList(growable: false));
  }
}

Map<String, dynamic> _object(Object? value) {
  if (value is! Map) throw const FormatException('Expected object');
  return Map<String, dynamic>.from(value);
}

String _id(Object? value) {
  final id = value?.toString() ?? '';
  if (!RegExp(r'^[A-Za-z0-9._-]{1,64}$').hasMatch(id)) {
    throw FormatException('Invalid control id: $id');
  }
  return id;
}

String _title(Object? value) {
  final title = (value ?? '').toString().trim();
  if (title.isEmpty || title.length > 120) throw FormatException('Invalid control name: $title');
  return title;
}

class AxonPluginFeature {
  const AxonPluginFeature({required this.id, required this.name, required this.type,
    required this.description, required this.defaultEnabled,
    required this.buttonText, required this.debug});
  final String id;
  final String name;
  final String type;
  final String description;
  final bool defaultEnabled;
  final String buttonText;
  final List<AxonPluginField> debug;

  factory AxonPluginFeature.fromJson(Map<String, dynamic> raw) {
    final type = (raw['type'] ?? '').toString().toLowerCase();
    if (type != 'toggle' && type != 'button') throw FormatException('Unsupported feature type $type');
    final desc = (raw['description'] ?? '').toString();
    if (desc.length > 320) throw const FormatException('Description too long');
    final debugRaw = raw['debug'];
    final entries = debugRaw == null ? <dynamic>[] : (debugRaw is List ? debugRaw : [debugRaw]);
    if (entries.length > 32 || (type == 'button' && entries.isNotEmpty)) {
      throw const FormatException('Invalid debug controls');
    }
    final used = <String>{};
    final fields = entries.map((e) {
      final field = AxonPluginField.fromJson(_object(e));
      if (!used.add(field.id)) throw FormatException('Duplicate debug id ${field.id}');
      return field;
    }).toList(growable: false);
    return AxonPluginFeature(id: _id(raw['id']), name: _title(raw['name']), type: type,
      description: desc, defaultEnabled: raw['default'] == true,
      buttonText: (raw['buttonText'] ?? '执行').toString(), debug: fields);
  }
}

/// Scalar types exactly follow PluginUiSpec.DEBUG_*.
class AxonPluginField {
  const AxonPluginField({required this.id, required this.name, required this.type,
    required this.defaultValue, this.min = 0, this.max = 100, this.step = 1,
    this.suffix = '', this.options = const [], this.minItems = 0,
    this.maxItems = 32, this.addText = '增加', this.fields = const []});
  final String id;
  final String name;
  final String type;
  final Object? defaultValue;
  final double min;
  final double max;
  final double step;
  final String suffix;
  final List<String> options;
  final int minItems;
  final int maxItems;
  final String addText;
  final List<AxonPluginField> fields;

  static const supportedTypes = {
    'slider', 'color', 'select', 'number', 'text', 'key', 'toggle', 'list', 'binding',
  };

  factory AxonPluginField.fromJson(Map<String, dynamic> json, [int depth = 0]) {
    final id = _id(json['id']);
    final name = _title(json['name']);
    final type = (json['type'] ?? '').toString().toLowerCase();
    if (!supportedTypes.contains(type)) throw FormatException('Unsupported debug type $type');
    final fallback = json['default'];
    if (type == 'list') {
      if (depth >= 2) throw const FormatException('Nested list depth exceeds two');
      final rows = json['fields'];
      if (rows is! List || rows.isEmpty || rows.length > 8) {
        throw const FormatException('List requires 1..8 fields');
      }
      final minItems = _integer(json['minItems'], 0).clamp(0, 32).toInt();
      final maxItems = _integer(json['maxItems'], 32).clamp(1, 32).toInt();
      if (minItems > maxItems) throw const FormatException('minItems exceeds maxItems');
      final used = <String>{};
      final subFields = rows.map((row) {
        final item = AxonPluginField.fromJson(_object(row), depth + 1);
        if (!used.add(item.id)) throw FormatException('Duplicate list field ${item.id}');
        return item;
      }).toList(growable: false);
      final defaults = fallback is List
          ? fallback.whereType<Map>().take(maxItems).map((r) => Map<String, dynamic>.from(r)).toList()
          : <Map<String, dynamic>>[];
      return AxonPluginField(id: id, name: name, type: type, defaultValue: defaults,
        minItems: minItems, maxItems: maxItems,
        fields: subFields, addText: (json['addText'] ?? '增加').toString());
    }
    if (type == 'slider' || type == 'number') {
      final min = _numeric(json['min'], 0);
      final max = _numeric(json['max'], 100);
      final step = _numeric(json['step'], 1);
      if (!min.isFinite || !max.isFinite || !step.isFinite || max <= min || step <= 0 || step > max - min) {
        throw FormatException('Invalid range for $id');
      }
      final value = normalizeAxonNumber(_numeric(fallback, min), min, max, step);
      return AxonPluginField(id: id, name: name, type: type,
        min: min, max: max, step: step, suffix: (json['suffix'] ?? '').toString(), defaultValue: value);
    }
    if (type == 'select') {
      final raw = json['options'];
      final options = raw is List ? raw.map((e) => e.toString()).toList() : <String>[];
      if (options.isEmpty) throw FormatException('Select $id has no options');
      final value = fallback?.toString() ?? options.first;
      return AxonPluginField(id: id, name: name, type: type,
        options: options, defaultValue: options.contains(value) ? value : options.first);
    }
    if (type == 'toggle') {
      return AxonPluginField(id: id, name: name, type: type, defaultValue: fallback == true);
    }
    if (type == 'text') {
      final v = fallback?.toString() ?? '';
      return AxonPluginField(id: id, name: name, type: type,
        defaultValue: v.length > 8192 ? v.substring(0, 8192) : v);
    }
    if (type == 'key') {
      return AxonPluginField(id: id, name: name, type: type,
        defaultValue: _integer(fallback, -1).clamp(-1, 1000).toInt());
    }
    if (type == 'binding') {
      return AxonPluginField(id: id, name: name, type: type,
        defaultValue: normalizeAxonBinding(fallback));
    }
    final colors = fallback is List ? fallback : [if (fallback != null) fallback];
    final valid = colors.take(8).map((e) => normalizeAxonColor(e.toString())).whereType<String>().toList();
    return AxonPluginField(id: id, name: name, type: type,
      defaultValue: valid.isEmpty ? <String>['#FFFFFFFF'] : valid);
  }

  Object? newDefault() {
    if (type != 'list') return cloneAxonValue(defaultValue);
    return (defaultValue as List).map((row) =>
        {for (final field in fields) field.id: cloneAxonValue((row as Map)[field.id] ?? field.newDefault())}).toList();
  }

  Map<String, dynamic> newRow() => {for (final field in fields) field.id: field.newDefault()};
}

Object? cloneAxonValue(Object? source) {
  if (source is Map) return source.map((k, v) => MapEntry(k.toString(), cloneAxonValue(v)));
  if (source is List) return source.map(cloneAxonValue).toList();
  return source;
}

int _integer(Object? value, int fallback) => value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
double _numeric(Object? value, double fallback) => value is num ? value.toDouble() : double.tryParse('$value') ?? fallback;

double normalizeAxonNumber(double input, double min, double max, double step) {
  if (!input.isFinite) input = min;
  final rounded = min + ((input.clamp(min, max) - min) / step).round() * step;
  return ((rounded * 1000000).round() / 1000000).clamp(min, max).toDouble();
}

String? normalizeAxonColor(String raw) {
  final normalized = raw.trim().toUpperCase();
  if (RegExp(r'^#[0-9A-F]{8}$').hasMatch(normalized)) return normalized;
  if (RegExp(r'^#[0-9A-F]{6}$').hasMatch(normalized)) return '#FF${normalized.substring(1)}';
  return null;
}

Map<String, dynamic> normalizeAxonBinding(Object? raw) {
  Map<String, dynamic> value;
  try {
    if (raw is String) {
      value = _object(jsonDecode(raw));
    } else if (raw is num) {
      value = {'keyCode': raw.toInt()};
    } else {
      value = raw is Map ? Map<String, dynamic>.from(raw) : {};
    }
  } catch (_) {
    value = {};
  }
  final region = value['region'] is Map ? Map<String, dynamic>.from(value['region'] as Map) : <String, dynamic>{};
  final width = _numeric(region['width'], .2).clamp(.01, 1.0).toDouble();
  final height = _numeric(region['height'], .2).clamp(.01, 1.0).toDouble();
  return {
    'source': value['source'] == 'touch' ? 'touch' : 'external',
    'keyCode': _integer(value['keyCode'], -1).clamp(-1, 1000).toInt(),
    'region': {
      'x': _numeric(region['x'], .4).clamp(0.0, 1 - width).toDouble(),
      'y': _numeric(region['y'], .4).clamp(0.0, 1 - height).toDouble(),
      'width': width,
      'height': height,
    },
  };
}

/// Axon normalized region: proportions of the target display viewport.
class AxonTouchRegion {
  const AxonTouchRegion(this.x, this.y, this.width, this.height);
  final double x, y, width, height;
  factory AxonTouchRegion.fromJson(Map<String, dynamic> json) {
    final width = _numeric(json['width'], .2).clamp(.01, 1.0).toDouble();
    final height = _numeric(json['height'], .2).clamp(.01, 1.0).toDouble();
    return AxonTouchRegion(_numeric(json['x'], .4).clamp(0.0, 1 - width).toDouble(),
      _numeric(json['y'], .4).clamp(0.0, 1 - height).toDouble(), width, height);
  }
  Map<String, double> toJson() => {'x': x, 'y': y, 'width': width, 'height': height};
  AxonTouchRegion move(double dx, double dy) =>
    AxonTouchRegion((x + dx).clamp(0.0, 1 - width).toDouble(),
      (y + dy).clamp(0.0, 1 - height).toDouble(), width, height);
  AxonTouchRegion resize(double dw, double dh) {
    final w = (width + dw).clamp(.01, 1 - x).toDouble();
    final h = (height + dh).clamp(.01, 1 - y).toDouble();
    return AxonTouchRegion(x, y, math.max(.01, w), math.max(.01, h));
  }
}
