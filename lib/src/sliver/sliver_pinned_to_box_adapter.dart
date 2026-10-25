import 'dart:math' as math;

import 'package:fl_scroll_view/src/sliver/overscroll_shift.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

/// 固定在视口顶部的 header，语义行为对齐 Flutter 的 [PinnedHeaderSliver]。
class FlSliverPinnedToBoxAdapter extends StatelessWidget {
  const FlSliverPinnedToBoxAdapter({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) => _FlSliverPinnedToBoxAdapter(
    child: FlOverscrollShift(child: Semantics(container: true, explicitChildNodes: true, child: child)),
  );
}

class _FlSliverPinnedToBoxAdapter extends SingleChildRenderObjectWidget {
  const _FlSliverPinnedToBoxAdapter({super.child});

  @override
  RenderSliverSingleBoxAdapter createRenderObject(BuildContext context) => _FlRenderSliverPinnedToBoxAdapter();
}

class _FlRenderSliverPinnedToBoxAdapter extends RenderSliverSingleBoxAdapter {
  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    assert(childExtent != null);
    final double effectiveRemainingPaintExtent = math.max(0, constraints.remainingPaintExtent - constraints.overlap);
    final double layoutExtent = (childExtent! - constraints.scrollOffset).clamp(0.0, effectiveRemainingPaintExtent);
    geometry = SliverGeometry(
      scrollExtent: childExtent!,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent!, effectiveRemainingPaintExtent),
      layoutExtent: layoutExtent,
      maxPaintExtent: childExtent!,
      maxScrollObstructionExtent: childExtent!,
      cacheExtent: calculateCacheOffset(constraints, from: 0.0, to: childExtent!),
      hasVisualOverflow: true,
    );
    setChildParentData(child!, constraints, geometry);
  }

  @override
  void setChildParentData(RenderObject child, SliverConstraints constraints, SliverGeometry? geometry) {
    final SliverPhysicalParentData? childParentData = child.parentData as SliverPhysicalParentData?;
    Offset offset = Offset.zero;
    switch (applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        offset += Offset(0.0, geometry!.paintExtent - childMainAxisPosition(child as RenderBox) - childExtent!);
        break;
      case AxisDirection.down:
        offset += Offset(0.0, childMainAxisPosition(child as RenderBox));
        break;
      case AxisDirection.left:
        offset += Offset(geometry!.paintExtent - childMainAxisPosition(child as RenderBox) - childExtent!, 0.0);
        break;
      case AxisDirection.right:
        offset += Offset(childMainAxisPosition(child as RenderBox), 0.0);
        break;
    }
    childParentData!.paintOffset = offset;
  }

  @override
  double childMainAxisPosition(RenderBox child) => 0.0;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    final SliverGeometry? geometry = this.geometry;
    final RenderBox? child = this.child;
    if (geometry == null || child == null || !child.hasSize) return;
    final double? extent = childExtent;
    if (extent != null && geometry.layoutExtent < extent) {
      config.addTagForChildren(RenderViewport.excludeFromScrolling);
    }
  }

  double? get childExtent {
    final RenderBox? child = this.child;
    if (child == null) return 0.0;
    assert(child.hasSize);
    switch (constraints.axis) {
      case Axis.vertical:
        return child.size.height;
      case Axis.horizontal:
        return child.size.width;
    }
  }
}
