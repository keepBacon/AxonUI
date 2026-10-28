import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:axon_flclash_flutter/axon_flclash_ui.dart';

void main() {
  test('Axon schema includes every existing plugin debug type', () {
    final types = {
      'slider', 'color', 'select', 'number', 'text',
      'key', 'toggle', 'list', 'binding',
    };
    expect(AxonPluginField.supportedTypes, containsAll(types));
    expect(AxonPluginField.supportedTypes.length, types.length);
  });

  test('Recursive controls hold defaults without native integration', () {
    final doc = AxonPluginDocument.fromJson({
      'features': [
        {
          'id': 'demo', 'type': 'toggle', 'name': '演示', 'default': true,
          'debug': [
            {'id': 'alpha', 'type': 'slider', 'name': '透明度',
              'min': 0, 'max': 100, 'step': 2, 'default': 36},
            {'id': 'colors', 'type': 'color', 'name': '颜色',
              'default': ['#FF112233']},
            {'id': 'items', 'type': 'list', 'name': '列表',
              'fields': [{'id': 'label', 'type': 'text', 'name': '名称',
                'default': '条目'}]},
          ],
        },
      ],
    });
    expect(doc.features.single.debug.length, 3);
    final fields = doc.features.single.debug;
    expect(fields[0].newDefault(), 36);
    expect(fields[1].newDefault(), ['#FF112233']);
    expect(fields[2].newRow()['label'], '条目');
  });

  testWidgets('UI checkbox toggles without platform channel', (tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AxonCheckboxTile(
      title: '界面选项', value: false, onChanged: (v) => result = v,
    ))));
    await tester.tap(find.byType(Checkbox));
    expect(result, isTrue);
  });

  testWidgets('UI grid selects a value without touching the engine', (tester) async {
    String chosen = 'a';
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AxonOptionGrid<String>(
      entries: const {'a': '选择一', 'b': '选择二'}, selected: chosen,
      onChanged: (v) => chosen = v,
    ))));
    await tester.tap(find.text('选择二'));
    expect(chosen, 'b');
  });

  testWidgets('Banner, empty state and tab strip render', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body:
      SingleChildScrollView(child: Column(children: [
        const AxonInfoBanner(title: '状态', message: '说明'),
        const AxonEmptyState(title: '暂无内容'),
        AxonAnimatedTabStrip(tabs: const ['A', 'B', 'C'], selected: 0,
          onChanged: (_) {}),
      ])))));
    expect(find.text('状态'), findsOneWidget);
    expect(find.text('暂无内容'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });
}
