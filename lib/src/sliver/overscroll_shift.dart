import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

/// 下拉刷新时让固定头部跟随 overscroll 下移，避免遮挡刷新指示器。
///
/// 收起状态下不做位移，因此正常上滑时仍然保持固定。
/// 仅库内部使用，不对外导出。
class FlOverscrollShift extends StatelessWidget {
  const FlOverscrollShift({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final EasyRefreshData? data = _easyRefreshData(context);
    if (data == null) return child;
    return AnimatedBuilder(
      animation: data.headerNotifier,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double offset = data.headerNotifier.offset;
        final Axis? axis = data.headerNotifier.axis;
        if (offset <= 0 || axis == null) {
          return Transform.translate(offset: Offset.zero, child: child);
        }
        final AxisDirection? axisDirection = data.headerNotifier.axisDirection;
        final bool reversed = axisDirection == AxisDirection.up || axisDirection == AxisDirection.left;
        final double delta = reversed ? -offset : offset;
        return Transform.translate(offset: axis == Axis.vertical ? Offset(0, delta) : Offset(delta, 0), child: child);
      },
    );
  }

  static EasyRefreshData? _easyRefreshData(BuildContext context) {
    if (context.findAncestorWidgetOfExactType<EasyRefresh>() == null) return null;
    return EasyRefresh.of(context);
  }
}
