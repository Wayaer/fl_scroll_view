part of 'scroll_list_grid_page.dart';

class _FlScrollListGridCountPage extends StatelessWidget {
  const _FlScrollListGridCountPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('FlScrollListGrid.count'),
        body: FlScrollListGrid.count(
            header: const _Header(),
            footer: const _Footer(),
            padding: const EdgeInsets.all(10),
            refreshConfig: _FlEasyRefreshConfig(),
            children: colorList
                .asMap()
                .entries
                .map((MapEntry<int, Color> entry) =>
                    ColorEntry(entry.key, entry.value))
                .toList()));
  }
}

class _FlScrollListGridPageWithCountGridStyle extends StatelessWidget {
  const _FlScrollListGridPageWithCountGridStyle(this.gridStyle);

  final GridStyle gridStyle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('$gridStyle'),
        body: FlScrollListGrid.count(
          gridStyle: gridStyle,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          maxCrossAxisExtent: gridStyle == GridStyle.aligned ? null : 100,
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          header: const _Header(),
          footer: const _Footer(),
          padding: const EdgeInsets.all(10),
          refreshConfig: _FlEasyRefreshConfig(),
          children: colorList.asMap().entries.map((MapEntry<int, Color> entry) {
            final index = entry.key;
            return ColorEntry(index, colorList[index],
                width: index.isEven ? 40 : 100,
                height: index.isEven ? 100 : 40);
          }).toList(),
        ));
  }
}
