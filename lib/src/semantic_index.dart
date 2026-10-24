import 'package:flutter/widgets.dart';

/// 默认 [SemanticIndexCallback]：语义索引等于子项 local index。
int kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;
