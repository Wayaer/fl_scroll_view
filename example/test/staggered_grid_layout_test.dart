import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('StaggeredGrid.count layouts without sizeAccessAllowed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                for (int i = 0; i < 12; i++)
                  StaggeredGridTile.count(
                    crossAxisCellCount: i.isEven ? 2 : 1,
                    mainAxisCellCount: i % 3 == 0 ? 2 : 1,
                    child: ColoredBox(
                      color: Colors.primaries[i % Colors.primaries.length],
                      child: Center(child: Text('$i')),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('0'), findsOneWidget);
  });
}
