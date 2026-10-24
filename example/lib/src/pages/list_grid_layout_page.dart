import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

/// 演示 [FlScrollListGrid] / [FlSliverListGrid] 的每一种 [ListGridLayout]
class ListGridLayoutPage extends StatelessWidget {
  const ListGridLayoutPage({
    super.key,
    required this.layout,
    this.useCount = false,
  });

  final ListGridLayout layout;
  final bool useCount;

  @override
  Widget build(BuildContext context) {
    final title = 'FlScrollListGrid.${useCount ? 'count' : 'builder'} · $layout';
    return Scaffold(
      appBar: AppBarText(title),
      body: useCount ? _buildCount() : _buildBuilder(),
    );
  }

  Widget _buildBuilder() {
    return FlScrollListGrid.builder(
      padding: const EdgeInsets.all(10),
      refreshConfig: demoRefreshConfig(),
      layout: layout,
      itemCount: demoItemCount,
      separatorBuilder: layout is ListGridListLayout
          ? (_, int index) => Divider(height: 12, thickness: 4, color: colorAt(index))
          : null,
      itemBuilder: (_, int index) => _item(layout, index),
    );
  }

  Widget _buildCount() {
    final children = List<Widget>.generate(
      demoItemCount,
      (int index) => _item(layout, index),
    );
    return FlScrollListGrid.count(
      padding: const EdgeInsets.all(10),
      refreshConfig: demoRefreshConfig(),
      layout: layout,
      children: children,
    );
  }
}

/// example 首页用的布局样例（各自带合适默认参数）
List<ListGridLayout> get demoListGridLayouts => [
  const ListGridLayout.list(),
  const ListGridLayout.grid(
    crossAxisCount: 2,
    maxCrossAxisExtent: 120,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 0.75,
  ),
  const ListGridLayout.masonry(
    crossAxisCount: 2,
    maxCrossAxisExtent: 120,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
  ),
  const ListGridLayout.aligned(
    crossAxisCount: 2,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
  ),
  const ListGridLayout.quilted(
    crossAxisCount: 4,
    pattern: quiltedPattern,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
  ),
  const ListGridLayout.staired(
    pattern: stairedPattern,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
  ),
  const ListGridLayout.woven(
    pattern: wovenPattern,
    crossAxisCount: 2,
    maxCrossAxisExtent: 120,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
  ),
];

Widget _item(ListGridLayout layout, int index) {
  final color = colorAt(index);
  return switch (layout) {
    ListGridListLayout() => ColorEntry(index, color, height: 72, width: double.infinity),
    ListGridMasonryLayout() => ColorEntry(index, color, height: masonryHeight(index)),
    ListGridAlignedLayout() => ColorEntry(index, color, height: alignedHeight(index)),
    ListGridGridLayout() ||
    ListGridQuiltedLayout() ||
    ListGridStairedLayout() ||
    ListGridWovenLayout() => ColorEntry(index, color, height: 100),
  };
}
