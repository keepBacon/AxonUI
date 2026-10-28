import 'package:flutter/services.dart';

/// Pure-Dart contract. All native features are opt-in and host-owned.
abstract class AxonUiStore {
  Future<Map<String, dynamic>> load();
  Future<void> setValue(String key, Object? value);
}

/// In-memory backing store for gallery, tests and preview without Axon.
class AxonMemoryStore implements AxonUiStore {
  AxonMemoryStore([Map<String, dynamic>? initial]) : _values = {...?initial};
  final Map<String, dynamic> _values;
  @override
  Future<Map<String, dynamic>> load() async => {..._values};
  @override
  Future<void> setValue(String key, Object? value) async { _values[key] = value; }
}

/// Optional Android MethodChannel adapter. Requires explicit registration in
/// a Flutter host Activity; without a host it throws MissingPluginException.
/// Native side must validate keys/types and map values to Axon itself.
class AxonMethodChannelStore implements AxonUiStore {
  const AxonMethodChannelStore();
  static const channel = MethodChannel('com.axon.input/flutter_ui');

  @override
  Future<Map<String, dynamic>> load() async {
    final raw = await channel.invokeMapMethod<String, dynamic>('load');
    return Map<String, dynamic>.from(raw ?? const <String, dynamic>{});
  }

  @override
  Future<void> setValue(String key, Object? value) =>
      channel.invokeMethod<void>('set', <String, Object?>{'key': key, 'value': value});
}

/// A schema for Axon's existing settings to be rendered as Flutter controls.
/// Simple JSON allows the host to add new toggles, sliders, choices and text
/// controls without hardcoding Java views. Unknown types are not rendered.
class AxonControlSpec {
  const AxonControlSpec({required this.id, required this.label, required this.type,
    this.description, this.min = 0, this.max = 100, this.options = const []});
  final String id;
  final String label;
  final String type; // 'toggle', 'slider', 'choice', 'text'
  final String? description;
  final double min;
  final double max;
  final List<String> options;

  factory AxonControlSpec.fromJson(Map<String, dynamic> json) {
    return AxonControlSpec(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      description: json['description']?.toString(),
      min: (json['min'] as num?)?.toDouble() ?? 0,
      max: (json['max'] as num?)?.toDouble() ?? 100,
      options: (json['options'] as List<dynamic>?)?.map((v) => v.toString()).toList() ?? const [],
    );
  }

  Map<String, Object?> toJson() => {'id': id, 'label': label,
    'type': type, 'description': description, 'min': min, 'max': max,
    'options': options};
}
