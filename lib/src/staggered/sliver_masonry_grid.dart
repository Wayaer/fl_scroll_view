import 'dart:math' as math;

import 'package:fl_scroll_view/src/staggered/sliver_simple_grid_delegate.dart';
import 'package:fl_scroll_view/src/staggered/layout_helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class _SliverMasonryGridParentData extends SliverMultiBoxAdaptorParentData {
  int? crossAxisIndex;

  double? lastMainAxisExtent;

  void applyZero() {
    layoutOffset = 0.0;
    crossAxisIndex = 0;
  }

  void apply(_SliverMasonryGridParentData parentData) {
    layoutOffset = parentData.layoutOffset;
    crossAxisIndex = parentData.crossAxisIndex;
  }

  @override
  String toString() => 'crossAxisIndex=$crossAxisIndex; ${super.toString()}';
}

class _RenderSliverMasonryGrid({
  required super.childManager,
  required this._gridDelegate,
  required double mainAxisSpacing,
  required double crossAxisSpacing,
}) extends RenderSliverMultiBoxAdaptor {
  this
    : assert(mainAxisSpacing >= 0),
      assert(crossAxisSpacing >= 0),
      _mainAxisSpacing = mainAxisSpacing,
      _crossAxisSpacing = crossAxisSpacing;

  SliverSimpleGridDelegate get gridDelegate => _gridDelegate;
  SliverSimpleGridDelegate _gridDelegate;

  set gridDelegate(SliverSimpleGridDelegate value) {
    if (_gridDelegate == value) {
      return;
    }

    if (value.runtimeType != _gridDelegate.runtimeType || value.shouldRelayout(_gridDelegate)) {
      markNeedsLayout();
    }

    _gridDelegate = value;
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

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _SliverMasonryGridParentData) child.parentData = _SliverMasonryGridParentData();
  }

  _SliverMasonryGridParentData _getParentData(RenderObject child) {
    return child.parentData as _SliverMasonryGridParentData;
  }

  double _stride = 0;
  int Function(int) _getCrossAxisIndex = (int index) => index;

  @override
  double childCrossAxisPosition(RenderBox child) {
    final crossAxisIndex = _childCrossAxisIndex(child)!;
    return _getCrossAxisIndex(crossAxisIndex) * _stride;
  }

  int? _childCrossAxisIndex(RenderBox child) {
    return _getParentData(child).crossAxisIndex;
  }

  final _previousCrossAxisIndexes = <int>[];

  final _previousMainAxisExtents = <double>[];

  @override
  bool addInitialChild({int index = 0, double layoutOffset = 0.0}) {
    final hasFirstChild = super.addInitialChild(index: index, layoutOffset: layoutOffset);
    if (hasFirstChild) {
      final parentData = _getParentData(firstChild!);
      parentData.applyZero();
    }
    return hasFirstChild;
  }

  @override
  void collectGarbage(int leadingGarbage, int trailingGarbage) {
    int count = leadingGarbage;
    RenderBox? child = firstChild!;
    while (count > 0 && child != null) {
      final crossAxisIndex = _childCrossAxisIndex(child);
      if (crossAxisIndex != null) {
        _previousCrossAxisIndexes.add(crossAxisIndex);
        _previousMainAxisExtents.add(paintExtentOf(child));
      }
      child = childAfter(child);
      count -= 1;
    }
    super.collectGarbage(leadingGarbage, trailingGarbage);
  }

  int _lastFirstVisibleChildIndex = 0;

  @override
  RenderBox? insertAndLayoutLeadingChild(BoxConstraints childConstraints, {bool parentUsesSize = false}) {
    final child = super.insertAndLayoutLeadingChild(childConstraints, parentUsesSize: parentUsesSize);
    if (child != null) {
      final parentData = _getParentData(child);
      parentData.crossAxisIndex = _previousCrossAxisIndexes.isNotEmpty ? _previousCrossAxisIndexes.removeLast() : 0;
      parentData.lastMainAxisExtent = _previousMainAxisExtents.isNotEmpty ? _previousMainAxisExtents.removeLast() : 0;
    }

    return child;
  }

  int? _lastCrossAxisCount;

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final crossAxisCount = _gridDelegate.getCrossAxisCount(constraints, crossAxisSpacing);

    _getCrossAxisIndex = axisDirectionIsReversed(constraints.crossAxisDirection)
        ? (int index) => crossAxisCount - index - 1
        : (int index) => index;

    _stride = (constraints.crossAxisExtent + crossAxisSpacing) / crossAxisCount;
    final childCrossAxisExtent = _stride - crossAxisSpacing;
    final childConstraints = constraints.asBoxConstraints(crossAxisExtent: childCrossAxisExtent);

    final double scrollOffset = constraints.scrollOffset + constraints.cacheOrigin;

    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;
    int leadingGarbage = 0;
    int trailingGarbage = 0;
    bool reachedEnd = false;

    final scrollOffsets = List.filled(crossAxisCount, 0.0);

    double positionChild(RenderBox child) {
      final crossAxisIndex = indexOfSmallest(scrollOffsets);
      final childParentData = _getParentData(child);
      childParentData.layoutOffset = scrollOffsets[crossAxisIndex];
      childParentData.crossAxisIndex = crossAxisIndex;
      scrollOffsets[crossAxisIndex] = childScrollOffset(child)! + paintExtentOf(child) + mainAxisSpacing;
      return scrollOffsets[crossAxisIndex];
    }

    if (_lastCrossAxisCount != null && _lastCrossAxisCount != crossAxisCount) {
      _previousCrossAxisIndexes.clear();
      _previousMainAxisExtents.clear();

      if (firstChild != null) {
        final firstIndex = indexOf(firstChild!);

        if (firstIndex != 0) {
          final lastIndex = indexOf(lastChild!);
          collectGarbage(0, lastIndex - firstIndex + 1);

          scrollOffsets.fillRange(0, crossAxisCount, 0);
          addInitialChild();
          RenderBox? child = firstChild;
          child!.layout(childConstraints, parentUsesSize: true);
          int index = indexOf(firstChild!);
          double newPositionOfLastFirstChild = 0;

          while (child != null && index <= _lastFirstVisibleChildIndex) {
            positionChild(child);
            newPositionOfLastFirstChild = childScrollOffset(child)!;
            child = insertAndLayoutChild(childConstraints, after: child, parentUsesSize: true);
            index++;
          }

          final scrollOffsetCorrection = newPositionOfLastFirstChild - scrollOffset;
          if (scrollOffsetCorrection != 0) {
            geometry = SliverGeometry(scrollOffsetCorrection: scrollOffsetCorrection);
            return;
          }
        }
      }
    }

    _lastCrossAxisCount = crossAxisCount;

    if (firstChild == null) {
      if (!addInitialChild()) {
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
        return;
      }
    }

    RenderBox? leadingChildWithLayout, trailingChildWithLayout;

    RenderBox? earliestUsefulChild = firstChild;

    if (childScrollOffset(firstChild!) == null) {
      int leadingChildrenWithoutLayoutOffset = 0;
      while (earliestUsefulChild != null && childScrollOffset(earliestUsefulChild) == null) {
        earliestUsefulChild = childAfter(earliestUsefulChild);
        leadingChildrenWithoutLayoutOffset += 1;
      }

      collectGarbage(leadingChildrenWithoutLayoutOffset, 0);

      if (firstChild == null) {
        if (!addInitialChild()) {
          geometry = SliverGeometry.zero;
          childManager.didFinishLayout();
          return;
        }
      }
    }

    scrollOffsets.fillRange(0, crossAxisCount, double.infinity);

    _SliverMasonryGridParentData computeFirstChildParentData() {
      final firstChildParentData = _getParentData(firstChild!);
      final mainAxisExtent = firstChildParentData.lastMainAxisExtent! + mainAxisSpacing;
      final crossAxisIndex = firstChildParentData.crossAxisIndex!;

      double offset = scrollOffsets[crossAxisIndex] - mainAxisExtent;

      for (int i = 0; i < crossAxisCount; i++) {
        if (i == crossAxisIndex) {
          continue;
        }
        final otherOffset = scrollOffsets[i];
        if ((offset - otherOffset).abs() < precisionErrorTolerance) {
          offset = otherOffset;
          break;
        }
      }

      return _SliverMasonryGridParentData()
        ..layoutOffset = offset
        ..crossAxisIndex = crossAxisIndex;
    }

    RenderBox? child = firstChild;

    if (child != null && indexOf(child) == 0) {
      final firstChildParentData = _getParentData(child);
      firstChildParentData.crossAxisIndex = 0;
    }

    while (child != null && scrollOffsets.any((x) => x.isInfinite)) {
      final index = _childCrossAxisIndex(child);
      if (index != null) {
        final scrollOffset = childScrollOffset(child)!;

        if (scrollOffsets[index] == double.infinity) {
          scrollOffsets[index] = scrollOffset;
        }
      }
      child = childAfter(child);
    }

    earliestUsefulChild = firstChild;
    while (scrollOffsets.any((x) => x > scrollOffset)) {
      earliestUsefulChild = insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);

      if (earliestUsefulChild == null) {
        // No child before firstChild. Continue from layoutOffset 0.
        // Do NOT emit scrollOffsetCorrection: -scrollOffset — that jumps the
        // whole CustomScrollView when masonry sits above later slivers.
        _getParentData(firstChild!).layoutOffset = 0;
        firstChild!.layout(childConstraints, parentUsesSize: true);
        earliestUsefulChild = firstChild;
        leadingChildWithLayout = earliestUsefulChild;
        trailingChildWithLayout ??= earliestUsefulChild;
        for (int i = 0; i < scrollOffsets.length; i++) {
          if (!scrollOffsets[i].isFinite || scrollOffsets[i] < 0) {
            scrollOffsets[i] = 0.0;
          }
        }
        break;
      }

      final firstChildParentData = computeFirstChildParentData();
      final newOffset = firstChildParentData.layoutOffset!;

      if (newOffset < -precisionErrorTolerance) {
        geometry = SliverGeometry(scrollOffsetCorrection: -newOffset);
        final childParentData = _getParentData(firstChild!);
        childParentData.apply(firstChildParentData);
        childParentData.layoutOffset = 0;
        return;
      }

      final childParentData = _getParentData(earliestUsefulChild);
      childParentData.apply(firstChildParentData);
      scrollOffsets[firstChildParentData.crossAxisIndex!] = newOffset;
      assert(earliestUsefulChild == firstChild);
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout ??= earliestUsefulChild;
    }

    final double? firstChildOffset = childScrollOffset(firstChild!);
    if (firstChildOffset == null || firstChildOffset < -precisionErrorTolerance) {
      _getParentData(firstChild!).layoutOffset = 0;
    }
    assert(childScrollOffset(firstChild!)! > -precisionErrorTolerance);

    if (scrollOffset < precisionErrorTolerance) {
      while (indexOf(firstChild!) > 0) {
        final childParentData = _getParentData(firstChild!);

        earliestUsefulChild = insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);
        assert(earliestUsefulChild != null);
        final firstChildParentData = computeFirstChildParentData();
        childParentData.apply(firstChildParentData);
        final firstChildScrollOffset = firstChildParentData.layoutOffset!;

        if (firstChildScrollOffset < -precisionErrorTolerance) {
          geometry = SliverGeometry(scrollOffsetCorrection: -firstChildScrollOffset);
          return;
        }
      }
    }

    assert(earliestUsefulChild == firstChild);
    assert(childScrollOffset(earliestUsefulChild!)! <= scrollOffset);

    if (leadingChildWithLayout == null) {
      earliestUsefulChild!.layout(childConstraints, parentUsesSize: true);
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout = earliestUsefulChild;
    }

    final leadingScrollOffset = scrollOffsets.reduce(math.min);

    bool inLayoutRange = true;
    child = earliestUsefulChild;
    int index = indexOf(child!);

    scrollOffsets[_childCrossAxisIndex(child)!] = childScrollOffset(child)! + paintExtentOf(child) + mainAxisSpacing;

    for (int i = 0; i < scrollOffsets.length; i++) {
      if (scrollOffsets[i] == double.infinity) {
        scrollOffsets[i] = 0.0;
      }
    }

    bool foundFirstVisibleChild = scrollOffsets.any((scrollOffset) => scrollOffset >= constraints.scrollOffset);
    _lastFirstVisibleChildIndex = indexOf(firstChild!);

    bool advance() {
      assert(child != null);
      if (child == trailingChildWithLayout) {
        inLayoutRange = false;
      }
      child = childAfter(child!);
      if (child == null) {
        inLayoutRange = false;
      }
      index += 1;
      if (!inLayoutRange) {
        if (child == null || indexOf(child!) != index) {
          child = insertAndLayoutChild(childConstraints, after: trailingChildWithLayout, parentUsesSize: true);
          if (child == null) return false;
        } else {
          child!.layout(childConstraints, parentUsesSize: true);
        }
        trailingChildWithLayout = child;
      }
      assert(child != null);
      positionChild(child!);
      if (!foundFirstVisibleChild && scrollOffsets.any((scrollOffset) => scrollOffset >= constraints.scrollOffset)) {
        foundFirstVisibleChild = true;
        _lastFirstVisibleChildIndex = indexOf(child!);
      }
      assert(indexOf(child!) == index);
      return true;
    }

    while (scrollOffsets.every((offset) => offset - mainAxisSpacing < scrollOffset)) {
      leadingGarbage += 1;
      if (!advance()) {
        assert(leadingGarbage == childCount);
        assert(child == null);

        collectGarbage(leadingGarbage - 1, 0);
        assert(firstChild == lastChild);
        final double extent = scrollOffsets.reduce(math.max) - mainAxisSpacing;
        geometry = SliverGeometry(scrollExtent: extent, maxPaintExtent: extent);
        return;
      }
    }

    while (scrollOffsets.any((offset) => offset - mainAxisSpacing < targetEndScrollOffset)) {
      if (!advance()) {
        reachedEnd = true;
        break;
      }
    }

    if (child != null) {
      child = childAfter(child!);
      while (child != null) {
        trailingGarbage += 1;
        child = childAfter(child!);
      }
    }

    collectGarbage(leadingGarbage, trailingGarbage);

    assert(debugAssertChildListIsNonEmptyAndContiguous());
    final endScrollOffset = scrollOffsets.reduce(math.max) - mainAxisSpacing;
    final double estimatedMaxScrollOffset;
    if (reachedEnd) {
      estimatedMaxScrollOffset = endScrollOffset;
    } else {
      estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
        constraints,
        firstIndex: indexOf(firstChild!),
        lastIndex: indexOf(lastChild!),
        leadingScrollOffset: leadingScrollOffset,
        trailingScrollOffset: endScrollOffset,
      );
      assert(estimatedMaxScrollOffset >= endScrollOffset - leadingScrollOffset);
    }
    final double paintExtent = calculatePaintOffset(constraints, from: leadingScrollOffset, to: endScrollOffset);
    final double cacheExtent = calculateCacheOffset(constraints, from: leadingScrollOffset, to: endScrollOffset);
    final double targetEndScrollOffsetForPaint = constraints.scrollOffset + constraints.remainingPaintExtent;
    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,

      hasVisualOverflow: endScrollOffset > targetEndScrollOffsetForPaint || constraints.scrollOffset > 0.0,
    );

    if (estimatedMaxScrollOffset == endScrollOffset) childManager.setDidUnderflow(true);
    childManager.didFinishLayout();
  }
}

class SliverMasonryGrid extends SliverMultiBoxAdaptorWidget {
  const SliverMasonryGrid({
    super.key,
    required super.delegate,
    required this.gridDelegate,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  }) : assert(mainAxisSpacing >= 0),
       assert(crossAxisSpacing >= 0);

  SliverMasonryGrid.count({
    Key? key,
    required int crossAxisCount,
    required IndexedWidgetBuilder itemBuilder,
    int? childCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
  }) : this(
         key: key,
         delegate: SliverChildBuilderDelegate(itemBuilder, childCount: childCount),
         gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
         mainAxisSpacing: mainAxisSpacing,
         crossAxisSpacing: crossAxisSpacing,
       );

  SliverMasonryGrid.extent({
    Key? key,
    required double maxCrossAxisExtent,
    required IndexedWidgetBuilder itemBuilder,
    int? childCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
  }) : this(
         key: key,
         delegate: SliverChildBuilderDelegate(itemBuilder, childCount: childCount),
         gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: maxCrossAxisExtent),
         mainAxisSpacing: mainAxisSpacing,
         crossAxisSpacing: crossAxisSpacing,
       );

  final SliverSimpleGridDelegate gridDelegate;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  @override
  RenderSliverMultiBoxAdaptor createRenderObject(BuildContext context) {
    final element = context as SliverMultiBoxAdaptorElement;
    return _RenderSliverMasonryGrid(
      childManager: element,
      gridDelegate: gridDelegate,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    (renderObject as _RenderSliverMasonryGrid)
      ..gridDelegate = gridDelegate
      ..mainAxisSpacing = mainAxisSpacing
      ..crossAxisSpacing = crossAxisSpacing;
  }
}

class MasonryGridView extends BoxScrollView {
  MasonryGridView({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required this.gridDelegate,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    super.scrollCacheExtent,
    List<Widget> children = const <Widget>[],
    int? semanticChildCount,
    super.dragStartBehavior,
    super.clipBehavior,
    ScrollViewKeyboardDismissBehavior super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.restorationId,
  }) : childrenDelegate = SliverChildListDelegate(
         children,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
       ),
       super(semanticChildCount: semanticChildCount ?? children.length);

  MasonryGridView.builder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required this.gridDelegate,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    super.scrollCacheExtent,
    int? semanticChildCount,
    super.dragStartBehavior,
    ScrollViewKeyboardDismissBehavior super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.restorationId,
    super.clipBehavior,
  }) : childrenDelegate = SliverChildBuilderDelegate(
         itemBuilder,
         childCount: itemCount,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
       ),
       super(semanticChildCount: semanticChildCount ?? itemCount);

  const MasonryGridView.custom({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required this.gridDelegate,
    required this.childrenDelegate,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    super.scrollCacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    ScrollViewKeyboardDismissBehavior super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.restorationId,
    super.clipBehavior,
  });

  MasonryGridView.count({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required int crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    super.scrollCacheExtent,
    int? semanticChildCount,
    super.dragStartBehavior,
    ScrollViewKeyboardDismissBehavior super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.restorationId,
    super.clipBehavior,
  }) : gridDelegate = SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
       childrenDelegate = SliverChildBuilderDelegate(
         itemBuilder,
         childCount: itemCount,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
       ),
       super(semanticChildCount: semanticChildCount ?? itemCount);

  MasonryGridView.extent({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required double maxCrossAxisExtent,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    super.scrollCacheExtent,
    int? semanticChildCount,
    super.dragStartBehavior,
    ScrollViewKeyboardDismissBehavior super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.restorationId,
    super.clipBehavior,
  }) : gridDelegate = SliverSimpleGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: maxCrossAxisExtent),
       childrenDelegate = SliverChildBuilderDelegate(
         itemBuilder,
         childCount: itemCount,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
       ),
       super(semanticChildCount: semanticChildCount ?? itemCount);

  final SliverSimpleGridDelegate gridDelegate;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final SliverChildDelegate childrenDelegate;

  @override
  Widget buildChildLayout(BuildContext context) {
    return SliverMasonryGrid(
      delegate: childrenDelegate,
      gridDelegate: gridDelegate,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
    );
  }
}
