import 'package:example/main.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/material.dart';

class ScrollListGridPage extends StatelessWidget {
  const ScrollListGridPage(this.gridStyle, {super.key});

  final GridStyle gridStyle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('ScrollList.builder GridStyle'),
        body: ScrollList.builder(
          gridStyle: gridStyle,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          maxCrossAxisExtent: gridStyle == GridStyle.aligned ? null : 100,
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          header: const _Header(),
          footer: const _Footer(),
          padding: const EdgeInsets.all(10),
          refreshConfig: _RefreshConfig(),
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

class ScrollListSeparatedPage extends StatelessWidget {
  const ScrollListSeparatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('ScrollList.separated'),
        body: ScrollList.builder(
          header: const _Header(),
          footer: const _Footer(),
          padding: const EdgeInsets.all(10),
          refreshConfig: _RefreshConfig(),
          itemCount: colorList.length,
          itemBuilder: (_, int index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ColorEntry(index, colorList[index])),
          separatorBuilder: (_, int index) => const Divider(
              color: Colors.amberAccent, height: 30, thickness: 10),
        ));
  }
}

class ScrollListPlaceholderPage extends StatelessWidget {
  const ScrollListPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('ScrollList.builder placeholder'),
        body: ScrollList.builder(
            header: const _Header(),
            footer: const _Footer(),
            padding: const EdgeInsets.all(10),
            refreshConfig: _RefreshConfig(),
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

class ScrollListBuilderPage extends StatelessWidget {
  const ScrollListBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('ScrollList.builder'),
        body: ScrollList.builder(
          header: const _Header(),
          footer: const _Footer(),
          padding: const EdgeInsets.all(10),
          refreshConfig: _RefreshConfig(),
          itemBuilder: (_, int index) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ColorEntry(
                  index, index.isEven ? colorList.first : colorList.last)),
        ));
  }
}

class ScrollListPage extends StatelessWidget {
  const ScrollListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('ScrollList'),
        body: ScrollList(
            padding: const EdgeInsets.all(10),
            header: const _Header(),
            footer: const _Footer(),
            refreshConfig: _RefreshConfig(),
            sliver: [
              const SliverTitle('SliverListGrid builder'),
              SliverListGrid.builder(
                  itemCount: colorList.length,
                  itemBuilder: (_, int index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ColorEntry(index, colorList[index]))),
              const SliverTitle('SliverListGrid.builder GridStyle.aligned'),
              SliverListGrid.builder(
                  gridStyle: GridStyle.aligned,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemCount: colorList.length,
                  itemBuilder: (_, int index) => ColorEntry(
                      index, colorList[index],
                      height: index & 3 == 0 ? 80 : 40)),
              const SliverTitle('SliverListGrid.count GridStyle.masonry'),
              SliverListGrid.count(
                  gridStyle: GridStyle.masonry,
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: colorList
                      .asMap()
                      .entries
                      .map((entry) => ColorEntry(entry.key, entry.value,
                          height: entry.key.isEven ? 100 : 70,
                          width: entry.key.isEven ? 50 : 100))
                      .toList()),
              const SliverTitle('SliverListGrid.builder GridStyle.masonry'),
              SliverListGrid.builder(
                  gridStyle: GridStyle.masonry,
                  maxCrossAxisExtent: 100,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemCount: colorList.length,
                  itemBuilder: (_, int index) => ColorEntry(
                      index, colorList[index],
                      height: index.isEven ? 100 : 70,
                      width: index.isEven ? 50 : 100)),
              const SliverTitle('SliverListGrid.builder maxCrossAxisExtent'),
              SliverListGrid.builder(
                  itemCount: colorList.length,
                  maxCrossAxisExtent: 100,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemBuilder: (_, int index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ColorEntry(index, colorList[index]))),
              const SliverTitle('SliverListGrid.builder crossAxisCount'),
              SliverListGrid.builder(
                  itemCount: colorList.length,
                  crossAxisCount: 8,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemBuilder: (_, int index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ColorEntry(index, colorList[index]))),
              const SliverTitle('SliverListGrid.builder separatorBuilder'),
              SliverListGrid.builder(
                  itemCount: colorList.length,
                  separatorBuilder: (_, int index) => Divider(
                      color: colorList[index], thickness: 10, height: 20),
                  itemBuilder: (_, int index) =>
                      ColorEntry(index, colorList[index])),
            ]));
  }
}

class SliverTitle extends StatelessWidget {
  const SliverTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
      child: Container(
          alignment: Alignment.center,
          color: colorList[14],
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          )));
}

class ScrollListCountPage extends StatelessWidget {
  const ScrollListCountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('ScrollList.count'),
        body: ScrollList.count(
            header: const _Header(),
            footer: const _Footer(),
            padding: const EdgeInsets.all(10),
            refreshConfig: _RefreshConfig(),
            children: colorList
                .asMap()
                .entries
                .map((MapEntry<int, Color> entry) =>
                    ColorEntry(entry.key, entry.value))
                .toList()));
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
          child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 100,
        alignment: Alignment.center,
        color: Colors.grey.withValues(alpha: 0.3),
        child: const Text('Header'),
      ));
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
          child: Container(
        margin: const EdgeInsets.only(top: 10),
        height: 100,
        alignment: Alignment.center,
        color: Colors.grey.withValues(alpha: 0.3),
        child: const Text('Footer'),
      ));
}

class _RefreshConfig extends RefreshConfig {
  _RefreshConfig()
      : super(onRefresh: () async {
          debugPrint('onRefresh');
          await Future.delayed(const Duration(seconds: 2), () {
            RefreshControllers().call(EasyRefreshType.refreshSuccess);
          });
        }, onLoading: () async {
          debugPrint('onLoading');
          await Future.delayed(const Duration(seconds: 2), () {
            RefreshControllers().call(EasyRefreshType.loadingSuccess);
          });
        });
}
