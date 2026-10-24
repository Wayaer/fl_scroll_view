import 'package:example/src/common/demo_kit.dart';
import 'package:example/src/pages/list_grid_layout_page.dart';
import 'package:example/src/pages/nested_page.dart';
import 'package:example/src/pages/showcase_page.dart';
import 'package:example/src/pages/sliver_pages.dart';
import 'package:example/src/pages/staggered_direct_page.dart';
import 'package:material_ui/material_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final layouts = demoListGridLayouts;
    return ListView(
      children: [
        const _GroupTitle('综合'),
        ElevatedText('Showcase · 混合全部样式与色卡', onTap: () => pushPage(const ShowcasePage())),
        const _GroupTitle('FlScrollListGrid.builder · ListGridLayout'),
        for (final layout in layouts)
          ElevatedText(
            'builder · $layout',
            onTap: () => pushPage(ListGridLayoutPage(layout: layout)),
          ),
        const _GroupTitle('FlScrollListGrid.count · ListGridLayout'),
        for (final layout in layouts)
          ElevatedText(
            'count · $layout',
            onTap: () => pushPage(ListGridLayoutPage(layout: layout, useCount: true)),
          ),
        const _GroupTitle('独立 staggered 组件'),
        ElevatedText(
          'MasonryGridView',
          onTap: () => pushPage(const StaggeredDirectPage(StaggeredDirectKind.masonryView)),
        ),
        ElevatedText(
          'AlignedGridView',
          onTap: () => pushPage(const StaggeredDirectPage(StaggeredDirectKind.alignedView)),
        ),
        ElevatedText(
          'StaggeredGrid',
          onTap: () => pushPage(const StaggeredDirectPage(StaggeredDirectKind.staggeredGrid)),
        ),
        const _GroupTitle('Sliver / 刷新'),
        ElevatedText('FlRefreshScrollView', onTap: () => pushPage(const FlRefreshScrollViewPage())),
        ElevatedText('FlSliverPersistentHeader', onTap: () => pushPage(const FlSliverPersistentHeaderPage())),
        ElevatedText('FlSliverPinnedToBoxAdapter', onTap: () => pushPage(const FlSliverPinnedToBoxAdapterPage())),
        ElevatedText('NestedScrollView', onTap: () => pushPage(const NestedScrollViewPage())),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
