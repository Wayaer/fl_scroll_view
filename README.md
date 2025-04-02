# fl_scroll_view

## Run [Web example](https://wayaer.github.io/fl_scroll_view/example/app/web/index.html#/)

### FlScrollListGrid.count

```dart
Widget build(BuildContext context) {
  return FlScrollListGrid.count(
      header: const Header(),
      footer: const Footer(),
      padding: const EdgeInsets.all(10),
      maxCrossAxisExtent: 100,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      gridStyle: GridStyle.masonry,
      refreshConfig: FlEasyRefreshConfig<void>(
          onRefresh: (EasyRefreshController controller) async {
            debugPrint('onRefresh');
            await Future.delayed(const Duration(seconds: 2), () {
              FlEasyRefreshControllers().call(FlEasyRefreshResult.refreshSuccess);
            });
          }, onLoad: (EasyRefreshController controller) async {
        debugPrint('onLoad');
        await Future.delayed(const Duration(seconds: 2), () {
          FlEasyRefreshControllers().call(FlEasyRefreshResult.loadingSuccess);
        });
      }),
      children: []);
}

```

### FlScrollListGrid.builder

```dart
Widget build(BuildContext context) {
  return FlScrollListGrid.builder(
      header: const Header(),
      footer: const Footer(),
      maxCrossAxisExtent: 100,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      gridStyle: GridStyle.masonry,
      separatorBuilder: (_, int index) => Divider(),
      refreshConfig: FlEasyRefreshConfig(
          onRefresh: (EasyRefreshController controller) async {
            debugPrint('onRefresh');
            await Future.delayed(const Duration(seconds: 2), () {
              FlEasyRefreshControllers().call(FlEasyRefreshResult.refreshSuccess);
            });
          }, onLoad: (EasyRefreshController controller) async {
        debugPrint('onLoad');
        await Future.delayed(const Duration(seconds: 2), () {
          FlEasyRefreshControllers().call(FlEasyRefreshResult.loadingSuccess);
        });
      }),
      children: []);
}

```

## Sliver

```dart
Widget build(BuildContext context) {
  return FlRefreshScrollView(
      controller: scrollController,
      refreshConfig: FlEasyRefreshConfig(
          onRefresh: (EasyRefreshController controller) async {
            debugPrint('onRefresh');
            await Future.delayed(const Duration(seconds: 2), () {
              FlEasyRefreshControllers().call(FlEasyRefreshResult.refreshSuccess);
            });
          }, onLoad: (EasyRefreshController controller) async {
        debugPrint('onLoad');
        await Future.delayed(const Duration(seconds: 2), () {
          FlEasyRefreshControllers().call(FlEasyRefreshResult.loadingSuccess);
        });
      }),
      slivers: [
        FlSliverPersistentHeader(
            pinned: true,
            floating: false,
            child: Container(
                color: colorList[9],
                alignment: Alignment.center,
                child: const Text('FlSliverPersistentHeader',
                    style: TextStyle(color: Colors.black)))),
        FlSliverListGrid.builder(
            itemCount: colorList.length,
            maxCrossAxisExtent: 100,
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            gridStyle: GridStyle.masonry,
            separatorBuilder: (_, int index) {
              return Text('s$index');
            },
            itemBuilder: (_, int index) {
              return ColorEntry(index, colorList[index]);
            }),
        FlSliverListGrid.count(
            maxCrossAxisExtent: 100,
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            gridStyle: GridStyle.masonry,
            children: [
            ]),
      ]);
}
```