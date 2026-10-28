import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:axon_flclash_flutter/axon_flclash_ui.dart';

void main() {
  testWidgets('Switch updates controlled state', (tester) async {
    bool changed = false;
    await tester.pumpWidget(MaterialApp(theme: axonTheme(),
      home: Scaffold(body: AxonSwitchTile(title: '开关', value: false,
        onChanged: (v) => changed = v))));
    await tester.tap(find.byType(Switch));
    expect(changed, isTrue);
  });

  testWidgets('Card and segmented control render', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: axonTheme(), home: const Scaffold(
      body: Column(children: [
        AxonCard(child: Text('卡片')),
        AxonSegmentedControl(labels: ['舒适', '均衡'], selected: 0, onChanged: null),
      ]))));
    expect(find.text('卡片'), findsOneWidget);
    expect(find.text('均衡'), findsOneWidget);
  });

  test('Control spec schema round trip', () {
    final spec = AxonControlSpec.fromJson({'id': 'cursor', 'label': '灵敏度',
      'type': 'slider', 'min': 0, 'max': 100});
    expect(spec.id, 'cursor');
    expect(spec.max, 100);
    expect(spec.toJson()['type'], 'slider');
  });
}
