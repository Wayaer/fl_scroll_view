import 'dart:async';

import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

extension ExtensionEasyRefreshController on EasyRefreshController {
  /// 根据 [FlEasyRefreshResult] 结束或触发刷新 / 加载。
  ///
  /// 也可在回调里直接调用 [finishRefresh] / [finishLoad] / [callRefresh] 等。
  void call(FlEasyRefreshResult result) {
    switch (result) {
      case FlEasyRefreshResult.refresh:
        callRefresh();
      case FlEasyRefreshResult.refreshSuccess:
        finishRefresh(IndicatorResult.success);
      case FlEasyRefreshResult.refreshFailed:
        finishRefresh(IndicatorResult.fail);
      case FlEasyRefreshResult.refreshNoMore:
        finishRefresh(IndicatorResult.noMore);
      case FlEasyRefreshResult.loading:
        callLoad();
      case FlEasyRefreshResult.loadingSuccess:
        finishLoad(IndicatorResult.success);
      case FlEasyRefreshResult.loadFailed:
        finishLoad(IndicatorResult.fail);
      case FlEasyRefreshResult.loadNoMore:
        finishLoad(IndicatorResult.noMore);
    }
  }
}

/// 刷新操作结果，可从 [FlEasyRefreshConfig.onRefresh] / [onLoad] 返回，
/// 由库自动调用 [EasyRefreshController.call]；也可在回调内自行 `controller.finishRefresh(...)`。
enum FlEasyRefreshResult {
  /// 触发刷新
  refresh,

  /// 刷新成功
  refreshSuccess,

  /// 刷新完成 没有数据
  refreshNoMore,

  /// 刷新失败
  refreshFailed,

  /// 触发加载
  loading,

  /// 加载成功
  loadingSuccess,

  /// 加载失败
  loadFailed,

  /// 加载完成 没有数据
  loadNoMore,
}

class FlEasyRefresh extends StatefulWidget {
  const FlEasyRefresh({super.key, this.child, this.builder, required this.config})
    : assert(child != null || builder != null);

  /// [EasyRefresh]
  final Widget? child;

  /// [EasyRefresh.builder]
  final ERChildBuilder? builder;

  /// [EasyRefresh] 配置
  final FlEasyRefreshConfig config;

  @override
  State<FlEasyRefresh> createState() => _FlEasyRefreshState();
}

class _FlEasyRefreshState extends State<FlEasyRefresh> {
  late EasyRefreshController controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _ownsController = config.controller == null;
    controller = config.controller ?? EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);
  }

  FlEasyRefreshConfig get config => widget.config;

  @override
  void didUpdateWidget(covariant FlEasyRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(config.controller, oldWidget.config.controller)) {
      _releaseController(oldWidget.config);
      _initController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final FutureOr<IndicatorResult?> Function()? onRefresh = config.onRefresh == null
        ? null
        : () async {
            try {
              final Object? result = await config.onRefresh!(controller);
              if (!mounted) return null;
              return _completeTask(result, refresh: true);
            } catch (error, stack) {
              final IndicatorResult? result = mounted
                  ? _completeTask(FlEasyRefreshResult.refreshFailed, refresh: true)
                  : null;
              FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack, library: 'fl_scroll_view'));
              return result;
            }
          };
    final FutureOr<IndicatorResult?> Function()? onLoad = config.onLoad == null
        ? null
        : () async {
            try {
              final Object? result = await config.onLoad!(controller);
              if (!mounted) return null;
              return _completeTask(result, refresh: false);
            } catch (error, stack) {
              final IndicatorResult? result = mounted
                  ? _completeTask(FlEasyRefreshResult.loadFailed, refresh: false)
                  : null;
              FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack, library: 'fl_scroll_view'));
              return result;
            }
          };
    if (widget.builder != null) {
      return EasyRefresh.builder(
        controller: controller,
        header: config.header,
        footer: config.footer,
        onRefresh: onRefresh,
        onLoad: onLoad,
        scrollController: config.scrollController,
        spring: config.spring,
        frictionFactor: config.frictionFactor,
        notRefreshHeader: config.notRefreshHeader,
        notLoadFooter: config.notLoadFooter,
        simultaneously: config.simultaneously,
        resetAfterRefresh: config.resetAfterRefresh,
        refreshOnStart: config.refreshOnStart,
        refreshOnStartHeader: config.refreshOnStartHeader,
        callRefreshOverOffset: config.callRefreshOverOffset,
        callLoadOverOffset: config.callLoadOverOffset,
        fit: config.fit,
        clipBehavior: config.clipBehavior,
        childBuilder: widget.builder,
        canLoadAfterNoMore: config.canLoadAfterNoMore,
        canRefreshAfterNoMore: config.canRefreshAfterNoMore,
        triggerAxis: config.triggerAxis,
        scrollBehaviorBuilder: config.scrollBehaviorBuilder,
        isNested: config.isNested,
        nestedOuterController: config.nestedOuterController,
        nestedInnerController: config.nestedInnerController,
      );
    }
    if (widget.child != null) {
      return EasyRefresh(
        controller: controller,
        header: config.header,
        footer: config.footer,
        onRefresh: onRefresh,
        onLoad: onLoad,
        scrollController: config.scrollController,
        spring: config.spring,
        frictionFactor: config.frictionFactor,
        notRefreshHeader: config.notRefreshHeader,
        notLoadFooter: config.notLoadFooter,
        simultaneously: config.simultaneously,
        resetAfterRefresh: config.resetAfterRefresh,
        refreshOnStart: config.refreshOnStart,
        refreshOnStartHeader: config.refreshOnStartHeader,
        callRefreshOverOffset: config.callRefreshOverOffset,
        callLoadOverOffset: config.callLoadOverOffset,
        fit: config.fit,
        clipBehavior: config.clipBehavior,
        canLoadAfterNoMore: config.canLoadAfterNoMore,
        canRefreshAfterNoMore: config.canRefreshAfterNoMore,
        triggerAxis: config.triggerAxis,
        scrollBehaviorBuilder: config.scrollBehaviorBuilder,
        isNested: config.isNested,
        nestedOuterController: config.nestedOuterController,
        nestedInnerController: config.nestedInnerController,
        child: widget.child,
      );
    }
    return const SizedBox();
  }

  /// 将回调返回值转换为 easy_refresh 的结束信号。
  ///
  /// controller 接管结束事件时由本库调用 finishRefresh / finishLoad；
  /// 否则返回 [IndicatorResult]，交给 EasyRefresh 自动结束。
  IndicatorResult? _completeTask(Object? result, {required bool refresh}) {
    if (result is IndicatorResult) return _applyResult(result, refresh: refresh);
    if (result is! FlEasyRefreshResult) return null;
    switch (result) {
      case FlEasyRefreshResult.refresh:
        controller.callRefresh();
        return null;
      case FlEasyRefreshResult.loading:
        controller.callLoad();
        return null;
      case FlEasyRefreshResult.refreshSuccess:
        return _applyResult(IndicatorResult.success, refresh: true, current: refresh);
      case FlEasyRefreshResult.refreshFailed:
        return _applyResult(IndicatorResult.fail, refresh: true, current: refresh);
      case FlEasyRefreshResult.refreshNoMore:
        return _applyResult(IndicatorResult.noMore, refresh: true, current: refresh);
      case FlEasyRefreshResult.loadingSuccess:
        return _applyResult(IndicatorResult.success, refresh: false, current: refresh);
      case FlEasyRefreshResult.loadFailed:
        return _applyResult(IndicatorResult.fail, refresh: false, current: refresh);
      case FlEasyRefreshResult.loadNoMore:
        return _applyResult(IndicatorResult.noMore, refresh: false, current: refresh);
    }
  }

  /// [refresh] 是结果对应的操作，[current] 是当前回调所属任务。
  ///
  /// 两者一致且 controller 未接管时，把结果返回给 EasyRefresh 自动结束；
  /// 跨操作结果则按原有语义强制结束目标操作。
  IndicatorResult? _applyResult(IndicatorResult result, {required bool refresh, bool? current}) {
    final bool takesOver = refresh ? controller.controlFinishRefresh : controller.controlFinishLoad;
    if (takesOver) {
      if (refresh) {
        controller.finishRefresh(result);
      } else {
        controller.finishLoad(result);
      }
      return null;
    }
    if (refresh == (current ?? refresh)) return result;
    if (refresh) {
      controller.finishRefresh(result, true);
    } else {
      controller.finishLoad(result, true);
    }
    return null;
  }

  @override
  void dispose() {
    _releaseController(config);
    super.dispose();
  }

  void _releaseController(FlEasyRefreshConfig disposingConfig) {
    // 仅销毁本组件创建的 controller；外部传入的由调用方自行 dispose
    if (_ownsController && disposingConfig.disposeController) controller.dispose();
  }
}

/// [FlEasyRefreshConfig.onRefresh] / [onLoad] 回调。
///
/// 参数为当前使用的 [EasyRefreshController]（外部传入或内部创建），可直接：
///
/// ```dart
/// onRefresh: (controller) async {
///   await loadData();
///   controller.finishRefresh(IndicatorResult.success);
///   // 或 return FlEasyRefreshResult.refreshSuccess;
/// }
/// ```
///
/// 返回值：
/// - [FlEasyRefreshResult]：库根据 controller 配置自动结束或触发对应操作
/// - [IndicatorResult]：作为本次任务结果；外部 controller 未接管结束事件时由 EasyRefresh 自动结束
/// - 其他 / `null`：需在回调内自行结束刷新或加载
///
/// 回调抛出的异常会被捕获并标记为失败，同时通过 [FlutterError.reportError] 上报，
/// 不会让指示器一直停留在 processing 状态。
typedef FlEasyRefreshCallback = FutureOr<dynamic> Function(EasyRefreshController controller);

class FlEasyRefreshConfig {
  const FlEasyRefreshConfig({
    this.controller,
    this.disposeController = true,
    this.onRefresh,
    this.onLoad,
    this.header,
    this.footer,
    this.spring,
    this.frictionFactor,
    this.simultaneously = false,
    this.canRefreshAfterNoMore = false,
    this.canLoadAfterNoMore = false,
    this.resetAfterRefresh = true,
    this.refreshOnStart = false,
    this.refreshOnStartHeader,
    this.callRefreshOverOffset = 20,
    this.callLoadOverOffset = 20,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.scrollController,
    this.notLoadFooter,
    this.notRefreshHeader,
    this.triggerAxis,
    this.scrollBehaviorBuilder,
    this.isNested = false,
    this.nestedOuterController,
    this.nestedInnerController,
  });

  /// 外部传入的 [EasyRefreshController]；为 null 时由 [FlEasyRefresh] 内部创建。
  ///
  /// 业务侧结束刷新 / 加载优先在 [onRefresh] / [onLoad] 回调参数上操作，
  /// 或在 State 中持有本字段以便页面其他位置触发 [EasyRefreshController.callRefresh]。
  ///
  /// 无需手动开启 `controlFinishRefresh` / `controlFinishLoad`：
  /// 未开启时库会把回调结果交给 EasyRefresh 自动结束，开启时则由库代为结束。
  final EasyRefreshController? controller;

  /// 是否在组件销毁时 dispose **内部创建** 的 controller，默认 true。
  /// 外部传入的 [controller] 不会被 dispose，需由调用方自行管理。
  final bool disposeController;

  /// 下拉刷新回调（null 为不开启刷新）。
  ///
  /// 回调参数为当前 [EasyRefreshController]，可直接 `controller.finishRefresh(...)`，
  /// 或返回 [FlEasyRefreshResult] 由库自动结束。
  final FlEasyRefreshCallback? onRefresh;

  /// 上拉加载回调（null 为不开启加载）。
  ///
  /// 用法同 [onRefresh]。
  final FlEasyRefreshCallback? onLoad;

  /// CustomHeader
  final Header? header;

  /// CustomFooter
  final Footer? footer;

  /// Structure that describes a spring's constants.
  /// When spring is not set in [Header] and [Footer].
  final SpringDescription? spring;

  /// Friction factor when list is out of bounds.
  final FrictionFactor? frictionFactor;

  /// Refresh and load can be performed simultaneously.
  final bool simultaneously;

  /// Is it possible to refresh after there is no more.
  final bool canRefreshAfterNoMore;

  /// Is it possible to load after there is no more.
  final bool canLoadAfterNoMore;

  /// Direction of execution.
  /// Other scroll directions will not show indicators and perform task.
  final Axis? triggerAxis;

  /// use [ERScrollBehavior] by default.
  final ERScrollBehaviorBuilder? scrollBehaviorBuilder;

  /// Use NestedScrollView-safe physics when this refresh wraps a nested scroll view.
  final bool isNested;

  /// Optional NestedScrollView outer [ScrollController].
  final ScrollController? nestedOuterController;

  /// Optional NestedScrollView inner [ScrollController].
  /// When the body has multiple inners, this should be the active inner.
  final ScrollController? nestedInnerController;

  /// Reset after refresh when no more deactivation is loaded.
  final bool resetAfterRefresh;

  /// Refresh on start.
  /// When the EasyRefresh build is complete, trigger the refresh.
  final bool refreshOnStart;

  /// Header for refresh on start.
  /// Use [header] when null.
  final Header? refreshOnStartHeader;

  /// Offset beyond trigger offset when calling refresh.
  /// Used when refreshOnStart is true and [EasyRefreshController.callRefresh].
  final double callRefreshOverOffset;

  /// Offset beyond trigger offset when calling load.
  /// Used when [EasyRefreshController.callLoad].
  final double callLoadOverOffset;

  /// See [Stack.StackFit]
  final StackFit fit;

  /// See [Stack.clipBehavior].
  final Clip clipBehavior;

  /// When the position cannot be determined, such as [NestedScrollView].
  /// Mainly used to trigger events.
  final ScrollController? scrollController;

  /// Overscroll behavior when [onRefresh] is null.
  /// Won't build widget.
  final NotRefreshHeader? notRefreshHeader;

  /// Overscroll behavior when [onLoad] is null.
  /// Won't build widget.
  final NotLoadFooter? notLoadFooter;

  FlEasyRefreshConfig copyWith({
    EasyRefreshController? controller,
    FlEasyRefreshCallback? onRefresh,
    FlEasyRefreshCallback? onLoad,
    Header? header,
    Footer? footer,
    SpringDescription? spring,
    FrictionFactor? frictionFactor,
    bool? simultaneously,
    bool? canRefreshAfterNoMore,
    bool? canLoadAfterNoMore,
    Axis? triggerAxis,
    ERScrollBehaviorBuilder? scrollBehaviorBuilder,
    bool? resetAfterRefresh,
    bool? refreshOnStart,
    Header? refreshOnStartHeader,
    double? callRefreshOverOffset,
    double? callLoadOverOffset,
    StackFit? fit,
    Clip? clipBehavior,
    ScrollController? scrollController,
    NotRefreshHeader? notRefreshHeader,
    NotLoadFooter? notLoadFooter,
    bool? disposeController,
    bool? isNested,
    ScrollController? nestedOuterController,
    ScrollController? nestedInnerController,
  }) => FlEasyRefreshConfig(
    disposeController: disposeController ?? this.disposeController,
    controller: controller ?? this.controller,
    onRefresh: onRefresh ?? this.onRefresh,
    onLoad: onLoad ?? this.onLoad,
    header: header ?? this.header,
    footer: footer ?? this.footer,
    spring: spring ?? this.spring,
    frictionFactor: frictionFactor ?? this.frictionFactor,
    simultaneously: simultaneously ?? this.simultaneously,
    canRefreshAfterNoMore: canRefreshAfterNoMore ?? this.canRefreshAfterNoMore,
    canLoadAfterNoMore: canLoadAfterNoMore ?? this.canLoadAfterNoMore,
    resetAfterRefresh: resetAfterRefresh ?? this.resetAfterRefresh,
    refreshOnStart: refreshOnStart ?? this.refreshOnStart,
    refreshOnStartHeader: refreshOnStartHeader ?? this.refreshOnStartHeader,
    callRefreshOverOffset: callRefreshOverOffset ?? this.callRefreshOverOffset,
    callLoadOverOffset: callLoadOverOffset ?? this.callLoadOverOffset,
    fit: fit ?? this.fit,
    clipBehavior: clipBehavior ?? this.clipBehavior,
    scrollController: scrollController ?? this.scrollController,
    notLoadFooter: notLoadFooter ?? this.notLoadFooter,
    notRefreshHeader: notRefreshHeader ?? this.notRefreshHeader,
    triggerAxis: triggerAxis ?? this.triggerAxis,
    scrollBehaviorBuilder: scrollBehaviorBuilder ?? this.scrollBehaviorBuilder,
    isNested: isNested ?? this.isNested,
    nestedOuterController: nestedOuterController ?? this.nestedOuterController,
    nestedInnerController: nestedInnerController ?? this.nestedInnerController,
  );

  FlEasyRefreshConfig marge([FlEasyRefreshConfig? config]) => copyWith(
    controller: config?.controller,
    onRefresh: config?.onRefresh,
    onLoad: config?.onLoad,
    header: config?.header,
    footer: config?.footer,
    spring: config?.spring,
    frictionFactor: config?.frictionFactor,
    simultaneously: config?.simultaneously,
    canRefreshAfterNoMore: config?.canRefreshAfterNoMore,
    canLoadAfterNoMore: config?.canLoadAfterNoMore,
    resetAfterRefresh: config?.resetAfterRefresh,
    refreshOnStart: config?.refreshOnStart,
    refreshOnStartHeader: config?.refreshOnStartHeader,
    callRefreshOverOffset: config?.callRefreshOverOffset,
    callLoadOverOffset: config?.callLoadOverOffset,
    fit: config?.fit,
    clipBehavior: config?.clipBehavior,
    scrollController: config?.scrollController,
    notLoadFooter: config?.notLoadFooter,
    notRefreshHeader: config?.notRefreshHeader,
    triggerAxis: config?.triggerAxis,
    scrollBehaviorBuilder: config?.scrollBehaviorBuilder,
    disposeController: config?.disposeController,
    isNested: config?.isNested,
    nestedOuterController: config?.nestedOuterController,
    nestedInnerController: config?.nestedInnerController,
  );
}
