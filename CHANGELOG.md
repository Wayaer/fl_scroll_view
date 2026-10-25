## 2.1.0

### 修复

* 空数据 + `shrinkWrap` / 无界主轴时，`placeholderFill` 不再强制使用 `SliverFillRemaining`，避免无限高度断言
* `onRefresh` / `onLoad` 回调抛异常时自动标记失败并通过 `FlutterError.reportError` 上报，指示器不再停留在 processing 状态
* 兼容外部 `EasyRefreshController`：无需手动开启 `controlFinishRefresh` / `controlFinishLoad`，库会按配置自动结束或交由 EasyRefresh 结束
* `SliverQuiltedGridDelegate` 修复跨列 tile 起始列越界导致的 `RangeError` 红屏；`indexList` 按最大 cell 索引补齐整行
* `SliverQuiltedGridDelegate` 在 pattern 为空或 `QuiltedGridTile.crossAxisCount` 超过列数时构造期抛出 `ArgumentError`
* `FlSliverPinnedToBoxAdapter` 的 `cacheExtent` 对齐 Flutter `PinnedHeaderSliver`；滚动重建时不再触发语义配置断言
* `maxCrossAxisExtent` 自适应列数至少为 1，避免极窄宽度下算出 0 列
* `staired` / `woven` 布局的 `shouldRelayout` 按 pattern 内容比较，相同内容的新列表不再触发无谓重排；`StairedGridTile` / `WovenGridTile` 补充 `==` / `hashCode`
* `aligned` 布局与 `findChildIndexCallback` / `findItemIndexCallback` 组合时在构造期给出断言提示
* 空数据且 `itemCount == 0` 时 `SliverAlignedGrid` 不再生成多余的分隔行

### 新增

* `FlOverscrollShift`：下拉刷新时 `pinned` / `floating` 的 `FlSliverPersistentHeader` 与 `FlSliverPinnedToBoxAdapter` 跟随刷新指示器同步下移，避免遮挡刷新 header；上滑时仍保持固定

### 变更

* `FlEasyRefresh` 内部 controller 默认开启 `controlFinishRefresh` / `controlFinishLoad`，统一接管任务结束
* 补充 `placeholderFill`、`physics`、`shrinkWrap`、`controller` 的优先级与默认行为文档

### 示例

* 示例重写为参数实验台：布局 / 刷新 / 滚动 / Sliver / 交错组件分页演示，支持明暗主题
* 示例移除 `device_preview_minus`，平台精简为 iOS / Web，并新增页面冒烟与布局回归测试

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
