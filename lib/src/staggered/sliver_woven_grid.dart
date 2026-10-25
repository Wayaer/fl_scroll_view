part of 'sliver_patterned_grids.dart';

@immutable
class WovenGridTile {
  const WovenGridTile(this.aspectRatio, {this.crossAxisRatio = 1, this.alignment = AlignmentDirectional.center})
    : assert(aspectRatio > 0),
      assert(crossAxisRatio > 0 && crossAxisRatio <= 1);

  final double aspectRatio;

  final double crossAxisRatio;

  final AlignmentDirectional alignment;

  @override
  bool operator ==(Object other) =>
      other is WovenGridTile &&
      other.aspectRatio == aspectRatio &&
      other.crossAxisRatio == crossAxisRatio &&
      other.alignment == alignment;

  @override
  int get hashCode => Object.hash(aspectRatio, crossAxisRatio, alignment);

  @override
  String toString() {
    final String ratio = crossAxisRatio > 1 ? ', $crossAxisRatio' : '';
    final String align = alignment != AlignmentDirectional.center ? ', $alignment' : '';
    return 'WovenGridTile($aspectRatio$ratio$align)';
  }
}

class SliverWovenGridDelegate extends _SliverPatternGridDelegate<WovenGridTile> {
  const SliverWovenGridDelegate.count({
    required super.pattern,
    required super.crossAxisCount,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    this.tileBottomSpace = 0,
  }) : assert(pattern.length <= crossAxisCount),
       super.count();

  const SliverWovenGridDelegate.extent({
    required super.pattern,
    required super.maxCrossAxisExtent,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    this.tileBottomSpace = 0,
  }) : super.extent();

  final double tileBottomSpace;

  @override
  PatternGridGeometries getGeometries(SliverConstraints constraints, int crossAxisCount) {
    final isHorizontal = constraints.axis == Axis.horizontal;
    final usableCrossAxisExtent = isHorizontal
        ? constraints.crossAxisExtent - crossAxisCount * tileBottomSpace
        : constraints.crossAxisExtent;
    final crossAxisExtent = (usableCrossAxisExtent + crossAxisSpacing) / crossAxisCount - crossAxisSpacing;
    final crossAxisStride = crossAxisExtent + crossAxisSpacing;
    final patternCount = pattern.length;

    final maxMainAxisExtentRatio = pattern.map((t) => t.crossAxisRatio / t.aspectRatio).reduce(math.max);
    final mainAxisExtent = crossAxisExtent * maxMainAxisExtentRatio + (isHorizontal ? 0 : tileBottomSpace);

    final count = crossAxisCount * 2;
    final tiles = List.filled(count, _kZeroGeometry);
    final bounds = List.filled(count, _kZeroGeometry);
    for (int i = 0; i < count; i++) {
      final startScrollOffset = i < crossAxisCount ? 0.0 : mainAxisExtent + mainAxisSpacing;
      final tilePatternIndex = i < crossAxisCount
          ? i % patternCount
          : (count - 1 - (i % crossAxisCount)) % patternCount;
      final tilePattern = pattern[tilePatternIndex];
      final tileCrossAxisExtent = crossAxisExtent * tilePattern.crossAxisRatio + (isHorizontal ? tileBottomSpace : 0);
      final tileMainAxisExtent = tileCrossAxisExtent / tilePattern.aspectRatio + (isHorizontal ? 0 : tileBottomSpace);
      final effectiveTextDirection = i < crossAxisCount ? TextDirection.ltr : TextDirection.rtl;
      final effectiveAlignment = tilePattern.alignment.resolve(effectiveTextDirection);
      final rect = effectiveAlignment.inscribe(
        Size(tileCrossAxisExtent, tileMainAxisExtent),
        Rect.fromLTWH(0, 0, crossAxisExtent, mainAxisExtent),
      );
      final startCrossAxisOffset = (i % crossAxisCount) * crossAxisStride;
      tiles[i] = SliverGridGeometry(
        scrollOffset: startScrollOffset + rect.top,
        crossAxisOffset: startCrossAxisOffset + rect.left,
        mainAxisExtent: tileMainAxisExtent,
        crossAxisExtent: tileCrossAxisExtent,
      );
      bounds[i] = SliverGridGeometry(
        scrollOffset: startScrollOffset,
        crossAxisOffset: startCrossAxisOffset,
        mainAxisExtent: mainAxisExtent,
        crossAxisExtent: crossAxisExtent,
      );
    }

    return PatternGridGeometries(tiles: tiles, bounds: bounds);
  }

  @override
  bool shouldRelayout(SliverWovenGridDelegate oldDelegate) {
    return super.shouldRelayout(oldDelegate) ||
        oldDelegate.tileBottomSpace != tileBottomSpace ||
        oldDelegate.crossAxisCount != crossAxisCount;
  }
}
