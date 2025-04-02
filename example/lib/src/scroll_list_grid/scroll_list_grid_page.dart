import 'package:example/main.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/material.dart';

part 'scroll_list_grid_builder_page.dart';

part 'scroll_list_grid_count_page.dart';

part 'scroll_widget.dart';

class FlScrollListGridPage extends StatelessWidget {
  const FlScrollListGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('FlScrollListGrid'),
        body: FlScrollListGrid.count(children: [
          ElevatedText('FlScrollListGrid',
              onTap: () => push(const _FlScrollListGridPage())),
          ElevatedText('FlScrollListGrid.builder',
              onTap: () => push(const _FlScrollListGridBuilderPage())),
          ElevatedText('FlScrollListGrid.builder separated',
              onTap: () =>
                  push(const _FlScrollListGridPageWithBuilderSeparated())),
          ElevatedText('FlScrollListGrid.builder placeholder',
              onTap: () =>
                  push(const _FlScrollListGridPageWithBuilderPlaceholder())),
          ElevatedText('FlScrollListGrid.builder GridStyle.none',
              onTap: () => push(const _FlScrollListGridPageWithBuilderGridStyle(
                  GridStyle.none))),
          ElevatedText('FlScrollListGrid.builder GridStyle.masonry',
              onTap: () => push(const _FlScrollListGridPageWithBuilderGridStyle(
                  GridStyle.masonry))),
          ElevatedText('FlScrollListGrid.builder GridStyle.aligned',
              onTap: () => push(const _FlScrollListGridPageWithBuilderGridStyle(
                  GridStyle.aligned))),
          ElevatedText('FlScrollListGrid.count',
              onTap: () => push(const _FlScrollListGridCountPage())),
          ElevatedText('FlScrollListGrid.count GridStyle.none',
              onTap: () => push(const _FlScrollListGridPageWithCountGridStyle(
                  GridStyle.none))),
          ElevatedText('FlScrollListGrid.count GridStyle.masonry',
              onTap: () => push(const _FlScrollListGridPageWithCountGridStyle(
                  GridStyle.masonry))),
        ]));
  }
}

class _FlScrollListGridPage extends StatelessWidget {
  const _FlScrollListGridPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('FlScrollListGrid'),
        body: FlScrollListGrid(
            padding: const EdgeInsets.all(10),
            header: const _Header(),
            footer: const _Footer(),
            refreshConfig: _FlEasyRefreshConfig(),
            sliver: [
              const SliverTitle('FlSliverListGrid builder'),
              FlSliverListGrid.builder(
                  itemCount: colorList.length,
                  itemBuilder: (_, int index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ColorEntry(index, colorList[index]))),
              const SliverTitle('FlSliverListGrid.builder GridStyle.aligned'),
              FlSliverListGrid.builder(
                  gridStyle: GridStyle.aligned,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemCount: colorList.length,
                  itemBuilder: (_, int index) => ColorEntry(
                      index, colorList[index],
                      height: index & 3 == 0 ? 80 : 40)),
              const SliverTitle('FlSliverListGrid.builder GridStyle.masonry'),
              FlSliverListGrid.builder(
                  gridStyle: GridStyle.masonry,
                  maxCrossAxisExtent: 100,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemCount: colorList.length,
                  itemBuilder: (_, int index) => ColorEntry(
                      index, colorList[index],
                      height: index.isEven ? 100 : 70,
                      width: index.isEven ? 50 : 100)),
              const SliverTitle('FlSliverListGrid.builder maxCrossAxisExtent'),
              FlSliverListGrid.builder(
                  itemCount: colorList.length,
                  maxCrossAxisExtent: 100,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemBuilder: (_, int index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ColorEntry(index, colorList[index]))),
              const SliverTitle('FlSliverListGrid.builder crossAxisCount'),
              FlSliverListGrid.builder(
                  itemCount: colorList.length,
                  crossAxisCount: 8,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemBuilder: (_, int index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ColorEntry(index, colorList[index]))),
              const SliverTitle('FlSliverListGrid.builder separatorBuilder'),
              FlSliverListGrid.builder(
                  itemCount: colorList.length,
                  separatorBuilder: (_, int index) => Divider(
                      color: colorList[index], thickness: 10, height: 20),
                  itemBuilder: (_, int index) =>
                      ColorEntry(index, colorList[index])),
              const SliverTitle('FlSliverListGrid.count GridStyle.masonry'),
              FlSliverListGrid.count(
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
            ]));
  }
}
