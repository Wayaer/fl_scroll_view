import 'dart:math' as math;

import 'package:fl_scroll_view/src/semantic_index.dart';
import 'package:fl_scroll_view/src/staggered/sliver_aligned_grid.dart';
import 'package:fl_scroll_view/src/staggered/sliver_masonry_grid.dart';
import 'package:fl_scroll_view/src/staggered/sliver_patterned_grids.dart';
import 'package:fl_scroll_view/src/staggered/sliver_quilted_grid.dart';
import 'package:fl_scroll_view/src/staggered/sliver_simple_grid_delegate.dart';
import 'package:flutter/widgets.dart';

/// [FlSliverListGrid] / [FlScrollListGrid] 的布局配置（密封类）。
///
/// 每种样式只暴露自己需要的参数，避免在 Widget 构造函数上堆砌无关字段。
/// 数据相关参数（`itemBuilder` / `itemCount` / `separatorBuilder` / placeholder 等）
/// 仍写在 [FlSliverListGrid] / [FlScrollListGrid] 上。
///
/// 常用写法：
///
/// ```dart
/// // 列表
/// FlSliverListGrid.builder(
///   layout: const ListGridLayout.list(),
///   itemCount: 20,
///   itemBuilder: (_, i) => Text('$i'),
/// );
///
/// // 固定列数网格
/// FlSliverListGrid.builder(
///   layout: const ListGridLayout.grid(crossAxisCount: 3, mainAxisSpacing: 8),
///   itemCount: 20,
///   itemBuilder: (_, i) => Tile(i),
/// );
///
/// // 拼布（pattern 必传）
/// FlSliverListGrid.builder(
///   layout: const ListGridLayout.quilted(
///     crossAxisCount: 4,
///     pattern: [
///       QuiltedGridTile(2, 2),
///       QuiltedGridTile(1, 1),
///       QuiltedGridTile(1, 1),
///       QuiltedGridTile(1, 2),
///     ],
///   ),
///   itemCount: 20,
///   itemBuilder: (_, i) => Tile(i),
/// );
/// ```
///
/// 可用工厂：
/// - [ListGridLayout.list] — 线性列表
/// - [ListGridLayout.grid] — 官方等分网格
/// - [ListGridLayout.masonry] — 瀑布流
/// - [ListGridLayout.aligned] — 按行对齐的不等高网格
/// - [ListGridLayout.quilted] — 拼布图案网格
/// - [ListGridLayout.staired] — 阶梯图案网格
/// - [ListGridLayout.woven] — 编织图案网格
sealed class ListGridLayout {
  const ListGridLayout();

  /// 线性列表。
  ///
  /// 对应 [SliverList]；若设置 [itemExtent] 则为 [SliverFixedExtentList]，
  /// 若设置 [prototypeItem] 则为 [SliverPrototypeExtentList]（[itemExtent] 优先）。
  ///
  /// [FlSliverListGrid.builder] 的 `separatorBuilder` 仅在本布局下生效。
  const factory ListGridLayout.list({
    /// 固定主轴长度（像素）
    double? itemExtent,

    /// 用原型子项推断主轴长度；[itemExtent] 非空时忽略
    Widget? prototypeItem,
  }) = ListGridListLayout;

  /// 官方等分网格，对应 [SliverGrid]。
  ///
  /// - 未设 [maxCrossAxisExtent] 时按 [crossAxisCount] 分列
  /// - 设置了 [maxCrossAxisExtent] 时按最大交叉轴宽度自适应列数（优先）
  /// - [mainAxisExtent] 非空时固定子项主轴长度，否则用 [childAspectRatio]
  const factory ListGridLayout.grid({
    /// 固定列数；未设置 [maxCrossAxisExtent] 时使用，默认 1
    int crossAxisCount,

    /// 交叉轴最大宽度，据此自适应列数；设置后优先于 [crossAxisCount]
    double? maxCrossAxisExtent,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,

    /// 子项宽高比（宽 / 高），[mainAxisExtent] 为空时生效，默认 1
    double childAspectRatio,

    /// 子项主轴长度；非空时优先于 [childAspectRatio]
    double? mainAxisExtent,
  }) = ListGridGridLayout;

  /// 瀑布流，对应 [SliverMasonryGrid]。
  ///
  /// 各列独立堆叠，子项高度可不同。列数规则同 [ListGridLayout.grid]：
  /// [maxCrossAxisExtent] 优先，否则用 [crossAxisCount]。
  const factory ListGridLayout.masonry({
    /// 固定列数；未设置 [maxCrossAxisExtent] 时使用，默认 1
    int crossAxisCount,

    /// 交叉轴最大宽度，据此自适应列数；设置后优先于 [crossAxisCount]
    double? maxCrossAxisExtent,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,
  }) = ListGridMasonryLayout;

  /// 按行对齐的不等高网格，对应 [SliverAlignedGrid]。
  ///
  /// 同一行取最高子项的高度作为行高，适合卡片高度不一但希望行对齐的场景。
  /// 列数规则同 [ListGridLayout.grid]。
  const factory ListGridLayout.aligned({
    /// 固定列数；未设置 [maxCrossAxisExtent] 时使用，默认 1
    int crossAxisCount,

    /// 交叉轴最大宽度，据此自适应列数；设置后优先于 [crossAxisCount]
    double? maxCrossAxisExtent,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,
  }) = ListGridAlignedLayout;

  /// 拼布图案网格，对应 [SliverQuiltedGridDelegate]。
  ///
  /// [pattern] 必传，描述每个 tile 占用的交叉轴 / 主轴 cell 数。
  /// 仅使用 [crossAxisCount]，不使用 `maxCrossAxisExtent`。
  const factory ListGridLayout.quilted({
    /// 交叉轴总 cell 数（图案坐标系）
    required int crossAxisCount,

    /// 拼布图案，循环排布
    required List<QuiltedGridTile> pattern,

    /// 图案重复方式，默认 [QuiltedGridRepeatPattern.same]
    QuiltedGridRepeatPattern repeatPattern,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,
  }) = ListGridQuiltedLayout;

  /// 阶梯图案网格，对应 [SliverStairedGridDelegate]。
  ///
  /// [pattern] 必传；列数由图案自身的交叉轴比例决定，无需 `crossAxisCount`。
  const factory ListGridLayout.staired({
    /// 阶梯图案
    required List<StairedGridTile> pattern,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,

    /// 每个 tile 主轴方向底部额外空间
    double tileBottomSpace,

    /// 是否从交叉轴反向开始排布
    bool startCrossAxisDirectionReversed,
  }) = ListGridStairedLayout;

  /// 编织图案网格，对应 [SliverWovenGridDelegate]。
  ///
  /// [pattern] 必传。列数规则：
  /// [maxCrossAxisExtent] 优先（extent 模式），否则用 [crossAxisCount]（count 模式）。
  const factory ListGridLayout.woven({
    /// 编织图案
    required List<WovenGridTile> pattern,

    /// 固定列数；未设置 [maxCrossAxisExtent] 时使用，默认 1
    int crossAxisCount,

    /// 交叉轴最大宽度；设置后走 extent 模式，优先于 [crossAxisCount]
    double? maxCrossAxisExtent,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,

    /// 每个 tile 主轴方向底部额外空间
    double tileBottomSpace,
  }) = ListGridWovenLayout;
}

/// [ListGridLayout.list] 的具体类型，可用于 `switch (layout)` 分支。
final class ListGridListLayout extends ListGridLayout {
  /// 创建列表布局；通常通过 [ListGridLayout.list] 构造。
  const ListGridListLayout({this.itemExtent, this.prototypeItem});

  /// 固定主轴长度，使用 [SliverFixedExtentList]；优先于 [prototypeItem]
  final double? itemExtent;

  /// 原型子项，使用 [SliverPrototypeExtentList]；[itemExtent] 优先
  final Widget? prototypeItem;

  @override
  String toString() => 'ListGridLayout.list';
}

/// [ListGridLayout.grid] 的具体类型，可用于 `switch (layout)` 分支。
final class ListGridGridLayout extends ListGridLayout {
  /// 创建官方网格布局；通常通过 [ListGridLayout.grid] 构造。
  const ListGridGridLayout({
    this.crossAxisCount = 1,
    this.maxCrossAxisExtent,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
  });

  /// 固定列数；未设置 [maxCrossAxisExtent] 时使用
  final int crossAxisCount;

  /// 交叉轴最大宽度，据此自适应列数；设置后优先于 [crossAxisCount]
  final double? maxCrossAxisExtent;

  /// 主轴方向间距
  final double mainAxisSpacing;

  /// 交叉轴方向间距
  final double crossAxisSpacing;

  /// 子项宽高比（宽 / 高）；[mainAxisExtent] 为空时生效
  final double childAspectRatio;

  /// 子项主轴长度；非空时优先于 [childAspectRatio]
  final double? mainAxisExtent;

  @override
  String toString() => 'ListGridLayout.grid';
}

/// [ListGridLayout.masonry] 的具体类型，可用于 `switch (layout)` 分支。
final class ListGridMasonryLayout extends ListGridLayout {
  /// 创建瀑布流布局；通常通过 [ListGridLayout.masonry] 构造。
  const ListGridMasonryLayout({
    this.crossAxisCount = 1,
    this.maxCrossAxisExtent,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  });

  /// 固定列数；未设置 [maxCrossAxisExtent] 时使用
  final int crossAxisCount;

  /// 交叉轴最大宽度，据此自适应列数；设置后优先于 [crossAxisCount]
  final double? maxCrossAxisExtent;

  /// 主轴方向间距
  final double mainAxisSpacing;

  /// 交叉轴方向间距
  final double crossAxisSpacing;

  @override
  String toString() => 'ListGridLayout.masonry';
}

/// [ListGridLayout.aligned] 的具体类型，可用于 `switch (layout)` 分支。
final class ListGridAlignedLayout extends ListGridLayout {
  /// 创建按行对齐布局；通常通过 [ListGridLayout.aligned] 构造。
  const ListGridAlignedLayout({
    this.crossAxisCount = 1,
    this.maxCrossAxisExtent,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  });

  /// 固定列数；未设置 [maxCrossAxisExtent] 时使用
  final int crossAxisCount;

  /// 交叉轴最大宽度，据此自适应列数；设置后优先于 [crossAxisCount]
  final double? maxCrossAxisExtent;

  /// 主轴方向间距
  final double mainAxisSpacing;

  /// 交叉轴方向间距
  final double crossAxisSpacing;

  @override
  String toString() => 'ListGridLayout.aligned';
}

/// [ListGridLayout.quilted] 的具体类型，可用于 `switch (layout)` 分支。
final class ListGridQuiltedLayout extends ListGridLayout {
  /// 创建拼布布局；通常通过 [ListGridLayout.quilted] 构造。
  const ListGridQuiltedLayout({
    required this.crossAxisCount,
    required this.pattern,
    this.repeatPattern = QuiltedGridRepeatPattern.same,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  });

  /// 交叉轴总 cell 数（图案坐标系）
  final int crossAxisCount;

  /// 拼布图案，循环排布
  final List<QuiltedGridTile> pattern;

  /// 图案重复方式
  final QuiltedGridRepeatPattern repeatPattern;

  /// 主轴方向间距
  final double mainAxisSpacing;

  /// 交叉轴方向间距
  final double crossAxisSpacing;

  @override
  String toString() => 'ListGridLayout.quilted';
}

/// [ListGridLayout.staired] 的具体类型，可用于 `switch (layout)` 分支。
final class ListGridStairedLayout extends ListGridLayout {
  /// 创建阶梯布局；通常通过 [ListGridLayout.staired] 构造。
  const ListGridStairedLayout({
    required this.pattern,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.tileBottomSpace = 0,
    this.startCrossAxisDirectionReversed = false,
  });

  /// 阶梯图案
  final List<StairedGridTile> pattern;

  /// 主轴方向间距
  final double mainAxisSpacing;

  /// 交叉轴方向间距
  final double crossAxisSpacing;

  /// 每个 tile 主轴方向底部额外空间
  final double tileBottomSpace;

  /// 是否从交叉轴反向开始排布
  final bool startCrossAxisDirectionReversed;

  @override
  String toString() => 'ListGridLayout.staired';
}

/// [ListGridLayout.woven] 的具体类型，可用于 `switch (layout)` 分支。
final class ListGridWovenLayout extends ListGridLayout {
  /// 创建编织布局；通常通过 [ListGridLayout.woven] 构造。
  const ListGridWovenLayout({
    required this.pattern,
    this.crossAxisCount = 1,
    this.maxCrossAxisExtent,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.tileBottomSpace = 0,
  });

  /// 编织图案
  final List<WovenGridTile> pattern;

  /// 固定列数；未设置 [maxCrossAxisExtent] 时使用
  final int crossAxisCount;

  /// 交叉轴最大宽度；设置后走 extent 模式，优先于 [crossAxisCount]
  final double? maxCrossAxisExtent;

  /// 主轴方向间距
  final double mainAxisSpacing;

  /// 交叉轴方向间距
  final double crossAxisSpacing;

  /// 每个 tile 主轴方向底部额外空间
  final double tileBottomSpace;

  @override
  String toString() => 'ListGridLayout.woven';
}

/// 组合 [SliverList]、[SliverGrid]、[SliverFixedExtentList]、[SliverPrototypeExtentList]、
/// [SliverMasonryGrid]、[SliverAlignedGrid] 以及 quilted / staired / woven 图案网格。
///
/// 布局参数通过 [layout] 传入，见 [ListGridLayout]。
class FlSliverListGrid extends StatelessWidget {
  /// 大量子组件时使用，按需构建并复用。
  ///
  /// 若同时传入 [separatorBuilder]，行为对齐 [ListView.separated]：
  /// 分隔符只出现在相邻子项之间（首尾无多余分隔符），
  /// 实际 child 数为 `max(0, itemCount * 2 - 1)`。
  const FlSliverListGrid.builder({
    super.key,
    required this.itemBuilder,
    this.separatorBuilder,
    this.itemCount,
    this.layout = const ListGridLayout.list(),
    this.findChildIndexCallback,
    this.findItemIndexCallback,
    this.semanticIndexCallback = kDefaultSemanticIndexCallback,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.placeholder,
    this.placeholderFill,
    this.placeholderFillOverscroll = false,
  }) : assert(
         findItemIndexCallback == null || findChildIndexCallback == null,
         'Cannot provide both findItemIndexCallback and findChildIndexCallback. '
         'Prefer findItemIndexCallback when using separatorBuilder.',
       ),
       assert(
         separatorBuilder == null || itemCount != null,
         'separatorBuilder 需要同时提供 itemCount（与 ListView.separated 一致）',
       ),
       assert(
         separatorBuilder == null || layout is ListGridListLayout,
         'separatorBuilder 仅支持 ListGridLayout.list（与 ListView.separated 一致）',
       ),
       children = null;

  /// 少量子组件时使用，直接传入 [children]，无需复用。
  const FlSliverListGrid.count({
    super.key,
    required this.children,
    this.layout = const ListGridLayout.list(),
    this.semanticIndexCallback = kDefaultSemanticIndexCallback,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.placeholder,
    this.placeholderFill,
    this.placeholderFillOverscroll = false,
  }) : assert(children != null),
       itemBuilder = null,
       itemCount = null,
       separatorBuilder = null,
       findChildIndexCallback = null,
       findItemIndexCallback = null;

  /// 子项构建器；[FlSliverListGrid.builder] 必传。
  ///
  /// 使用 [separatorBuilder] 时，[index] 范围为 `0 .. itemCount - 1`。
  final IndexedWidgetBuilder? itemBuilder;

  /// 分隔组件构建器，仅 [ListGridListLayout] 生效；用法对齐 [ListView.separated]。
  ///
  /// - 分隔符只插在子项之间：第 0 个在 item 0 之后，最后一个在末项之前
  /// - [index] 范围为 `0 .. itemCount - 2`
  /// - 必须同时提供 [itemCount]
  /// - 不可与 [ListGridListLayout.itemExtent] / [ListGridListLayout.prototypeItem] 同用；
  ///   若同时传入，运行时仍走 [SliverList]（忽略固定高度）
  final IndexedWidgetBuilder? separatorBuilder;

  /// 子项数量（不含分隔符）。使用 [separatorBuilder] 时必传。
  final int? itemCount;

  /// 子组件列表；[FlSliverListGrid.count] 必传
  final List<Widget>? children;

  /// 布局配置，默认 [ListGridLayout.list]
  final ListGridLayout layout;

  /// 根据 [Key] 查找 **child** 索引（含分隔符占位），透传给 [SliverChildBuilderDelegate]。
  ///
  /// 使用 [separatorBuilder] 时请改用 [findItemIndexCallback]（返回不含分隔符的 item 索引）。
  final ChildIndexGetter? findChildIndexCallback;

  /// 根据 [Key] 查找 **item** 索引（不含分隔符），对齐 [ListView.separated.findItemIndexCallback]。
  ///
  /// 使用 [separatorBuilder] 时库会将返回值映射为 `itemIndex * 2` 再交给 delegate。
  final ChildIndexGetter? findItemIndexCallback;

  /// 语义索引回调。使用 [separatorBuilder] 时，奇数位（分隔符）不参与语义索引，
  /// 偶数位会以 item 索引（`index ~/ 2`）调用本回调。
  final SemanticIndexCallback semanticIndexCallback;

  /// 是否自动包裹 AutomaticKeepAlive
  final bool addAutomaticKeepAlives;

  /// 是否自动包裹 RepaintBoundary
  final bool addRepaintBoundaries;

  /// 是否添加语义索引
  final bool addSemanticIndexes;

  /// [itemCount] 为 0 或 [children] 为空时的占位组件
  final Widget? placeholder;

  /// 为 true 时 [placeholder] 使用 [SliverFillRemaining] 铺满可视区域
  final bool? placeholderFill;

  /// [placeholderFill] 为 true 时，占位是否伸入 overscroll 区域，默认 false
  final bool placeholderFillOverscroll;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = children != null ? children!.isEmpty : itemCount == 0;
    if (isEmpty) {
      return placeholderFill == true
          ? SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: placeholderFillOverscroll,
              child: placeholder,
            )
          : SliverToBoxAdapter(child: placeholder);
    }

    // 与 ListView.separated 一致：仅 list 布局 + separatorBuilder 时交错插入分隔符
    final bool separate = layout is ListGridListLayout && separatorBuilder != null;
    late final SliverChildDelegate delegate;
    if (itemBuilder != null) {
      int? childCount = itemCount;
      IndexedWidgetBuilder item = itemBuilder!;
      SemanticIndexCallback indexCallback = semanticIndexCallback;
      ChildIndexGetter? childIndexGetter = findItemIndexCallback ?? findChildIndexCallback;
      if (separate) {
        item = (BuildContext context, int index) {
          final int itemIndex = index ~/ 2;
          if (index.isEven) {
            return itemBuilder!(context, itemIndex);
          }
          return separatorBuilder!(context, itemIndex);
        };
        childCount = _computeActualChildCount(itemCount!);
        indexCallback = (Widget widget, int index) {
          // 分隔符无语义索引；item 语义索引为 itemIndex（可再经 semanticIndexCallback 定制）
          return index.isEven ? semanticIndexCallback(widget, index ~/ 2) : null;
        };
        // findItemIndexCallback 返回 item 索引，需映射为含分隔符的 child 索引
        if (findItemIndexCallback != null) {
          childIndexGetter = (Key key) {
            final int? itemIndex = findItemIndexCallback!(key);
            return itemIndex == null ? null : itemIndex * 2;
          };
        }
      }
      delegate = SliverChildBuilderDelegate(
        item,
        childCount: childCount,
        findChildIndexCallback: childIndexGetter,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        semanticIndexCallback: indexCallback,
      );
    } else {
      delegate = SliverChildListDelegate(
        children!,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        semanticIndexCallback: semanticIndexCallback,
      );
    }

    switch (layout) {
      case ListGridListLayout(:final itemExtent, :final prototypeItem):
        // 有 separator 时必须用变高度 SliverList，不能用 FixedExtent / Prototype
        if (!separate && itemExtent != null) {
          return SliverFixedExtentList(delegate: delegate, itemExtent: itemExtent);
        }
        if (!separate && prototypeItem != null) {
          return SliverPrototypeExtentList(delegate: delegate, prototypeItem: prototypeItem);
        }
        return SliverList(delegate: delegate);
      case ListGridGridLayout(
        :final crossAxisCount,
        :final maxCrossAxisExtent,
        :final mainAxisSpacing,
        :final crossAxisSpacing,
        :final childAspectRatio,
        :final mainAxisExtent,
      ):
        final SliverGridDelegate gridDelegate = maxCrossAxisExtent != null
            ? SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisExtent: mainAxisExtent,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
                childAspectRatio: childAspectRatio,
                maxCrossAxisExtent: maxCrossAxisExtent,
              )
            : SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: mainAxisExtent,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
                childAspectRatio: childAspectRatio,
                crossAxisCount: crossAxisCount,
              );
        return SliverGrid(delegate: delegate, gridDelegate: gridDelegate);
      case ListGridMasonryLayout(
        :final crossAxisCount,
        :final maxCrossAxisExtent,
        :final mainAxisSpacing,
        :final crossAxisSpacing,
      ):
        return SliverMasonryGrid(
          delegate: delegate,
          gridDelegate: _simpleGridDelegate(crossAxisCount, maxCrossAxisExtent),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );
      case ListGridAlignedLayout(
        :final crossAxisCount,
        :final maxCrossAxisExtent,
        :final mainAxisSpacing,
        :final crossAxisSpacing,
      ):
        final IndexedWidgetBuilder alignedBuilder =
            itemBuilder ?? (BuildContext context, int index) => children![index];
        return SliverAlignedGrid(
          itemBuilder: alignedBuilder,
          itemCount: itemCount ?? children?.length,
          gridDelegate: _simpleGridDelegate(crossAxisCount, maxCrossAxisExtent),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: semanticIndexCallback,
        );
      case ListGridQuiltedLayout(
        :final crossAxisCount,
        :final pattern,
        :final repeatPattern,
        :final mainAxisSpacing,
        :final crossAxisSpacing,
      ):
        return SliverGrid(
          delegate: delegate,
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: crossAxisCount,
            pattern: pattern,
            repeatPattern: repeatPattern,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
          ),
        );
      case ListGridStairedLayout(
        :final pattern,
        :final mainAxisSpacing,
        :final crossAxisSpacing,
        :final tileBottomSpace,
        :final startCrossAxisDirectionReversed,
      ):
        return SliverGrid(
          delegate: delegate,
          gridDelegate: SliverStairedGridDelegate(
            pattern: pattern,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            tileBottomSpace: tileBottomSpace,
            startCrossAxisDirectionReversed: startCrossAxisDirectionReversed,
          ),
        );
      case ListGridWovenLayout(
        :final pattern,
        :final crossAxisCount,
        :final maxCrossAxisExtent,
        :final mainAxisSpacing,
        :final crossAxisSpacing,
        :final tileBottomSpace,
      ):
        final SliverGridDelegate wovenDelegate = maxCrossAxisExtent != null
            ? SliverWovenGridDelegate.extent(
                pattern: pattern,
                maxCrossAxisExtent: maxCrossAxisExtent,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
                tileBottomSpace: tileBottomSpace,
              )
            : SliverWovenGridDelegate.count(
                pattern: pattern,
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
                tileBottomSpace: tileBottomSpace,
              );
        return SliverGrid(delegate: delegate, gridDelegate: wovenDelegate);
    }
  }

  SliverSimpleGridDelegate _simpleGridDelegate(int crossAxisCount, double? maxCrossAxisExtent) =>
      maxCrossAxisExtent != null
      ? SliverSimpleGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: maxCrossAxisExtent)
      : SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount);

  int _computeActualChildCount(int itemCount) => math.max(0, itemCount * 2 - 1);
}
