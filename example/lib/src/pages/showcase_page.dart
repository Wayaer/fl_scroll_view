import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

/// 综合页：串联库内主要滚动样式；每张色卡颜色只跟全局 index 绑定
class ShowcasePage extends StatelessWidget {
  const ShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    int cursor = 0;
    List<int> take(int count) {
      final int start = cursor;
      cursor += count;
      return List<int>.generate(count, (int index) => start + index);
    }

    final List<int> listIdx = take(6);
    final List<int> gridIdx = take(9);
    final List<int> masonryIdx = take(10);
    final List<int> alignedIdx = take(8);
    final List<int> quiltedIdx = take(8);
    final List<int> stairedIdx = take(6);
    final List<int> wovenIdx = take(6);
    final List<int> staggeredIdx = take(12);
    final List<int> allIdx = take(120);

    return Scaffold(
      appBar: AppBarText('Showcase 综合页'),
      body: FlRefreshScrollView(
        padding: const EdgeInsets.all(10),
        refreshConfig: demoRefreshConfig(),
        slivers: [
          FlSliverPersistentHeader(
            pinned: true,
            floating: false,
            minHeight: 56,
            maxHeight: 112,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool expanded = constraints.maxHeight >= 90;
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF312E81), Color(0xFF4F46E5), Color(0xFF0EA5E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.dashboard_customize_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'fl_scroll_view · Showcase',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      if (expanded) ...[
                        const SizedBox(height: 10),
                        Text(
                          'pinned header + pinned box + 7 种 ListGridLayout + StaggeredGrid 同屏滚动',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.86), fontSize: 11.5),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          FlSliverPinnedToBoxAdapter(
            child: Container(
              height: 46,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)])),
              child: Row(
                children: [
                  const Icon(Icons.push_pin_rounded, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'FlSliverPinnedToBoxAdapter · 始终固定',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const DemoPill('pull to refresh', color: Colors.white, dense: true),
                ],
              ),
            ),
          ),
          SectionTitle('ListGridLayout.list', subtitle: '线性列表 + separatorBuilder'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.list(),
            itemCount: listIdx.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (_, int i) {
              final int index = listIdx[i];
              return ColorEntry(index, colorAt(index), height: 52, width: double.infinity, label: 'list $index');
            },
          ),
          SectionTitle('ListGridLayout.grid', subtitle: '3 列等分网格'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.grid(crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6),
            itemCount: gridIdx.length,
            itemBuilder: (_, int i) {
              final int index = gridIdx[i];
              return ColorEntry(index, colorAt(index), label: 'grid $index');
            },
          ),
          SectionTitle('ListGridLayout.masonry', subtitle: '2 列瀑布流，高度自由'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.masonry(crossAxisCount: 2, mainAxisSpacing: 6, crossAxisSpacing: 6),
            itemCount: masonryIdx.length,
            itemBuilder: (_, int i) {
              final int index = masonryIdx[i];
              return ColorEntry(index, colorAt(index), height: masonryHeight(index), label: 'masonry $index');
            },
          ),
          SectionTitle('ListGridLayout.aligned', subtitle: '行对齐网格'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.aligned(crossAxisCount: 2, mainAxisSpacing: 6, crossAxisSpacing: 6),
            itemCount: alignedIdx.length,
            itemBuilder: (_, int i) {
              final int index = alignedIdx[i];
              return ColorEntry(index, colorAt(index), height: alignedHeight(index), label: 'aligned $index');
            },
          ),
          SectionTitle('ListGridLayout.quilted', subtitle: '4 列拼布图案'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.quilted(
              crossAxisCount: 4,
              pattern: quiltedPattern,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: quiltedIdx.length,
            itemBuilder: (_, int i) {
              final int index = quiltedIdx[i];
              return ColorEntry(index, colorAt(index), label: 'quilted $index');
            },
          ),
          SectionTitle('ListGridLayout.staired', subtitle: '左右交替的阶梯图案'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.staired(pattern: stairedPattern, mainAxisSpacing: 6, crossAxisSpacing: 6),
            itemCount: stairedIdx.length,
            itemBuilder: (_, int i) {
              final int index = stairedIdx[i];
              return ColorEntry(index, colorAt(index), label: 'staired $index');
            },
          ),
          SectionTitle('ListGridLayout.woven', subtitle: '上下两排交错的编织图案'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.woven(
              pattern: wovenPattern,
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: wovenIdx.length,
            itemBuilder: (_, int i) {
              final int index = wovenIdx[i];
              return ColorEntry(index, colorAt(index), label: 'woven $index');
            },
          ),
          SectionTitle('StaggeredGrid', subtitle: '一次性布局的不规则拼块'),
          SliverToBoxAdapter(
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                for (final int index in staggeredIdx)
                  StaggeredGridTile.count(
                    crossAxisCellCount: index.isEven ? 2 : 1,
                    mainAxisCellCount: index % 3 == 0 ? 2 : 1,
                    child: ColorEntry(index, colorAt(index), label: 'tile $index'),
                  ),
              ],
            ),
          ),
          SectionTitle('全量色卡', subtitle: '4 列网格 · 120 项'),
          FlSliverListGrid.builder(
            layout: const ListGridLayout.grid(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: allIdx.length,
            itemBuilder: (_, int i) {
              final int index = allIdx[i];
              return ColorEntry(index, colorAt(index), label: '$index');
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
