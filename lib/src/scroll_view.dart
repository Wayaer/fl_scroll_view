import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 可刷新的滚动组件
/// 嵌套 sliver 家族组件
class RefreshScrollView extends StatelessWidget {
  const RefreshScrollView(
      {super.key,
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
      this.scrollBehavior,
      this.restorationId});

  /// CustomScrollView
  /// keyboardDismissBehavior
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// restorationId
  final String? restorationId;

  /// clipBehavior
  final Clip clipBehavior;

  /// dragStartBehavior
  final DragStartBehavior dragStartBehavior;

  /// semanticChildCount
  final int? semanticChildCount;

  /// cacheExtent
  final double? cacheExtent;

  /// anchor
  final double anchor;

  /// center
  final Key? center;

  /// scrollBehavior
  final ScrollBehavior? scrollBehavior;

  /// physics
  final ScrollPhysics? physics;

  /// primary
  final bool? primary;

  /// controller
  final ScrollController? controller;

  /// shrinkWrap
  final bool? shrinkWrap;

  /// reverse
  final bool reverse;

  /// scrollDirection
  final Axis scrollDirection;

  /// slivers
  final List<Widget> slivers;

  /// Extra parameters
  /// noScrollBehavior
  final bool noScrollBehavior;

  /// padding
  final EdgeInsetsGeometry? padding;

  /// refreshConfig
  final RefreshConfig? refreshConfig;

  /// getShrinkWrap
  bool _shrinkWrap(bool? shrinkWrap, ScrollPhysics? physics) {
    if (shrinkWrap != null) return shrinkWrap;
    return physics == const NeverScrollableScrollPhysics();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = buildCustomScrollView(physics);
    if (noScrollBehavior) {
      widget = ScrollConfiguration(behavior: NoScrollBehavior(), child: widget);
    }
    if (refreshConfig != null) {
      widget = EasyRefreshed(
          config: refreshConfig!.copyWith(scrollController: controller),
          builder: (_, ScrollPhysics physics) =>
              buildCustomScrollView(physics));
    }
    if (padding != null) widget = Padding(padding: padding!, child: widget);
    return widget;
  }

  List<Widget> get buildSlivers => slivers;

  CustomScrollView buildCustomScrollView(ScrollPhysics? physics) =>
      CustomScrollView(
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          scrollBehavior: scrollBehavior,
          shrinkWrap: _shrinkWrap(shrinkWrap, physics),
          center: center,
          anchor: anchor,
          cacheExtent: cacheExtent,
          slivers: buildSlivers,
          semanticChildCount: semanticChildCount,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
          physics: physics);
}

class NoScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}
