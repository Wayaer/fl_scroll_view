import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('masonry above other slivers: scroll both ways without assert', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              FlSliverListGrid.builder(
                layout: const ListGridLayout.masonry(
                  crossAxisCount: 2,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemCount: 12,
                itemBuilder: (_, i) => ColorEntry(i, colorAt(i), height: masonryHeight(i)),
              ),
              FlSliverListGrid.builder(
                layout: const ListGridLayout.quilted(
                  crossAxisCount: 4,
                  pattern: quiltedPattern,
                ),
                itemCount: 8,
                itemBuilder: (_, i) => ColorEntry(i + 20, colorAt(i + 20)),
              ),
              FlSliverListGrid.builder(
                layout: const ListGridLayout.staired(pattern: stairedPattern),
                itemCount: 6,
                itemBuilder: (_, i) => ColorEntry(i + 40, colorAt(i + 40)),
              ),
              FlSliverListGrid.builder(
                layout: const ListGridLayout.list(),
                itemCount: 40,
                itemBuilder: (_, i) => ColorEntry(
                  i + 50,
                  colorAt(i + 50),
                  height: 56,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    final ScrollableState state = tester.state(find.byType(Scrollable));
    final max = state.position.maxScrollExtent;

    for (var offset = 0.0; offset <= max; offset += 120) {
      state.position.jumpTo(offset.clamp(0.0, state.position.maxScrollExtent));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        state.position.pixels,
        greaterThanOrEqualTo(offset.clamp(0.0, state.position.maxScrollExtent) - 1),
        reason: 'down jump $offset snapped to ${state.position.pixels}',
      );
    }

    for (var offset = max; offset >= 0; offset -= 120) {
      state.position.jumpTo(offset.clamp(0.0, state.position.maxScrollExtent));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });
}
