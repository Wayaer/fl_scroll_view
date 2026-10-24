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
  const FlEasyRefresh({
    super.key,
    this.child,
    this.builder,
    required this.config,
  }) : assert(child != null || builder != null);

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
    controller =
        config.controller ??
        EasyRefreshController(
          controlFinishRefresh: config.onRefresh != null,
          controlFinishLoad: config.onLoad != null,
        );
  }

  FlEasyRefreshConfig get config => widget.config;

  @override
  void didUpdateWidget(covariant FlEasyRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldConfig = oldWidget.config;
    final bool controllerChanged = !identical(config.controller, oldConfig.controller);
    final bool finishFlagsChanged =
        _ownsController &&
        ((config.onRefresh != null) != (oldConfig.onRefresh != null) ||
            (config.onLoad != null) != (oldConfig.onLoad != null));
    if (controllerChanged || finishFlagsChanged) {
      _releaseController(oldConfig);
      _initController();
    }
  }

  @override
  Widget build(BuildContext context) {
    FutureOr<void> Function()? onRefresh;
    if (config.onRefresh != null) {
      onRefresh = () async {
        final result = await config.onRefresh!.call(controller);
        if (!mounted) return;
        // 返回 FlEasyRefreshResult 时自动结束；也可在回调内直接 controller.finishRefresh(...)
        if (result is FlEasyRefreshResult) controller(result);
      };
    }
    FutureOr<void> Function()? onLoad;
    if (config.onLoad != null) {
      onLoad = () async {
        final result = await config.onLoad!.call(controller);
        if (!mounted) return;
        if (result is FlEasyRefreshResult) controller(result);
      };
    }
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
/// - [FlEasyRefreshResult]：库在回调结束后自动 [EasyRefreshController.call]
/// - 其他 / `null`：需在回调内自行结束刷新或加载
typedef FlEasyRefreshCallback = FutureOr<dynamic> Function(
  EasyRefreshController controller,
);

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
