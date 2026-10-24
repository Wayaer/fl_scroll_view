import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

/// 可刷新的滚动组件
/// 嵌套 sliver 家族组件
class FlRefreshScrollView extends StatelessWidget {
  const FlRefreshScrollView({
    super.key,
    this.refreshConfig,
    this.padding,
    this.slivers = const [],
    this.noScrollBehavior = false,
    this.shrinkWrap,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.anchor = 0.0,
    this.cacheExtent,
    this.controller,
    this.primary,
    this.physics,
    this.center,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.scrollBehavior,
    this.restorationId,
  });

  /// 拖拽时是否收起键盘
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// 状态恢复 id
  final String? restorationId;

  /// 超出边界时的裁剪方式
  final Clip clipBehavior;

  /// 拖拽起始行为
  final DragStartBehavior dragStartBehavior;

  /// 语义子节点数量
  final int? semanticChildCount;

  /// 预缓存范围（像素）
  final double? cacheExtent;

  /// 相对于视口的锚点，0.0～1.0
  final double anchor;

  /// 作为布局中心的子 sliver 的 [Key]
  final Key? center;

  /// 滚动行为
  final ScrollBehavior? scrollBehavior;

  /// 滚动物理效果
  final ScrollPhysics? physics;

  /// 是否使用 PrimaryScrollController
  final bool? primary;

  /// 滚动控制器
  final ScrollController? controller;

  /// 是否由内容决定自身尺寸；未传时，[physics] 为 [NeverScrollableScrollPhysics] 则为 true
  final bool? shrinkWrap;

  /// 是否反向滚动
  final bool reverse;

  /// 滚动方向
  final Axis scrollDirection;

  /// 命中测试行为，默认 [HitTestBehavior.opaque]
  final HitTestBehavior hitTestBehavior;

  /// sliver 列表
  final List<Widget> slivers;

  /// 为 true 时移除滚动水波纹等滚动行为
  final bool noScrollBehavior;

  /// 外边距（包在滚动视图外侧；[builder] 未设 itemCount 时列表主轴无限，不宜再用 SliverPadding 包 sliver）
  final EdgeInsetsGeometry? padding;

  /// 下拉刷新 / 上拉加载配置
  final FlEasyRefreshConfig? refreshConfig;

  bool _shrinkWrap(bool? shrinkWrap, ScrollPhysics? physics) {
    if (shrinkWrap != null) return shrinkWrap;
    return physics is NeverScrollableScrollPhysics;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildScroll(ScrollPhysics? scrollPhysics) {
      Widget scrollView = buildCustomScrollView(scrollPhysics);
      if (noScrollBehavior) {
        scrollView = ScrollConfiguration(behavior: const NoScrollBehavior(), child: scrollView);
      }
      return scrollView;
    }

    Widget child;
    if (refreshConfig != null) {
      child = FlEasyRefresh(
        config: refreshConfig!.copyWith(scrollController: controller),
        builder: (_, ScrollPhysics physics) => buildScroll(physics),
      );
    } else {
      child = buildScroll(physics);
    }
    if (padding != null) child = Padding(padding: padding!, child: child);
    return child;
  }

  List<Widget> get buildSlivers => slivers;

  CustomScrollView buildCustomScrollView(ScrollPhysics? physics) => CustomScrollView(
    scrollDirection: scrollDirection,
    reverse: reverse,
    controller: controller,
    primary: primary,
    scrollBehavior: scrollBehavior,
    shrinkWrap: _shrinkWrap(shrinkWrap, physics),
    center: center,
    anchor: anchor,
    scrollCacheExtent: cacheExtent == null ? null : ScrollCacheExtent.pixels(cacheExtent!),
    slivers: buildSlivers,
    semanticChildCount: semanticChildCount,
    dragStartBehavior: dragStartBehavior,
    keyboardDismissBehavior: keyboardDismissBehavior,
    restorationId: restorationId,
    clipBehavior: clipBehavior,
    physics: physics,
    hitTestBehavior: hitTestBehavior,
  );
}

class NoScrollBehavior extends ScrollBehavior {
  const NoScrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
