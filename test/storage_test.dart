import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:axon_flclash_flutter/flclash_ui.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  test('UI-only MethodChannel saves display preferences',()async{
    final messenger=TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls=<String,Object?>{};
    messenger.setMockMethodCallHandler(FlAndroidStore.channel,(call)async{
      if(call.method=='load')return <String,Object?>{'theme_seed':0xFF0787FA};
      if(call.method=='set')calls.addAll(Map<String,Object?>.from(call.arguments as Map));
      return null;
    });
    const store=FlAndroidStore();
    expect((await store.load())['theme_seed'],0xFF0787FA);
    await store.save('theme_mode','light');
    expect(calls['key'],'theme_mode');
    expect(calls['value'],'light');
    messenger.setMockMethodCallHandler(FlAndroidStore.channel,null);
  });
}
