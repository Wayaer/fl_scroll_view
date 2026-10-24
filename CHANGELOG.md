## 2.0.0

### 依赖与环境

* Flutter `>=3.47`，Dart `^3.13`
* `easy_refresh` `^4.0.0`
* 移除依赖 `flutter_staggered_grid_view`，交错布局已内置进本包
* 新增依赖 `material_ui`；指示器 / 主题请改用 `package:material_ui/material_ui.dart`（必要时包一层 `MaterialUiCompatibilityBridge`）

### 列表样式 API

布局参数收进密封类 `ListGridLayout`（定义于 `sliver_list_grid.dart`）：

```dart
FlScrollListGrid.builder(
  layout: const ListGridLayout.grid(crossAxisCount: 3),
  itemCount: 20,
  itemBuilder: (_, i) => Text('$i'),
);

FlScrollListGrid.builder(
  layout: const ListGridLayout.quilted(
    crossAxisCount: 4,
    pattern: [
      QuiltedGridTile(2, 2),
      QuiltedGridTile(1, 1),
      QuiltedGridTile(1, 1),
      QuiltedGridTile(1, 2),
    ],
  ),
  itemCount: 20,
  itemBuilder: (_, i) => Text('$i'),
);
```

可用布局：`list` / `grid` / `masonry` / `aligned` / `quilted` / `staired` / `woven`。  
`separatorBuilder` 行为对齐 `ListView.separated`；可用 `findItemIndexCallback`（返回 item 索引，库内自动 `* 2`）。

### 交错布局

从本包导入即可（不再依赖 `flutter_staggered_grid_view`）：`MasonryGridView`、`AlignedGridView`、`SliverMasonryGrid`、`SliverAlignedGrid`、`StaggeredGrid` / `StaggeredGridTile`、`QuiltedGridTile` / `SliverQuiltedGridDelegate`、`StairedGridTile` / `SliverStairedGridDelegate`、`WovenGridTile` / `SliverWovenGridDelegate`、`SliverSimpleGridDelegate*` 等。

### EasyRefresh

* EasyRefresh 4 需配合 `material_ui` 主题；`ClassicHeader` / `ClassicFooter` 等仍由本包 re-export
* 无全局 `FlEasyRefreshControllers`；在 `onRefresh` / `onLoad` 回调参数上使用 `EasyRefreshController`，或显式传入 `FlEasyRefreshConfig.controller`

```dart
FlEasyRefreshConfig(
  onRefresh: (controller) async {
    await load();
    controller.finishRefresh(IndicatorResult.success);
    // 或 return FlEasyRefreshResult.refreshSuccess;
  },
);
```

### 其它

* `MasonryGridView` / `AlignedGridView` 使用 `scrollCacheExtent`（Flutter 3.47）
* 修复 `StaggeredGrid` 固定 cell 尺寸时错误读取 `RenderBox.size` 的断言
* 修复 `SliverMasonryGrid` 位于其他 sliver 上方时错误 `scrollOffsetCorrection` 导致回弹
* `separatorBuilder`：非 list 布局构造期 assert；与 `itemExtent` / `prototypeItem` 同用时强制走 `SliverList`
