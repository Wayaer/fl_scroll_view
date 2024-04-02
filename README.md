# fl_scroll_view

## Run [Web example](https://wayaer.github.io/fl_scroll_view/example/app/web/index.html#/)

### ScrollList.count

```dart
Widget build(BuildContext context) {
  return ScrollList.count(
      header: const Header(),
      footer: const Footer(),
      padding: const EdgeInsets.all(10),
      maxCrossAxisExtent: 100,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      gridStyle: GridStyle.masonry,
      refreshConfig: RefreshConfig(
          onRefresh: () async {
            debugPrint('onRefresh');
            await Future.delayed(const Duration(seconds: 2), () {
              RefreshControllers().call(EasyRefreshType.refreshSuccess);
            });
          }, onLoading: () async {
        debugPrint('onLoading');
        await Future.delayed(const Duration(seconds: 2), () {
          RefreshControllers().call(EasyRefreshType.loadingSuccess);
        });
      }),
      children: []);
}

```

### ScrollList.builder

```dart
Widget build(BuildContext context) {
  return ScrollList.builder(
      header: const Header(),
      footer: const Footer(),
      maxCrossAxisExtent: 100,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      gridStyle: GridStyle.masonry,
      separatorBuilder: (_, int index) => Divider(),
      refreshConfig: RefreshConfig(
          onRefresh: () async {
            debugPrint('onRefresh');
            await Future.delayed(const Duration(seconds: 2), () {
              RefreshControllers().call(EasyRefreshType.refreshSuccess);
            });
          }, onLoading: () async {
        debugPrint('onLoading');
        await Future.delayed(const Duration(seconds: 2), () {
          RefreshControllers().call(EasyRefreshType.loadingSuccess);
        });
      }),
      children: []);
}

```

## Sliver

```dart
Widget build(BuildContext context) {
  return RefreshScrollView(
      controller: scrollController,
      refreshConfig: RefreshConfig(
          onRefresh: () async {
            debugPrint('onRefresh');
            await Future.delayed(const Duration(seconds: 2), () {
              RefreshControllers().call(EasyRefreshType.refreshSuccess);
            });
          }, onLoading: () async {
        debugPrint('onLoading');
        await Future.delayed(const Duration(seconds: 2), () {
          RefreshControllers().call(EasyRefreshType.loadingSuccess);
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
        SliverListGrid.builder(
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
        SliverListGrid.count(
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