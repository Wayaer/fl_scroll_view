import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

enum GridStyle {
  none,
  masonry,
  aligned,
}

int kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;

/// 组合[SliverList]、[SliverGrid]、[SliverFixedExtentList]、[SliverPrototypeExtentList]、[SliverMasonryGrid]、[SliverAlignedGrid]
class FlSliverListGrid extends StatelessWidget {
  /// 大量子组件,需要复用
  const FlSliverListGrid.builder({
    super.key,
    required this.itemBuilder,
    this.separatorBuilder,
    this.itemCount,
    this.gridStyle = GridStyle.none,
    this.crossAxisCount = 1,
    this.maxCrossAxisExtent,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
    this.findChildIndexCallback,
    this.semanticIndexCallback = kDefaultSemanticIndexCallback,
    this.itemExtent,
    this.prototypeItem,
    this.addAutomaticKeepALives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.placeholder,
    this.placeholderFill,
    this.placeholderFillOverscroll = false,
  }) : children = null;

  /// 少量子组件可使用 children 无需复用
  const FlSliverListGrid.count({
    super.key,
    required this.children,
    this.gridStyle = GridStyle.none,
    this.crossAxisCount = 1,
    this.maxCrossAxisExtent,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
    this.semanticIndexCallback = kDefaultSemanticIndexCallback,
    this.itemExtent,
    this.prototypeItem,
    this.addAutomaticKeepALives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.placeholder,
    this.placeholderFill,
    this.placeholderFillOverscroll = false,
  })  : assert(children != null),
        assert(gridStyle != GridStyle.aligned),
        itemBuilder = null,
        itemCount = null,
        separatorBuilder = null,
        findChildIndexCallback = null;

  /// 大量子组件,需要复用
  final IndexedWidgetBuilder? itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final int? itemCount;

  /// 少量子组件可使用 children 无需复用
  final List<Widget>? children;

  /// 横轴子元素的数量 自适应最大像素
  /// use [SliverGridDelegateWithFixedCrossAxisCount] or [SliverSimpleGridDelegateWithFixedCrossAxisCount]
  final int crossAxisCount;

  /// 横轴元素最大像素 自适应列数
  /// use [SliverGridDelegateWithMaxCrossAxisExtent] or [SliverSimpleGridDelegateWithMaxCrossAxisExtent]
  final double? maxCrossAxisExtent;

  /// 主轴方向子元素的间距
  final double mainAxisSpacing;

  /// 横轴方向子元素的间距
  final double crossAxisSpacing;

  /// 子元素在横轴长度和主轴长度的比例
  /// [gridStyle] == [GridStyle.none] 生效
  final double childAspectRatio;

  /// 子元素在主轴上的长度。[mainAxisExtent] 优先 [childAspectRatio]
  /// [gridStyle] == [GridStyle.none] 生效
  final double? mainAxisExtent;

  /// use [SliverFixedExtentList]、[itemExtent] 优先 [prototypeItem]
  final double? itemExtent;

  /// use [SliverPrototypeExtentList]、[itemExtent] 优先 [prototypeItem]
  final Widget? prototypeItem;

  final ChildIndexGetter? findChildIndexCallback;
  final SemanticIndexCallback semanticIndexCallback;
  final bool addAutomaticKeepALives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;

  /// itemCount==0 || children.isisEmpty 时 占位
  final Widget? placeholder;

  /// [placeholderFill]=true,[placeholder] use [SliverFillRemaining]
  final bool? placeholderFill;

  /// Indicates whether the child should stretch to fill the overscroll area
  /// created by certain scroll physics, such as iOS' default scroll physics.
  /// This flag is only relevant when [placeholderFill] is true.
  ///
  /// Defaults to false, meaning that the default behavior is for the child to
  /// maintain its size and not extend into the overscroll area.
  final bool placeholderFillOverscroll;

  /// [GridStyle] grid 样式
  final GridStyle gridStyle;

  @override
  Widget build(BuildContext context) {
    if ((children ?? []).isEmpty && itemCount == 0) {
      return placeholderFill == true
          ? SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: placeholderFillOverscroll,
              child: placeholder)
          : SliverToBoxAdapter(child: placeholder);
    }
    late SliverChildDelegate delegate;
    if (itemBuilder != null) {
      int? childCount = itemCount;
      IndexedWidgetBuilder item = itemBuilder!;
      if (separatorBuilder != null && childCount != null) {
        item = (BuildContext context, int index) {
          final int itemIndex = index ~/ 2;
          return index.isEven
              ? itemBuilder!(context, itemIndex)
              : separatorBuilder!(context, itemIndex);
        };
        childCount = _computeActualChildCount(childCount);
      }
      delegate = SliverChildBuilderDelegate(item,
          childCount: childCount,
          findChildIndexCallback: findChildIndexCallback,
          addAutomaticKeepAlives: addAutomaticKeepALives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: semanticIndexCallback);
    } else if (children != null) {
      delegate = SliverChildListDelegate(children!,
          addAutomaticKeepAlives: addAutomaticKeepALives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: semanticIndexCallback);
    }

    if (crossAxisCount > 1 || maxCrossAxisExtent != null) {
      SliverSimpleGridDelegate? simpleGridDelegate;
      SliverGridDelegate? gridDelegate;
      if (maxCrossAxisExtent != null) {
        simpleGridDelegate = SliverSimpleGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent!);
        gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
            maxCrossAxisExtent: maxCrossAxisExtent!);
      } else if (crossAxisCount > 1) {
        simpleGridDelegate = SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount);
        gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
            crossAxisCount: crossAxisCount);
      }
      switch (gridStyle) {
        case GridStyle.none:
          return SliverGrid(delegate: delegate, gridDelegate: gridDelegate!);
        case GridStyle.masonry:
          return SliverMasonryGrid(
              delegate: delegate,
              gridDelegate: simpleGridDelegate!,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing);
        case GridStyle.aligned:
          return SliverAlignedGrid(
              itemBuilder: itemBuilder!,
              itemCount: itemCount,
              gridDelegate: simpleGridDelegate!,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              addAutomaticKeepAlives: addAutomaticKeepALives,
              addRepaintBoundaries: addRepaintBoundaries);
      }
    } else if (itemExtent != null) {
      return SliverFixedExtentList(delegate: delegate, itemExtent: itemExtent!);
    } else if (prototypeItem != null) {
      return SliverPrototypeExtentList(
          delegate: delegate, prototypeItem: prototypeItem!);
    } else {
      return SliverList(delegate: delegate);
    }
  }

  int _computeActualChildCount(int itemCount) => math.max(0, itemCount * 2 - 1);
}
