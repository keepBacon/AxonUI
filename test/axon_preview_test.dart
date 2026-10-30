import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:axon_flclash_flutter/axon_preview/app.dart';
import 'package:axon_flclash_flutter/flclash/store.dart';
void main(){
  testWidgets('Axon UI Lab is the default preview, not a FlClash dashboard',(tester)async{
    await tester.pumpWidget(AxonPreviewApp(store:FlMemoryStore()));
    await tester.pumpAndSettle();
    expect(find.text('AXON / UI LAB'),findsOneWidget);
    expect(find.text('组件目录'),findsOneWidget);
    expect(find.text('仪表盘'),findsNothing);
    expect(tester.takeException(),isNull);
  });
  testWidgets('Axon controls change local UI state',(tester)async{
    await tester.pumpWidget(AxonPreviewApp(store:FlMemoryStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('segment-Axon 控件')));
    await tester.pumpAndSettle();
    final toggle=find.byKey(const ValueKey('axon-toggle'));
    expect(toggle,findsOneWidget);
    final before=tester.widget<Switch>(toggle).value;
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(toggle).value,!before);
    expect(tester.takeException(),isNull);
  });
  testWidgets('The Axon layout editor is an isolated drag preview',(tester)async{
    await tester.pumpWidget(AxonPreviewApp(store:FlMemoryStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('segment-布局编辑')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('draggable-key')),findsOneWidget);
    expect(find.text('仅视觉状态'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
  testWidgets('Material page toggles the real glass mode',(tester)async{
    await tester.pumpWidget(AxonPreviewApp(store:FlMemoryStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('segment-材质动效')));
    await tester.pumpAndSettle();
    expect(find.text('原生 Shader 材质实验'),findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('segment-无玻璃')));
    await tester.pumpAndSettle();
    expect(tester.takeException(),isNull);
  });
}
