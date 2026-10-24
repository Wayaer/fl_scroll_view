import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

class NestedScrollViewPage extends StatelessWidget {
  const NestedScrollViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarText('NestedScrollView'),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
          FlSliverPersistentHeader(
            pinned: true,
            floating: false,
            maxHeight: 100,
            minHeight: 56,
            child: Container(
              color: Colors.indigo,
              alignment: Alignment.center,
              child: const Text(
                'FlSliverPersistentHeader',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          FlSliverPinnedToBoxAdapter(
            child: Container(
              color: Colors.teal,
              height: 64,
              alignment: Alignment.center,
              child: const Text(
                'FlSliverPinnedToBoxAdapter',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        body: FlRefreshScrollView(
          // NestedScrollView 内层刷新需开启 isNested，否则 physics / 指示器易异常
          refreshConfig: demoRefreshConfig().copyWith(isNested: true),
          slivers: [
            FlSliverListGrid.builder(
              layout: const ListGridLayout.masonry(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: demoItemCount,
              itemBuilder: (_, int index) => ColorEntry(
                index,
                colorAt(index),
                height: masonryHeight(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
