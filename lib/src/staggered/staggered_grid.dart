import 'dart:math' as math;

import 'package:fl_scroll_view/src/staggered/layout_helpers.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class _StaggeredGridParentData extends ContainerBoxParentData<RenderBox> {
  int? crossAxisCellCount;

  num? mainAxisCellCount;

  double? mainAxisExtent;

  double? _realMainAxisExtent;

  @override
  String toString() =>
      'crossAxisCellCount=$crossAxisCellCount; mainAxisCellCount=$mainAxisCellCount; mainAxisExtent=$mainAxisExtent';
}

abstract class StaggeredGridDelegate {
  const StaggeredGridDelegate();

  int getCrossAxisCount(double crossAxisExtent, double crossAxisSpacing);

  bool shouldRelayout(covariant StaggeredGridDelegate oldDelegate);
}

class StaggeredGridDelegateWithFixedCrossAxisCount extends StaggeredGridDelegate {
  const StaggeredGridDelegateWithFixedCrossAxisCount({required this.crossAxisCount}) : assert(crossAxisCount > 0);

  final int crossAxisCount;

  @override
  int getCrossAxisCount(double crossAxisExtent, double crossAxisSpacing) => crossAxisCount;

  @override
  bool shouldRelayout(StaggeredGridDelegateWithFixedCrossAxisCount oldDelegate) =>
      oldDelegate.crossAxisCount != crossAxisCount;
}

class StaggeredGridDelegateWithMaxCrossAxisExtent extends StaggeredGridDelegate {
  const StaggeredGridDelegateWithMaxCrossAxisExtent({required this.maxCrossAxisExtent})
    : assert(maxCrossAxisExtent > 0);

  final double maxCrossAxisExtent;

  @override
  int getCrossAxisCount(double crossAxisExtent, double crossAxisSpacing) {
    return (crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing)).ceil();
  }

  @override
  bool shouldRelayout(StaggeredGridDelegateWithMaxCrossAxisExtent oldDelegate) {
    return oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent;
  }
}

class _RenderStaggeredGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _StaggeredGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _StaggeredGridParentData> {
  _RenderStaggeredGrid({
    List<RenderBox>? children,
    required this._delegate,
    required double mainAxisSpacing,
    required double crossAxisSpacing,
    required this._axisDirection,
    required this._textDirection,
  }) : assert(mainAxisSpacing >= 0),
       assert(crossAxisSpacing >= 0),
       _mainAxisSpacing = mainAxisSpacing,
       _crossAxisSpacing = crossAxisSpacing {
    addAll(children);
  }

  StaggeredGridDelegate get delegate => _delegate;
  StaggeredGridDelegate _delegate;

  set delegate(StaggeredGridDelegate newDelegate) {
    if (_delegate == newDelegate) return;
    if (newDelegate.runtimeType != _delegate.runtimeType || newDelegate.shouldRelayout(_delegate)) {
      markNeedsLayout();
    }
    _delegate = newDelegate;
  }

  double get mainAxisSpacing => _mainAxisSpacing;
  double _mainAxisSpacing;

  set mainAxisSpacing(double value) {
    if (_mainAxisSpacing == value) return;
    _mainAxisSpacing = value;
    markNeedsLayout();
  }

  double get crossAxisSpacing => _crossAxisSpacing;
  double _crossAxisSpacing;

  set crossAxisSpacing(double value) {
    if (_crossAxisSpacing == value) return;
    _crossAxisSpacing = value;
    markNeedsLayout();
  }

  AxisDirection get axisDirection => _axisDirection;
  AxisDirection _axisDirection;

  set axisDirection(AxisDirection value) {
    if (_axisDirection == value) {
      return;
    }
    _axisDirection = value;
    markNeedsLayout();
  }

  Axis get mainAxis => axisDirectionToAxis(_axisDirection);

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _StaggeredGridParentData) child.parentData = _StaggeredGridParentData();
  }

  _StaggeredGridParentData _getParentData(RenderBox child) => child.parentData as _StaggeredGridParentData;

  @override
  double computeMinIntrinsicWidth(double height) => _computeIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) => _computeIntrinsicWidth(height);

  double _computeIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicHeight(double width) => _computeIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _computeIntrinsicHeight(width);

  double _computeIntrinsicHeight(double width) => 0;

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  bool _hasVisualOverflow = false;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final size = _computeSize(constraints: constraints, layoutChild: _dryLayoutChild);
    return constraints.constrain(size);
  }

  Size _computeSize({required BoxConstraints constraints, required _ChildLayouter layoutChild}) {
    final crossAxisExtent = mainAxis == Axis.vertical ? constraints.maxWidth : constraints.maxHeight;
    final crossAxisCount = delegate.getCrossAxisCount(crossAxisExtent, crossAxisSpacing);
    final stride = (crossAxisExtent + crossAxisSpacing) / crossAxisCount;

    int computeCrossAxisCellCount(_StaggeredGridParentData childParentData, int crossAxisCount) {
      return math.min(childParentData.crossAxisCellCount ?? 1, crossAxisCount);
    }

    if (crossAxisCount == 0 || firstChild == null) {
      final extent = crossAxisExtent.isFinite ? crossAxisExtent : 0.0;
      return mainAxis == Axis.vertical ? Size(extent, 0) : Size(0, extent);
    }

    final offsets = List.filled(crossAxisCount, 0.0);
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = _getParentData(child);
      final crossAxisCellCount = computeCrossAxisCellCount(childParentData, crossAxisCount);
      final crossAxisExtent = stride * crossAxisCellCount - crossAxisSpacing;
      final shouldFitContent = childParentData.mainAxisExtent == null && childParentData.mainAxisCellCount == null;
      double mainAxisExtent = 0;
      if (shouldFitContent) {
        final childConstraints = mainAxis == Axis.vertical
            ? BoxConstraints.tightFor(width: crossAxisExtent)
            : BoxConstraints.tightFor(height: crossAxisExtent);
        final childSize = layoutChild(child, childConstraints, parentUsesSize: true);
        mainAxisExtent = mainAxis == Axis.vertical ? childSize.height : childSize.width;
      } else {
        final mainAxisCellCount = childParentData.mainAxisCellCount ?? 1;
        final mainAxisFixedExtent = childParentData.mainAxisExtent;
        mainAxisExtent = mainAxisFixedExtent ?? stride * mainAxisCellCount - mainAxisSpacing;

        final childSize = mainAxis == Axis.vertical
            ? Size(crossAxisExtent, mainAxisExtent)
            : Size(mainAxisExtent, crossAxisExtent);
        final childConstraints = BoxConstraints.tight(childSize);
        layoutChild(child, childConstraints);
      }
      childParentData._realMainAxisExtent = mainAxisExtent;

      final origin = _findBestCandidate(offsets, crossAxisCellCount);
      final mainAxisOffset = origin.mainAxisOffset;
      final crossAxisOffset = origin.crossAxisIndex * stride;
      final offset = mainAxis == Axis.vertical
          ? Offset(crossAxisOffset, mainAxisOffset)
          : Offset(mainAxisOffset, crossAxisOffset);

      childParentData.offset = offset;

      final nextTileOffset = mainAxisOffset + mainAxisExtent + mainAxisSpacing;
      for (int i = 0; i < crossAxisCellCount; i++) {
        offsets[origin.crossAxisIndex + i] = nextTileOffset;
      }

      child = childAfter(child);
    }

    final mainAxisExtent = offsets.reduce(math.max) - mainAxisSpacing;
    if (axisDirectionIsReversed(axisDirection)) {
      child = firstChild;
      while (child != null) {
        final childParentData = _getParentData(child);
        final offset = childParentData.offset;
        final crossAxisOffset = _crossAxisOffset(offset);
        final mainAxisOffset = mainAxisExtent - _mainAxisOffset(offset) - childParentData._realMainAxisExtent!;
        final newOffset = mainAxis == Axis.vertical
            ? Offset(crossAxisOffset, mainAxisOffset)
            : Offset(mainAxisOffset, crossAxisOffset);
        childParentData.offset = newOffset;
        child = childAfter(child);
      }
    }

    if (mainAxis == Axis.vertical && textDirection == TextDirection.rtl) {
      child = firstChild;
      while (child != null) {
        final childParentData = _getParentData(child);
        final crossAxisCellCount = computeCrossAxisCellCount(childParentData, crossAxisCount);
        final crossAxisCellExtent = stride * crossAxisCellCount - crossAxisSpacing;
        final offset = childParentData.offset;
        final crossAxisOffset = crossAxisExtent - offset.dx - crossAxisCellExtent;
        final mainAxisOffset = offset.dy;
        final newOffset = Offset(crossAxisOffset, mainAxisOffset);
        childParentData.offset = newOffset;
        child = childAfter(child);
      }
    }

    final size = mainAxis == Axis.vertical
        ? Size(crossAxisExtent, mainAxisExtent)
        : Size(mainAxisExtent, crossAxisExtent);
    return size;
  }

  @override
  void performLayout() {
    final requestedSize = _computeSize(constraints: constraints, layoutChild: _layoutChild);
    size = constraints.constrain(requestedSize);
    _hasVisualOverflow = size != requestedSize;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasVisualOverflow) {
      context.pushClipRect(needsCompositing, offset, Offset.zero & size, defaultPaint);
    } else {
      defaultPaint(context, offset);
    }
  }

  Size _dryLayoutChild(RenderBox child, BoxConstraints constraints, {bool parentUsesSize = false}) {
    return child.getDryLayout(constraints);
  }

  Size _layoutChild(RenderBox child, BoxConstraints constraints, {bool parentUsesSize = false}) {
    child.layout(constraints, parentUsesSize: parentUsesSize);
    return parentUsesSize ? child.size : Size.zero;
  }

  double _crossAxisOffset(Offset offset) => mainAxis == Axis.vertical ? offset.dx : offset.dy;

  double _mainAxisOffset(Offset offset) => mainAxis == Axis.vertical ? offset.dy : offset.dx;

  _TileOrigin _findBestCandidate(List<double> offsets, int crossAxisCount) {
    final length = offsets.length;
    _TileOrigin bestCandidate = const _TileOrigin(0, double.infinity);
    for (int i = 0; i < length; i++) {
      final offset = offsets[i];
      if (lessOrNearEqual(bestCandidate.mainAxisOffset, offset)) continue;

      int start = 0;
      int span = 0;
      for (int j = 0; j < length && span < crossAxisCount && length - j >= crossAxisCount - span; j++) {
        if (lessOrNearEqual(offsets[j], offset)) {
          span++;
          if (span == crossAxisCount) bestCandidate = _TileOrigin(start, offset);
        } else {
          start = j + 1;
          span = 0;
        }
      }
    }
    return bestCandidate;
  }
}

class _TileOrigin {
  const _TileOrigin(this.crossAxisIndex, this.mainAxisOffset);

  final int crossAxisIndex;
  final double mainAxisOffset;
}

typedef _ChildLayouter = Size Function(RenderBox child, BoxConstraints constraints, {bool parentUsesSize});

class StaggeredGrid extends MultiChildRenderObjectWidget {
  const StaggeredGrid.custom({
    super.key,
    required this.delegate,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.axisDirection,
    super.children,
  }) : assert(mainAxisSpacing >= 0),
       assert(crossAxisSpacing >= 0);

  StaggeredGrid.count({
    Key? key,
    required int crossAxisCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    AxisDirection? axisDirection,
    List<Widget> children = const <Widget>[],
  }) : this.custom(
         key: key,
         delegate: StaggeredGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
         mainAxisSpacing: mainAxisSpacing,
         crossAxisSpacing: crossAxisSpacing,
         axisDirection: axisDirection,
         children: children,
       );

  StaggeredGrid.extent({
    Key? key,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    AxisDirection? axisDirection,
    List<Widget> children = const <Widget>[],
  }) : this.custom(
         key: key,
         delegate: StaggeredGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: maxCrossAxisExtent),
         mainAxisSpacing: mainAxisSpacing,
         crossAxisSpacing: crossAxisSpacing,
         axisDirection: axisDirection,
         children: children,
       );

  final StaggeredGridDelegate delegate;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final AxisDirection? axisDirection;

  @override
  RenderBox createRenderObject(BuildContext context) {
    return _RenderStaggeredGrid(
      delegate: delegate,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      axisDirection: axisDirection ?? Scrollable.maybeOf(context)?.axisDirection ?? AxisDirection.down,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    (renderObject as _RenderStaggeredGrid)
      ..delegate = delegate
      ..mainAxisSpacing = mainAxisSpacing
      ..crossAxisSpacing = crossAxisSpacing
      ..axisDirection = axisDirection ?? Scrollable.maybeOf(context)?.axisDirection ?? AxisDirection.down
      ..textDirection = Directionality.of(context);
  }
}

class StaggeredGridTile extends ParentDataWidget<_StaggeredGridParentData> {
  const StaggeredGridTile._({
    super.key,
    required this.crossAxisCellCount,
    required this.mainAxisCellCount,
    required this.mainAxisExtent,
    required super.child,
  }) : assert(crossAxisCellCount > 0),
       assert(mainAxisCellCount == null || mainAxisCellCount > 0),
       assert(mainAxisExtent == null || mainAxisExtent > 0);

  const StaggeredGridTile.count({
    Key? key,
    required int crossAxisCellCount,
    required num mainAxisCellCount,
    required Widget child,
  }) : this._(
         key: key,
         crossAxisCellCount: crossAxisCellCount,
         mainAxisCellCount: mainAxisCellCount,
         mainAxisExtent: null,
         child: child,
       );

  const StaggeredGridTile.extent({
    Key? key,
    required int crossAxisCellCount,
    required double mainAxisExtent,
    required Widget child,
  }) : this._(
         key: key,
         crossAxisCellCount: crossAxisCellCount,
         mainAxisCellCount: null,
         mainAxisExtent: mainAxisExtent,
         child: child,
       );

  const StaggeredGridTile.fit({
    Key? key,
    required int crossAxisCellCount,
    required Widget child,
  }) : this._(
         key: key,
         crossAxisCellCount: crossAxisCellCount,
         mainAxisCellCount: null,
         mainAxisExtent: null,
         child: child,
       );

  final int crossAxisCellCount;

  final num? mainAxisCellCount;

  final double? mainAxisExtent;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData;
    if (parentData is _StaggeredGridParentData) {
      bool needsLayout = false;

      if (parentData.crossAxisCellCount != crossAxisCellCount) {
        parentData.crossAxisCellCount = crossAxisCellCount;
        needsLayout = true;
      }

      if (parentData.mainAxisCellCount != mainAxisCellCount) {
        parentData.mainAxisCellCount = mainAxisCellCount;
        needsLayout = true;
      }

      if (parentData.mainAxisExtent != mainAxisExtent) {
        parentData.mainAxisExtent = mainAxisExtent;
        needsLayout = true;
      }

      if (needsLayout) {
        final targetParent = renderObject.parent;
        if (targetParent is _RenderStaggeredGrid) {
          targetParent.markNeedsLayout();
        }
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => StaggeredGrid;
}
