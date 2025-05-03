import 'package:example/main.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/material.dart';

class FlSliverPersistentHeaderPage extends StatelessWidget {
  const FlSliverPersistentHeaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('FlSliverPersistentHeader'),
        body: FlRefreshScrollView(padding: const EdgeInsets.all(10), slivers: [
          FlSliverPersistentHeader(
              pinned: true,
              floating: true,
              minHeight: 0,
              maxHeight: 100,
              child: Container(
                  color: colorList[9],
                  alignment: Alignment.center,
                  child: const Text('FlSliverPersistentHeader',
                      style: TextStyle(color: Colors.black)))),
          FlSliverListGrid.builder(
              itemCount: colorList.length,
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              itemBuilder: (_, int index) {
                return ColorEntry(index, colorList[index]);
              }),
        ]));
  }
}

class FlSliverPinnedToBoxAdapterPage extends StatelessWidget {
  const FlSliverPinnedToBoxAdapterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('FlSliverPinnedToBoxAdapter'),
        body: FlRefreshScrollView(padding: const EdgeInsets.all(10), slivers: [
          FlSliverPinnedToBoxAdapter(
              child: Container(
                  height: 100,
                  color: colorList[9],
                  alignment: Alignment.center,
                  child: const Text('FlSliverPinnedToBoxAdapter',
                      style: TextStyle(color: Colors.black)))),
          FlSliverListGrid.builder(
              itemCount: colorList.length,
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              itemBuilder: (_, int index) {
                return ColorEntry(index, colorList[index]);
              }),
        ]));
  }
}

class FlRefreshScrollViewPage extends StatelessWidget {
  const FlRefreshScrollViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Scaffold(
        appBar: AppBarText('FlRefreshScrollView'),
        body: FlRefreshScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(10),
            refreshConfig: FlEasyRefreshConfig(onRefresh: (_) async {
              debugPrint('onRefresh');
              await Future.delayed(const Duration(seconds: 2));
              return FlEasyRefreshResult.refreshSuccess;
            }, onLoad: (_) async {
              debugPrint('onLoad');
              await Future.delayed(const Duration(seconds: 2));
              return FlEasyRefreshResult.loadingSuccess;
            }),
            slivers: [
              FlSliverListGrid.builder(
                  itemCount: colorList.length,
                  maxCrossAxisExtent: 60,
                  separatorBuilder: (_, int index) {
                    return Text('s$index');
                  },
                  itemBuilder: (_, int index) {
                    return ColorEntry(index, colorList[index]);
                  }),
              FlSliverListGrid.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: colorList
                      .asMap()
                      .entries
                      .map((MapEntry<int, Color> entry) =>
                          ColorEntry(entry.key, entry.value))
                      .toList()),
            ]));
  }
}
