import 'package:example/main.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/material.dart';

class FlSliverPersistentHeaderPage extends StatelessWidget {
  const FlSliverPersistentHeaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Scaffold(
        appBar: AppBarText('FlSliverPersistentHeader'),
        body: RefreshScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(10),
            slivers: [
              ...slivers,
              SliverListGrid.builder(
                  itemCount: colorList.length,
                  maxCrossAxisExtent: 60,
                  separatorBuilder: (_, int index) {
                    return Text('s$index');
                  },
                  itemBuilder: (_, int index) {
                    return ColorEntry(index, colorList[index]);
                  }),
              SliverListGrid.count(
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

  List<Widget> get slivers => [
        FlSliverPersistentHeader(
            pinned: true,
            floating: true,
            minHeight: 10,
            child: Container(
                height: 60,
                color: colorList[9],
                alignment: Alignment.center,
                child: const Text('FlSliverPersistentHeader',
                    style: TextStyle(color: Colors.black)))),
      ];
}

class RefreshScrollViewPage extends StatelessWidget {
  const RefreshScrollViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Scaffold(
        appBar: AppBarText('RefreshScrollView'),
        body: RefreshScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(10),
            refreshConfig: RefreshConfig(onRefresh: (_) async {
              debugPrint('onRefresh');
              await Future.delayed(const Duration(seconds: 2));
              return EasyRefreshType.refreshSuccess;
            }, onLoad: (_) async {
              debugPrint('onLoading');
              await Future.delayed(const Duration(seconds: 2));
              return EasyRefreshType.loadingSuccess;
            }),
            slivers: [
              SliverListGrid.builder(
                  itemCount: colorList.length,
                  maxCrossAxisExtent: 60,
                  separatorBuilder: (_, int index) {
                    return Text('s$index');
                  },
                  itemBuilder: (_, int index) {
                    return ColorEntry(index, colorList[index]);
                  }),
              SliverListGrid.count(
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
