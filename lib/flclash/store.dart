import 'package:flutter/services.dart';

/// Storage concerns only display choices, not gamepad or input engine state.
abstract class FlUiStore {
  Future<Map<String, dynamic>> load();
  Future<void> save(String key, Object? value);
}
class FlMemoryStore implements FlUiStore {
  FlMemoryStore([Map<String, dynamic>? initial]) : _values = {...?initial};
  final Map<String, dynamic> _values;
  @override
  Future<Map<String, dynamic>> load() async => {..._values};
  @override
  Future<void> save(String key, Object? value) async => _values[key] = value;
}
class FlAndroidStore implements FlUiStore {
  const FlAndroidStore();
  static const channel = MethodChannel('com.axon.ui/preferences');
  @override
  Future<Map<String, dynamic>> load() async =>
      Map<String, dynamic>.from(await channel.invokeMapMethod<String, dynamic>('load') ?? {});
  @override
  Future<void> save(String key, Object? value) =>
      channel.invokeMethod<void>('set', {'key': key, 'value': value});
}
