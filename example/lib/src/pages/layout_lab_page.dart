import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

enum DemoLayoutKind { list, grid, masonry, aligned, quilted, staired, woven }

extension DemoLayoutKindX on DemoLayoutKind {
  String get label => switch (this) {
    DemoLayoutKind.list => 'List',
    DemoLayoutKind.grid => 'Grid',
    DemoLayoutKind.masonry => 'Masonry',
    DemoLayoutKind.aligned => 'Aligned',
    DemoLayoutKind.quilted => 'Quilted',
    DemoLayoutKind.staired => 'Staired',
    DemoLayoutKind.woven => 'Woven',
  };

  String get subtitle => switch (this) {
    DemoLayoutKind.list => 'SliverList / SliverFixedExtentList / 分隔符',
    DemoLayoutKind.grid => 'SliverGrid 等分网格，支持自适应列宽',
    DemoLayoutKind.masonry => '各列独立堆叠，子项高度自由',
    DemoLayoutKind.aligned => '同一行行高对齐，行内底部留白',
    DemoLayoutKind.quilted => '按 pattern 拼布，跨行跨列排布',
    DemoLayoutKind.staired => '阶梯图案，左右交替排列',
    DemoLayoutKind.woven => '编织图案，上下两排交错',
  };
}

class LayoutLabPage extends StatefulWidget {
  const LayoutLabPage({super.key, this.kind = DemoLayoutKind.grid});

  final DemoLayoutKind kind;

  @override
  State<LayoutLabPage> createState() => _LayoutLabPageState();
}

class _LayoutLabPageState extends State<LayoutLabPage> {
  late DemoLayoutKind _kind;
  int _columns = 3;
  bool _maxExtentMode = false;
  double _maxExtent = 140;
  double _spacing = 8;
  double _aspectRatio = 1;
  bool _fixedMainExtent = false;
  double _mainExtent = 96;
  bool _fixedItemExtent = false;
  double _itemExtent = 72;
  bool _separator = true;
  bool _empty = false;
  bool _placeholderFill = true;
  bool _placeholderFillOverscroll = false;
  bool _useCount = false;
  bool _reverse = false;
  int _seed = 0;
  int _itemCount = 48;
  QuiltedGridRepeatPattern _repeatPattern = QuiltedGridRepeatPattern.same;
  bool _stairedReversed = false;
  double _tileBottomSpace = 0;
  AlignmentDirectional _wovenAlignment = AlignmentDirectional.center;
  double _wovenCrossAxisRatio = 0.9;

  int get _minColumns => switch (_kind) {
    DemoLayoutKind.quilted => 4,
    DemoLayoutKind.woven => 2,
    _ => 1,
  };

  @override
  void initState() {
    super.initState();
    _kind = widget.kind;
    _columns = _kind == DemoLayoutKind.quilted ? 4 : 3;
  }

  void _reset() {
    setState(() {
      _kind = widget.kind;
      _columns = _kind == DemoLayoutKind.quilted ? 4 : 3;
      _maxExtentMode = false;
      _maxExtent = 140;
      _spacing = 8;
      _aspectRatio = 1;
      _fixedMainExtent = false;
      _mainExtent = 96;
      _fixedItemExtent = false;
      _itemExtent = 72;
      _separator = true;
      _empty = false;
      _placeholderFill = true;
      _placeholderFillOverscroll = false;
      _useCount = false;
      _reverse = false;
      _seed = 0;
      _itemCount = 48;
      _repeatPattern = QuiltedGridRepeatPattern.same;
      _stairedReversed = false;
      _tileBottomSpace = 0;
      _wovenAlignment = AlignmentDirectional.center;
      _wovenCrossAxisRatio = 0.9;
    });
  }

  ListGridLayout get _layout {
    switch (_kind) {
      case DemoLayoutKind.list:
        return ListGridLayout.list(itemExtent: _fixedItemExtent ? _itemExtent : null);
      case DemoLayoutKind.grid:
        return ListGridLayout.grid(
          crossAxisCount: _columns,
          maxCrossAxisExtent: _maxExtentMode ? _maxExtent : null,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          childAspectRatio: _aspectRatio,
          mainAxisExtent: _fixedMainExtent ? _mainExtent : null,
        );
      case DemoLayoutKind.masonry:
        return ListGridLayout.masonry(
          crossAxisCount: _columns,
          maxCrossAxisExtent: _maxExtentMode ? _maxExtent : null,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
        );
      case DemoLayoutKind.aligned:
        return ListGridLayout.aligned(
          crossAxisCount: _columns,
          maxCrossAxisExtent: _maxExtentMode ? _maxExtent : null,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
        );
      case DemoLayoutKind.quilted:
        return ListGridLayout.quilted(
          crossAxisCount: _columns,
          pattern: quiltedPattern,
          repeatPattern: _repeatPattern,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
        );
      case DemoLayoutKind.staired:
        return ListGridLayout.staired(
          pattern: stairedPattern,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          tileBottomSpace: _tileBottomSpace,
          startCrossAxisDirectionReversed: _stairedReversed,
        );
      case DemoLayoutKind.woven:
        return ListGridLayout.woven(
          pattern: [
            const WovenGridTile(1),
            WovenGridTile(5 / 7, crossAxisRatio: _wovenCrossAxisRatio, alignment: _wovenAlignment),
          ],
          crossAxisCount: _columns,
          maxCrossAxisExtent: _maxExtentMode ? _maxExtent : null,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          tileBottomSpace: _tileBottomSpace,
        );
    }
  }

  Widget _item(int index) {
    final int value = index + _seed;
    final Color color = colorAt(value);
    final String label = '#$value';
    switch (_kind) {
      case DemoLayoutKind.list:
        return ColorEntry(
          value,
          color,
          height: _fixedItemExtent ? _itemExtent : 64,
          width: double.infinity,
          label: label,
        );
      case DemoLayoutKind.masonry:
        return ColorEntry(value, color, height: masonryHeight(value), label: label);
      case DemoLayoutKind.aligned:
        return ColorEntry(value, color, height: alignedHeight(value), label: label);
      case DemoLayoutKind.grid:
      case DemoLayoutKind.quilted:
      case DemoLayoutKind.staired:
      case DemoLayoutKind.woven:
        return ColorEntry(value, color, height: 100, width: double.infinity, label: label);
    }
  }

  Widget _divider(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: colorAt(index + _seed).withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final FlEasyRefreshConfig config = FlEasyRefreshConfig(
      onRefresh: (EasyRefreshController controller) async {
        await Future<void>.delayed(const Duration(milliseconds: 650));
        if (!mounted) return FlEasyRefreshResult.refreshSuccess;
        setState(() => _seed += 7);
        return FlEasyRefreshResult.refreshSuccess;
      },
      onLoad: (EasyRefreshController controller) async {
        await Future<void>.delayed(const Duration(milliseconds: 650));
        if (!mounted) return FlEasyRefreshResult.loadingSuccess;
        setState(() => _itemCount += 12);
        return FlEasyRefreshResult.loadingSuccess;
      },
    );
    final bool showSeparator = _kind == DemoLayoutKind.list && _separator;
    final Widget? placeholder = _empty
        ? DemoEmptyPlaceholder(fill: _placeholderFill, overscroll: _placeholderFillOverscroll)
        : null;
    final int count = _empty ? 0 : _itemCount;

    if (_useCount) {
      return FlScrollListGrid.count(
        key: ValueKey<String>('layout-count-${_kind.name}-$_empty'),
        padding: const EdgeInsets.all(12),
        refreshConfig: config,
        reverse: _reverse,
        layout: _layout,
        placeholder: placeholder,
        placeholderFill: _placeholderFill,
        placeholderFillOverscroll: _placeholderFillOverscroll,
        children: [for (int i = 0; i < count; i++) _item(i)],
      );
    }

    return FlScrollListGrid.builder(
      key: ValueKey<String>('layout-builder-${_kind.name}-$_empty'),
      padding: const EdgeInsets.all(12),
      refreshConfig: config,
      reverse: _reverse,
      layout: _layout,
      itemCount: count,
      separatorBuilder: showSeparator ? (_, int index) => _divider(index) : null,
      itemBuilder: (_, int index) => _item(index),
      placeholder: placeholder,
      placeholderFill: _placeholderFill,
      placeholderFillOverscroll: _placeholderFillOverscroll,
    );
  }

  String get _repeatPatternName {
    if (_repeatPattern == QuiltedGridRepeatPattern.inverted) return 'inverted';
    if (_repeatPattern == QuiltedGridRepeatPattern.mirrored) return 'mirrored';
    return 'same';
  }

  String get _columnArg =>
      _maxExtentMode ? 'maxCrossAxisExtent: ${_maxExtent.toStringAsFixed(0)}' : 'crossAxisCount: $_columns';

  String _layoutCall(String name, List<String> args) {
    if (args.isEmpty) return 'ListGridLayout.$name()';
    return 'const ListGridLayout.$name(\n${args.map((String arg) => '  $arg').join(',\n')}\n)';
  }

  String get _code {
    final String spacing = 'mainAxisSpacing: ${_spacing.toStringAsFixed(0)}';
    final String crossSpacing = 'crossAxisSpacing: ${_spacing.toStringAsFixed(0)}';
    final String layoutCode = switch (_kind) {
      DemoLayoutKind.list => _layoutCall('list', [
        if (_fixedItemExtent) 'itemExtent: ${_itemExtent.toStringAsFixed(0)}',
      ]),
      DemoLayoutKind.grid => _layoutCall('grid', [
        _columnArg,
        spacing,
        crossSpacing,
        if (_fixedMainExtent)
          'mainAxisExtent: ${_mainExtent.toStringAsFixed(0)}'
        else
          'childAspectRatio: ${_aspectRatio.toStringAsFixed(2)}',
      ]),
      DemoLayoutKind.masonry => _layoutCall('masonry', [_columnArg, spacing, crossSpacing]),
      DemoLayoutKind.aligned => _layoutCall('aligned', [_columnArg, spacing, crossSpacing]),
      DemoLayoutKind.quilted => _layoutCall('quilted', [
        'crossAxisCount: $_columns',
        'pattern: quiltedPattern',
        'repeatPattern: QuiltedGridRepeatPattern.$_repeatPatternName',
        spacing,
        crossSpacing,
      ]),
      DemoLayoutKind.staired => _layoutCall('staired', [
        'pattern: stairedPattern',
        spacing,
        crossSpacing,
        if (_tileBottomSpace > 0) 'tileBottomSpace: ${_tileBottomSpace.toStringAsFixed(0)}',
        if (_stairedReversed) 'startCrossAxisDirectionReversed: true',
      ]),
      DemoLayoutKind.woven => _layoutCall('woven', [
        _columnArg,
        'pattern: wovenPattern',
        spacing,
        crossSpacing,
        if (_tileBottomSpace > 0) 'tileBottomSpace: ${_tileBottomSpace.toStringAsFixed(0)}',
      ]),
    };
    final String indented = layoutCode.replaceAll('\n', '\n  ');

    return 'FlScrollListGrid.builder(\n'
        '  layout: $indented,\n'
        '  itemCount: $_itemCount,\n'
        '  itemBuilder: (_, i) => Tile(i),\n'
        '${showSeparator ? '  separatorBuilder: (_, i) => Divider(),\n' : ''}'
        '  refreshConfig: config,\n'
        ');';
  }

  bool get showSeparator => _kind == DemoLayoutKind.list && _separator;

  List<Widget> _controls() {
    final bool isCountType = _kind != DemoLayoutKind.quilted && _kind != DemoLayoutKind.staired;
    final bool isColumnType = _kind != DemoLayoutKind.staired;

    return [
      DemoParamRow(
        label: '布局',
        child: DemoChoice<DemoLayoutKind>(
          value: _kind,
          options: {for (final DemoLayoutKind kind in DemoLayoutKind.values) kind: kind.label},
          onChanged: (DemoLayoutKind kind) => setState(() {
            _kind = kind;
            if (_kind == DemoLayoutKind.quilted || _kind == DemoLayoutKind.staired) _maxExtentMode = false;
            if (_columns < _minColumns) _columns = _minColumns;
          }),
        ),
      ),
      if (isColumnType) ...[
        DemoSlider(
          label: _maxExtentMode ? '最大宽' : '列数',
          value: _maxExtentMode ? _maxExtent : _columns.toDouble(),
          min: _maxExtentMode ? 80 : _minColumns.toDouble(),
          max: _maxExtentMode ? 320 : 6,
          divisions: _maxExtentMode ? 24 : 6 - _minColumns,
          display: _maxExtentMode ? _maxExtent.toStringAsFixed(0) : '$_columns',
          onChanged: (double value) => setState(() {
            if (_maxExtentMode) {
              _maxExtent = value;
            } else {
              _columns = value.round();
            }
          }),
        ),
        if (isCountType)
          DemoParamRow(
            label: '列宽',
            child: DemoToggle(
              label: 'maxCrossAxisExtent 自适应',
              value: _maxExtentMode,
              onChanged: (bool value) => setState(() => _maxExtentMode = value),
            ),
          ),
      ],
      DemoSlider(
        label: '间距',
        value: _spacing,
        min: 0,
        max: 24,
        divisions: 24,
        display: _spacing.toStringAsFixed(0),
        onChanged: (double value) => setState(() => _spacing = value),
      ),
      DemoSlider(
        label: '项数',
        value: _itemCount.toDouble(),
        min: 6,
        max: 96,
        divisions: 30,
        display: '$_itemCount',
        onChanged: (double value) => setState(() => _itemCount = value.round()),
      ),
      if (_kind == DemoLayoutKind.list) ...[
        DemoParamRow(
          label: '列表',
          child: _useCount
              ? DemoToggle(
                  label: '固定 itemExtent',
                  value: _fixedItemExtent,
                  onChanged: (bool value) => setState(() => _fixedItemExtent = value),
                )
              : DemoToggles(
                  labels: const ['separatorBuilder', '固定 itemExtent'],
                  values: [_separator, _fixedItemExtent],
                  onChanged: (int index, bool value) => setState(() {
                    if (index == 0) {
                      _separator = value;
                    } else {
                      _fixedItemExtent = value;
                    }
                  }),
                ),
        ),
        if (_useCount)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'count 模式不提供 separatorBuilder（与 FlScrollListGrid.count 一致）。',
              style: TextStyle(fontSize: 10.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          )
        else if (_separator && _fixedItemExtent)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'separatorBuilder 与 itemExtent 同用时，库会退回普通 SliverList。',
              style: TextStyle(fontSize: 10.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        if (_fixedItemExtent)
          DemoSlider(
            label: 'itemExtent',
            value: _itemExtent,
            min: 40,
            max: 160,
            divisions: 24,
            display: _itemExtent.toStringAsFixed(0),
            onChanged: (double value) => setState(() => _itemExtent = value),
          ),
      ],
      if (_kind == DemoLayoutKind.grid) ...[
        DemoParamRow(
          label: '主轴',
          child: DemoToggle(
            label: '固定 mainAxisExtent（忽略宽高比）',
            value: _fixedMainExtent,
            onChanged: (bool value) => setState(() => _fixedMainExtent = value),
          ),
        ),
        if (_fixedMainExtent)
          DemoSlider(
            label: '主轴高',
            value: _mainExtent,
            min: 48,
            max: 200,
            divisions: 19,
            display: _mainExtent.toStringAsFixed(0),
            onChanged: (double value) => setState(() => _mainExtent = value),
          )
        else
          DemoSlider(
            label: '宽高比',
            value: _aspectRatio,
            min: 0.5,
            max: 1.8,
            divisions: 26,
            display: _aspectRatio.toStringAsFixed(2),
            onChanged: (double value) => setState(() => _aspectRatio = value),
          ),
      ],
      if (_kind == DemoLayoutKind.quilted)
        DemoParamRow(
          label: '重复',
          child: DemoChoice<QuiltedGridRepeatPattern>(
            value: _repeatPattern,
            options: const {
              QuiltedGridRepeatPattern.same: 'same',
              QuiltedGridRepeatPattern.inverted: 'inverted',
              QuiltedGridRepeatPattern.mirrored: 'mirrored',
            },
            onChanged: (QuiltedGridRepeatPattern value) => setState(() => _repeatPattern = value),
          ),
        ),
      if (_kind == DemoLayoutKind.staired || _kind == DemoLayoutKind.woven)
        DemoSlider(
          label: '底部空间',
          value: _tileBottomSpace,
          min: 0,
          max: 24,
          divisions: 24,
          display: _tileBottomSpace.toStringAsFixed(0),
          onChanged: (double value) => setState(() => _tileBottomSpace = value),
        ),
      if (_kind == DemoLayoutKind.staired)
        DemoParamRow(
          label: '排布',
          child: DemoToggle(
            label: 'startCrossAxisDirectionReversed',
            value: _stairedReversed,
            onChanged: (bool value) => setState(() => _stairedReversed = value),
          ),
        ),
      if (_kind == DemoLayoutKind.woven) ...[
        DemoParamRow(
          label: '对齐',
          child: DemoChoice<AlignmentDirectional>(
            value: _wovenAlignment,
            options: {
              AlignmentDirectional.centerStart: 'centerStart',
              AlignmentDirectional.center: 'center',
              AlignmentDirectional.centerEnd: 'centerEnd',
            },
            onChanged: (AlignmentDirectional value) => setState(() => _wovenAlignment = value),
          ),
        ),
        DemoSlider(
          label: '交叉比',
          value: _wovenCrossAxisRatio,
          min: 0.3,
          max: 1,
          divisions: 14,
          display: _wovenCrossAxisRatio.toStringAsFixed(2),
          onChanged: (double value) => setState(() {
            _wovenCrossAxisRatio = value;
          }),
        ),
      ],
      DemoParamRow(
        label: '构建',
        child: DemoToggles(
          labels: const ['count 模式', 'reverse 反向'],
          values: [_useCount, _reverse],
          onChanged: (int index, bool value) => setState(() {
            if (index == 0) {
              _useCount = value;
            } else {
              _reverse = value;
            }
          }),
        ),
      ),
      DemoParamRow(
        label: '空数据',
        child: DemoToggles(
          labels: const ['空数据', '占位铺满', '伸入 overscroll'],
          values: [_empty, _placeholderFill, _placeholderFillOverscroll],
          onChanged: (int index, bool value) => setState(() {
            switch (index) {
              case 0:
                _empty = value;
              case 1:
                _placeholderFill = value;
              case 2:
                _placeholderFillOverscroll = value;
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
        '${_kind.label} · 参数实验台',
        actions: [
          IconButton(
            tooltip: '查看代码',
            icon: const Icon(Icons.code_rounded),
            onPressed: () => showCodeSheet(context, title: '${_kind.label} 调用示例', code: _code),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _kind.subtitle,
                    style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
                const DemoPill('下拉刷新 / 上拉加载', icon: Icons.refresh_rounded, dense: true),
              ],
            ),
          ),
          Expanded(child: _buildPreview()),
          DemoDock(
            title: 'ListGridLayout 参数实验台',
            trailing: TextButton(onPressed: _reset, child: const Text('重置')),
            children: _controls(),
          ),
        ],
      ),
    );
  }
}
