part of 'sliver_patterned_grids.dart';

@immutable
class StairedGridTile {
  const StairedGridTile(this.crossAxisRatio, this.aspectRatio)
    : assert(crossAxisRatio > 0 && crossAxisRatio <= 1),
      assert(aspectRatio > 0);

  final double crossAxisRatio;

  final double aspectRatio;

  @override
  String toString() => 'StairedGridTile($crossAxisRatio, $aspectRatio)';
}

class SliverStairedGridDelegate extends _SliverPatternGridDelegate<StairedGridTile> {
  const SliverStairedGridDelegate({
    required super.pattern,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    this.tileBottomSpace = 0,
    this.startCrossAxisDirectionReversed = false,
  }) : assert(tileBottomSpace >= 0),
       super.count(crossAxisCount: 1);

  final double tileBottomSpace;

  final bool startCrossAxisDirectionReversed;

  @override
  PatternGridGeometries getGeometries(SliverConstraints constraints, int crossAxisCount) {
    final maxCrossAxisExtent = constraints.crossAxisExtent;
    final List<SliverGridGeometry> geometries = List.filled(pattern.length, _kZeroGeometry);
    int i = 0;
    double mainAxisOffset = 0;
    double crossAxisOffset = startCrossAxisDirectionReversed ? maxCrossAxisExtent : 0;
    bool reversed = startCrossAxisDirectionReversed;
    while (i < tileCount) {
      int startIndex = i;
      double crossAxisRatioSum = 0;
      while (crossAxisRatioSum < 1 && i < tileCount) {
        crossAxisRatioSum += pattern[i].crossAxisRatio;
        i++;
      }
      if (crossAxisRatioSum > 1) {
        i--;
      }
      final tileBottomSpaceSum = tileBottomSpace * (i - startIndex);
      final isHorizontal = constraints.axis == Axis.horizontal;
      final usableCrossAxisExtent =
          ((startIndex == 0 ? maxCrossAxisExtent : maxCrossAxisExtent - crossAxisSpacing) -
                  (i - startIndex - 1) * crossAxisSpacing -
                  (i == tileCount ? crossAxisSpacing : 0) -
                  (isHorizontal ? tileBottomSpaceSum : 0))
              .clamp(0, maxCrossAxisExtent);

      double targetMainAxisOffset = 0;
      for (int j = startIndex; j < i; j++) {
        final tile = pattern[j];
        final crossAxisExtent = usableCrossAxisExtent * tile.crossAxisRatio + (isHorizontal ? tileBottomSpace : 0);
        final mainAxisExtent = crossAxisExtent / tile.aspectRatio + (isHorizontal ? 0 : tileBottomSpace);
        crossAxisOffset = reversed ? crossAxisOffset - crossAxisExtent : crossAxisOffset;
        final tileRect = SliverGridGeometry(
          scrollOffset: mainAxisOffset,
          crossAxisOffset: crossAxisOffset,
          mainAxisExtent: mainAxisExtent,
          crossAxisExtent: crossAxisExtent,
        );
        final endMainAxisOffset = mainAxisOffset + mainAxisExtent;

        crossAxisOffset = reversed
            ? crossAxisOffset - crossAxisSpacing
            : crossAxisOffset + crossAxisExtent + crossAxisSpacing;
        mainAxisOffset += mainAxisSpacing;
        geometries[j] = tileRect;
        if (endMainAxisOffset > targetMainAxisOffset) {
          targetMainAxisOffset = endMainAxisOffset;
        }
      }

      mainAxisOffset = targetMainAxisOffset + mainAxisSpacing;
      reversed = !reversed;
      crossAxisOffset = reversed ? maxCrossAxisExtent - crossAxisSpacing : crossAxisSpacing;
    }

    return PatternGridGeometries(tiles: geometries, bounds: geometries);
  }

  @override
  bool shouldRelayout(SliverStairedGridDelegate oldDelegate) {
    return super.shouldRelayout(oldDelegate) ||
        oldDelegate.tileBottomSpace != tileBottomSpace ||
        oldDelegate.startCrossAxisDirectionReversed != startCrossAxisDirectionReversed;
  }
}
