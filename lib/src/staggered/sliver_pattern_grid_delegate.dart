part of 'sliver_patterned_grids.dart';

const _kZeroGeometry = SliverGridGeometry(
  scrollOffset: 0,
  crossAxisOffset: 0,
  mainAxisExtent: 0,
  crossAxisExtent: 0,
);

/// 一组 pattern 周期内的格子几何：真实绘制区域 [tiles] + 占位包围盒 [bounds]。
///
/// 仅供 staired / woven 内部使用，不从 package 导出。
@immutable
class PatternGridGeometries {
  const PatternGridGeometries({required this.tiles, required this.bounds})
    : assert(tiles.length == bounds.length);

  final List<SliverGridGeometry> tiles;

  final List<SliverGridGeometry> bounds;
}

abstract class _SliverPatternGridDelegate<T> extends SliverGridDelegate {
  const _SliverPatternGridDelegate._({
    required this.pattern,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.crossAxisCount,
    this.maxCrossAxisExtent,
  }) : assert(mainAxisSpacing >= 0),
       assert(crossAxisSpacing >= 0),
       assert(crossAxisCount == null || crossAxisCount > 0),
       assert(maxCrossAxisExtent == null || maxCrossAxisExtent > 0),
       assert(crossAxisCount != null || maxCrossAxisExtent != null),
       tileCount = pattern.length;

  const _SliverPatternGridDelegate.count({
    required List<T> pattern,
    required int crossAxisCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
  }) : this._(
         pattern: pattern,
         mainAxisSpacing: mainAxisSpacing,
         crossAxisSpacing: crossAxisSpacing,
         crossAxisCount: crossAxisCount,
       );

  const _SliverPatternGridDelegate.extent({
    required List<T> pattern,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
  }) : this._(
         pattern: pattern,
         mainAxisSpacing: mainAxisSpacing,
         crossAxisSpacing: crossAxisSpacing,
         maxCrossAxisExtent: maxCrossAxisExtent,
       );

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final List<T> pattern;

  final int tileCount;

  final int? crossAxisCount;

  final double? maxCrossAxisExtent;

  @protected
  PatternGridGeometries getGeometries(
    SliverConstraints constraints,
    int crossAxisCount,
  );

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final crossAxisCount =
        this.crossAxisCount ?? (constraints.crossAxisExtent / (maxCrossAxisExtent! + crossAxisSpacing)).ceil();
    final geometries = getGeometries(constraints, crossAxisCount);
    return _SliverPatternGridLayout(
      mainAxisSpacing: mainAxisSpacing,
      crossAxisExtent: constraints.crossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
      tiles: geometries.tiles,
      bounds: geometries.bounds,
    );
  }

  @override
  bool shouldRelayout(_SliverPatternGridDelegate oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing;
  }
}

class _SliverPatternGridLayout extends SliverGridLayout {
  _SliverPatternGridLayout({
    required this.mainAxisSpacing,
    required this.tiles,
    required this.bounds,
    required this.crossAxisExtent,
    this.reverseCrossAxis = false,
  }) : tileCount = tiles.length,
       patternMainAxisExtent = bounds.last.trailingScrollOffset + mainAxisSpacing;

  final double mainAxisSpacing;
  final double crossAxisExtent;
  final bool reverseCrossAxis;
  final List<SliverGridGeometry> tiles;
  final List<SliverGridGeometry> bounds;
  final int tileCount;
  final double patternMainAxisExtent;

  @override
  double computeMaxScrollOffset(int childCount) {
    if (childCount == 0) {
      return 0;
    }

    final lastFilledPatternTrailingScrollOffset = (childCount ~/ tileCount) * patternMainAxisExtent;

    if (childCount % tileCount == 0) {
      return lastFilledPatternTrailingScrollOffset - mainAxisSpacing;
    }

    final maxIndex = (childCount - 1) % tileCount;
    final maxRemainingScrollOffset = tiles.take(maxIndex + 1).map((x) => x.trailingScrollOffset).reduce(math.max);
    return lastFilledPatternTrailingScrollOffset + maxRemainingScrollOffset;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final startMainAxisOffset = (index ~/ tileCount) * patternMainAxisExtent;
    final rect = tileRectAt(index);
    final realRect = _translate(rect, startMainAxisOffset);

    if (reverseCrossAxis) {
      return SliverGridGeometry(
        scrollOffset: realRect.scrollOffset,
        crossAxisOffset: crossAxisExtent - realRect.crossAxisOffset - realRect.crossAxisExtent,
        mainAxisExtent: realRect.mainAxisExtent,
        crossAxisExtent: realRect.crossAxisExtent,
      );
    }

    return realRect;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    final patternCount = (scrollOffset ~/ patternMainAxisExtent);
    final mainAxisOffset = scrollOffset - patternCount * patternMainAxisExtent;
    for (int i = 0; i < tileCount; i++) {
      if (_isRectVisibleAtMainAxisOffset(bounds[i], mainAxisOffset)) {
        return i + patternCount * tileCount;
      }
    }

    return 0;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    final patternCount = (scrollOffset ~/ patternMainAxisExtent);

    final mainAxisOffset = scrollOffset - patternCount * patternMainAxisExtent;
    for (int i = tileCount - 1; i >= 0; i--) {
      if (_isRectVisibleAtMainAxisOffset(bounds[i], mainAxisOffset)) {
        return i + patternCount * tileCount;
      }
    }

    return 0;
  }

  bool _isRectVisibleAtMainAxisOffset(
    SliverGridGeometry rect,
    double mainAxisOffset,
  ) {
    return rect.scrollOffset <= mainAxisOffset && rect.trailingScrollOffset >= (mainAxisOffset - mainAxisSpacing);
  }

  SliverGridGeometry tileRectAt(int index) {
    return tiles[index % tileCount];
  }

  SliverGridGeometry _translate(SliverGridGeometry rect, double translation) {
    return SliverGridGeometry(
      scrollOffset: rect.scrollOffset + translation,
      crossAxisOffset: rect.crossAxisOffset,
      mainAxisExtent: rect.mainAxisExtent,
      crossAxisExtent: rect.crossAxisExtent,
    );
  }
}
