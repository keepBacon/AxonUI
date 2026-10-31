import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:axon_flclash_flutter/flclash_ui.dart';

void main(){
  testWidgets('Axon gamepad swap and compatibility UI', (tester) async {
    await tester.pumpWidget(const MaterialApp(home:Scaffold(
      body:SingleChildScrollView(child:FlAxonGamepadStudio()))));
    await tester.pumpAndSettle();
    expect(find.text('兼容模式与按键交换'),findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('axon-swap-A / B')));
    await tester.pumpAndSettle();
    expect(tester.takeException(),isNull);
  });

  testWidgets('Axon touch regions drag in normalized canvas', (tester) async {
    await tester.pumpWidget(const MaterialApp(home:Scaffold(
      body:SingleChildScrollView(child:FlAxonTouchStudio()))));
    await tester.pumpAndSettle();
    final before=tester.widget<Text>(
      find.byKey(const ValueKey('axon-region-position'))).data;
    await tester.drag(find.byKey(const ValueKey('axon-region-0')),
      const Offset(36,17));
    await tester.pumpAndSettle();
    final after=tester.widget<Text>(
      find.byKey(const ValueKey('axon-region-position'))).data;
    expect(after,isNot(before));
    expect(tester.takeException(),isNull);
  });

  testWidgets('Axon custom key text stick selector', (tester) async {
    await tester.pumpWidget(const MaterialApp(home:Scaffold(
      body:SingleChildScrollView(child:FlAxonCustomStudio()))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('文本'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('axon-custom-label')),findsOneWidget);
    expect(tester.takeException(),isNull);
  });

  testWidgets('Axon media list and chroma editor', (tester) async {
    await tester.pumpWidget(const MaterialApp(home:Scaffold(
      body:SingleChildScrollView(child:FlAxonMediaStudio()))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('axon-media-add')));
    await tester.pumpAndSettle();
    expect(find.text('素材列表 · 3'),findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('axon-media-chroma')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('axon-media-chroma')));
    await tester.pumpAndSettle();
    expect(find.text('抠像强度'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });

  testWidgets('Axon workspace state is locally editable', (tester) async {
    await tester.pumpWidget(const MaterialApp(home:Scaffold(
      body:SingleChildScrollView(child:FlAxonWorkspaceStudio()))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('axon-workspace-4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('axon-workspace-save')));
    await tester.pumpAndSettle();
    expect(find.text('槽位 5 · 已保存演示'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });

  testWidgets('Axon shortcut matrix exposes mock bindings', (tester) async {
    await tester.pumpWidget(const MaterialApp(home:Scaffold(
      body:SingleChildScrollView(child:FlAxonShortcutStudio()))));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('axon-binding-常规按显')),findsOneWidget);
    expect(find.text('UI 模拟，不会注册或触发按键'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });


  testWidgets('Showcase mixed cards keep navigation and local state',
    (tester) async {
    await tester.pumpWidget(FlClashAxonApp(store:FlMemoryStore()));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('showcase-hero')),findsOneWidget);
    expect(find.byKey(const ValueKey('showcase-category-键显')),findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('showcase-category-键显')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('entry-arrow-键鼠')),findsOneWidget);
    expect(find.byKey(const ValueKey('entry-arrow-手柄')),findsOneWidget);
    expect(find.byKey(const ValueKey('entry-arrow-自定义')),findsOneWidget);
    expect(find.byKey(const ValueKey('color-debug-preview')),findsNothing);
    expect(tester.takeException(),isNull);
  });

  testWidgets('Plugin workbench changes preview-only fields',
    (tester) async {
    await tester.pumpWidget(const MaterialApp(home:Scaffold(
      body:SingleChildScrollView(child:FlPluginWorkbench()))));
    await tester.pumpAndSettle();
    final toggle=find.byKey(const ValueKey('plugin-demo-switch'));
    expect(tester.widget<Switch>(toggle).value,isTrue);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(toggle).value,isFalse);
    final slider=find.byKey(const ValueKey('plugin-demo-slider'));
    await tester.drag(slider,const Offset(80,0));
    await tester.pumpAndSettle();
    expect(tester.takeException(),isNull);
  });

  testWidgets('Showcase hero material and interactive miniature',
    (tester) async {
    await tester.pumpWidget(const MaterialApp(home:Scaffold(
      body:SingleChildScrollView(child:FlShowcaseHero(features:42,glass:1)))));
    await tester.pumpAndSettle();
    expect(find.text('当前材质：标准玻璃'),findsOneWidget);
    final preview=find.byKey(const ValueKey('hero-live-preview'));
    expect(preview,findsOneWidget);
    await tester.tap(preview);
    await tester.pumpAndSettle();
    expect(tester.takeException(),isNull);
  });

  testWidgets('Plugin list sample reorders and binds locally',
    (tester) async {
    await tester.pumpWidget(const MaterialApp(home:Scaffold(
      body:SingleChildScrollView(child:FlPluginEditorPreview()))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('plugin-move-1')));
    await tester.pumpAndSettle();
    expect(find.text('触控层'),findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('plugin-demo-bind')));
    await tester.pumpAndSettle();
    expect(find.text('快捷键 · Ctrl + K'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });

  testWidgets('Four navigation tabs are present',(tester)async{
    await tester.pumpWidget(FlClashAxonApp(store:FlMemoryStore()));
    await tester.pumpAndSettle();
    for(final label in const ['主页','键显','插件','其他']){
      expect(find.text(label),findsWidgets);
    }
    expect(find.byType(NavigationDock),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
  testWidgets('Key display opens only three category entrances',(tester)async{
    await tester.pumpWidget(FlClashAxonApp(store:FlMemoryStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('键显').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('entry-arrow-键鼠')),findsOneWidget);
    expect(find.byKey(const ValueKey('entry-arrow-手柄')),findsOneWidget);
    expect(find.byKey(const ValueKey('entry-arrow-自定义')),findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('entry-arrow-自定义')));
    await tester.pumpAndSettle();
    // The feature catalogue uses a lazily built ListView. Sections farther
    // down do not exist until its Scrollable is scrolled into view.
    final groups = find.byType(FlFeatureGroupsScreen);
    expect(groups, findsOneWidget);
    final list = find.descendant(
      of: groups,
      matching: find.byType(Scrollable),
    );
    expect(list, findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('颜色与材质'),
      160,
      scrollable: list,
    );
    expect(find.text('颜色与材质'), findsOneWidget);
    // Preview parameters must NOT be embedded inline in the catalogue.
    expect(find.byKey(const ValueKey('color-debug-preview')), findsNothing);
    final row = find.byKey(const ValueKey('debug-arrow-颜色调试'));
    await tester.scrollUntilVisible(row, 120, scrollable: list);
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.text('颜色调试'), findsWidgets);
    expect(find.byKey(const ValueKey('color-debug-preview')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('debug-back')));
    await tester.pumpAndSettle();
    // The list retains its scroll offset. Its section heading may be
    // lazily unmounted once the target row has scrolled past the heading.
    expect(find.byType(FlFeatureGroupsScreen), findsOneWidget);
    expect(find.byType(FlFeatureDebugScreen), findsNothing);
    final restoredList = find.descendant(
      of: find.byType(FlFeatureGroupsScreen),
      matching: find.byType(Scrollable),
    );
    expect(restoredList, findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('debug-arrow-颜色调试')),
      120,
      scrollable: restoredList,
    );
    expect(find.byKey(const ValueKey('debug-arrow-颜色调试')),
      findsOneWidget);
    expect(find.byKey(const ValueKey('color-debug-preview')), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Dark nested pages keep readable backgrounds and headers',
    (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme:flTheme(brightness:Brightness.dark,seed:Colors.blue,glass:2),
      home:Builder(builder:(context)=>Scaffold(body:Center(
        child:FilledButton(
          onPressed:()=>openPreviewFeatures(
            context,'键鼠',PreviewCatalog.keyboard),
          child:const Text('打开分类'))))),
    ));
    await tester.tap(find.text('打开分类'));
    await tester.pumpAndSettle();
    expect(find.text('键鼠'),findsOneWidget);
    expect(find.byType(FlShowcasePageSurface),findsOneWidget);
    expect(tester.takeException(),isNull);
  });

  testWidgets('Showcase preview opacity is controlled locally',
    (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: Center(child: SizedBox(width: 360,
        child: FlShowcaseInteractionPreview())),
    )));
    await tester.pumpAndSettle();
    final fade=find.byKey(const ValueKey('showcase-preview-opacity'));
    final initial=tester.widget<AnimatedOpacity>(fade).opacity;
    expect(initial, closeTo(.64, .001));
    final slider=find.byKey(const ValueKey('showcase-preview-slider'));
    await tester.drag(slider, const Offset(120, 0));
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedOpacity>(fade).opacity, greaterThan(initial));
    expect(tester.takeException(),isNull);
  });

  testWidgets('Dense catalogue remains separate from debug panels',
    (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: FlKeyDisplayScreen(),
    )));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('entry-arrow-键鼠')),findsOneWidget);
    expect(find.byKey(const ValueKey('entry-arrow-手柄')),findsOneWidget);
    expect(find.byKey(const ValueKey('entry-arrow-自定义')),findsOneWidget);
    expect(find.byType(FlShowcaseInteractionPreview),findsNothing);
    expect(find.byKey(const ValueKey('color-debug-preview')),findsNothing);
    expect(tester.takeException(),isNull);
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
  testWidgets('Direct upstream FlClash dock is mounted and responsive',(tester) async {
    var selected=0;
    await tester.pumpWidget(MaterialApp(home:Scaffold(
      body:StatefulBuilder(builder:(context,set)=>Align(
        alignment:Alignment.bottomCenter,
        child:NavigationDock(
          selectedIndex:selected,
          destinations:const [
            NavigationDockDestination(glyph:Icons.home_outlined,label:'首页'),
            NavigationDockDestination(glyph:Icons.tune_outlined,label:'设置'),
            NavigationDockDestination(glyph:Icons.palette_outlined,label:'主题'),
          ],
          onSelected:(index)=>set(()=>selected=index),
        ),
      )),
    )));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDock),findsOneWidget);
    await tester.tap(find.text('设置').first);
    await tester.pumpAndSettle();
    expect(selected,1);
    expect(tester.takeException(),isNull);
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
    // The ValueKey belongs to the private _FlConnectedButton wrapper.
    // Inspect its public AnimatedContainer descendant rather than casting
    // the wrapper itself to AnimatedContainer.
    final modeSurface = find.descendant(
      of: mode,
      matching: find.byType(AnimatedContainer),
    );
    expect(modeSurface, findsOneWidget);
    final selectedMode = tester.widget<AnimatedContainer>(modeSurface);
    final decoration = selectedMode.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFF0787FA));

    // The previously selected rule button must lose the selected tint.
    final rule = find.byKey(const ValueKey('dashboard-mode-0'));
    final ruleSurface = find.descendant(
      of: rule,
      matching: find.byType(AnimatedContainer),
    );
    expect(ruleSurface, findsOneWidget);
    final ruleDecoration =
        tester.widget<AnimatedContainer>(ruleSurface).decoration! as BoxDecoration;
    expect(ruleDecoration.color, isNot(const Color(0xFF0787FA)));

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
  testWidgets('Segmented selection thumb travels and can be retargeted',(tester) async {
    var selected = '一';
    await tester.pumpWidget(MaterialApp(home: Scaffold(body:
      StatefulBuilder(builder: (context, set) => FlSegmented<String>(
        values: const ['一', '二', '三'],
        label: (v) => v,
        value: selected,
        onChanged: (v) => set(() => selected = v),
      )),
    )));
    await tester.pumpAndSettle();
    final thumb = find.byKey(const ValueKey('segmented-thumb'));
    expect(thumb, findsOneWidget);
    final start = tester.getTopLeft(thumb).dx;
    await tester.tap(find.text('三'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final traveling = tester.getTopLeft(thumb).dx;
    await tester.pumpAndSettle();
    final destination = tester.getTopLeft(thumb).dx;
    expect(traveling, greaterThan(start));
    expect(traveling, lessThan(destination));
    await tester.tap(find.text('二'));
    await tester.pumpAndSettle();
    expect(selected, '二');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pressed controls recover and honor reduced motion',(tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body:
      FlPressScale(pressedScale: .9, child: InkWell(
        onTap: () {}, child: const SizedBox(width: 120, height: 60),
      )),
    )));
    final target = find.byType(InkWell);
    final gesture = await tester.startGesture(tester.getCenter(target));
    await tester.pump();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, .9);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await tester.pumpWidget(MaterialApp(home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Scaffold(body: FlSegmented<String>(
        values: const ['甲', '乙'], label: (v) => v, value: '甲',
        onChanged: (_) {},
      )),
    )));
    final indicator = tester.widget<AnimatedPositioned>(
      find.byKey(const ValueKey('segmented-thumb')));
    expect(indicator.duration, Duration.zero);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Fade-through supports rapid page retargeting',(tester) async {
    var tab = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body:
      StatefulBuilder(builder: (context, set) => Column(children: [
        FilledButton(onPressed: () => set(() => tab = (tab + 1) % 3),
          child: const Text('next')),
        Expanded(child: FlFadeThrough(
          child: Center(key: ValueKey(tab),
            child: Text(['第一页', '第二页', '第三页'][tab])),
        )),
      ])),
    )));
    await tester.pumpAndSettle();
    await tester.tap(find.text('next'));
    await tester.pump(const Duration(milliseconds: 90));
    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();
    expect(find.text('第三页'), findsOneWidget);
    expect(find.text('第一页'), findsNothing);
    expect(find.text('第二页'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Slider touch enlarges and releases value badge',(tester) async {
    var value = 40.0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body:
      StatefulBuilder(builder: (context, set) => FlSliderPanel(
        title: '速度', value: value,
        onChanged: (v) => set(() => value = v),
      )),
    )));
    await tester.pumpAndSettle();
    final badge = find.byKey(const ValueKey('slider-value-速度'));
    final slider = find.byType(Slider);
    final finger = await tester.startGesture(tester.getCenter(slider));
    await tester.pump();
    expect(tester.widget<AnimatedScale>(badge).scale, greaterThan(1));
    await finger.moveBy(const Offset(55, 0));
    await tester.pump();
    await finger.up();
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(badge).scale, 1);
    expect(tester.takeException(), isNull);
  });


  testWidgets('Visual style switches and chips are local UI',(tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: SingleChildScrollView(child: Column(children:[
        FlPreviewStyle(),
        FlPreviewChips(),
      ])),
    )));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('preview-key-style')), findsOneWidget);
    final chip = find.byKey(const ValueKey('preview-chip-Shift'));
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    final selected = tester.widget<FilterChip>(chip);
    expect(selected.selected, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Color debugging accepts valid HEX and updates sample',(tester) async {
    await tester.pumpWidget(const MaterialApp(home:Scaffold(
      body:SingleChildScrollView(child:FlColorDebug()))));
    await tester.pumpAndSettle();
    final field=find.byKey(const ValueKey('color-debug-hex'));
    await tester.enterText(field,'FFFF0000');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.textContaining('FFFF0000'),findsWidgets);
    expect(tester.takeException(),isNull);
  });
  testWidgets('Animation debugging plays and resets',(tester) async {
    await tester.pumpWidget(const MaterialApp(home:Scaffold(
      body:SingleChildScrollView(child:FlAnimationDebug()))));
    await tester.pumpAndSettle();
    final play = find.byKey(const ValueKey('animation-debug-play'));
    final reset = find.byKey(const ValueKey('animation-debug-reset'));
    await tester.ensureVisible(play);
    await tester.pumpAndSettle();
    await tester.tap(play);
    await tester.pump(const Duration(milliseconds:100));
    await tester.ensureVisible(reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(tester.takeException(),isNull);
  });
  testWidgets('Color sequence and press controls render independently',(tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body:
      SingleChildScrollView(child: Column(children: [
        FlColorSequenceDebug(), FlPressDebug(),
      ])),
    )));
    await tester.pumpAndSettle();
    final add = find.byKey(const ValueKey('color-stop-add'));
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('color-stop-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('press-debug-target')), findsWidgets);
    expect(tester.takeException(), isNull);
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
