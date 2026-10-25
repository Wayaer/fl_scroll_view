import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

enum DemoPhysics { bouncing, clamping, never }

extension DemoPhysicsX on DemoPhysics {
  String get label => switch (this) {
    DemoPhysics.bouncing => 'Bouncing',
    DemoPhysics.clamping => 'Clamping',
    DemoPhysics.never => 'Never',
  };

  ScrollPhysics get physics => switch (this) {
    DemoPhysics.bouncing => const BouncingScrollPhysics(),
    DemoPhysics.clamping => const ClampingScrollPhysics(),
    DemoPhysics.never => const NeverScrollableScrollPhysics(),
  };
}

class ScrollViewLabPage extends StatefulWidget {
  const ScrollViewLabPage({super.key});

  @override
  State<ScrollViewLabPage> createState() => _ScrollViewLabPageState();
}

class _ScrollViewLabPageState extends State<ScrollViewLabPage> {
  final ScrollController _scrollController = ScrollController();
  Axis _axis = Axis.vertical;
  bool _reverse = false;
  bool _refreshEnabled = false;
  bool _cacheExtent = false;
  bool _noScrollBehavior = false;
  bool _dismissOnDrag = true;
  double _anchor = 0;
  double _padding = 12;
  DemoPhysics _physics = DemoPhysics.bouncing;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpTo(double factor) {
    if (!_scrollController.hasClients) return;
    final ScrollPosition position = _scrollController.position;
    final double target = (position.maxScrollExtent * factor).clamp(position.minScrollExtent, position.maxScrollExtent);
    _scrollController.animateTo(target, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  String get _code {
    return 'FlRefreshScrollView(\n'
        '  controller: controller,\n'
        '  scrollDirection: $_axis,\n'
        '  reverse: $_reverse,\n'
        '  anchor: ${_anchor.toStringAsFixed(2)},\n'
        '  padding: EdgeInsets.all(${_padding.toStringAsFixed(0)}),\n'
        '  cacheExtent: ${_cacheExtent ? '800' : 'null'},\n'
        '  noScrollBehavior: $_noScrollBehavior,\n'
        '  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.${_dismissOnDrag ? 'onDrag' : 'manual'},\n'
        '  physics: ${_physics.physics.runtimeType}(),\n'
        '  refreshConfig: ${_refreshEnabled ? 'config' : 'null'},\n'
        '  slivers: [\n'
        '    FlSliverPinnedToBoxAdapter(child: PinnedBar()),\n'
        '    FlSliverListGrid.builder(\n'
        '      layout: const ListGridLayout.list(),\n'
        '      itemCount: 40,\n'
        '      itemBuilder: (_, i) => Tile(i),\n'
        '    ),\n'
        '  ],\n'
        ');';
  }

  Widget _pinnedBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.push_pin_rounded, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'FlSliverPinnedToBoxAdapter · 滚动时始终停留',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          _JumpButton(label: '顶部', onTap: () => _jumpTo(0)),
          _JumpButton(label: '中间', onTap: () => _jumpTo(0.5)),
          _JumpButton(label: '底部', onTap: () => _jumpTo(1)),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        decoration: InputDecoration(
          isDense: true,
          hintText: _dismissOnDrag ? '拖动列表会收起键盘（onDrag）' : '拖动列表不会收起键盘（manual）',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _verticalItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DemoListCard(
        index: index,
        title: '第 $index 行',
        subtitle: 'scrollDirection: ${_axis.name} · reverse: $_reverse · anchor: ${_anchor.toStringAsFixed(2)}',
      ),
    );
  }

  Widget _horizontalItem(int index) {
    final Color color = colorAt(index);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        width: 156,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.65)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.swap_horiz_rounded, color: Colors.white70, size: 20),
            const Spacer(),
            Text(
              '$index',
              style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800),
            ),
            Text('horizontal', style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildScroll() {
    final bool vertical = _axis == Axis.vertical;
    return FlRefreshScrollView(
      key: ValueKey<String>('scroll-${_axis.name}-$_reverse-$_anchor-${_physics.name}-$_refreshEnabled'),
      controller: _scrollController,
      scrollDirection: _axis,
      reverse: _reverse,
      anchor: _anchor,
      padding: EdgeInsets.all(_padding),
      cacheExtent: _cacheExtent ? 800 : null,
      noScrollBehavior: _noScrollBehavior,
      keyboardDismissBehavior: _dismissOnDrag
          ? ScrollViewKeyboardDismissBehavior.onDrag
          : ScrollViewKeyboardDismissBehavior.manual,
      physics: _physics.physics,
      refreshConfig: _refreshEnabled ? demoRefreshConfig(delay: const Duration(milliseconds: 700)) : null,
      slivers: [
        if (vertical) ...[
          FlSliverPinnedToBoxAdapter(child: _pinnedBar(context)),
          SliverToBoxAdapter(child: _searchField()),
          SectionTitle(
            'FlRefreshScrollView · vertical',
            subtitle: _refreshEnabled ? '刷新已开启：physics 由 EasyRefresh 接管' : '刷新已关闭：physics = ${_physics.label}',
          ),
        ],
        FlSliverListGrid.builder(
          layout: const ListGridLayout.list(),
          itemCount: 40,
          itemBuilder: (_, int index) => vertical ? _verticalItem(index) : _horizontalItem(index),
        ),
        if (vertical)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 18, 12, 28),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  DemoPill('controller 跳转', icon: Icons.speed_rounded, dense: true),
                  DemoPill('padding', icon: Icons.space_bar_rounded, dense: true),
                  DemoPill('anchor', icon: Icons.vertical_align_top_rounded, dense: true),
                  DemoPill('cacheExtent', icon: Icons.memory_rounded, dense: true),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _controls() {
    return [
      DemoParamRow(
        label: '方向',
        child: DemoChoice<Axis>(
          value: _axis,
          options: const {Axis.vertical: 'vertical', Axis.horizontal: 'horizontal'},
          onChanged: (Axis axis) => setState(() => _axis = axis),
        ),
      ),
      DemoParamRow(
        label: 'anchor',
        child: DemoChoice<double>(
          value: _anchor,
          options: {0.0: '0.0', 0.2: '0.2', 0.5: '0.5'},
          onChanged: (double value) => setState(() => _anchor = value),
        ),
      ),
      DemoParamRow(
        label: 'physics',
        child: DemoChoice<DemoPhysics>(
          value: _physics,
          options: {for (final DemoPhysics physics in DemoPhysics.values) physics: physics.label},
          onChanged: (DemoPhysics physics) => setState(() => _physics = physics),
        ),
      ),
      DemoSlider(
        label: 'padding',
        value: _padding,
        min: 0,
        max: 32,
        divisions: 16,
        display: _padding.toStringAsFixed(0),
        onChanged: (double value) => setState(() => _padding = value),
      ),
      DemoParamRow(
        label: '开关',
        child: DemoToggles(
          labels: const ['reverse', 'cacheExtent 800', 'noScrollBehavior', 'onDrag 收键盘', '开启刷新'],
          values: [_reverse, _cacheExtent, _noScrollBehavior, _dismissOnDrag, _refreshEnabled],
          onChanged: (int index, bool value) => setState(() {
            switch (index) {
              case 0:
                _reverse = value;
              case 1:
                _cacheExtent = value;
              case 2:
                _noScrollBehavior = value;
              case 3:
                _dismissOnDrag = value;
              case 4:
                _refreshEnabled = value;
            }
          }),
        ),
      ),
      if (_refreshEnabled)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '提示：开启刷新时，physics 由 EasyRefresh 传入的 ScrollPhysics 接管；'
            '关闭刷新后可观察 Bouncing / Clamping / Never。',
            style: TextStyle(fontSize: 10.5, height: 1.4, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarText(
        'FlRefreshScrollView 参数',
        actions: [
          IconButton(
            tooltip: '查看代码',
            icon: const Icon(Icons.code_rounded),
            onPressed: () => showCodeSheet(context, title: 'FlRefreshScrollView 示例', code: _code),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildScroll()),
          DemoDock(title: '滚动容器参数实验台', children: _controls()),
        ],
      ),
    );
  }
}

class _JumpButton extends StatelessWidget {
  const _JumpButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}
