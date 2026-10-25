import 'package:example/src/common/demo_kit.dart';
import 'package:example/src/pages/layout_lab_page.dart';
import 'package:example/src/pages/list_options_page.dart';
import 'package:example/src/pages/nested_page.dart';
import 'package:example/src/pages/refresh_lab_page.dart';
import 'package:example/src/pages/scroll_view_lab_page.dart';
import 'package:example/src/pages/showcase_page.dart';
import 'package:example/src/pages/sliver_lab_page.dart';
import 'package:example/src/pages/staggered_lab_page.dart';
import 'package:material_ui/material_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<_DemoGroup> get _groups => [
    _DemoGroup('综合示例', [
      _DemoEntry(
        title: 'Showcase 综合页',
        subtitle: '7 种布局 + 刷新 + Sliver 组合同屏滚动',
        icon: Icons.dashboard_customize_rounded,
        color: demoSeedColors[0],
        builder: (_) => const ShowcasePage(),
      ),
    ]),
    _DemoGroup('布局 · ListGridLayout', [
      _DemoEntry(
        title: 'List 线性列表',
        subtitle: 'itemExtent · prototypeItem · separatorBuilder',
        icon: Icons.view_agenda_rounded,
        color: demoSeedColors[0],
        builder: (_) => const LayoutLabPage(kind: DemoLayoutKind.list),
      ),
      _DemoEntry(
        title: 'Grid 等分网格',
        subtitle: 'crossAxisCount · maxCrossAxisExtent · childAspectRatio',
        icon: Icons.grid_view_rounded,
        color: demoSeedColors[1],
        builder: (_) => const LayoutLabPage(kind: DemoLayoutKind.grid),
      ),
      _DemoEntry(
        title: 'Masonry 瀑布流',
        subtitle: '各列独立堆叠，子项高度可不同',
        icon: Icons.view_quilt_rounded,
        color: demoSeedColors[2],
        builder: (_) => const LayoutLabPage(kind: DemoLayoutKind.masonry),
      ),
      _DemoEntry(
        title: 'Aligned 行对齐网格',
        subtitle: '同一行取最高子项，行内底部对齐',
        icon: Icons.table_rows_rounded,
        color: demoSeedColors[3],
        builder: (_) => const LayoutLabPage(kind: DemoLayoutKind.aligned),
      ),
      _DemoEntry(
        title: 'Quilted 拼布图案',
        subtitle: 'QuiltedGridTile · repeatPattern: same/inverted/mirrored',
        icon: Icons.grid_on_rounded,
        color: demoSeedColors[4],
        builder: (_) => const LayoutLabPage(kind: DemoLayoutKind.quilted),
      ),
      _DemoEntry(
        title: 'Staired 阶梯图案',
        subtitle: 'crossAxisRatio · aspectRatio · tileBottomSpace · 反向排布',
        icon: Icons.stairs_rounded,
        color: demoSeedColors[5],
        builder: (_) => const LayoutLabPage(kind: DemoLayoutKind.staired),
      ),
      _DemoEntry(
        title: 'Woven 编织图案',
        subtitle: 'aspectRatio · crossAxisRatio · alignment',
        icon: Icons.stacked_bar_chart_rounded,
        color: demoSeedColors[0],
        builder: (_) => const LayoutLabPage(kind: DemoLayoutKind.woven),
      ),
    ]),
    _DemoGroup('刷新与加载', [
      _DemoEntry(
        title: 'FlEasyRefreshConfig 实验台',
        subtitle: 'Header/Footer 风格 · simultaneously · noMore · controller',
        icon: Icons.refresh_rounded,
        color: demoSeedColors[3],
        builder: (_) => const RefreshLabPage(),
      ),
    ]),
    _DemoGroup('滚动容器', [
      _DemoEntry(
        title: 'FlRefreshScrollView 参数',
        subtitle: 'reverse · scrollDirection · physics · anchor · padding · controller',
        icon: Icons.swap_vert_rounded,
        color: demoSeedColors[2],
        builder: (_) => const ScrollViewLabPage(),
      ),
      _DemoEntry(
        title: 'Sliver 头部组合',
        subtitle: 'FlSliverPersistentHeader · FlSliverPinnedToBoxAdapter',
        icon: Icons.layers_rounded,
        color: demoSeedColors[1],
        builder: (_) => const SliverLabPage(),
      ),
      _DemoEntry(
        title: 'NestedScrollView 嵌套',
        subtitle: 'isNested · 外层 Header + 内层 FlRefreshScrollView',
        icon: Icons.call_merge_rounded,
        color: demoSeedColors[4],
        builder: (_) => const NestedPage(),
      ),
    ]),
    _DemoGroup('列表细节', [
      _DemoEntry(
        title: 'separator · placeholder · keepAlive',
        subtitle: 'findItemIndexCallback 打乱保状态 · 空数据占位 · header/footer',
        icon: Icons.tune_rounded,
        color: demoSeedColors[5],
        builder: (_) => const ListOptionsPage(),
      ),
    ]),
    _DemoGroup('独立交错组件', [
      _DemoEntry(
        title: 'MasonryGridView',
        subtitle: 'count / extent / builder · 瀑布流独立滚动组件',
        icon: Icons.waterfall_chart_rounded,
        color: demoSeedColors[2],
        builder: (_) => const StaggeredLabPage(mode: StaggeredMode.masonry),
      ),
      _DemoEntry(
        title: 'AlignedGridView',
        subtitle: 'count / extent / custom · 行对齐独立滚动组件',
        icon: Icons.view_module_rounded,
        color: demoSeedColors[3],
        builder: (_) => const StaggeredLabPage(mode: StaggeredMode.aligned),
      ),
      _DemoEntry(
        title: 'StaggeredGrid 拼块',
        subtitle: 'count / extent / fit + 自定义 StaggeredGridDelegate',
        icon: Icons.dashboard_rounded,
        color: demoSeedColors[0],
        builder: (_) => const StaggeredLabPage(mode: StaggeredMode.staggered),
      ),
      _DemoEntry(
        title: 'SliverMasonryGrid · SliverAlignedGrid',
        subtitle: 'sliver 版本，可与其他 sliver 混排并下拉刷新',
        icon: Icons.layers_rounded,
        color: demoSeedColors[5],
        builder: (_) => const StaggeredLabPage(mode: StaggeredMode.sliver),
      ),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            title: const Text('fl_scroll_view', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            actions: const [DemoThemeToggle()],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _HeroCard(),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          for (final _DemoGroup group in _groups) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 8),
                    Text(group.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text('${group.entries.length}', style: TextStyle(fontSize: 11, color: scheme.outline)),
                  ],
                ),
              ),
            ),
            SliverList.separated(
              itemCount: group.entries.length,
              itemBuilder: (BuildContext context, int index) => _EntryTile(entry: group.entries[index]),
              separatorBuilder: (_, _) => const SizedBox(height: 8),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _DemoGroup {
  const _DemoGroup(this.title, this.entries);

  final String title;
  final List<_DemoEntry> entries;
}

class _DemoEntry {
  const _DemoEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.view_stream_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'fl_scroll_view',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                ),
              ),
              const DemoPill('v2.0.0', color: Colors.white, dense: true),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '刷新滚动 + 七种列表网格布局 + 交错排布封装合集。',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              DemoPill('easy_refresh 4.x', icon: Icons.refresh_rounded, color: Colors.white, dense: true),
              DemoPill('ListGridLayout', icon: Icons.grid_view_rounded, color: Colors.white, dense: true),
              DemoPill('Staggered Grid', icon: Icons.view_quilt_rounded, color: Colors.white, dense: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final _DemoEntry entry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => pushPage(entry.builder(context)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [entry.color, entry.color.withValues(alpha: 0.68)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(entry.icon, color: Colors.white, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                      entry.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, height: 1.4, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
