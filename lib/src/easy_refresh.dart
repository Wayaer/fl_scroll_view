import 'dart:async';

import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/material.dart';

class FlEasyRefreshControllers {
  factory FlEasyRefreshControllers() =>
      _singleton ??= FlEasyRefreshControllers._();

  FlEasyRefreshControllers._();

  static FlEasyRefreshControllers? _singleton;

  /// 所有的控制器
  final Map<int, EasyRefreshController> _controllers = {};

  Map<int, EasyRefreshController> get controllers => _controllers;

  /// 根据 id 获取控制器
  EasyRefreshController? get(int controllersId) => _controllers[controllersId];

  /// 最近一次调用刷新组件的 Controller
  EasyRefreshController? _last;

  EasyRefreshController? get last => _last;
}

extension ExtensionEasyRefreshController on EasyRefreshController {
  void call(FlEasyRefreshResult result) {
    switch (result) {
      case FlEasyRefreshResult.refresh:
        callRefresh();
        break;
      case FlEasyRefreshResult.refreshSuccess:
        finishRefresh(IndicatorResult.success);
        break;
      case FlEasyRefreshResult.refreshFailed:
        finishRefresh(IndicatorResult.fail);
        break;
      case FlEasyRefreshResult.refreshNoMore:
        finishRefresh(IndicatorResult.noMore);
        break;
      case FlEasyRefreshResult.loading:
        callLoad();
        break;
      case FlEasyRefreshResult.loadingSuccess:
        finishLoad(IndicatorResult.success);
        break;
      case FlEasyRefreshResult.loadFailed:
        finishLoad(IndicatorResult.fail);
        break;
      case FlEasyRefreshResult.loadNoMore:
        finishLoad(IndicatorResult.noMore);
        break;
    }
  }
}

/// 刷新操作
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

  /// [EasyRefresh]配置信息
  final FlEasyRefreshConfig config;

  @override
  State<FlEasyRefresh> createState() => _FlEasyRefreshState();
}

class _FlEasyRefreshState extends State<FlEasyRefresh> {
  late EasyRefreshController controller;

  @override
  void initState() {
    initController();
    super.initState();
  }

  void initController() {
    controller = config.controller ??
        EasyRefreshController(
            controlFinishRefresh: config.onRefresh != null,
            controlFinishLoad: config.onLoad != null);
    controllers[controllerId] = controller;
  }

  int get controllerId => widget.config.controllerId ?? controller.hashCode;

  FlEasyRefreshConfig get config => widget.config;

  Map<int, EasyRefreshController> get controllers =>
      FlEasyRefreshControllers()._controllers;

  @override
  void didUpdateWidget(covariant FlEasyRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      if (config.controller != null && controller != config.controller) {
        removeController();
        initController();
      }
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    FutureOr Function()? onRefresh;
    if (config.onRefresh != null) {
      onRefresh = () async {
        FlEasyRefreshControllers()._last = controller;
        final result = await config.onRefresh!.call(controller);
        if (result is FlEasyRefreshResult) controller(result);
      };
    }
    FutureOr Function()? onLoad;
    if (config.onLoad != null) {
      onLoad = () async {
        FlEasyRefreshControllers()._last = controller;
        final result = await config.onLoad!.call(controller);
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
        child: widget.child,
      );
    }
    return SizedBox();
  }

  @override
  void dispose() {
    removeController();
    super.dispose();
  }

  void removeController() {
    if (!config.disposeController) return;
    controller.dispose();
    controllers.remove(controllerId);
    if (controller.hashCode == FlEasyRefreshControllers()._last.hashCode) {
      FlEasyRefreshControllers()._last = controllers.values.lastOrNull;
    }
  }
}

/// return [Null] or [FlEasyRefreshResult]
typedef FlEasyRefreshCallback = FutureOr<dynamic> Function(
    EasyRefreshController controller);

class FlEasyRefreshConfig {
  const FlEasyRefreshConfig(
      {this.controller,
      this.controllerId,
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
      this.scrollBehaviorBuilder});

  /// 可不传controller，
  /// 若想关闭刷新组件可以通过发送消息
  final EasyRefreshController? controller;

  /// 是否销毁 controller 默认 true
  final bool disposeController;

  /// 每个 controller id 用于[FlEasyRefreshControllers.controllers]获取 controller
  final int? controllerId;

  /// 下拉刷新回调(null为不开启刷新)
  final FlEasyRefreshCallback? onRefresh;

  /// 上拉加载回调(null为不开启加载)
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
  }) =>
      FlEasyRefreshConfig(
          controller: controller ?? this.controller,
          onRefresh: onRefresh ?? this.onRefresh,
          onLoad: onLoad ?? this.onLoad,
          header: header ?? this.header,
          footer: footer ?? this.footer,
          spring: spring ?? this.spring,
          frictionFactor: frictionFactor ?? this.frictionFactor,
          simultaneously: simultaneously ?? this.simultaneously,
          canRefreshAfterNoMore:
              canRefreshAfterNoMore ?? this.canRefreshAfterNoMore,
          canLoadAfterNoMore: canLoadAfterNoMore ?? this.canLoadAfterNoMore,
          resetAfterRefresh: resetAfterRefresh ?? this.resetAfterRefresh,
          refreshOnStart: refreshOnStart ?? this.refreshOnStart,
          refreshOnStartHeader:
              refreshOnStartHeader ?? this.refreshOnStartHeader,
          callRefreshOverOffset:
              callRefreshOverOffset ?? this.callRefreshOverOffset,
          callLoadOverOffset: callLoadOverOffset ?? this.callLoadOverOffset,
          fit: fit ?? this.fit,
          clipBehavior: clipBehavior ?? this.clipBehavior,
          scrollController: scrollController ?? this.scrollController,
          notLoadFooter: notLoadFooter ?? this.notLoadFooter,
          notRefreshHeader: notRefreshHeader ?? this.notRefreshHeader,
          triggerAxis: triggerAxis ?? this.triggerAxis,
          scrollBehaviorBuilder:
              scrollBehaviorBuilder ?? this.scrollBehaviorBuilder);

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
      refreshOnStartHeader: refreshOnStartHeader,
      callRefreshOverOffset: config?.callRefreshOverOffset,
      callLoadOverOffset: config?.callLoadOverOffset,
      fit: config?.fit,
      clipBehavior: config?.clipBehavior,
      scrollController: config?.scrollController,
      notLoadFooter: config?.notLoadFooter,
      notRefreshHeader: config?.notRefreshHeader,
      triggerAxis: config?.triggerAxis,
      scrollBehaviorBuilder: scrollBehaviorBuilder);
}
