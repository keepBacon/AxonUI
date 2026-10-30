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
    // The first choice group is initially mounted in the visible viewport.
    expect(find.byType(FlChoiceGroup<ThemeMode>), findsOneWidget);
    // Lower sections are created lazily by ListView; scroll before checking.
    await tester.scrollUntilVisible(
      find.text('固定'), 240,
      scrollable: find.byType(Scrollable).first,
    );
    // scrollUntilVisible can stop when a lazily built child is still in
    // viewport cache extent. Bring it completely on-screen before tapping.
    await tester.ensureVisible(find.text('固定'));
    await tester.pumpAndSettle();
    expect(find.byType(FlChoiceGroup<bool>), findsWidgets);
    await tester.tap(find.text('固定'));
    await tester.pumpAndSettle();
    final row = tester.widget<FlSettingRow>(
      find.ancestor(
        of: find.text('固定'), matching: find.byType(FlSettingRow),
      ).first,
    );
    expect(row.selected, isTrue);
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
  testWidgets('Live miniature preview fits short panels and animates tabs',(tester)async{
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SizedBox(
        height: 234,
        child: FlLivePreview(
          accent: Colors.blue, floating: true,
          slide: true, glass: 2, dark: false,
        ),
      )),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('preview-tab-2')));
    await tester.pumpAndSettle();
    expect(find.text('配置'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Glass modes select real FlClash shader-backed surfaces',(tester) async {
    Widget demo(int level) => MaterialApp(
      home: Scaffold(body: LiquidGlassScope(
        enabled: level > 0,
        quality: level == 1 ? LiquidGlassQuality.standard : LiquidGlassQuality.ultra,
        child: LiquidGlassHost(
          enabled: level > 0,
          child: FlGlassScope(
            level: level,
            child: const Center(
              child: FlGlassSurface(
                pill: true,
                child: SizedBox(width: 250, height: 58, child: Text('Glass test')),
              ),
            ),
          ),
        ),
      )),
    );
    await tester.pumpWidget(demo(0));
    await tester.pumpAndSettle();
    expect(find.byType(LiquidGlass), findsNothing);
    await tester.pumpWidget(demo(1));
    await tester.pumpAndSettle();
    expect(find.byType(LiquidGlass), findsOneWidget);
    await tester.pumpWidget(demo(2));
    await tester.pumpAndSettle();
    expect(find.byType(LiquidGlass), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Glass dock selection lens responds to taps',(tester) async {
    var chosen = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: StatefulBuilder(builder: (context, set) => Center(
        child: SizedBox(width: 340, child: FlLiquidNavigationDock(
          selectedIndex: chosen,
          destinations: const [
            FlDockDestination(Icons.home_outlined, '总览'),
            FlDockDestination(Icons.settings_outlined, '设置'),
            FlDockDestination(Icons.palette_outlined, '主题'),
          ],
          onSelected: (index) => set(() => chosen = index),
        )),
      )),
    )));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    expect(chosen, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('FlClash-style dashboard controls stay UI-only',(tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: FlOverviewScreen(openTheme: () {}),
    )));
    await tester.pumpAndSettle();
    expect(find.text('仪表盘'), findsOneWidget);
    expect(find.text('状态'), findsOneWidget);
    expect(find.byKey(const ValueKey('dashboard-power')), findsOneWidget);

    // Status is local widget state only; no network or input engine is used.
    await tester.tap(find.byKey(const ValueKey('dashboard-power')));
    await tester.pumpAndSettle();
    expect(find.text('预览正在运行'), findsOneWidget);
    expect(find.textContaining('不执行设备操作'), findsOneWidget);

    // Mode selector replaces the previous '模式展示' widget.
    final mode = find.byKey(const ValueKey('dashboard-mode-1'));
    await tester.scrollUntilVisible(
      mode, 150, scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(mode);
    await tester.pumpAndSettle();
    await tester.tap(mode);
    await tester.pumpAndSettle();
    final selectedMode = tester.widget<AnimatedContainer>(mode);
    final decoration = selectedMode.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFF0787FA));

    // New dashboard-edit control opens the expanded UI-only layout description.
    final edit = find.byKey(const ValueKey('dashboard-edit'));
    await tester.scrollUntilVisible(
      edit, -180, scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(edit);
    await tester.pumpAndSettle();
    await tester.tap(edit);
    await tester.pumpAndSettle();
    final expanded = find.textContaining('布局编辑预览');
    await tester.scrollUntilVisible(
      expanded, 170, scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(expanded);
    await tester.pumpAndSettle();
    expect(expanded, findsOneWidget);
    expect(tester.takeException(), isNull);
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
