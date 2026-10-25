import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

@immutable
class QuiltedGridTile {
  const QuiltedGridTile(this.mainAxisCount, this.crossAxisCount)
    : assert(mainAxisCount > 0),
      assert(crossAxisCount > 0);

  final int mainAxisCount;

  final int crossAxisCount;

  @override
  String toString() {
    return 'QuiltedGridTile($mainAxisCount, $crossAxisCount)';
  }
}

class SliverQuiltedGridDelegate extends SliverGridDelegate {
  SliverQuiltedGridDelegate({
    required this.crossAxisCount,
    required List<QuiltedGridTile> pattern,
    this.repeatPattern = QuiltedGridRepeatPattern.same,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  }) : assert(crossAxisCount > 0),
       assert(mainAxisSpacing >= 0),
       assert(crossAxisSpacing >= 0),
       pattern = _validatedPattern(pattern, crossAxisCount),
       _pattern = _toPattern(pattern, crossAxisCount, repeatPattern);

  static List<QuiltedGridTile> _validatedPattern(List<QuiltedGridTile> pattern, int crossAxisCount) {
    if (pattern.isEmpty) {
      throw ArgumentError.value(pattern, 'pattern', 'pattern 不能为空');
    }
    if (pattern.any((QuiltedGridTile tile) => tile.crossAxisCount > crossAxisCount)) {
      throw ArgumentError.value(pattern, 'pattern', 'QuiltedGridTile.crossAxisCount 不能超过 crossAxisCount');
    }
    return List<QuiltedGridTile>.of(pattern);
  }

  final int crossAxisCount;

  final List<QuiltedGridTile> pattern;

  final QuiltedGridRepeatPattern repeatPattern;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final _QuiltedTilePattern _pattern;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final crossAxisExtent = constraints.crossAxisExtent;
    final cellExtent = (crossAxisExtent + crossAxisSpacing) / crossAxisCount - crossAxisSpacing;
    return _SliverQuiltedGridLayout(
      cellExtent: cellExtent,
      crossAxisExtent: crossAxisExtent,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      pattern: _pattern,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverQuiltedGridDelegate oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.repeatPattern != repeatPattern ||
        !_samePattern(oldDelegate.pattern, pattern);
  }

  static bool _samePattern(List<QuiltedGridTile> a, List<QuiltedGridTile> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].mainAxisCount != b[i].mainAxisCount || a[i].crossAxisCount != b[i].crossAxisCount) return false;
    }
    return true;
  }

  static _QuiltedTilePattern _toPattern(
    List<QuiltedGridTile> source,
    int crossAxisCount,
    QuiltedGridRepeatPattern repeatPattern,
  ) {
    final tileCount = source.length + repeatPattern.repeatedTileCount(source.length);
    final minTileIndexes = <int>[];
    final maxTileIndexes = <int>[];
    final maxMainAxisCellCounts = List<int>.filled(tileCount, 0);
    final mainAxisIndexes = List<int>.filled(tileCount, 0);
    final crossAxisIndexes = List<int>.filled(tileCount, 0);
    final indexes = <int, int>{};

    final offsets = List<int>.generate(crossAxisCount, (index) => 0);
    void position(List<QuiltedGridTile> tiles, Map<int, int>? cellIndexes, int start) {
      for (int i = 0; i < tiles.length; i++) {
        final tile = tiles[i];
        final fullIndex = start + i;
        final tileCrossAxisCount = tile.crossAxisCount;
        final tileMainAxisCount = tile.mainAxisCount;

        // 只在能完整放下当前 tile 的起始列中选择最矮的一列，
        // 否则跨列 tile 落在最后一列时会越界。
        final int lastStart = crossAxisCount - tileCrossAxisCount;
        int crossAxisIndex = 0;
        int smallestOffset = offsets[0];
        for (int candidate = 1; candidate <= lastStart; candidate++) {
          if (offsets[candidate] < smallestOffset) {
            smallestOffset = offsets[candidate];
            crossAxisIndex = candidate;
          }
        }

        final mainAxisIndex = offsets[crossAxisIndex];
        mainAxisIndexes[fullIndex] = mainAxisIndex;
        crossAxisIndexes[fullIndex] = crossAxisIndex;
        for (int j = 0; j < tileCrossAxisCount; j++) {
          offsets[crossAxisIndex + j] += tileMainAxisCount;
          if (cellIndexes != null) {
            for (int k = 0; k < tileMainAxisCount; k++) {
              final cellIndex = (crossAxisIndex + j) + (mainAxisIndex + k) * crossAxisCount;
              cellIndexes[cellIndex] = i;
            }
          }
        }

        for (int j = 0; j < tileMainAxisCount; j++) {
          final index = mainAxisIndex + j;
          if (minTileIndexes.length == index) {
            minTileIndexes.add(fullIndex);
          } else {
            minTileIndexes[index] = math.min(minTileIndexes[index], fullIndex);
          }
          if (maxTileIndexes.length == index) {
            maxTileIndexes.add(fullIndex);
          } else {
            maxTileIndexes[index] = math.max(maxTileIndexes[index], fullIndex);
          }
        }

        maxMainAxisCellCounts[fullIndex] = offsets.reduce(math.max);
      }
    }

    position(source, indexes, 0);
    // 允许 tile 之间留下空格，indexList 需要覆盖到最大 cell 并补齐整行。
    final int maxCellIndex = indexes.keys.reduce(math.max);
    final int mainAxisCellCount = maxCellIndex ~/ crossAxisCount + 1;
    final indexList = List<int>.filled(mainAxisCellCount * crossAxisCount, -1);
    for (final MapEntry<int, int> entry in indexes.entries) {
      indexList[entry.key] = entry.value;
    }
    final repeatedIndexes = repeatPattern.repeatedIndexes(indexList, crossAxisCount);
    final tiles = source.toList();
    if (repeatedIndexes.isNotEmpty) {
      final repeatedTiles = repeatedIndexes.map((index) => source[index]).toList();
      position(repeatedTiles, null, source.length);
      tiles.addAll(repeatedTiles);
    }

    return _QuiltedTilePattern(
      tiles: tiles,
      mainAxisIndexes: mainAxisIndexes,
      crossAxisIndexes: crossAxisIndexes,
      maxMainAxisCellCounts: maxMainAxisCellCounts,
      minTileIndexes: minTileIndexes,
      maxTileIndexes: maxTileIndexes,
      mainAxisCellCount: offsets.reduce(math.max),
    );
  }
}

class _QuiltedTilePattern {
  const _QuiltedTilePattern({
    required this.tiles,
    required this.crossAxisIndexes,
    required this.mainAxisIndexes,
    required this.maxMainAxisCellCounts,
    required this.minTileIndexes,
    required this.maxTileIndexes,
    required this.mainAxisCellCount,
  }) : tileCount = tiles.length;

  final List<QuiltedGridTile> tiles;
  final int tileCount;
  final List<int> crossAxisIndexes;
  final List<int> mainAxisIndexes;
  final List<int> maxMainAxisCellCounts;
  final List<int> minTileIndexes;
  final List<int> maxTileIndexes;
  final int mainAxisCellCount;

  int crossAxisIndexOf(int index) {
    return crossAxisIndexes[index % tileCount];
  }

  int mainAxisIndexOf(int index) {
    return mainAxisIndexes[index % tileCount];
  }

  int maxMainAxisCellCountOf(int count) {
    return maxMainAxisCellCounts[count % tileCount];
  }

  int getMinTileIndexForMainAxisIndex(int mainAxisIndex) {
    return minTileIndexes[mainAxisIndex % mainAxisCellCount];
  }

  int getMaxTileIndexForMainAxisIndex(int mainAxisIndex) {
    return maxTileIndexes[mainAxisIndex % mainAxisCellCount];
  }

  QuiltedGridTile tileOf(int index) {
    return tiles[index % tileCount];
  }
}

class _SliverQuiltedGridLayout extends SliverGridLayout {
  const _SliverQuiltedGridLayout({
    required double cellExtent,
    required this.crossAxisExtent,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.pattern,
    required this.reverseCrossAxis,
  }) : assert(cellExtent > 0),
       assert(mainAxisSpacing >= 0),
       assert(crossAxisSpacing >= 0),
       mainAxisStride = cellExtent + mainAxisSpacing,
       crossAxisStride = cellExtent + crossAxisSpacing;

  final double crossAxisExtent;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final double mainAxisStride;

  final double crossAxisStride;

  final _QuiltedTilePattern pattern;

  final bool reverseCrossAxis;

  @override
  double computeMaxScrollOffset(int childCount) {
    if (childCount == 0) {
      return 0;
    }

    final mainAxisCellCountBeforeLastPattern = (childCount ~/ pattern.tileCount) * pattern.mainAxisCellCount;

    final remainingChildCount = childCount % pattern.tileCount;

    final remainingMainAxisCellCount = remainingChildCount == 0
        ? 0
        : pattern.maxMainAxisCellCountOf(remainingChildCount - 1);

    final nbCellsInMainAxis = mainAxisCellCountBeforeLastPattern + remainingMainAxisCellCount;

    return nbCellsInMainAxis * mainAxisStride - mainAxisSpacing;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final mainAxisCellCountBeforeLastPattern = (index ~/ pattern.tileCount) * pattern.mainAxisCellCount;
    final mainAxisIndex = mainAxisCellCountBeforeLastPattern + pattern.mainAxisIndexOf(index);
    final crossAxisIndex = pattern.crossAxisIndexOf(index);
    final tile = pattern.tileOf(index);

    final crossAxisExtent = tile.crossAxisCount * crossAxisStride - crossAxisSpacing;

    return SliverGridGeometry(
      scrollOffset: mainAxisIndex * mainAxisStride,
      crossAxisOffset: _getOffsetFromStartInCrossAxis(crossAxisIndex * crossAxisStride, crossAxisExtent),
      mainAxisExtent: tile.mainAxisCount * mainAxisStride - mainAxisSpacing,
      crossAxisExtent: crossAxisExtent,
    );
  }

  double _getOffsetFromStartInCrossAxis(double crossAxisStart, double childCrossAxisExtent) {
    if (reverseCrossAxis) return crossAxisExtent - crossAxisStart - childCrossAxisExtent;
    return crossAxisStart;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    final mainAxisIndex = (scrollOffset ~/ mainAxisStride);
    final a = (mainAxisIndex ~/ pattern.mainAxisCellCount) * pattern.tileCount;
    final result = a + pattern.getMinTileIndexForMainAxisIndex(mainAxisIndex);
    return result;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    final mainAxisIndex = (scrollOffset ~/ mainAxisStride);
    final a = (mainAxisIndex ~/ pattern.mainAxisCellCount) * pattern.tileCount;
    final result = a + pattern.getMaxTileIndexForMainAxisIndex(mainAxisIndex);
    return result;
  }
}

abstract class QuiltedGridRepeatPattern {
  const QuiltedGridRepeatPattern();

  static const QuiltedGridRepeatPattern same = _QuiltedGridRepeatSamePattern();

  static const QuiltedGridRepeatPattern inverted = _QuiltedGridRepeatInvertedPattern();

  static const QuiltedGridRepeatPattern mirrored = _QuiltedGridRepeatMirroredPattern();

  List<int> repeatedIndexes(List<int> indexes, int crossAxisCount);

  int repeatedTileCount(int tileCount);
}

class _QuiltedGridRepeatSamePattern extends QuiltedGridRepeatPattern {
  const _QuiltedGridRepeatSamePattern();

  @override
  List<int> repeatedIndexes(List<int> indexes, int crossAxisCount) {
    return [];
  }

  @override
  int repeatedTileCount(int tileCount) => 0;
}

class _QuiltedGridRepeatInvertedPattern extends QuiltedGridRepeatPattern {
  const _QuiltedGridRepeatInvertedPattern();

  @override
  List<int> repeatedIndexes(List<int> indexes, int crossAxisCount) {
    final result = <int>[];
    final added = <int>{};
    for (int i = indexes.length - 1; i >= 0; i--) {
      final index = indexes[i];
      if (index != -1 && !added.contains(index)) {
        result.add(index);
        added.add(index);
      }
    }

    return result;
  }

  @override
  int repeatedTileCount(int tileCount) => tileCount;
}

class _QuiltedGridRepeatMirroredPattern extends QuiltedGridRepeatPattern {
  const _QuiltedGridRepeatMirroredPattern();

  @override
  List<int> repeatedIndexes(List<int> indexes, int crossAxisCount) {
    final result = <int>[];
    final added = <int>{};

    final mainAxisCount = indexes.length ~/ crossAxisCount;

    for (int i = mainAxisCount - 1; i >= 0; i--) {
      for (int j = 0; j < crossAxisCount; j++) {
        final index = indexes[i * crossAxisCount + j];
        if (index != -1 && !added.contains(index)) {
          result.add(index);
          added.add(index);
        }
      }
    }

    return result;
  }

  @override
  int repeatedTileCount(int tileCount) => tileCount;
}
