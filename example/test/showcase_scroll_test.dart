import 'package:example/src/pages/showcase_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('Showcase jumps stay put through staired region', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ShowcasePage()));
    await tester.pump();

    final ScrollableState state = tester.state(find.byType(Scrollable).first);
    final labels = <String, double?>{};

    for (var offset = 0.0; offset <= state.position.maxScrollExtent; offset += 200) {
      state.position.jumpTo(offset);
      await tester.pump();
      // Must not snap backwards more than a small epsilon.
      expect(
        state.position.pixels,
        greaterThanOrEqualTo(offset - 1.0),
        reason: 'jump $offset snapped to ${state.position.pixels}',
      );
      for (final label in [
        'ListGridLayout.quilted',
        'ListGridLayout.staired',
        'ListGridLayout.woven',
      ]) {
        if (find.text(label).evaluate().isNotEmpty) {
          labels.putIfAbsent(label, () => state.position.pixels);
        }
      }
    }

    expect(labels.containsKey('ListGridLayout.staired'), isTrue, reason: 'labels=$labels');
    expect(labels.containsKey('ListGridLayout.quilted'), isTrue);

    // Re-enter staired and ensure we don't fall back to quilted-only.
    final stairedAt = labels['ListGridLayout.staired']!;
    state.position.jumpTo(stairedAt);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('ListGridLayout.staired'), findsOneWidget);
    expect(state.position.pixels, closeTo(stairedAt, 50));
  });
}
