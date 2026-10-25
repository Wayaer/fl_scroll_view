import 'package:flutter/foundation.dart' show precisionErrorTolerance;

/// 最短列 / 最小轨道：返回 [values] 中最小值下标（并列取最前）。
///
/// 用于 masonry、quilted 等按「当前最短」放置下一格的布局。
int indexOfSmallest(List<num> values) {
  assert(values.isNotEmpty);
  int index = 0;
  for (int i = 1; i < values.length; i++) {
    if (values[i] < values[index]) index = i;
  }
  return index;
}

/// 带浮点容差的 `a <= b`（[precisionErrorTolerance]）。
bool lessOrNearEqual(double a, double b) => a < b || (a - b).abs() < precisionErrorTolerance;
