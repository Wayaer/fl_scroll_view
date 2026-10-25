import 'dart:math' as math;

import 'package:flutter/rendering.dart';

abstract class SliverSimpleGridDelegate {
  const SliverSimpleGridDelegate();

  int getCrossAxisCount(SliverConstraints constraints, double crossAxisSpacing);

  bool shouldRelayout(covariant SliverSimpleGridDelegate oldDelegate);
}

class SliverSimpleGridDelegateWithFixedCrossAxisCount extends SliverSimpleGridDelegate {
  const SliverSimpleGridDelegateWithFixedCrossAxisCount({required this.crossAxisCount}) : assert(crossAxisCount > 0);

  final int crossAxisCount;

  @override
  int getCrossAxisCount(SliverConstraints constraints, double crossAxisSpacing) {
    return crossAxisCount;
  }

  @override
  bool shouldRelayout(SliverSimpleGridDelegateWithFixedCrossAxisCount oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount;
  }
}

class SliverSimpleGridDelegateWithMaxCrossAxisExtent extends SliverSimpleGridDelegate {
  const SliverSimpleGridDelegateWithMaxCrossAxisExtent({required this.maxCrossAxisExtent})
    : assert(maxCrossAxisExtent > 0);

  final double maxCrossAxisExtent;

  @override
  int getCrossAxisCount(SliverConstraints constraints, double crossAxisSpacing) {
    return math.max(1, (constraints.crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing)).ceil());
  }

  @override
  bool shouldRelayout(SliverSimpleGridDelegateWithMaxCrossAxisExtent oldDelegate) {
    return oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent;
  }
}
