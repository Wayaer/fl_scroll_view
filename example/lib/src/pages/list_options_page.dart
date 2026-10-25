import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

class ListOptionsPage extends StatefulWidget {
  const ListOptionsPage({super.key});

  @override
  State<ListOptionsPage> createState() => _ListOptionsPageState();
}

class _ListOptionsPageState extends State<ListOptionsPage> {
  List<int> _order = List<int>.generate(24, (int index) => index);
  bool _empty = false;
  bool _separator = true;
  bool _useCount = false;
  bool _placeholderFill = true;
  bool _fillOverscroll = false;
  bool _keepAlives = true;
  bool _repaint = true;
  bool _semantic = true;
  bool _showHeader = true;
  bool _showFooter = true;
  bool _reverse = false;

  void _shuffle() {
    setState(() {
      _order = [..._order]..shuffle();
    });
  }

  String get _orderPreview {
    final List<int> head = _order.take(4).toList();
    return '顺序 ${head.join(' · ')}${_order.length > head.length ? ' …' : ''}';
  }

  String get _code {
    return 'FlScrollListGrid.builder(\n'
        '  layout: const ListGridLayout.list(),\n'
        '  itemCount: items.length, // ${_empty ? '0 = 空数据' : '${_order.length}'}\n'
        '  ${_separator ? 'separatorBuilder: (_, i) => Divider(),' : '// separatorBuilder 已关闭'}\n'
        '  findItemIndexCallback: (key) => indexOfItem(key),\n'
        '  addAutomaticKeepAlives: $_keepAlives,\n'
        '  addRepaintBoundaries: $_repaint,\n'
        '  addSemanticIndexes: $_semantic,\n'
        '  placeholder: DemoEmptyPlaceholder(),\n'
        '  placeholderFill: $_placeholderFill,\n'
        '  placeholderFillOverscroll: $_fillOverscroll,\n'
        '  header: HeaderSliver(),\n'
        '  footer: FooterSliver(),\n'
        '  itemBuilder: (_, i) => CounterEntry(key: ValueKey(items[i]), id: items[i]),\n'
        ');';
  }

  Widget _buildPreview() {
    final FlEasyRefreshConfig config = demoRefreshConfig(delay: const Duration(milliseconds: 500));
    final Widget? placeholder = _empty
        ? DemoEmptyPlaceholder(fill: _placeholderFill, overscroll: _fillOverscroll)
        : null;
    final Widget? header = _showHeader
        ? DemoInfoSliver(
            title: '列表细节参数',
            message:
                '打乱顺序后，已点击的次数不会丢——'
                '这是 findItemIndexCallback + Key 的效果。'
                'separatorBuilder 只在相邻 item 之间插入；placeholder 用于空数据。',
            tags: [_orderPreview, 'separator: $_separator', 'keepAlive: $_keepAlives', 'semantic: $_semantic'],
          )
        : null;
    final Widget? footer = _showFooter
        ? SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'footer sliver · itemCount = ${_empty ? 0 : _order.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          )
        : null;

    if (_useCount) {
      return FlScrollListGrid.count(
        key: ValueKey<String>('options-count-$_empty-$_showHeader-$_showFooter'),
        padding: const EdgeInsets.all(12),
        refreshConfig: config,
        reverse: _reverse,
        layout: const ListGridLayout.list(),
        header: header,
        footer: footer,
        placeholder: placeholder,
        placeholderFill: _placeholderFill,
        placeholderFillOverscroll: _fillOverscroll,
        addAutomaticKeepAlives: _keepAlives,
        addRepaintBoundaries: _repaint,
        addSemanticIndexes: _semantic,
        children: [
          if (!_empty)
            for (final int id in _order) _CounterEntry(key: ValueKey<int>(id), id: id, keepAlive: _keepAlives),
        ],
      );
    }

    return FlScrollListGrid.builder(
      key: ValueKey<String>('options-builder-$_empty-$_showHeader-$_showFooter'),
      padding: const EdgeInsets.all(12),
      refreshConfig: config,
      reverse: _reverse,
      layout: const ListGridLayout.list(),
      itemCount: _empty ? 0 : _order.length,
      separatorBuilder: _separator ? (_, int index) => const Divider(height: 8, thickness: 2) : null,
      findItemIndexCallback: (Key key) {
        if (key is! ValueKey<int>) return null;
        final int index = _order.indexOf(key.value);
        return index < 0 ? null : index;
      },
      addAutomaticKeepAlives: _keepAlives,
      addRepaintBoundaries: _repaint,
      addSemanticIndexes: _semantic,
      itemBuilder: (_, int index) {
        final int id = _order[index];
        return Padding(
          key: ValueKey<int>(id),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _CounterEntry(id: id, keepAlive: _keepAlives),
        );
      },
      header: header,
      footer: footer,
      placeholder: placeholder,
      placeholderFill: _placeholderFill,
      placeholderFillOverscroll: _fillOverscroll,
    );
  }

  List<Widget> _controls() {
    return [
      DemoActionRow(
        actions: [
          FilledButton.tonalIcon(
            onPressed: _useCount ? null : _shuffle,
            icon: const Icon(Icons.shuffle_rounded, size: 18),
            label: const Text('打乱顺序'),
          ),
          OutlinedButton.icon(
            onPressed: () => setState(() => _order = List<int>.generate(24, (int index) => index)),
            icon: const Icon(Icons.sort_rounded, size: 18),
            label: const Text('恢复顺序'),
          ),
        ],
      ),
      DemoParamRow(
        label: '列表',
        child: DemoToggles(
          labels: const ['separatorBuilder', 'count 模式', '反向 reverse'],
          values: [_separator, _useCount, _reverse],
          onChanged: (int index, bool value) => setState(() {
            switch (index) {
              case 0:
                _separator = value;
              case 1:
                _useCount = value;
              case 2:
                _reverse = value;
            }
          }),
        ),
      ),
      DemoParamRow(
        label: '空数据',
        child: DemoToggles(
          labels: const ['空数据', 'placeholderFill', 'fillOverscroll'],
          values: [_empty, _placeholderFill, _fillOverscroll],
          onChanged: (int index, bool value) => setState(() {
            switch (index) {
              case 0:
                _empty = value;
              case 1:
                _placeholderFill = value;
              case 2:
                _fillOverscroll = value;
            }
          }),
        ),
      ),
      DemoParamRow(
        label: '构建选项',
        child: DemoToggles(
          labels: const ['keepAlive', 'repaintBoundaries', 'semanticIndexes'],
          values: [_keepAlives, _repaint, _semantic],
          onChanged: (int index, bool value) => setState(() {
            switch (index) {
              case 0:
                _keepAlives = value;
              case 1:
                _repaint = value;
              case 2:
                _semantic = value;
            }
          }),
        ),
      ),
      DemoParamRow(
        label: 'Sliver',
        child: DemoToggles(
          labels: const ['header', 'footer'],
          values: [_showHeader, _showFooter],
          onChanged: (int index, bool value) => setState(() {
            if (index == 0) {
              _showHeader = value;
            } else {
              _showFooter = value;
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
        '列表细节 · 参数',
        actions: [
          IconButton(
            tooltip: '查看代码',
            icon: const Icon(Icons.code_rounded),
            onPressed: () => showCodeSheet(context, title: 'FlScrollListGrid 列表细节', code: _code),
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
                    '先点几次 + 号，再打乱顺序；'
                    '未开启 keepAlive 时，滚出屏幕再回来计数会重置。',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildPreview()),
          DemoDock(title: 'separator · placeholder · keepAlive', children: _controls()),
        ],
      ),
    );
  }
}

class _CounterEntry extends StatefulWidget {
  const _CounterEntry({super.key, required this.id, required this.keepAlive});

  final int id;
  final bool keepAlive;

  @override
  State<_CounterEntry> createState() => _CounterEntryState();
}

class _CounterEntryState extends State<_CounterEntry> with AutomaticKeepAliveClientMixin<_CounterEntry> {
  int _count = 0;

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void didUpdateWidget(covariant _CounterEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keepAlive != widget.keepAlive) updateKeepAlive();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Color color = colorAt(widget.id);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            child: Text(
              '${widget.id}',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Key: ValueKey<int>(${widget.id})', style: TextStyle(fontSize: 12, color: scheme.onSurface)),
          ),
          Text(
            '$_count',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
          ),
          IconButton(
            onPressed: () => setState(() => _count += 1),
            icon: const Icon(Icons.add_circle_rounded, size: 24),
            color: color,
          ),
        ],
      ),
    );
  }
}
