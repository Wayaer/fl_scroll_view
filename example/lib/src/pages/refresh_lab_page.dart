import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

enum DemoIndicatorStyle { inherited, classic, material, cupertino, bezier, phoenix, delivery, taurus }

extension DemoIndicatorStyleX on DemoIndicatorStyle {
  String get label => switch (this) {
    DemoIndicatorStyle.inherited => '默认',
    DemoIndicatorStyle.classic => 'Classic',
    DemoIndicatorStyle.material => 'Material',
    DemoIndicatorStyle.cupertino => 'Cupertino',
    DemoIndicatorStyle.bezier => 'Bezier',
    DemoIndicatorStyle.phoenix => 'Phoenix',
    DemoIndicatorStyle.delivery => 'Delivery',
    DemoIndicatorStyle.taurus => 'Taurus',
  };
}

class RefreshLabPage extends StatefulWidget {
  const RefreshLabPage({super.key});

  @override
  State<RefreshLabPage> createState() => _RefreshLabPageState();
}

class _RefreshLabPageState extends State<RefreshLabPage> {
  final EasyRefreshController _controller = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

  List<int> _items = List<int>.generate(24, (int index) => index);
  int _page = 0;
  bool _noMore = false;
  bool _failNextRefresh = false;
  bool _failNextLoad = false;
  bool _simultaneously = false;
  bool _canLoadAfterNoMore = false;
  bool _canRefreshAfterNoMore = false;
  bool _refreshOnStart = false;
  bool _resetAfterRefresh = true;
  bool _enableRefresh = true;
  bool _enableLoad = true;
  bool _showMessage = false;
  DemoIndicatorStyle _headerStyle = DemoIndicatorStyle.inherited;
  DemoIndicatorStyle _footerStyle = DemoIndicatorStyle.inherited;
  String _lastResult = '等待操作';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<FlEasyRefreshResult> _handleRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (_failNextRefresh) {
      if (mounted) setState(() => _failNextRefresh = false);
      return FlEasyRefreshResult.refreshFailed;
    }
    if (!mounted) return FlEasyRefreshResult.refreshSuccess;
    setState(() {
      _items = List<int>.generate(24, (int index) => index);
      _page = 0;
      _noMore = false;
      _lastResult = '刷新成功 · 24 条';
    });
    return FlEasyRefreshResult.refreshSuccess;
  }

  Future<FlEasyRefreshResult> _handleLoad() async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (_failNextLoad) {
      if (mounted) setState(() => _failNextLoad = false);
      return FlEasyRefreshResult.loadFailed;
    }
    if (!mounted) return FlEasyRefreshResult.loadingSuccess;
    if (_noMore) return FlEasyRefreshResult.loadNoMore;
    final int start = _items.length;
    setState(() {
      _items = [..._items, for (int i = 0; i < 12; i++) start + i];
      _page += 1;
      _noMore = _page >= 3;
      _lastResult = _noMore ? '第 $_page 页 · 没有更多数据' : '第 $_page 页 · 加载成功';
    });
    return _noMore ? FlEasyRefreshResult.loadNoMore : FlEasyRefreshResult.loadingSuccess;
  }

  Header? _buildHeader() {
    switch (_headerStyle) {
      case DemoIndicatorStyle.inherited:
        return null;
      case DemoIndicatorStyle.classic:
        return ClassicHeader(
          triggerOffset: 70,
          showMessage: _showMessage,
          messageText: '上次更新 %T',
          dragText: '下拉刷新',
          armedText: '松开刷新',
          readyText: '正在刷新',
          processingText: '刷新中…',
          processedText: '刷新完成',
          failedText: '刷新失败',
          noMoreText: '没有更多了',
        );
      case DemoIndicatorStyle.material:
        return const MaterialHeader();
      case DemoIndicatorStyle.cupertino:
        return const CupertinoHeader();
      case DemoIndicatorStyle.bezier:
        return const BezierHeader();
      case DemoIndicatorStyle.phoenix:
        return const PhoenixHeader();
      case DemoIndicatorStyle.delivery:
        return const DeliveryHeader();
      case DemoIndicatorStyle.taurus:
        return const TaurusHeader();
    }
  }

  Footer? _buildFooter() {
    switch (_footerStyle) {
      case DemoIndicatorStyle.inherited:
        return null;
      case DemoIndicatorStyle.classic:
        return ClassicFooter(
          showMessage: _showMessage,
          dragText: '上拉加载',
          armedText: '松开加载',
          readyText: '正在加载',
          processingText: '加载中…',
          processedText: '加载完成',
          failedText: '加载失败',
          noMoreText: '没有更多了',
        );
      case DemoIndicatorStyle.material:
        return const MaterialFooter();
      case DemoIndicatorStyle.cupertino:
        return const CupertinoFooter();
      case DemoIndicatorStyle.bezier:
        return const BezierFooter();
      case DemoIndicatorStyle.phoenix:
        return const PhoenixFooter();
      case DemoIndicatorStyle.delivery:
        return const DeliveryFooter();
      case DemoIndicatorStyle.taurus:
        return const TaurusFooter();
    }
  }

  FlEasyRefreshConfig get _config {
    final bool hasRefresh = _enableRefresh;
    final bool hasLoad = _enableLoad;
    return FlEasyRefreshConfig(
      controller: _controller,
      header: hasRefresh ? _buildHeader() : null,
      footer: hasLoad ? _buildFooter() : null,
      onRefresh: hasRefresh ? (EasyRefreshController controller) => _handleRefresh() : null,
      onLoad: hasLoad ? (EasyRefreshController controller) => _handleLoad() : null,
      simultaneously: _simultaneously,
      canLoadAfterNoMore: _canLoadAfterNoMore,
      canRefreshAfterNoMore: _canRefreshAfterNoMore,
      resetAfterRefresh: _resetAfterRefresh,
      refreshOnStart: _refreshOnStart,
      notRefreshHeader: hasRefresh ? null : const NotRefreshHeader(),
      notLoadFooter: hasLoad ? null : const NotLoadFooter(),
    );
  }

  void _resetData() {
    setState(() {
      _items = List<int>.generate(24, (int index) => index);
      _page = 0;
      _noMore = false;
      _lastResult = '数据已重置';
    });
    _controller.resetHeader();
    _controller.resetFooter();
  }

  String get _code {
    final String headerCode = _headerStyle == DemoIndicatorStyle.inherited
        ? 'null // 使用全局默认'
        : '${_headerStyle.label}Header()';
    final String footerCode = _footerStyle == DemoIndicatorStyle.inherited
        ? 'null // 使用全局默认'
        : '${_footerStyle.label}Footer()';
    return 'FlScrollListGrid.builder(\n'
        '  refreshConfig: FlEasyRefreshConfig(\n'
        '    controller: controller, // controlFinishRefresh/Load: true\n'
        '    header: $headerCode,\n'
        '    footer: $footerCode,\n'
        '    onRefresh: (_) async => FlEasyRefreshResult.refreshSuccess,\n'
        '    onLoad: (_) async => FlEasyRefreshResult.loadingSuccess,\n'
        '    simultaneously: $_simultaneously,\n'
        '    canLoadAfterNoMore: $_canLoadAfterNoMore,\n'
        '    canRefreshAfterNoMore: $_canRefreshAfterNoMore,\n'
        '    resetAfterRefresh: $_resetAfterRefresh,\n'
        '    refreshOnStart: $_refreshOnStart,\n'
        '  ),\n'
        '  layout: const ListGridLayout.list(),\n'
        '  itemCount: items.length,\n'
        '  itemBuilder: (_, i) => Tile(items[i]),\n'
        ');';
  }

  List<Widget> _controls() {
    return [
      DemoActionRow(
        actions: [
          FilledButton.tonalIcon(
            onPressed: () => _controller.callRefresh(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('callRefresh'),
          ),
          OutlinedButton.icon(
            onPressed: () => _controller.callLoad(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            label: const Text('callLoad'),
          ),
          TextButton.icon(
            onPressed: _resetData,
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('重置'),
          ),
        ],
      ),
      DemoParamRow(
        label: 'Header',
        child: DemoChoice<DemoIndicatorStyle>(
          value: _headerStyle,
          options: {for (final DemoIndicatorStyle style in DemoIndicatorStyle.values) style: style.label},
          onChanged: (DemoIndicatorStyle style) => setState(() => _headerStyle = style),
        ),
      ),
      DemoParamRow(
        label: 'Footer',
        child: DemoChoice<DemoIndicatorStyle>(
          value: _footerStyle,
          options: {for (final DemoIndicatorStyle style in DemoIndicatorStyle.values) style: style.label},
          onChanged: (DemoIndicatorStyle style) => setState(() => _footerStyle = style),
        ),
      ),
      DemoParamRow(
        label: '开关',
        child: DemoToggles(
          labels: const ['开启刷新', '开启加载', 'simultaneously', 'Classic showMessage'],
          values: [_enableRefresh, _enableLoad, _simultaneously, _showMessage],
          onChanged: (int index, bool value) => setState(() {
            switch (index) {
              case 0:
                _enableRefresh = value;
              case 1:
                _enableLoad = value;
              case 2:
                _simultaneously = value;
              case 3:
                _showMessage = value;
            }
          }),
        ),
      ),
      DemoParamRow(
        label: 'noMore',
        child: DemoToggles(
          labels: const ['canLoadAfterNoMore', 'canRefreshAfterNoMore', 'resetAfterRefresh', 'refreshOnStart'],
          values: [_canLoadAfterNoMore, _canRefreshAfterNoMore, _resetAfterRefresh, _refreshOnStart],
          onChanged: (int index, bool value) => setState(() {
            switch (index) {
              case 0:
                _canLoadAfterNoMore = value;
              case 1:
                _canRefreshAfterNoMore = value;
              case 2:
                _resetAfterRefresh = value;
              case 3:
                _refreshOnStart = value;
            }
          }),
        ),
      ),
      DemoParamRow(
        label: '异常',
        child: DemoToggles(
          labels: const ['下次刷新失败', '下次加载失败'],
          values: [_failNextRefresh, _failNextLoad],
          onChanged: (int index, bool value) => setState(() {
            if (index == 0) {
              _failNextRefresh = value;
            } else {
              _failNextLoad = value;
            }
          }),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarText(
        '刷新 · 加载实验台',
        actions: [
          IconButton(
            tooltip: '查看代码',
            icon: const Icon(Icons.code_rounded),
            onPressed: () => showCodeSheet(context, title: 'FlEasyRefreshConfig 示例', code: _code),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlScrollListGrid.builder(
              key: ValueKey<String>('refresh-$_refreshOnStart-$_enableRefresh-$_enableLoad'),
              padding: const EdgeInsets.all(12),
              refreshConfig: _config,
              layout: const ListGridLayout.list(),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              header: DemoInfoSliver(
                title: 'FlEasyRefreshConfig',
                message:
                    '下拉触发 onRefresh，上拉触发 onLoad；'
                    '返回值 FlEasyRefreshResult 会被库自动结束。'
                    '外部 controller 可随时 callRefresh / callLoad。',
                tags: ['已加载 ${_items.length} 条', 'page $_page', _noMore ? 'noMore' : '可加载', _lastResult],
              ),
              footer: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _noMore ? Icons.check_circle_outline_rounded : Icons.arrow_downward_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _noMore ? '已经到底了 · loadNoMore' : '继续上拉可加载下一页',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              itemBuilder: (_, int index) {
                final int value = _items[index];
                return DemoListCard(
                  index: value,
                  title: '第 $value 条数据',
                  subtitle: value < 24 ? '第一页数据 · refresh 会重置' : 'load 追加的第 ${value ~/ 12} 页',
                );
              },
            ),
          ),
          DemoDock(title: 'FlEasyRefreshConfig 参数实验台', children: _controls()),
        ],
      ),
    );
  }
}
