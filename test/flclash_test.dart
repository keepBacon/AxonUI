import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:axon_flclash_flutter/flclash_ui.dart';

void main(){
  testWidgets('FlClash theme is the default screen with real selection groups',(tester)async{
    await tester.pumpWidget(FlClashAxonApp(store:FlMemoryStore()));
    await tester.pumpAndSettle();
    expect(find.text('主题'),findsWidgets);
    expect(find.text('外观模式'),findsOneWidget);
    expect(find.text('浅色'),findsOneWidget);
    expect(find.byType(FlChoiceGroup<bool>),findsWidgets);
  });
  testWidgets('Navigation exposes freshly rebuilt FlClash controls',(tester)async{
    await tester.pumpWidget(FlClashAxonApp(store:FlMemoryStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-back')));
    await tester.pumpAndSettle();
    expect(find.text('概览'),findsWidgets);
    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    expect(find.text('控件'),findsWidgets);
    expect(find.byType(FlToggleRow),findsWidgets);
  });
  testWidgets('Segmented choice updates locally',(tester)async{
    var chosen='滑动';
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:StatefulBuilder(
      builder:(context,set)=>FlSegmented<String>(values:const ['滑动','淡入'],
        label:(s)=>s,value:chosen,onChanged:(v)=>set(()=>chosen=v))))));
    await tester.tap(find.text('淡入'));
    await tester.pumpAndSettle();
    expect(chosen,'淡入');
  });
  testWidgets('Declarative schema is strictly UI only',(tester)async{
    await tester.pumpWidget(const MaterialApp(home:Scaffold(body:SingleChildScrollView(
      child:FlSchemaPanel(features:[{'id':'a','name':'界面','type':'toggle',
        'debug':[{'id':'show','name':'显示','type':'toggle','default':true}]}])))));
    await tester.pumpAndSettle();
    expect(find.text('界面'),findsOneWidget);
    expect(find.text('显示'),findsOneWidget);
  });
}
