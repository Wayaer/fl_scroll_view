import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 滑动类型设置 [physics]
/// AlwaysScrollableScrollPhysics() 总是可以滑动
/// NeverScrollableScrollPhysics() 禁止滚动
/// BouncingScrollPhysics()  内容超过一屏 有回弹效果
/// ClampingScrollPhysics()  包裹内容 不会有回弹
///
///
/// [FlSliverListGrid.builder]
/// [FlSliverListGrid.count]
///
/// [FlSliverListGrid]
/// [FlSliverListGrid.builder]
/// [FlSliverListGrid.count]
class FlScrollListGrid extends FlRefreshScrollView {
  const FlScrollListGrid({
    super.key,
    super.reverse = false,
    super.shrinkWrap,
    super.noScrollBehavior = false,
    super.primary,
    super.scrollDirection = Axis.vertical,
    super.clipBehavior = Clip.hardEdge,
    super.dragStartBehavior = DragStartBehavior.start,
    super.restorationId,
    super.cacheExtent,
    super.physics,
    super.padding,
    super.refreshConfig,
    super.controller,
    super.hitTestBehavior = HitTestBehavior.opaque,
    required this.sliver,
    this.header,
    this.footer,
  });

  FlScrollListGrid.builder({
    super.key,
    super.reverse = false,
    super.shrinkWrap,
    super.noScrollBehavior = false,
    super.primary,
    super.scrollDirection = Axis.vertical,
    super.clipBehavior = Clip.hardEdge,
    super.dragStartBehavior = DragStartBehavior.start,
    super.restorationId,
    super.cacheExtent,
    super.physics,
    super.padding,
    super.refreshConfig,
    super.controller,
    super.hitTestBehavior = HitTestBehavior.opaque,
    ChildIndexGetter? findChildIndexCallback,
    SemanticIndexCallback semanticIndexCallback = kDefaultSemanticIndexCallback,
    bool addAutomaticKeepALives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    GridStyle gridStyle = GridStyle.none,
    required IndexedWidgetBuilder itemBuilder,
    IndexedWidgetBuilder? separatorBuilder,
    int? itemCount,

    /// use [SliverFixedExtentList]、[itemExtent] 优先 [prototypeItem]
    double? itemExtent,

    /// use [SliverPrototypeExtentList]、[itemExtent] 优先 [prototypeItem]
    Widget? prototypeItem,

    /// 横轴子元素的数量 自适应最大像素
    /// use [SliverGridDelegateWithFixedCrossAxisCount] or [SliverSimpleGridDelegateWithFixedCrossAxisCount]
    int crossAxisCount = 1,

    /// 横轴元素最大像素 自适应列数
    /// use [SliverGridDelegateWithMaxCrossAxisExtent] or [SliverSimpleGridDelegateWithMaxCrossAxisExtent]
    double? maxCrossAxisExtent,

    /// 主轴方向子元素的间距
    double mainAxisSpacing = 0,

    /// 横轴方向子元素的间距
    double crossAxisSpacing = 0,

    /// 子元素在横轴长度和主轴长度的比例
    double childAspectRatio = 1,

    /// 子元素在主轴上的长度。[mainAxisExtent] 优先 [childAspectRatio]
    double? mainAxisExtent,

    /// itemCount==0 || children.isisEmpty 时 占位
    Widget? placeholder,

    /// [placeholderFill]=true,[placeholder] use [SliverFillRemaining]
    bool? placeholderFill,

    /// Indicates whether the child should stretch to fill the overscroll area
    /// created by certain scroll physics, such as iOS' default scroll physics.
    /// This flag is only relevant when [placeholderFill] is true.
    ///
    /// Defaults to false, meaning that the default behavior is for the child to
    /// maintain its size and not extend into the overscroll area.
    bool placeholderFillOverscroll = false,

    /// header
    this.header,

    /// footer
    this.footer,
  }) : sliver = [
          FlSliverListGrid.builder(
              placeholder: placeholder,
              placeholderFill: _placeholderFill(placeholderFill, physics),
              placeholderFillOverscroll: placeholderFillOverscroll,
              mainAxisExtent: mainAxisExtent,
              maxCrossAxisExtent: maxCrossAxisExtent,
              childAspectRatio: childAspectRatio,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              addSemanticIndexes: addSemanticIndexes,
              addRepaintBoundaries: addRepaintBoundaries,
              addAutomaticKeepALives: addAutomaticKeepALives,
              findChildIndexCallback: findChildIndexCallback,
              semanticIndexCallback: semanticIndexCallback,
              gridStyle: gridStyle,
              itemBuilder: itemBuilder,
              separatorBuilder: separatorBuilder,
              itemCount: itemCount,
              itemExtent: itemExtent,
              prototypeItem: prototypeItem)
        ];

  FlScrollListGrid.count({
    super.key,
    super.reverse = false,
    super.shrinkWrap,
    super.noScrollBehavior = false,
    super.primary,
    super.scrollDirection = Axis.vertical,
    super.clipBehavior = Clip.hardEdge,
    super.dragStartBehavior = DragStartBehavior.start,
    super.restorationId,
    super.cacheExtent,
    super.physics,
    super.padding,
    super.refreshConfig,
    super.controller,
    super.hitTestBehavior = HitTestBehavior.opaque,
    SemanticIndexCallback semanticIndexCallback = kDefaultSemanticIndexCallback,
    bool addAutomaticKeepALives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    GridStyle gridStyle = GridStyle.none,
    required List<Widget> children,

    /// use [SliverFixedExtentList]、[itemExtent] 优先 [prototypeItem]
    double? itemExtent,

    /// use [SliverPrototypeExtentList]、[itemExtent] 优先 [prototypeItem]
    Widget? prototypeItem,

    /// 横轴子元素的数量 自适应最大像素
    /// use [SliverGridDelegateWithFixedCrossAxisCount] or [SliverSimpleGridDelegateWithFixedCrossAxisCount]
    int crossAxisCount = 1,

    /// 横轴元素最大像素 自适应列数
    /// use [SliverGridDelegateWithMaxCrossAxisExtent] or [SliverSimpleGridDelegateWithMaxCrossAxisExtent]
    double? maxCrossAxisExtent,

    /// 主轴方向子元素的间距
    double mainAxisSpacing = 0,

    /// 横轴方向子元素的间距
    double crossAxisSpacing = 0,

    /// 子元素在横轴长度和主轴长度的比例
    /// [gridStyle] == [GridStyle.none] 生效
    double childAspectRatio = 1,

    /// 子元素在主轴上的长度。[mainAxisExtent] 优先 [childAspectRatio]
    /// [gridStyle] == [GridStyle.none] 生效
    double? mainAxisExtent,

    /// itemCount==0 || children.isisEmpty 时 占位
    Widget? placeholder,

    /// [placeholderFill]=true,[placeholder] use [SliverFillRemaining]
    bool? placeholderFill,

    /// Indicates whether the child should stretch to fill the overscroll area
    /// created by certain scroll physics, such as iOS' default scroll physics.
    /// This flag is only relevant when [placeholderFill] is true.
    ///
    /// Defaults to false, meaning that the default behavior is for the child to
    /// maintain its size and not extend into the overscroll area.
    bool placeholderFillOverscroll = false,

    /// header
    this.header,

    /// footer
    this.footer,
  }) : sliver = [
          FlSliverListGrid.count(
              semanticIndexCallback: semanticIndexCallback,
              placeholder: placeholder,
              placeholderFill: _placeholderFill(placeholderFill, physics),
              placeholderFillOverscroll: placeholderFillOverscroll,
              mainAxisExtent: mainAxisExtent,
              maxCrossAxisExtent: maxCrossAxisExtent,
              childAspectRatio: childAspectRatio,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              addSemanticIndexes: addSemanticIndexes,
              addRepaintBoundaries: addRepaintBoundaries,
              addAutomaticKeepALives: addAutomaticKeepALives,
              itemExtent: itemExtent,
              prototypeItem: prototypeItem,
              gridStyle: gridStyle,
              children: children)
        ];

  static bool _placeholderFill(bool? placeholderFill, ScrollPhysics? physics) {
    if (placeholderFill != null) return placeholderFill;
    return physics != const NeverScrollableScrollPhysics();
  }

  /// 添加多个 [Widget]
  final List<Widget> sliver;

  /// 添加头部 Sliver 组件
  final Widget? header;

  /// 添加底部 Sliver 组件
  final Widget? footer;

  @override
  List<Widget> get buildSlivers {
    final List<Widget> slivers = [];
    if (sliver.isNotEmpty) slivers.addAll(sliver);
    if (header != null) slivers.insert(0, header!);
    if (footer != null) slivers.add(footer!);
    return slivers;
  }
}
