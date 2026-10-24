import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

class FlRefreshScrollViewPage extends StatelessWidget {
  const FlRefreshScrollViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarText('FlRefreshScrollView'),
      body: FlRefreshScrollView(
        padding: const EdgeInsets.all(10),
        refreshConfig: demoRefreshConfig(),
        slivers: [
          const SectionTitle('FlSliverListGrid.grid'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.grid(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: demoItemCount,
            itemBuilder: (_, int index) => ColorEntry(index, colorAt(index)),
          ),
          const SectionTitle('FlSliverListGrid.masonry'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.masonry(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: demoItemCount,
            itemBuilder: (_, int index) => ColorEntry(
              index + demoItemCount,
              colorAt(index + demoItemCount),
              height: masonryHeight(index),
            ),
          ),
        ],
      ),
    );
  }
}

class FlSliverPersistentHeaderPage extends StatelessWidget {
  const FlSliverPersistentHeaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarText('FlSliverPersistentHeader'),
      body: FlRefreshScrollView(
        padding: const EdgeInsets.all(10),
        refreshConfig: demoRefreshConfig(),
        slivers: [
          FlSliverPersistentHeader(
            pinned: true,
            floating: false,
            minHeight: 48,
            maxHeight: 120,
            child: Container(
              color: colorAt(9),
              alignment: Alignment.center,
              child: const Text('Pinned PersistentHeader', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.list(),
            itemCount: demoItemCount,
            itemBuilder: (_, int index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ColorEntry(index, colorAt(index), width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }
}

class FlSliverPinnedToBoxAdapterPage extends StatelessWidget {
  const FlSliverPinnedToBoxAdapterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarText('FlSliverPinnedToBoxAdapter'),
      body: FlRefreshScrollView(
        padding: const EdgeInsets.all(10),
        refreshConfig: demoRefreshConfig(),
        slivers: [
          FlSliverPinnedToBoxAdapter(
            child: Container(
              height: 72,
              color: colorAt(12),
              alignment: Alignment.center,
              child: const Text('Pinned To Box Adapter', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.aligned(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: demoItemCount,
            itemBuilder: (_, int index) => ColorEntry(
              index,
              colorAt(index),
              height: alignedHeight(index),
            ),
          ),
        ],
      ),
    );
  }
}
