import 'dart:math' as math;

import 'package:fl_scroll_view/src/semantic_index.dart';
import 'package:fl_scroll_view/src/staggered/sliver_simple_grid_delegate.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class _UniformTrackParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderUniformTrack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _UniformTrackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _UniformTrackParentData> {
  _RenderUniformTrack({
    List<RenderBox>? children,
    double spacing = 0,
    required int division,
    required AxisDirection direction,
  }) : assert(spacing >= 0),
       assert(division > 0),
       _spacing = spacing,
       _direction = direction,
       _isHorizontal = axisDirectionToAxis(direction) == Axis.horizontal,
       _isDirectionReversed = axisDirectionIsReversed(direction),
       _division = division {
    addAll(children);
  }

  double get spacing => _spacing;
  double _spacing;

  set spacing(double value) {
    assert(value >= 0);
    if (_spacing == value) {
      return;
    }
    _spacing = value;
    markNeedsLayout();
  }

  AxisDirection get direction => _direction;
  AxisDirection _direction;

  set direction(AxisDirection value) {
    if (_direction == value) {
      return;
    }
    _direction = value;
    _isHorizontal = axisDirectionToAxis(value) == Axis.horizontal;
    _isDirectionReversed = axisDirectionIsReversed(value);
    markNeedsLayout();
  }

  bool _isHorizontal;
  bool _isDirectionReversed;

  int get division => _division;
  int _division;

  set division(int value) {
    assert(value > 0);
    if (_division == value) {
      return;
    }
    _division = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _UniformTrackParentData) child.parentData = _UniformTrackParentData();
  }

  _UniformTrackParentData _getParentData(RenderBox child) {
    return child.parentData as _UniformTrackParentData;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(constraints, ChildLayoutHelper.dryLayoutChild);
  }

  Size _computeSize(BoxConstraints constraints, ChildLayouter layoutChild) {
    final mainAxisExtent = _isHorizontal ? constraints.maxWidth : constraints.maxHeight;
    final childMainAxisExtent = ((mainAxisExtent + spacing) / division) - spacing;
    final childConstraints = _isHorizontal
        ? BoxConstraints.tightFor(width: childMainAxisExtent)
        : BoxConstraints.tightFor(height: childMainAxisExtent);
    RenderBox? child = firstChild;

    double getChildCrossAxisExtent(Size size) {
      return _isHorizontal ? size.height : size.width;
    }

    double maxChildCrossAxisExtent = 0;

    while (child != null) {
      final size = layoutChild(child, childConstraints);
      maxChildCrossAxisExtent = math.max(
        maxChildCrossAxisExtent,
        getChildCrossAxisExtent(size),
      );
      child = childAfter(child);
    }

    return size = constraints.constrain(
      _isHorizontal ? Size(mainAxisExtent, maxChildCrossAxisExtent) : Size(maxChildCrossAxisExtent, mainAxisExtent),
    );
  }

  @override
  void performLayout() {
    size = _computeSize(constraints, ChildLayoutHelper.layoutChild);
    final mainAxisExtent = _isHorizontal ? constraints.maxWidth : constraints.maxHeight;
    final childMainAxisExtent = ((mainAxisExtent + spacing) / division) - spacing;
    final maxChildCrossAxisExtent = _isHorizontal ? size.height : size.width;

    double getChildCrossAxisExtent(RenderBox child) {
      return _isHorizontal ? child.size.height : child.size.width;
    }

    final secondPassChildConstraints = _isHorizontal
        ? BoxConstraints.tightFor(
            width: childMainAxisExtent,
            height: maxChildCrossAxisExtent,
          )
        : BoxConstraints.tightFor(
            height: childMainAxisExtent,
            width: maxChildCrossAxisExtent,
          );

    RenderBox? child = firstChild;
    final stride = childMainAxisExtent + spacing;
    int index = 0;

    double getMainAxisPosition(int index) {
      final effectiveIndex = _isDirectionReversed ? division - index - 1 : index;
      return effectiveIndex * stride;
    }

    while (child != null) {
      if (getChildCrossAxisExtent(child) != maxChildCrossAxisExtent) {
        child.layout(secondPassChildConstraints, parentUsesSize: true);
      }
      final childParentData = _getParentData(child);
      final childMainAxisPosition = getMainAxisPosition(index);
      childParentData.offset = _isHorizontal ? Offset(childMainAxisPosition, 0) : Offset(0, childMainAxisPosition);
      index++;
      child = childParentData.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

class _UniformTrack extends MultiChildRenderObjectWidget {
  const _UniformTrack({
    required this.division,
    this.spacing = 0,
    required this.direction,
    required super.children,
  }) : assert(spacing >= 0),
       assert(division > 0),
       assert(children.length <= division);

  final double spacing;
  final int division;
  final AxisDirection direction;

  @override
  _RenderUniformTrack createRenderObject(BuildContext context) {
    return _RenderUniformTrack(direction: direction, division: division, spacing: spacing);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderUniformTrack renderObject) {
    renderObject
      ..direction = direction
      ..division = division
      ..spacing = spacing;
  }
}

class SliverAlignedGrid extends StatelessWidget {
  const SliverAlignedGrid({
    super.key,
    required this.itemBuilder,
    this.itemCount,
    required this.gridDelegate,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback = kDefaultSemanticIndexCallback,
  });

  SliverAlignedGrid.count({
    Key? key,
    required NullableIndexedWidgetBuilder itemBuilder,
    int? itemCount,
    required int crossAxisCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    SemanticIndexCallback semanticIndexCallback = kDefaultSemanticIndexCallback,
  }) : this(
         key: key,
         itemBuilder: itemBuilder,
         itemCount: itemCount,
         gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: crossAxisCount,
         ),
         mainAxisSpacing: mainAxisSpacing,
         crossAxisSpacing: crossAxisSpacing,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
         semanticIndexCallback: semanticIndexCallback,
       );

  SliverAlignedGrid.extent({
    Key? key,
    required NullableIndexedWidgetBuilder itemBuilder,
    int? itemCount,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    SemanticIndexCallback semanticIndexCallback = kDefaultSemanticIndexCallback,
  }) : this(
         key: key,
         itemBuilder: itemBuilder,
         itemCount: itemCount,
         gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
           maxCrossAxisExtent: maxCrossAxisExtent,
         ),
         mainAxisSpacing: mainAxisSpacing,
         crossAxisSpacing: crossAxisSpacing,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
         semanticIndexCallback: semanticIndexCallback,
       );

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final SliverSimpleGridDelegate gridDelegate;

  final NullableIndexedWidgetBuilder itemBuilder;

  final int? itemCount;

  final bool addAutomaticKeepAlives;

  final bool addRepaintBoundaries;

  final bool addSemanticIndexes;

  final SemanticIndexCallback semanticIndexCallback;

  @override
  Widget build(BuildContext context) {
    final localItemCount = itemCount;
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = gridDelegate.getCrossAxisCount(
          constraints,
          crossAxisSpacing,
        );
        final listItemCount = localItemCount == null
            ? null
            : ((localItemCount + crossAxisCount - 1) ~/ crossAxisCount) * 2 - 1;
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index.isOdd) {
                return _Gap(mainAxisExtent: mainAxisSpacing);
              }

              final startIndex = (index ~/ 2) * crossAxisCount;
              final children = [
                for (int i = 0; i < crossAxisCount; i++) _buildItem(context, startIndex + i, itemCount),
              ].whereType<Widget>();

              if (children.isEmpty) {
                return null;
              }

              return _UniformTrack(
                direction: constraints.crossAxisDirection,
                division: crossAxisCount,
                spacing: crossAxisSpacing,
                children: [...children],
              );
            },
            childCount: listItemCount,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            semanticIndexCallback: (widget, index) {
              if (index.isOdd) return null;
              return semanticIndexCallback(widget, (index ~/ 2) * crossAxisCount);
            },
          ),
        );
      },
    );
  }

  Widget? _buildItem(BuildContext context, int index, int? childCount) {
    if (index < 0 || (childCount != null && index >= childCount)) {
      return null;
    }

    return itemBuilder(context, index);
  }
}

class _Gap extends StatelessWidget {
  const _Gap({required this.mainAxisExtent});

  final double mainAxisExtent;

  @override
  Widget build(BuildContext context) {
    final axis = axisDirectionToAxis(Scrollable.of(context).axisDirection);
    return axis == Axis.vertical ? SizedBox(height: mainAxisExtent) : SizedBox(width: mainAxisExtent);
  }
}

class AlignedGridView extends BoxScrollView {
  const AlignedGridView.custom({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required this.gridDelegate,
    required this.itemBuilder,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    super.scrollCacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    ScrollViewKeyboardDismissBehavior super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.restorationId,
    super.clipBehavior,
  });

  AlignedGridView.count({
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
    required this.itemBuilder,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    super.scrollCacheExtent,
    int? semanticChildCount,
    super.dragStartBehavior,
    ScrollViewKeyboardDismissBehavior super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.restorationId,
    super.clipBehavior,
  }) : gridDelegate = SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
       super(semanticChildCount: semanticChildCount ?? itemCount);

  AlignedGridView.extent({
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
    required this.itemBuilder,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    super.scrollCacheExtent,
    int? semanticChildCount,
    super.dragStartBehavior,
    ScrollViewKeyboardDismissBehavior super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.restorationId,
    super.clipBehavior,
  }) : gridDelegate = SliverSimpleGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: maxCrossAxisExtent),
       super(semanticChildCount: semanticChildCount ?? itemCount);

  final SliverSimpleGridDelegate gridDelegate;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final NullableIndexedWidgetBuilder itemBuilder;

  final int? itemCount;

  final bool addAutomaticKeepAlives;

  final bool addRepaintBoundaries;

  @override
  Widget buildChildLayout(BuildContext context) {
    return SliverAlignedGrid(
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      gridDelegate: gridDelegate,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
    );
  }
}
