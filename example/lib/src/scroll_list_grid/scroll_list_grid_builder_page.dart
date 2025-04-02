part of 'scroll_list_grid_page.dart';

class _FlScrollListGridBuilderPage extends StatelessWidget {
  const _FlScrollListGridBuilderPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('FlScrollListGrid.builder'),
        body: FlScrollListGrid.builder(
          header: const _Header(),
          footer: const _Footer(),
          padding: const EdgeInsets.all(10),
          refreshConfig: _FlEasyRefreshConfig(),
          itemBuilder: (_, int index) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ColorEntry(
                  index, index.isEven ? colorList.first : colorList.last)),
        ));
  }
}

class _FlScrollListGridPageWithBuilderSeparated extends StatelessWidget {
  const _FlScrollListGridPageWithBuilderSeparated();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('FlScrollListGrid.separated'),
        body: FlScrollListGrid.builder(
          header: const _Header(),
          footer: const _Footer(),
          padding: const EdgeInsets.all(10),
          refreshConfig: _FlEasyRefreshConfig(),
          itemCount: colorList.length,
          itemBuilder: (_, int index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ColorEntry(index, colorList[index])),
          separatorBuilder: (_, int index) => const Divider(
              color: Colors.amberAccent, height: 30, thickness: 10),
        ));
  }
}

class _FlScrollListGridPageWithBuilderPlaceholder extends StatelessWidget {
  const _FlScrollListGridPageWithBuilderPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('placeholder'),
        body: FlScrollListGrid.builder(
            header: const _Header(),
            footer: const _Footer(),
            padding: const EdgeInsets.all(10),
            refreshConfig: _FlEasyRefreshConfig(),
            placeholder: Container(
                alignment: Alignment.center,
                color: colorList[14],
                padding: const EdgeInsets.symmetric(vertical: 10),
                child:
                    const Text('没有数据', style: TextStyle(color: Colors.white))),
            itemCount: 0,
            itemBuilder: (_, int index) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ColorEntry(index, colorList[index]),
                )));
  }
}

class _FlScrollListGridPageWithBuilderGridStyle extends StatelessWidget {
  const _FlScrollListGridPageWithBuilderGridStyle(this.gridStyle);

  final GridStyle gridStyle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('$gridStyle'),
        body: FlScrollListGrid.builder(
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
          itemCount: [...colorList, ...colorList, ...colorList].length,
          itemBuilder: (_, int index) {
            if (gridStyle == GridStyle.aligned) {
              return ColorEntry(
                  index, [...colorList, ...colorList, ...colorList][index],
                  height: index & 3 == 0 ? 100 : 40);
            }
            return ColorEntry(
                index, [...colorList, ...colorList, ...colorList][index],
                width: index.isEven ? 40 : 100,
                height: index.isEven ? 100 : 40);
          },
        ));
  }
}
