import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

enum StaggeredMode { masonry, aligned, staggered, sliver }

extension StaggeredModeX on StaggeredMode {
  String get label => switch (this) {
    StaggeredMode.masonry => 'MasonryGridView',
    StaggeredMode.aligned => 'AlignedGridView',
    StaggeredMode.staggered => 'StaggeredGrid',
    StaggeredMode.sliver => 'Sliver 版',
  };
}

enum StaggeredApi { count, extent, custom }

extension StaggeredApiX on StaggeredApi {
  String get label => switch (this) {
    StaggeredApi.count => 'count',
    StaggeredApi.extent => 'extent',
    StaggeredApi.custom => 'custom',
  };
}

enum StaggeredTileMode { count, extent, fit }

extension StaggeredTileModeX on StaggeredTileMode {
  String get label => switch (this) {
    StaggeredTileMode.count => 'tile.count',
    StaggeredTileMode.extent => 'tile.extent',
    StaggeredTileMode.fit => 'tile.fit',
  };
}

class StaggeredLabPage extends StatefulWidget {
  const StaggeredLabPage({super.key, this.mode = StaggeredMode.masonry});

  final StaggeredMode mode;

  @override
  State<StaggeredLabPage> createState() => _StaggeredLabPageState();
}

class _StaggeredLabPageState extends State<StaggeredLabPage> {
  late StaggeredMode _mode;
  StaggeredApi _api = StaggeredApi.count;
  StaggeredTileMode _tileMode = StaggeredTileMode.count;
  int _columns = 2;
  double _maxExtent = 170;
  double _spacing = 8;
  int _count = 36;
  int _seed = 0;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    _columns = _mode == StaggeredMode.staggered ? 4 : 2;
  }

  Widget _item(int index) {
    final int value = index + _seed;
    return ColorEntry(
      value,
      colorAt(value),
      height: switch (_mode) {
        StaggeredMode.masonry => masonryHeight(value),
        StaggeredMode.aligned => alignedHeight(value),
        StaggeredMode.staggered => 80,
        StaggeredMode.sliver => masonryHeight(value),
      },
      label: '$value',
    );
  }

  Widget _buildMasonry() {
    Widget itemBuilder(BuildContext context, int index) => _item(index);
    switch (_api) {
      case StaggeredApi.count:
        return MasonryGridView.count(
          padding: const EdgeInsets.all(12),
          crossAxisCount: _columns,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          itemCount: _count,
          itemBuilder: itemBuilder,
        );
      case StaggeredApi.extent:
        return MasonryGridView.extent(
          padding: const EdgeInsets.all(12),
          maxCrossAxisExtent: _maxExtent,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          itemCount: _count,
          itemBuilder: itemBuilder,
        );
      case StaggeredApi.custom:
        return MasonryGridView.custom(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: _columns),
          childrenDelegate: SliverChildBuilderDelegate(itemBuilder, childCount: _count),
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
        );
    }
  }

  Widget _buildAligned() {
    Widget? itemBuilder(BuildContext context, int index) => _item(index);
    switch (_api) {
      case StaggeredApi.count:
        return AlignedGridView.count(
          padding: const EdgeInsets.all(12),
          crossAxisCount: _columns,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          itemCount: _count,
          itemBuilder: itemBuilder,
        );
      case StaggeredApi.extent:
        return AlignedGridView.extent(
          padding: const EdgeInsets.all(12),
          maxCrossAxisExtent: _maxExtent,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          itemCount: _count,
          itemBuilder: itemBuilder,
        );
      case StaggeredApi.custom:
        return AlignedGridView.custom(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: _columns),
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          itemCount: _count,
          itemBuilder: itemBuilder,
        );
    }
  }

  Widget _staggeredTile(int index) {
    final int value = index + _seed;
    final int crossAxisCellCount = index % 5 == 0 ? 2 : 1;
    switch (_tileMode) {
      case StaggeredTileMode.count:
        return StaggeredGridTile.count(
          crossAxisCellCount: crossAxisCellCount,
          mainAxisCellCount: index % 4 == 0 ? 2 : 1,
          child: ColorEntry(value, colorAt(value), height: 80, width: double.infinity, label: 'c$value'),
        );
      case StaggeredTileMode.extent:
        return StaggeredGridTile.extent(
          crossAxisCellCount: crossAxisCellCount,
          mainAxisExtent: 64 + (index % 4) * 26,
          child: ColorEntry(value, colorAt(value), height: 80, width: double.infinity, label: 'e$value'),
        );
      case StaggeredTileMode.fit:
        return StaggeredGridTile.fit(
          crossAxisCellCount: crossAxisCellCount,
          child: ColorEntry(
            value,
            colorAt(value),
            height: 56 + (index % 5) * 26,
            width: double.infinity,
            label: 'f$value',
          ),
        );
    }
  }

  Widget _buildStaggered() {
    final List<Widget> tiles = [for (int i = 0; i < _count; i++) _staggeredTile(i)];
    final Widget grid = switch (_api) {
      StaggeredApi.count => StaggeredGrid.count(
        crossAxisCount: _columns,
        mainAxisSpacing: _spacing,
        crossAxisSpacing: _spacing,
        children: tiles,
      ),
      StaggeredApi.extent => StaggeredGrid.extent(
        maxCrossAxisExtent: _maxExtent,
        mainAxisSpacing: _spacing,
        crossAxisSpacing: _spacing,
        children: tiles,
      ),
      StaggeredApi.custom => StaggeredGrid.custom(
        delegate: StaggeredGridDelegateWithFixedCrossAxisCount(crossAxisCount: _columns),
        mainAxisSpacing: _spacing,
        crossAxisSpacing: _spacing,
        children: tiles,
      ),
    };
    return SingleChildScrollView(padding: const EdgeInsets.all(12), child: grid);
  }

  Widget _buildSliver() {
    return FlRefreshScrollView(
      padding: const EdgeInsets.all(12),
      refreshConfig: demoRefreshConfig(delay: const Duration(milliseconds: 700)),
      slivers: [
        DemoInfoSliver(
          title: 'SliverMasonryGrid · SliverAlignedGrid',
          message:
              '两种 sliver 可以直接与其他 sliver 混排，'
              '并和 FlRefreshScrollView 的下拉刷新组合。',
          tags: ['crossAxisCount: $_columns', 'spacing: ${_spacing.toStringAsFixed(0)}'],
        ),
        SectionTitle('SliverMasonryGrid.count', subtitle: '瀑布流 sliver，子项高度自由'),
        SliverMasonryGrid.count(
          crossAxisCount: _columns,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          childCount: _count,
          itemBuilder: (_, int index) => Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: ColorEntry(
              index + _seed,
              colorAt(index + _seed),
              height: masonryHeight(index + _seed),
              label: 'm${index + _seed}',
            ),
          ),
        ),
        SectionTitle('SliverAlignedGrid.count', subtitle: '按行对齐 sliver，同一行取最高子项'),
        SliverAlignedGrid.count(
          crossAxisCount: _columns,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          itemCount: _count,
          itemBuilder: (_, int index) => ColorEntry(
            index + _seed + 100,
            colorAt(index + _seed + 100),
            height: alignedHeight(index + _seed + 100),
            label: 'a${index + _seed + 100}',
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildBody() {
    return switch (_mode) {
      StaggeredMode.masonry => _buildMasonry(),
      StaggeredMode.aligned => _buildAligned(),
      StaggeredMode.staggered => _buildStaggered(),
      StaggeredMode.sliver => _buildSliver(),
    };
  }

  String get _code {
    if (_mode == StaggeredMode.sliver) {
      return 'SliverMasonryGrid.count(crossAxisCount: $_columns, childCount: $_count, ...)\n'
          'SliverAlignedGrid.count(crossAxisCount: $_columns, itemCount: $_count, ...)';
    }
    final bool extent = _api == StaggeredApi.extent;
    final String gridDelegate = extent
        ? 'SliverSimpleGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: ${_maxExtent.toStringAsFixed(0)})'
        : 'SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: $_columns)';
    final String leader = extent
        ? 'maxCrossAxisExtent: ${_maxExtent.toStringAsFixed(0)},'
        : 'crossAxisCount: $_columns,';
    final String common =
        '  mainAxisSpacing: ${_spacing.toStringAsFixed(0)},\n'
        '  crossAxisSpacing: ${_spacing.toStringAsFixed(0)},\n';

    final String body;
    switch (_mode) {
      case StaggeredMode.masonry:
        body = switch (_api) {
          StaggeredApi.count =>
            'MasonryGridView.count(\n'
                '  $leader\n'
                '$common  itemCount: $_count,\n'
                '  itemBuilder: (_, i) => Tile(i),\n'
                ');',
          StaggeredApi.extent =>
            'MasonryGridView.extent(\n'
                '  $leader\n'
                '$common  itemCount: $_count,\n'
                '  itemBuilder: (_, i) => Tile(i),\n'
                ');',
          StaggeredApi.custom =>
            'MasonryGridView.custom(\n  gridDelegate: $gridDelegate,\n'
                '  childrenDelegate: SliverChildBuilderDelegate((_, i) => Tile(i), childCount: $_count),\n$common);',
        };
      case StaggeredMode.aligned:
        body = switch (_api) {
          StaggeredApi.count =>
            'AlignedGridView.count(\n'
                '  $leader\n'
                '$common  itemCount: $_count,\n'
                '  itemBuilder: (_, i) => Tile(i),\n'
                ');',
          StaggeredApi.extent =>
            'AlignedGridView.extent(\n'
                '  $leader\n'
                '$common  itemCount: $_count,\n'
                '  itemBuilder: (_, i) => Tile(i),\n'
                ');',
          StaggeredApi.custom =>
            'AlignedGridView.custom(\n  gridDelegate: $gridDelegate,\n$common  itemCount: $_count,\n'
                '  itemBuilder: (_, i) => Tile(i),\n);',
        };
      case StaggeredMode.staggered:
        body = switch (_api) {
          StaggeredApi.count =>
            'StaggeredGrid.count(\n  $leader\n$common  children: [\n'
                '    StaggeredGridTile.${_tileMode.name}(...),\n  ],\n);',
          StaggeredApi.extent =>
            'StaggeredGrid.extent(\n  $leader\n$common  children: [\n'
                '    StaggeredGridTile.${_tileMode.name}(...),\n  ],\n);',
          StaggeredApi.custom =>
            'StaggeredGrid.custom(\n  delegate: $gridDelegate,\n$common  children: [\n'
                '    StaggeredGridTile.${_tileMode.name}(...),\n  ],\n);',
        };
      case StaggeredMode.sliver:
        body = '';
    }
    return body;
  }

  List<Widget> _controls() {
    return [
      DemoActionRow(
        actions: [
          FilledButton.tonalIcon(
            onPressed: () => setState(() => _seed += 5),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text('换一组颜色/高度'),
          ),
        ],
      ),
      DemoParamRow(
        label: '组件',
        child: DemoChoice<StaggeredMode>(
          value: _mode,
          options: {for (final StaggeredMode mode in StaggeredMode.values) mode: mode.label},
          onChanged: (StaggeredMode mode) => setState(() => _mode = mode),
        ),
      ),
      if (_mode != StaggeredMode.sliver)
        DemoParamRow(
          label: '构造',
          child: DemoChoice<StaggeredApi>(
            value: _api,
            options: {for (final StaggeredApi api in StaggeredApi.values) api: api.label},
            onChanged: (StaggeredApi api) => setState(() => _api = api),
          ),
        ),
      if (_mode == StaggeredMode.staggered)
        DemoParamRow(
          label: 'Tile',
          child: DemoChoice<StaggeredTileMode>(
            value: _tileMode,
            options: {for (final StaggeredTileMode mode in StaggeredTileMode.values) mode: mode.label},
            onChanged: (StaggeredTileMode mode) => setState(() => _tileMode = mode),
          ),
        ),
      if (_mode != StaggeredMode.sliver && _api == StaggeredApi.extent)
        DemoSlider(
          label: '最大宽',
          value: _maxExtent,
          min: 80,
          max: 280,
          divisions: 20,
          display: _maxExtent.toStringAsFixed(0),
          onChanged: (double value) => setState(() => _maxExtent = value),
        )
      else
        DemoSlider(
          label: '列数',
          value: _columns.toDouble(),
          min: 1,
          max: 6,
          divisions: 5,
          display: '$_columns',
          onChanged: (double value) => setState(() => _columns = value.round()),
        ),
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
        label: '数量',
        value: _count.toDouble(),
        min: 8,
        max: 60,
        divisions: 26,
        display: '$_count',
        onChanged: (double value) => setState(() => _count = value.round()),
      ),
      if (_mode == StaggeredMode.staggered)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'StaggeredGrid 一次性布局全部子项，适合少量不规则拼块；'
            '长列表请用 MasonryGridView 或 Sliver 版本。'
            'tile.count 用主轴 cell 数，tile.extent 用固定像素，'
            'tile.fit 由内容决定高度。',
            style: TextStyle(fontSize: 10.5, height: 1.4, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarText(
        _mode.label,
        actions: [
          IconButton(
            tooltip: '查看代码',
            icon: const Icon(Icons.code_rounded),
            onPressed: () => showCodeSheet(context, title: '${_mode.label} 示例', code: _code),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          DemoDock(title: '交错组件参数实验台', children: _controls()),
        ],
      ),
    );
  }
}
