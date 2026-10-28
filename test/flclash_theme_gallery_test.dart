import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:axon_flclash_flutter/axon_flclash_ui.dart';

void main() {
  testWidgets('FlClash choice group preserves UI-only callbacks', (tester) async {
    bool floating = true;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: FlChoiceGroup<bool>(
      title: '底栏', icon: Icons.layers, value: floating,
      options: const [FlChoice(true, '悬浮'), FlChoice(false, '固定')],
      onChanged: (next) => floating = next,
    ))));
    expect(find.text('悬浮'), findsOneWidget);
    await tester.tap(find.text('固定'));
    expect(floating, false);
  });

  testWidgets('Animated pill segment responds to selection', (tester) async {
    int index = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: FlPillSegmented(
      values: const ['跟随系统', '自定义'], selected: index,
      onChanged: (next) => index = next,
    ))));
    await tester.tap(find.text('自定义'));
    expect(index, 1);
  });

  testWidgets('Theme page is the full visual control screen', (tester) async {
    final store = AxonMemoryStore();
    await tester.pumpWidget(MaterialApp(home: FlClashThemeGallery(
      store: store, mode: ThemeMode.light, seed: const Color(0xFF0087F8),
      onThemeChanged: (_) {}, onSeedChanged: (_) {}, onOpenControls: () {},
    )));
    await tester.pump();
    expect(find.text('主题'), findsOneWidget);
    expect(find.text('配色风格'), findsOneWidget);
    expect(find.text('底栏'), findsOneWidget);
    expect(find.text('悬浮'), findsOneWidget);
  });
}
