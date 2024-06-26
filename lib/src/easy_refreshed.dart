import 'dart:async';

import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/material.dart';

class RefreshControllers {
  factory RefreshControllers() => _singleton ??= RefreshControllers._();

  RefreshControllers._();

  static RefreshControllers? _singleton;

  final Map<int, EasyRefreshController> _controllers = {};

  void _set(EasyRefreshController controller) {
    _controllers[controller.hashCode] = controller;
  }

  EasyRefreshController? get(int hashCode) => _controllers[hashCode];

  void remove(int hashCode) {
    _controllers.remove(hashCode);
  }

  /// 最近一次调用刷新组件的 Controller
  EasyRefreshController? current;

  /// 调用当前刷新
  void call(EasyRefreshType data, {EasyRefreshController? controller}) {
    switch (data) {
      case EasyRefreshType.refresh:
        (controller ?? current)?.callRefresh();
        break;
      case EasyRefreshType.refreshSuccess:
        (controller ?? current)?.finishRefresh(IndicatorResult.success);
        break;
      case EasyRefreshType.refreshFailed:
        (controller ?? current)?.finishRefresh(IndicatorResult.fail);
        break;
      case EasyRefreshType.refreshNoMore:
        (controller ?? current)?.finishRefresh(IndicatorResult.noMore);
        break;
      case EasyRefreshType.loading:
        (controller ?? current)?.callLoad();
        break;
      case EasyRefreshType.loadingSuccess:
        (controller ?? current)?.finishLoad(IndicatorResult.success);
        break;
      case EasyRefreshType.loadFailed:
        (controller ?? current)?.finishLoad(IndicatorResult.fail);
        break;
      case EasyRefreshType.loadNoMore:
        (controller ?? current)?.finishLoad(IndicatorResult.noMore);
        break;
    }
  }
}

/// 刷新类型
enum EasyRefreshType {
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

typedef EasyRefreshControllerCallback = void Function(
    EasyRefreshController controller);

class EasyRefreshed extends StatefulWidget {
  const EasyRefreshed({
    super.key,
    this.child,
    this.builder,
    required this.config,
  }) : assert(child != null || builder != null);

  /// 用于 非ScrollView
  final Widget? child;

  /// 用于 ScrollView
  final ERChildBuilder? builder;

  /// 刷新组件配置信息
  final RefreshConfig config;

  @override
  State<EasyRefreshed> createState() => _EasyRefreshedState();
}

class _EasyRefreshedState extends State<EasyRefreshed> {
  late EasyRefreshController controller;
  late RefreshConfig config;

  @override
  void initState() {
    super.initState();
    initConfig();
  }

  void initConfig() {
    config = widget.config;
    controller = config.controller ??
        EasyRefreshController(
            controlFinishRefresh: config.onRefresh != null,
            controlFinishLoad: config.onLoading != null);
    RefreshControllers()._set(controller);
  }

  @override
  void didUpdateWidget(covariant EasyRefreshed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      if (config.controller != null && controller != config.controller) {
        controller.dispose();
      }
      initConfig();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
        controller: controller,
        header: config.header ?? FlScrollView.globalRefreshHeader,
        footer: config.footer ?? FlScrollView.globalRefreshFooter,
        onLoad: config.onLoading == null
            ? null
            : () {
                RefreshControllers().current = controller;
                config.onLoading!.call();
              },
        onRefresh: config.onRefresh == null
            ? null
            : () {
                RefreshControllers().current = controller;
                config.onRefresh!.call();
              },
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
        childBuilder: widget.builder ?? (_, __) => widget.child!,
        canLoadAfterNoMore: config.canLoadAfterNoMore,
        canRefreshAfterNoMore: config.canRefreshAfterNoMore,
        triggerAxis: config.triggerAxis,
        scrollBehaviorBuilder: config.scrollBehaviorBuilder);
  }

  @override
  void dispose() {
    controller.dispose();
    if (RefreshControllers().current == controller) {
      RefreshControllers().current = null;
    }
    super.dispose();
  }
}

class RefreshConfig {
  const RefreshConfig(
      {this.controller,
      this.onRefresh,
      this.onLoading,
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
  /// sendRefreshType(RefreshCompletedType.refresh);
  final EasyRefreshController? controller;

  /// 下拉刷新回调(null为不开启刷新)
  final FutureOr Function()? onRefresh;

  /// 上拉加载回调(null为不开启加载)
  final FutureOr Function()? onLoading;

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

  RefreshConfig copyWith({
    EasyRefreshController? controller,
    FutureOr Function()? onRefresh,
    FutureOr Function()? onLoading,
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
      RefreshConfig(
          controller: controller ?? this.controller,
          onRefresh: onRefresh ?? this.onRefresh,
          onLoading: onLoading ?? this.onLoading,
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

  RefreshConfig marge([RefreshConfig? config]) => copyWith(
      controller: config?.controller,
      onRefresh: config?.onRefresh,
      onLoading: config?.onLoading,
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
