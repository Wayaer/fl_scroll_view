import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

class NestedPage extends StatelessWidget {
  const NestedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarText('NestedScrollView 嵌套'),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
          FlSliverPersistentHeader(
            pinned: true,
            floating: false,
            maxHeight: 170,
            minHeight: 56,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool expanded = constraints.maxHeight >= 128 && constraints.maxWidth >= 380;
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.call_merge_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'NestedScrollView',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const DemoPill('isNested: true', color: Colors.white, dense: true),
                        ],
                      ),
                      if (expanded) ...[
                        const SizedBox(height: 12),
                        Text(
                          '外层 FlSliverPersistentHeader + FlSliverPinnedToBoxAdapter；'
                          '内层 FlRefreshScrollView 需开启 FlEasyRefreshConfig.isNested，'
                          '否则 physics 和指示器容易异常。',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11.5, height: 1.5),
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
              height: 50,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.push_pin_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'FlSliverPinnedToBoxAdapter 始终固定在顶部',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const DemoPill('offset 0', dense: true),
                ],
              ),
            ),
          ),
        ],
        body: FlRefreshScrollView(
          padding: const EdgeInsets.all(12),
          refreshConfig: demoRefreshConfig(delay: const Duration(milliseconds: 700)).copyWith(isNested: true),
          slivers: [
            const DemoInfoSliver(
              title: '内层刷新 + 外层折叠',
              message:
                  '向上拖动时先折叠外层 header，再滚动内层内容；'
                  '内层下拉刷新会与外层滚动协调。',
              tags: ['NestedScrollView', 'isNested', 'FlEasyRefreshConfig.copyWith'],
            ),
            const SectionTitle('FlSliverListGrid.masonry', subtitle: '内层瀑布流 sliver'),
            FlSliverListGrid.builder(
              layout: const ListGridLayout.masonry(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: 24,
              itemBuilder: (_, int index) =>
                  ColorEntry(index, colorAt(index), height: masonryHeight(index), label: 'masonry $index'),
            ),
            const SectionTitle('FlSliverListGrid.list', subtitle: '内层普通列表'),
            FlSliverListGrid.builder(
              layout: const ListGridLayout.list(),
              itemCount: 40,
              itemBuilder: (_, int index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DemoListCard(index: index, title: '内层第 $index 行'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
