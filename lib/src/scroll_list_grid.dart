import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:fl_scroll_view/src/semantic_index.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

/// 带下拉刷新的列表 / 网格滚动组件，内部组合 [FlSliverListGrid]。
///
/// 常用构造：
/// - [FlScrollListGrid]：自行传入多个 sliver
/// - [FlScrollListGrid.builder]：大量数据，按需构建
/// - [FlScrollListGrid.count]：少量数据，直接传 [children]
///
/// [physics] 常用取值：
/// - [AlwaysScrollableScrollPhysics]：始终可滚动
/// - [NeverScrollableScrollPhysics]：禁止滚动
/// - [BouncingScrollPhysics]：内容超一屏时有回弹
/// - [ClampingScrollPhysics]：无回弹
///
/// 传入 [refreshConfig] 时，实际 physics 由 EasyRefresh 接管，
/// [physics] 仅用于推导 [shrinkWrap] 与 [placeholderFill] 的默认值。
class FlScrollListGrid extends FlRefreshScrollView {
  /// 自行组合多个 sliver，可额外加 [header] / [footer]。
  const FlScrollListGrid({
    super.key,

    /// 是否反向滚动
    super.reverse = false,

    /// 是否由内容决定自身尺寸；未传时，[physics] 为 [NeverScrollableScrollPhysics] 则为 true
    super.shrinkWrap,

    /// 为 true 时移除滚动水波纹等滚动行为
    super.noScrollBehavior = false,

    /// 是否使用 PrimaryScrollController
    super.primary,

    /// 滚动方向
    super.scrollDirection = Axis.vertical,

    /// 超出边界时的裁剪方式
    super.clipBehavior = Clip.hardEdge,

    /// 拖拽起始行为
    super.dragStartBehavior = DragStartBehavior.start,

    /// 状态恢复 id
    super.restorationId,

    /// 预缓存范围（像素）
    super.cacheExtent,

    /// 滚动物理效果
    super.physics,

    /// 外边距
    super.padding,

    /// 下拉刷新 / 上拉加载配置
    super.refreshConfig,

    /// 滚动控制器
    super.controller,

    /// 命中测试行为，默认 [HitTestBehavior.opaque]
    super.hitTestBehavior = HitTestBehavior.opaque,

    /// 中间的 sliver 列表
    required this.sliver,

    /// 顶部 sliver，插在 [sliver] 之前
    this.header,

    /// 底部 sliver，接在 [sliver] 之后
    this.footer,
  });

  /// 大量数据时使用，内部为 [FlSliverListGrid.builder]。
  FlScrollListGrid.builder({
    super.key,

    /// 是否反向滚动
    super.reverse = false,

    /// 是否由内容决定自身尺寸；未传时，[physics] 为 [NeverScrollableScrollPhysics] 则为 true
    super.shrinkWrap,

    /// 为 true 时移除滚动水波纹等滚动行为
    super.noScrollBehavior = false,

    /// 是否使用 PrimaryScrollController
    super.primary,

    /// 滚动方向
    super.scrollDirection = Axis.vertical,

    /// 超出边界时的裁剪方式
    super.clipBehavior = Clip.hardEdge,

    /// 拖拽起始行为
    super.dragStartBehavior = DragStartBehavior.start,

    /// 状态恢复 id
    super.restorationId,

    /// 预缓存范围（像素）
    super.cacheExtent,

    /// 滚动物理效果
    super.physics,

    /// 外边距
    super.padding,

    /// 下拉刷新 / 上拉加载配置
    super.refreshConfig,

    /// 滚动控制器
    super.controller,

    /// 命中测试行为，默认 [HitTestBehavior.opaque]
    super.hitTestBehavior = HitTestBehavior.opaque,

    /// 根据 [Key] 查找 child 索引（含分隔符）；与 [findItemIndexCallback] 互斥
    ChildIndexGetter? findChildIndexCallback,

    /// 根据 [Key] 查找 item 索引（不含分隔符），对齐 [ListView.separated]
    ChildIndexGetter? findItemIndexCallback,

    /// 语义索引回调
    SemanticIndexCallback semanticIndexCallback = kDefaultSemanticIndexCallback,

    /// 是否自动包裹 AutomaticKeepAlive
    bool addAutomaticKeepAlives = true,

    /// 是否自动包裹 RepaintBoundary
    bool addRepaintBoundaries = true,

    /// 是否添加语义索引
    bool addSemanticIndexes = true,

    /// 布局配置，默认列表
    ListGridLayout layout = const ListGridLayout.list(),

    /// 子项构建器
    required IndexedWidgetBuilder itemBuilder,

    /// 分隔组件构建器，仅 [ListGridListLayout] 生效；用法对齐 [ListView.separated]
    IndexedWidgetBuilder? separatorBuilder,

    /// 子项数量（不含分隔符）；使用 [separatorBuilder] 时必传
    int? itemCount,

    /// [itemCount] 为 0 时的占位组件
    Widget? placeholder,

    /// 为 true 时 [placeholder] 使用 [SliverFillRemaining] 铺满可视区域。
    ///
    /// 未显式传入时：
    /// - [shrinkWrap] 为 true：false（无界主轴下 SliverFillRemaining 会断言）；
    /// - 否则：[physics] 为 [NeverScrollableScrollPhysics] 时 false，其余为 true
    bool? placeholderFill,

    /// [placeholderFill] 为 true 时，占位是否伸入 overscroll 区域，默认 false
    bool placeholderFillOverscroll = false,

    /// 顶部 sliver
    this.header,

    /// 底部 sliver
    this.footer,
  }) : sliver = [
         FlSliverListGrid.builder(
           placeholder: placeholder,
           placeholderFill: _placeholderFill(placeholderFill, physics, shrinkWrap),
           placeholderFillOverscroll: placeholderFillOverscroll,
           addSemanticIndexes: addSemanticIndexes,
           addRepaintBoundaries: addRepaintBoundaries,
           addAutomaticKeepAlives: addAutomaticKeepAlives,
           findChildIndexCallback: findChildIndexCallback,
           findItemIndexCallback: findItemIndexCallback,
           semanticIndexCallback: semanticIndexCallback,
           layout: layout,
           itemBuilder: itemBuilder,
           separatorBuilder: separatorBuilder,
           itemCount: itemCount,
         ),
       ];

  /// 少量数据时使用，内部为 [FlSliverListGrid.count]。
  FlScrollListGrid.count({
    super.key,

    /// 是否反向滚动
    super.reverse = false,

    /// 是否由内容决定自身尺寸；未传时，[physics] 为 [NeverScrollableScrollPhysics] 则为 true
    super.shrinkWrap,

    /// 为 true 时移除滚动水波纹等滚动行为
    super.noScrollBehavior = false,

    /// 是否使用 PrimaryScrollController
    super.primary,

    /// 滚动方向
    super.scrollDirection = Axis.vertical,

    /// 超出边界时的裁剪方式
    super.clipBehavior = Clip.hardEdge,

    /// 拖拽起始行为
    super.dragStartBehavior = DragStartBehavior.start,

    /// 状态恢复 id
    super.restorationId,

    /// 预缓存范围（像素）
    super.cacheExtent,

    /// 滚动物理效果
    super.physics,

    /// 外边距
    super.padding,

    /// 下拉刷新 / 上拉加载配置
    super.refreshConfig,

    /// 滚动控制器
    super.controller,

    /// 命中测试行为，默认 [HitTestBehavior.opaque]
    super.hitTestBehavior = HitTestBehavior.opaque,

    /// 语义索引回调
    SemanticIndexCallback semanticIndexCallback = kDefaultSemanticIndexCallback,

    /// 是否自动包裹 AutomaticKeepAlive
    bool addAutomaticKeepAlives = true,

    /// 是否自动包裹 RepaintBoundary
    bool addRepaintBoundaries = true,

    /// 是否添加语义索引
    bool addSemanticIndexes = true,

    /// 布局配置，默认列表
    ListGridLayout layout = const ListGridLayout.list(),

    /// 子组件列表
    required List<Widget> children,

    /// [children] 为空时的占位组件
    Widget? placeholder,

    /// 为 true 时 [placeholder] 使用 [SliverFillRemaining] 铺满可视区域。
    ///
    /// 未显式传入时：
    /// - [shrinkWrap] 为 true：false（无界主轴下 SliverFillRemaining 会断言）；
    /// - 否则：[physics] 为 [NeverScrollableScrollPhysics] 时 false，其余为 true
    bool? placeholderFill,

    /// [placeholderFill] 为 true 时，占位是否伸入 overscroll 区域，默认 false
    bool placeholderFillOverscroll = false,

    /// 顶部 sliver
    this.header,

    /// 底部 sliver
    this.footer,
  }) : sliver = [
         FlSliverListGrid.count(
           semanticIndexCallback: semanticIndexCallback,
           placeholder: placeholder,
           placeholderFill: _placeholderFill(placeholderFill, physics, shrinkWrap),
           placeholderFillOverscroll: placeholderFillOverscroll,
           addSemanticIndexes: addSemanticIndexes,
           addRepaintBoundaries: addRepaintBoundaries,
           addAutomaticKeepAlives: addAutomaticKeepAlives,
           layout: layout,
           children: children,
         ),
       ];

  static bool _placeholderFill(bool? placeholderFill, ScrollPhysics? physics, bool? shrinkWrap) {
    if (placeholderFill != null) return placeholderFill;
    if (shrinkWrap == true) return false;
    return physics is! NeverScrollableScrollPhysics;
  }

  /// 中间的 sliver 列表
  final List<Widget> sliver;

  /// 顶部 sliver，插在 [sliver] 之前
  final Widget? header;

  /// 底部 sliver，接在 [sliver] 之后
  final Widget? footer;

  @override
  List<Widget> get buildSlivers => [?header, ...sliver, ?footer];
}
