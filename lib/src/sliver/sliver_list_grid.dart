import 'dart:math' as math;

import 'package:fl_scroll_view/src/semantic_index.dart';
import 'package:fl_scroll_view/src/staggered/sliver_aligned_grid.dart';
import 'package:fl_scroll_view/src/staggered/sliver_masonry_grid.dart';
import 'package:fl_scroll_view/src/staggered/sliver_patterned_grids.dart';
import 'package:fl_scroll_view/src/staggered/sliver_quilted_grid.dart';
import 'package:fl_scroll_view/src/staggered/sliver_simple_grid_delegate.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// [FlSliverListLayout] / [FlScrollListLayout] 的布局配置（密封类）。
///
/// 一种样式对应一个工厂 + 一个具体类型，每种样式只暴露自己需要的参数：
///
/// 列表类：
/// - [ListLayout.list] — 线性列表，可选 [ListPlainLayout.separatorBuilder]
/// - [ListLayout.fixed] — 固定主轴长度
/// - [ListLayout.prototype] — 用原型推断主轴长度
///
/// 等分网格（[SliverGrid]）：
/// - [ListLayout.gridCount] — 固定列数
/// - [ListLayout.gridExtent] — 按最大交叉轴宽度自适应列数
///
/// 瀑布流（[SliverMasonryGrid]）：
/// - [ListLayout.masonryCount] — 固定列数
/// - [ListLayout.masonryExtent] — 按最大交叉轴宽度自适应列数
///
/// 行对齐（[SliverAlignedGrid]）：
/// - [ListLayout.alignedCount] — 固定列数
/// - [ListLayout.alignedExtent] — 按最大交叉轴宽度自适应列数
///
/// 图案网格：
/// - [ListLayout.quilted] — 拼布图案（[SliverQuiltedGridDelegate]）
/// - [ListLayout.staired] — 阶梯图案（[SliverStairedGridDelegate]）
/// - [ListLayout.wovenCount] — 编织图案，固定列数
/// - [ListLayout.wovenExtent] — 编织图案，按最大交叉轴宽度自适应列数
///
/// ```dart
/// // 线性列表
/// FlSliverListLayout.builder(
///   layout: const ListLayout.list(),
///   itemCount: 20,
///   itemBuilder: (_, i) => Text('$i'),
/// );
///
/// // 带分隔符
/// FlSliverListLayout.builder(
///   layout: ListLayout.list(separatorBuilder: (_, i) => const Divider()),
///   itemCount: 20,
///   itemBuilder: (_, i) => Text('$i'),
/// );
///
/// // 固定 3 列等分网格
/// FlSliverListLayout.builder(
///   layout: const ListLayout.gridCount(crossAxisCount: 3, mainAxisSpacing: 8),
///   itemCount: 20,
///   itemBuilder: (_, i) => Tile(i),
/// );
/// ```
sealed class ListLayout {
  const ListLayout();

  /// 线性列表，对应 [SliverList]。
  ///
  /// 传入 [separatorBuilder] 时行为对齐 [ListView.separated]：
  /// 分隔符只出现在相邻子项之间（首尾无多余分隔符），
  /// 实际 child 数为 `max(0, itemCount * 2 - 1)`。
  const factory ListLayout.list({IndexedWidgetBuilder? separatorBuilder}) = ListPlainLayout;

  /// 固定主轴长度，对应 [SliverFixedExtentList]。
  const factory ListLayout.fixed({required double itemExtent}) = ListFixedLayout;

  /// 用原型子项推断主轴长度，对应 [SliverPrototypeExtentList]。
  const factory ListLayout.prototype({required Widget prototypeItem}) = ListPrototypeLayout;

  /// 官方等分网格，固定列数，对应 [SliverGridDelegateWithFixedCrossAxisCount]。
  ///
  /// 若 [mainAxisExtent] 非空则固定子项主轴长度，否则用 [childAspectRatio]。
  const factory ListLayout.gridCount({
    /// 固定列数
    int crossAxisCount,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,

    /// 子项宽高比（宽 / 高），[mainAxisExtent] 为空时生效
    double childAspectRatio,

    /// 子项主轴长度；非空时优先于 [childAspectRatio]
    double? mainAxisExtent,
  }) = ListGridCountLayout;

  /// 官方等分网格，按交叉轴最大宽度自适应列数，
  /// 对应 [SliverGridDelegateWithMaxCrossAxisExtent]。
  const factory ListLayout.gridExtent({
    /// 交叉轴最大宽度
    required double maxCrossAxisExtent,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,

    /// 子项宽高比（宽 / 高），[mainAxisExtent] 为空时生效
    double childAspectRatio,

    /// 子项主轴长度；非空时优先于 [childAspectRatio]
    double? mainAxisExtent,
  }) = ListGridExtentLayout;

  /// 瀑布流，固定列数，对应 [SliverMasonryGrid]。
  ///
  /// 各列独立堆叠，子项高度可不同。
  const factory ListLayout.masonryCount({
    /// 固定列数
    int crossAxisCount,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,
  }) = ListMasonryCountLayout;

  /// 瀑布流，按交叉轴最大宽度自适应列数。
  const factory ListLayout.masonryExtent({
    /// 交叉轴最大宽度
    required double maxCrossAxisExtent,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,
  }) = ListMasonryExtentLayout;

  /// 按行对齐的不等高网格，固定列数，对应 [SliverAlignedGrid]。
  ///
  /// 同一行取最高子项的高度作为行高。
  const factory ListLayout.alignedCount({
    /// 固定列数
    int crossAxisCount,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,
  }) = ListAlignedCountLayout;

  /// 按行对齐的不等高网格，按交叉轴最大宽度自适应列数。
  const factory ListLayout.alignedExtent({
    /// 交叉轴最大宽度
    required double maxCrossAxisExtent,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,
  }) = ListAlignedExtentLayout;

  /// 拼布图案网格，对应 [SliverQuiltedGridDelegate]。
  ///
  /// [pattern] 描述每个 tile 占用的交叉轴 / 主轴 cell 数，循环排布。
  const factory ListLayout.quilted({
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
  }) = ListQuiltedLayout;

  /// 阶梯图案网格，对应 [SliverStairedGridDelegate]。
  ///
  /// 列数由图案自身的交叉轴比例决定。
  const factory ListLayout.staired({
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
  }) = ListStairedLayout;

  /// 编织图案网格，固定列数，对应 [SliverWovenGridDelegate.count]。
  const factory ListLayout.wovenCount({
    /// 编织图案
    required List<WovenGridTile> pattern,

    /// 固定列数
    int crossAxisCount,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,

    /// 每个 tile 主轴方向底部额外空间
    double tileBottomSpace,
  }) = ListWovenCountLayout;

  /// 编织图案网格，按交叉轴最大宽度自适应列数，
  /// 对应 [SliverWovenGridDelegate.extent]。
  const factory ListLayout.wovenExtent({
    /// 编织图案
    required List<WovenGridTile> pattern,

    /// 交叉轴最大宽度
    required double maxCrossAxisExtent,

    /// 主轴方向间距
    double mainAxisSpacing,

    /// 交叉轴方向间距
    double crossAxisSpacing,

    /// 每个 tile 主轴方向底部额外空间
    double tileBottomSpace,
  }) = ListWovenExtentLayout;
}

/// 带 [mainAxisSpacing] / [crossAxisSpacing] 的布局基类。
///
/// 除列表类与图案类以外的网格族都继承此基类，避免重复声明间距字段。
abstract class _SpacingLayout extends ListLayout {
  const _SpacingLayout({this.mainAxisSpacing = 0, this.crossAxisSpacing = 0});

  /// 主轴方向间距
  final double mainAxisSpacing;

  /// 交叉轴方向间距
  final double crossAxisSpacing;
}

/// [ListLayout.list] 的具体类型，可用于 `switch (layout)` 分支。
final class ListPlainLayout extends ListLayout {
  /// 创建线性列表布局；通常通过 [ListLayout.list] 构造。
  const ListPlainLayout({this.separatorBuilder});

  /// 分隔组件构建器，用法对齐 [ListView.separated]。
  ///
  /// - 分隔符只插在子项之间：第 0 个在 item 0 之后，最后一个在末项之前
  /// - [index] 范围为 `0 .. itemCount - 2`
  /// - 必须同时提供 `itemCount`
  final IndexedWidgetBuilder? separatorBuilder;

  @override
  String toString() => 'ListLayout.list';
}

/// [ListLayout.fixed] 的具体类型，可用于 `switch (layout)` 分支。
final class ListFixedLayout extends ListLayout {
  /// 创建固定主轴长度布局；通常通过 [ListLayout.fixed] 构造。
  const ListFixedLayout({required this.itemExtent});

  /// 固定主轴长度
  final double itemExtent;

  @override
  String toString() => 'ListLayout.fixed';
}

/// [ListLayout.prototype] 的具体类型，可用于 `switch (layout)` 分支。
final class ListPrototypeLayout extends ListLayout {
  /// 创建原型主轴长度布局；通常通过 [ListLayout.prototype] 构造。
  const ListPrototypeLayout({required this.prototypeItem});

  /// 原型子项，用其主轴长度作为所有子项的主轴长度
  final Widget prototypeItem;

  @override
  String toString() => 'ListLayout.prototype';
}

/// [ListLayout.gridCount] 的具体类型，可用于 `switch (layout)` 分支。
final class ListGridCountLayout extends _SpacingLayout {
  /// 创建固定列数等分网格；通常通过 [ListLayout.gridCount] 构造。
  const ListGridCountLayout({
    this.crossAxisCount = 1,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
  });

  /// 固定列数
  final int crossAxisCount;

  /// 子项宽高比（宽 / 高）；[mainAxisExtent] 为空时生效
  final double childAspectRatio;

  /// 子项主轴长度；非空时优先于 [childAspectRatio]
  final double? mainAxisExtent;

  @override
  String toString() => 'ListLayout.gridCount';
}

/// [ListLayout.gridExtent] 的具体类型，可用于 `switch (layout)` 分支。
final class ListGridExtentLayout extends _SpacingLayout {
  /// 创建自适应列数等分网格；通常通过 [ListLayout.gridExtent] 构造。
  const ListGridExtentLayout({
    required this.maxCrossAxisExtent,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
  });

  /// 交叉轴最大宽度
  final double maxCrossAxisExtent;

  /// 子项宽高比（宽 / 高）；[mainAxisExtent] 为空时生效
  final double childAspectRatio;

  /// 子项主轴长度；非空时优先于 [childAspectRatio]
  final double? mainAxisExtent;

  @override
  String toString() => 'ListLayout.gridExtent';
}

/// [ListLayout.masonryCount] 的具体类型，可用于 `switch (layout)` 分支。
final class ListMasonryCountLayout extends _SpacingLayout {
  /// 创建固定列数瀑布流；通常通过 [ListLayout.masonryCount] 构造。
  const ListMasonryCountLayout({this.crossAxisCount = 1, super.mainAxisSpacing, super.crossAxisSpacing});

  /// 固定列数
  final int crossAxisCount;

  @override
  String toString() => 'ListLayout.masonryCount';
}

/// [ListLayout.masonryExtent] 的具体类型，可用于 `switch (layout)` 分支。
final class ListMasonryExtentLayout extends _SpacingLayout {
  /// 创建自适应列数瀑布流；通常通过 [ListLayout.masonryExtent] 构造。
  const ListMasonryExtentLayout({
    required this.maxCrossAxisExtent,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
  });

  /// 交叉轴最大宽度
  final double maxCrossAxisExtent;

  @override
  String toString() => 'ListLayout.masonryExtent';
}

/// [ListLayout.alignedCount] 的具体类型，可用于 `switch (layout)` 分支。
final class ListAlignedCountLayout extends _SpacingLayout {
  /// 创建固定列数行对齐布局；通常通过 [ListLayout.alignedCount] 构造。
  const ListAlignedCountLayout({this.crossAxisCount = 1, super.mainAxisSpacing, super.crossAxisSpacing});

  /// 固定列数
  final int crossAxisCount;

  @override
  String toString() => 'ListLayout.alignedCount';
}

/// [ListLayout.alignedExtent] 的具体类型，可用于 `switch (layout)` 分支。
final class ListAlignedExtentLayout extends _SpacingLayout {
  /// 创建自适应列数行对齐布局；通常通过 [ListLayout.alignedExtent] 构造。
  const ListAlignedExtentLayout({
    required this.maxCrossAxisExtent,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
  });

  /// 交叉轴最大宽度
  final double maxCrossAxisExtent;

  @override
  String toString() => 'ListLayout.alignedExtent';
}

/// [ListLayout.quilted] 的具体类型，可用于 `switch (layout)` 分支。
final class ListQuiltedLayout extends _SpacingLayout {
  /// 创建拼布布局；通常通过 [ListLayout.quilted] 构造。
  const ListQuiltedLayout({
    required this.crossAxisCount,
    required this.pattern,
    this.repeatPattern = QuiltedGridRepeatPattern.same,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
  });

  /// 交叉轴总 cell 数（图案坐标系）
  final int crossAxisCount;

  /// 拼布图案，循环排布
  final List<QuiltedGridTile> pattern;

  /// 图案重复方式
  final QuiltedGridRepeatPattern repeatPattern;

  @override
  String toString() => 'ListLayout.quilted';
}

/// [ListLayout.staired] 的具体类型，可用于 `switch (layout)` 分支。
final class ListStairedLayout extends _SpacingLayout {
  /// 创建阶梯布局；通常通过 [ListLayout.staired] 构造。
  const ListStairedLayout({
    required this.pattern,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    this.tileBottomSpace = 0,
    this.startCrossAxisDirectionReversed = false,
  });

  /// 阶梯图案
  final List<StairedGridTile> pattern;

  /// 每个 tile 主轴方向底部额外空间
  final double tileBottomSpace;

  /// 是否从交叉轴反向开始排布
  final bool startCrossAxisDirectionReversed;

  @override
  String toString() => 'ListLayout.staired';
}

/// [ListLayout.wovenCount] 的具体类型，可用于 `switch (layout)` 分支。
final class ListWovenCountLayout extends _SpacingLayout {
  /// 创建固定列数编织布局；通常通过 [ListLayout.wovenCount] 构造。
  const ListWovenCountLayout({
    required this.pattern,
    this.crossAxisCount = 1,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    this.tileBottomSpace = 0,
  });

  /// 编织图案
  final List<WovenGridTile> pattern;

  /// 固定列数
  final int crossAxisCount;

  /// 每个 tile 主轴方向底部额外空间
  final double tileBottomSpace;

  @override
  String toString() => 'ListLayout.wovenCount';
}

/// [ListLayout.wovenExtent] 的具体类型，可用于 `switch (layout)` 分支。
final class ListWovenExtentLayout extends _SpacingLayout {
  /// 创建自适应列数编织布局；通常通过 [ListLayout.wovenExtent] 构造。
  const ListWovenExtentLayout({
    required this.pattern,
    required this.maxCrossAxisExtent,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    this.tileBottomSpace = 0,
  });

  /// 编织图案
  final List<WovenGridTile> pattern;

  /// 交叉轴最大宽度
  final double maxCrossAxisExtent;

  /// 每个 tile 主轴方向底部额外空间
  final double tileBottomSpace;

  @override
  String toString() => 'ListLayout.wovenExtent';
}

/// 组合 [SliverList]、[SliverGrid]、[SliverFixedExtentList]、[SliverPrototypeExtentList]、
/// [SliverMasonryGrid]、[SliverAlignedGrid] 以及 quilted / staired / woven 图案网格。
///
/// 布局参数通过 [layout] 传入，见 [ListLayout]。
class FlSliverListLayout extends StatelessWidget {
  /// 大量子组件时使用，按需构建并复用。
  ///
  /// [ListLayout.list] 上带 `separatorBuilder` 时，行为对齐 [ListView.separated]。
  const FlSliverListLayout.builder({
    super.key,
    required this.itemBuilder,
    this.itemCount,
    this.layout = const ListLayout.list(),
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
         layout is! ListAlignedCountLayout || (findChildIndexCallback == null && findItemIndexCallback == null),
         'Aligned 布局按行批量构建，不支持 findChildIndexCallback / findItemIndexCallback',
       ),
       assert(
         layout is! ListAlignedExtentLayout || (findChildIndexCallback == null && findItemIndexCallback == null),
         'Aligned 布局按行批量构建，不支持 findChildIndexCallback / findItemIndexCallback',
       ),
       children = null;

  /// 少量子组件时使用，直接传入 [children]，无需复用。
  const FlSliverListLayout.count({
    super.key,
    required this.children,
    this.layout = const ListLayout.list(),
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
       findChildIndexCallback = null,
       findItemIndexCallback = null;

  /// 子项构建器；[FlSliverListLayout.builder] 必传。
  ///
  /// [ListPlainLayout.separatorBuilder] 非空时，[index] 范围为 `0 .. itemCount - 1`。
  final IndexedWidgetBuilder? itemBuilder;

  /// 子项数量（不含分隔符）。
  final int? itemCount;

  /// 子组件列表；[FlSliverListLayout.count] 必传
  final List<Widget>? children;

  /// 布局配置，默认 [ListLayout.list]
  final ListLayout layout;

  /// 根据 [Key] 查找 **child** 索引（含分隔符占位），透传给 [SliverChildBuilderDelegate]。
  ///
  /// [ListPlainLayout.separatorBuilder] 非空时请改用 [findItemIndexCallback]
  /// （返回不含分隔符的 item 索引）。Aligned 布局不支持该回调。
  final ChildIndexGetter? findChildIndexCallback;

  /// 根据 [Key] 查找 **item** 索引（不含分隔符），对齐 [ListView.separated.findItemIndexCallback]。
  ///
  /// [ListPlainLayout.separatorBuilder] 非空时，库会将返回值映射为 `itemIndex * 2`
  /// 再交给 delegate。Aligned 布局不支持该回调。
  final ChildIndexGetter? findItemIndexCallback;

  /// 语义索引回调。
  ///
  /// [ListPlainLayout.separatorBuilder] 非空时，奇数位（分隔符）不参与语义索引，
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
      if (placeholderFill != true) return SliverToBoxAdapter(child: placeholder);
      return SliverLayoutBuilder(
        builder: (BuildContext context, SliverConstraints constraints) {
          // shrinkWrap / 无界主轴下 SliverFillRemaining 会因无限高度触发断言
          if (!constraints.viewportMainAxisExtent.isFinite) return SliverToBoxAdapter(child: placeholder);
          return SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: placeholderFillOverscroll,
            child: placeholder,
          );
        },
      );
    }

    // 与 ListView.separated 一致：仅 ListPlainLayout + separatorBuilder 时交错插入分隔符
    final ListLayout currentLayout = layout;
    final IndexedWidgetBuilder? separatorBuilder = currentLayout is ListPlainLayout
        ? currentLayout.separatorBuilder
        : null;
    // children 模式忽略 separatorBuilder，无需 itemCount
    assert(
      separatorBuilder == null || itemBuilder == null || itemCount != null,
      'separatorBuilder 需要同时提供 itemCount（与 ListView.separated 一致）',
    );
    final bool separate = separatorBuilder != null;
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
          return separatorBuilder(context, itemIndex);
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
      case ListPlainLayout():
        return SliverList(delegate: delegate);
      case ListFixedLayout(:final itemExtent):
        return SliverFixedExtentList(delegate: delegate, itemExtent: itemExtent);
      case ListPrototypeLayout(:final prototypeItem):
        return SliverPrototypeExtentList(delegate: delegate, prototypeItem: prototypeItem);
      case ListGridCountLayout(
        :final crossAxisCount,
        :final mainAxisSpacing,
        :final crossAxisSpacing,
        :final childAspectRatio,
        :final mainAxisExtent,
      ):
        return SliverGrid(
          delegate: delegate,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
            crossAxisCount: crossAxisCount,
          ),
        );
      case ListGridExtentLayout(
        :final maxCrossAxisExtent,
        :final mainAxisSpacing,
        :final crossAxisSpacing,
        :final childAspectRatio,
        :final mainAxisExtent,
      ):
        return SliverGrid(
          delegate: delegate,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
            maxCrossAxisExtent: maxCrossAxisExtent,
          ),
        );
      case ListMasonryCountLayout(:final crossAxisCount, :final mainAxisSpacing, :final crossAxisSpacing):
        return SliverMasonryGrid(
          delegate: delegate,
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );
      case ListMasonryExtentLayout(:final maxCrossAxisExtent, :final mainAxisSpacing, :final crossAxisSpacing):
        return SliverMasonryGrid(
          delegate: delegate,
          gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: maxCrossAxisExtent),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );
      case ListAlignedCountLayout(:final crossAxisCount, :final mainAxisSpacing, :final crossAxisSpacing):
        return SliverAlignedGrid(
          itemBuilder: _alignedItemBuilder,
          itemCount: itemCount ?? children?.length,
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: semanticIndexCallback,
        );
      case ListAlignedExtentLayout(:final maxCrossAxisExtent, :final mainAxisSpacing, :final crossAxisSpacing):
        return SliverAlignedGrid(
          itemBuilder: _alignedItemBuilder,
          itemCount: itemCount ?? children?.length,
          gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: maxCrossAxisExtent),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: semanticIndexCallback,
        );
      case ListQuiltedLayout(
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
      case ListStairedLayout(
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
      case ListWovenCountLayout(
        :final pattern,
        :final crossAxisCount,
        :final mainAxisSpacing,
        :final crossAxisSpacing,
        :final tileBottomSpace,
      ):
        return SliverGrid(
          delegate: delegate,
          gridDelegate: SliverWovenGridDelegate.count(
            pattern: pattern,
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            tileBottomSpace: tileBottomSpace,
          ),
        );
      case ListWovenExtentLayout(
        :final pattern,
        :final maxCrossAxisExtent,
        :final mainAxisSpacing,
        :final crossAxisSpacing,
        :final tileBottomSpace,
      ):
        return SliverGrid(
          delegate: delegate,
          gridDelegate: SliverWovenGridDelegate.extent(
            pattern: pattern,
            maxCrossAxisExtent: maxCrossAxisExtent,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            tileBottomSpace: tileBottomSpace,
          ),
        );
      case _SpacingLayout():
        throw StateError('Unreachable: _SpacingLayout 为抽象基类，不应被实例化');
    }
  }

  Widget _alignedItemBuilder(BuildContext context, int index) =>
      itemBuilder != null ? itemBuilder!(context, index) : children![index];

  int _computeActualChildCount(int itemCount) => math.max(0, itemCount * 2 - 1);
}
