import 'package:fl_scroll_view/fl_scroll_view.dart';

export 'package:easy_refresh/easy_refresh.dart';
export 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

export 'src/easy_refreshed.dart';
export 'src/scroll_list.dart';
export 'src/scroll_view.dart';
export 'src/sliver/sliver_list_grid.dart';
export 'src/sliver/sliver_persistent_header.dart';
export 'src/sliver/sliver_pinned_to_box_adapter.dart';

class FlScrollView {
  FlScrollView._();

  static Header globalRefreshHeader = const ClassicHeader(
      dragText: '请尽情拉我',
      armedText: '可以松开我了',
      readyText: '我要开始刷新了',
      processingText: '我在拼命刷新中',
      processedText: '我已经刷新完成了',
      failedText: '我刷新失败了唉',
      noMoreText: '没有更多了',
      showMessage: false);

  static Footer globalRefreshFooter = const ClassicFooter(
      dragText: '请尽情拉我',
      armedText: '可以松开我了',
      readyText: '我要准备加载了',
      processingText: '我在拼命加载中',
      processedText: '我已经加载完成了',
      failedText: '我加载失败了唉',
      noMoreText: '没有更多了哦',
      showMessage: false);
}
