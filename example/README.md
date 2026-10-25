# fl_scroll_view example

交互式示例应用：用底部「参数实验台」实时切换库封装好的参数，直接观察布局、刷新与滚动效果。

## 运行

```bash
flutter pub get
flutter run -d chrome   # 或 iOS 模拟器 / 真机
flutter test            # 页面冒烟测试 + 布局回归测试
```

## 页面

| 分组 | 页面 | 展示的参数 / 效果 |
| --- | --- | --- |
| 综合 | Showcase | 7 种 `ListGridLayout`、`StaggeredGrid`、pinned header、下拉刷新同屏 |
| 布局 | List | `itemExtent`、`separatorBuilder`、`reverse`、`count` 模式 |
| 布局 | Grid | `crossAxisCount` / `maxCrossAxisExtent` 自适应、`childAspectRatio`、`mainAxisExtent` |
| 布局 | Masonry | 列数 / 最大列宽、主轴与交叉轴间距 |
| 布局 | Aligned | 行对齐网格 + 不同子项高度 |
| 布局 | Quilted | `QuiltedGridTile` pattern、`repeatPattern: same / inverted / mirrored` |
| 布局 | Staired | `crossAxisRatio`、`aspectRatio`、`tileBottomSpace`、反向排布 |
| 布局 | Woven | `aspectRatio`、`crossAxisRatio`、`alignment`、`tileBottomSpace` |
| 布局 | 通用 | `placeholder` / `placeholderFill` / `placeholderFillOverscroll`、空数据、count 模式 |
| 刷新 | FlEasyRefreshConfig | 7 种 Header/Footer 风格、`simultaneously`、`canLoadAfterNoMore`、`refreshOnStart`、失败与 noMore、外部 controller 触发 |
| 滚动 | FlRefreshScrollView | `reverse`、`scrollDirection`、`physics`、`anchor`、`padding`、`cacheExtent`、`noScrollBehavior`、`keyboardDismissBehavior`、controller 跳转 |
| Sliver | FlSliverPersistentHeader | `pinned` / `floating` / `minHeight` / `maxHeight` 折叠 |
| Sliver | FlSliverPinnedToBoxAdapter | 固定顶部 + 实时 offset |
| Sliver | NestedScrollView | `FlEasyRefreshConfig.isNested` 内层刷新 |
| 列表细节 | separator / placeholder / keepAlive | `findItemIndexCallback` 打乱保状态、空数据占位、header/footer sliver |
| 交错 | MasonryGridView / AlignedGridView | `count` / `extent` / `custom` 三种构造 |
| 交错 | StaggeredGrid | `.count` / `.extent` / `.custom`，`tile.count` / `tile.extent` / `tile.fit` |
| 交错 | Sliver 版 | `SliverMasonryGrid` + `SliverAlignedGrid` 混排与刷新 |

每个实验台右上角的 `</>` 按钮可查看/复制当前参数对应的调用代码。
