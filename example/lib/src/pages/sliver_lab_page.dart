import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

class SliverLabPage extends StatefulWidget {
  const SliverLabPage({super.key});

  @override
  State<SliverLabPage> createState() => _SliverLabPageState();
}

class _SliverLabPageState extends State<SliverLabPage> {
  final ScrollController _controller = ScrollController();
  bool _pinned = true;
  bool _floating = false;
  bool _showPinnedBox = true;
  bool _showSecondHeader = false;
  bool _reverse = false;
  double _minHeight = 56;
  double _maxHeight = 128;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _code {
    final String pinnedLine = _showPinnedBox
        ? 'FlSliverPinnedToBoxAdapter(child: PinnedBar()),'
        : '// FlSliverPinnedToBoxAdapter 已关闭';
    return 'FlRefreshScrollView(\n'
        '  controller: controller,\n'
        '  slivers: [\n'
        '    FlSliverPersistentHeader(\n'
        '      pinned: $_pinned,\n'
        '      floating: $_floating,\n'
        '      minHeight: ${_minHeight.toStringAsFixed(0)},\n'
        '      maxHeight: ${_maxHeight.toStringAsFixed(0)},\n'
        '      child: HeaderContent(),\n'
        '    ),\n'
        '    $pinnedLine\n'
        '    FlSliverListGrid.builder(\n'
        '      layout: const ListGridLayout.list(),\n'
        '      itemCount: 60,\n'
        '      itemBuilder: (_, i) => Tile(i),\n'
        '    ),\n'
        '  ],\n'
        ');';
  }

  Widget _header() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool expanded = constraints.maxHeight >= 92 && constraints.maxWidth >= 360;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF312E81), Color(0xFF4F46E5), Color(0xFF0EA5E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.layers_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'FlSliverPersistentHeader',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  DemoPill(
                    '${_minHeight.toStringAsFixed(0)} → ${_maxHeight.toStringAsFixed(0)}',
                    color: Colors.white,
                    dense: true,
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 10),
                Flexible(
                  child: Text(
                    'pinned: $_pinned · floating: $_floating\n'
                    '折叠时只保留 minHeight，展开时为 maxHeight；这段文字会在折叠时被裁剪。',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11.5, height: 1.5),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _pinnedBox() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double offset = _controller.hasClients ? _controller.offset : 0;
        return Container(
          height: 48,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)])),
          child: Row(
            children: [
              const Icon(Icons.push_pin_rounded, color: Colors.white70, size: 17),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'FlSliverPinnedToBoxAdapter',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                'offset ${offset.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _controls() {
    return [
      DemoParamRow(
        label: 'Persistent',
        child: DemoToggles(
          labels: const ['pinned', 'floating', '反向 reverse'],
          values: [_pinned, _floating, _reverse],
          onChanged: (int index, bool value) => setState(() {
            switch (index) {
              case 0:
                _pinned = value;
              case 1:
                _floating = value;
              case 2:
                _reverse = value;
            }
          }),
        ),
      ),
      DemoSlider(
        label: 'minHeight',
        value: _minHeight,
        min: 56,
        max: 120,
        divisions: 16,
        display: _minHeight.toStringAsFixed(0),
        onChanged: (double value) => setState(() => _minHeight = value),
      ),
      DemoSlider(
        label: 'maxHeight',
        value: _maxHeight,
        min: 56,
        max: 220,
        divisions: 41,
        display: _maxHeight.toStringAsFixed(0),
        onChanged: (double value) => setState(() => _maxHeight = value),
      ),
      DemoParamRow(
        label: '组合',
        child: DemoToggles(
          labels: const ['PinnedToBoxAdapter', '第二个 floating header'],
          values: [_showPinnedBox, _showSecondHeader],
          onChanged: (int index, bool value) => setState(() {
            if (index == 0) {
              _showPinnedBox = value;
            } else {
              _showSecondHeader = value;
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
        'Sliver 头部组合',
        actions: [
          IconButton(
            tooltip: '查看代码',
            icon: const Icon(Icons.code_rounded),
            onPressed: () => showCodeSheet(context, title: 'Sliver 头部示例', code: _code),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlRefreshScrollView(
              controller: _controller,
              reverse: _reverse,
              padding: const EdgeInsets.all(10),
              refreshConfig: demoRefreshConfig(delay: const Duration(milliseconds: 700)),
              slivers: [
                FlSliverPersistentHeader(
                  pinned: _pinned,
                  floating: _floating,
                  minHeight: _minHeight,
                  maxHeight: _maxHeight,
                  child: _header(),
                ),
                if (_showSecondHeader)
                  FlSliverPersistentHeader(
                    pinned: false,
                    floating: true,
                    minHeight: 36,
                    maxHeight: 40,
                    child: Container(
                      color: const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        '第二个 floating header · 向上滚动时重新出现',
                        style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                if (_showPinnedBox) FlSliverPinnedToBoxAdapter(child: _pinnedBox()),
                DemoInfoSliver(
                  title: 'pinned / floating / minHeight / maxHeight',
                  message:
                      'pinned 一直停留；floating 在向上滚动时重新出现；'
                      '两者都关闭时头部会随内容滚出屏幕。'
                      'maxHeight → minHeight 之间由 Flutter 负责折叠，'
                      'FlSliverPinnedToBoxAdapter 则固定在顶部。',
                  tags: [
                    'pinned: $_pinned',
                    'floating: $_floating',
                    if (_showPinnedBox) 'PinnedToBoxAdapter',
                    if (_showSecondHeader) 'floating header ×2',
                  ],
                ),
                SectionTitle('FlSliverListGrid.list', subtitle: '下方列表用于观察头部折叠与固定效果'),
                FlSliverListGrid.builder(
                  layout: const ListGridLayout.list(),
                  itemCount: 60,
                  itemBuilder: (_, int index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DemoListCard(index: index, title: '第 $index 行内容'),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
          DemoDock(title: 'Sliver 头部参数实验台', children: _controls()),
        ],
      ),
    );
  }
}
