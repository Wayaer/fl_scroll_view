# fl_scroll_view

基于 `easy_refresh` 4.x 的可刷新滚动封装，内置 list / grid / masonry / aligned / quilted / staired / woven 与 `StaggeredGrid`。

要求 **Flutter >= 3.47**、`material_ui`。请用 `package:material_ui/material_ui.dart` 的 `MaterialApp`；若仍有依赖导入 `package:flutter/material.dart`，外层包一层 `MaterialUiCompatibilityBridge`。

[Web example](https://wayaer.github.io/fl_scroll_view/example/app/web/index.html#/)

## 综合示例

一个 `FlRefreshScrollView` 内串联常用 sliver 与多种 `ListGridLayout`：

```dart
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

class ShowcasePage extends StatelessWidget {
  const ShowcasePage({super.key});

  static const quiltedPattern = [
    QuiltedGridTile(2, 2),
    QuiltedGridTile(1, 1),
    QuiltedGridTile(1, 1),
    QuiltedGridTile(1, 2),
  ];

  static const stairedPattern = [
    StairedGridTile(0.5, 1),
    StairedGridTile(0.5, 3 / 4),
    StairedGridTile(1.0, 10 / 4),
  ];

  static const wovenPattern = [
    WovenGridTile(1),
    WovenGridTile(5 / 7, crossAxisRatio: 0.9, alignment: AlignmentDirectional.centerEnd),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('fl_scroll_view')),
      body: FlRefreshScrollView(
        padding: const EdgeInsets.all(10),
        refreshConfig: FlEasyRefreshConfig(
          onRefresh: (_) async {
            await Future<void>.delayed(const Duration(seconds: 1));
            return FlEasyRefreshResult.refreshSuccess;
          },
          onLoad: (_) async {
            await Future<void>.delayed(const Duration(seconds: 1));
            return FlEasyRefreshResult.loadingSuccess;
          },
        ),
        slivers: [
          FlSliverPersistentHeader(
            pinned: true,
            minHeight: 48,
            maxHeight: 96,
            child: Container(
              color: Colors.black87,
              alignment: Alignment.center,
              child: const Text('Pinned header', style: TextStyle(color: Colors.white)),
            ),
          ),
          FlSliverPinnedToBoxAdapter(
            child: Container(
              height: 44,
              color: Colors.deepOrange,
              alignment: Alignment.center,
              child: const Text('Pinned box', style: TextStyle(color: Colors.white)),
            ),
          ),
          // list
          FlSliverListGrid.builder(
            layout: const ListGridLayout.list(),
            itemCount: 8,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) => _Tile(i, height: 56),
          ),
          // grid
          FlSliverListGrid.builder(
            layout: const ListGridLayout.grid(
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 9,
            itemBuilder: (_, i) => _Tile(i + 8),
          ),
          // masonry
          FlSliverListGrid.builder(
            layout: const ListGridLayout.masonry(
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 10,
            itemBuilder: (_, i) => _Tile(i + 17, height: 60 + (i % 5) * 24),
          ),
          // aligned
          FlSliverListGrid.builder(
            layout: const ListGridLayout.aligned(
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 8,
            itemBuilder: (_, i) => _Tile(i + 27, height: i.isEven ? 100 : 48),
          ),
          // quilted
          FlSliverListGrid.builder(
            layout: const ListGridLayout.quilted(
              crossAxisCount: 4,
              pattern: quiltedPattern,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 8,
            itemBuilder: (_, i) => _Tile(i + 35),
          ),
          // staired
          FlSliverListGrid.builder(
            layout: const ListGridLayout.staired(
              pattern: stairedPattern,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 6,
            itemBuilder: (_, i) => _Tile(i + 43),
          ),
          // woven
          FlSliverListGrid.builder(
            layout: const ListGridLayout.woven(
              pattern: wovenPattern,
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 8,
            itemBuilder: (_, i) => _Tile(i + 49),
          ),
          // StaggeredGrid（非 sliver，包在 SliverToBoxAdapter 中）
          SliverToBoxAdapter(
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                for (int i = 0; i < 12; i++)
                  StaggeredGridTile.count(
                    crossAxisCellCount: i.isEven ? 2 : 1,
                    mainAxisCellCount: i % 3 == 0 ? 2 : 1,
                    child: _Tile(i + 57),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.index, {this.height = 80});

  final int index;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hue = (index * 47) % 360;
    return Container(
      height: height,
      alignment: Alignment.center,
      color: HSLColor.fromAHSL(1, hue.toDouble(), 0.72, 0.48).toColor(),
      child: Text('$index', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
```

单独页面也可用 `FlScrollListGrid.builder` / `.count`，通过 `layout: ListGridLayout.*(...)` 切换样式。
