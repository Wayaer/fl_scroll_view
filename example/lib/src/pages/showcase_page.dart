import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

/// 综合页：串联库内主要滚动样式；每张色卡颜色只跟全局 index 绑定
class ShowcasePage extends StatelessWidget {
  const ShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    var cursor = 0;
    List<int> take(int n) {
      final start = cursor;
      cursor += n;
      return List<int>.generate(n, (i) => start + i);
    }

    final listIdx = take(8);
    final gridIdx = take(9);
    final masonryIdx = take(10);
    final alignedIdx = take(8);
    final quiltedIdx = take(8);
    final stairedIdx = take(6);
    final wovenIdx = take(8);
    final staggeredIdx = take(12);
    final allIdx = take(demoItemCount);

    return Scaffold(
      appBar: AppBarText('综合 Showcase'),
      body: FlRefreshScrollView(
        padding: const EdgeInsets.all(10),
        refreshConfig: demoRefreshConfig(),
        slivers: [
          FlSliverPersistentHeader(
            pinned: true,
            floating: false,
            minHeight: 44,
            maxHeight: 88,
            child: Container(
              color: Colors.black87,
              alignment: Alignment.center,
              child: const Text(
                '一卡一色 · list/grid/masonry/aligned/quilted/staired/woven/StaggeredGrid',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          FlSliverPinnedToBoxAdapter(
            child: Container(
              height: 48,
              color: Colors.deepOrange,
              alignment: Alignment.center,
              child: const Text('FlSliverPinnedToBoxAdapter', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SectionTitle('ListGridLayout.list'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.list(),
            itemCount: listIdx.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, int i) {
              final index = listIdx[i];
              return ColorEntry(
                index,
                colorAt(index),
                height: 56,
                width: double.infinity,
                label: 'list $index',
              );
            },
          ),
          const SectionTitle('ListGridLayout.grid'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.grid(
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: gridIdx.length,
            itemBuilder: (_, int i) {
              final index = gridIdx[i];
              return ColorEntry(index, colorAt(index), label: 'grid $index');
            },
          ),
          const SectionTitle('ListGridLayout.masonry'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.masonry(
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: masonryIdx.length,
            itemBuilder: (_, int i) {
              final index = masonryIdx[i];
              return ColorEntry(
                index,
                colorAt(index),
                height: masonryHeight(index),
                label: 'masonry $index',
              );
            },
          ),
          const SectionTitle('ListGridLayout.aligned'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.aligned(
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: alignedIdx.length,
            itemBuilder: (_, int i) {
              final index = alignedIdx[i];
              return ColorEntry(
                index,
                colorAt(index),
                height: alignedHeight(index),
                label: 'aligned $index',
              );
            },
          ),
          const SectionTitle('ListGridLayout.quilted'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.quilted(
              crossAxisCount: 4,
              pattern: quiltedPattern,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: quiltedIdx.length,
            itemBuilder: (_, int i) {
              final index = quiltedIdx[i];
              return ColorEntry(index, colorAt(index), label: 'quilted $index');
            },
          ),
          const SectionTitle('ListGridLayout.staired'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.staired(
              pattern: stairedPattern,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: stairedIdx.length,
            itemBuilder: (_, int i) {
              final index = stairedIdx[i];
              return ColorEntry(index, colorAt(index), label: 'staired $index');
            },
          ),
          const SectionTitle('ListGridLayout.woven'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.woven(
              pattern: wovenPattern,
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: wovenIdx.length,
            itemBuilder: (_, int i) {
              final index = wovenIdx[i];
              return ColorEntry(index, colorAt(index), label: 'woven $index');
            },
          ),
          const SectionTitle('StaggeredGrid'),
          SliverToBoxAdapter(
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                for (final index in staggeredIdx)
                  StaggeredGridTile.count(
                    crossAxisCellCount: index.isEven ? 2 : 1,
                    mainAxisCellCount: index % 3 == 0 ? 2 : 1,
                    child: ColorEntry(index, colorAt(index), label: 'tile $index'),
                  ),
              ],
            ),
          ),
          const SectionTitle('全量色卡'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.grid(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: allIdx.length,
            itemBuilder: (_, int i) {
              final index = allIdx[i];
              return ColorEntry(index, colorAt(index), label: '$index');
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
