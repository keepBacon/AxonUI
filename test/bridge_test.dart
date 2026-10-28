import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:axon_flclash_flutter/axon_flclash_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MethodChannel load / set serializes Axon UI settings', () async {
    final received = <String, Object?>{};
    final messenger = TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(AxonMethodChannelStore.channel,
        (MethodCall call) async {
      if (call.method == 'load') {
        return <String, Object?>{'enabled': true, 'sensitivity': 65.0};
      }
      if (call.method == 'set') {
        received.addAll(Map<String, Object?>.from(call.arguments as Map));
        return null;
      }
      throw MissingPluginException();
    });

    const store = AxonMethodChannelStore();
    final state = await store.load();
    expect(state['enabled'], true);
    await store.setValue('sensitivity', 74.0);
    expect(received, {'key': 'sensitivity', 'value': 74.0});
    messenger.setMockMethodCallHandler(AxonMethodChannelStore.channel, null);
  });
}
