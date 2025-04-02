import 'package:device_preview_minus/device_preview_minus.dart';
import 'package:example/src/nested_scroll_view_page.dart';
import 'package:example/src/scroll_list_grid/scroll_list_grid_page.dart';
import 'package:example/src/scroll_view_page.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  EasyRefresh.defaultHeaderBuilder = () => const ClassicHeader(
      dragText: '请尽情拉我',
      armedText: '可以松开我了',
      readyText: '我要开始刷新了',
      processingText: '我在拼命刷新中',
      processedText: '我已经刷新完成了',
      failedText: '我刷新失败了唉',
      noMoreText: '没有更多了',
      showMessage: false);
  EasyRefresh.defaultFooterBuilder = () => const ClassicFooter(
      dragText: '请尽情拉我',
      armedText: '可以松开我了',
      readyText: '我要准备加载了',
      processingText: '我在拼命加载中',
      processedText: '我已经加载完成了',
      failedText: '我加载失败了唉',
      noMoreText: '没有更多了哦',
      showMessage: false);
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return DevicePreview(
        enabled: kIsWeb,
        defaultDevice: Devices.ios.iPhone13Mini,
        builder: (context) => MaterialApp(
            navigatorKey: navigatorKey,
            locale: DevicePreview.locale(context),
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            debugShowCheckedModeBanner: false,
            builder: (BuildContext context, Widget? child) {
              return DevicePreview.appBuilder(context, child);
            },
            home: Scaffold(
                appBar: AppBar(title: const Text('FlScrollView')),
                body: const HomePage())));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          ElevatedText('FlScrollListGrid',
              onTap: () => push(const FlScrollListGridPage())),
          ElevatedText('FlRefreshScrollView',
              onTap: () => push(const FlRefreshScrollViewPage())),
          ElevatedText('FlSliverPersistentHeader',
              onTap: () => push(const FlSliverPersistentHeaderPage())),
          ElevatedText('FlSliverPinnedToBoxAdapter',
              onTap: () => push(const FlSliverPinnedToBoxAdapterPage())),
          ElevatedText('NestedScrollView',
              onTap: () => push(const NestedScrollViewPage())),
        ]);
  }
}

const List<Color> colorList = <Color>[
  ...Colors.accents,
  ...Colors.primaries,
];

class AppBarText extends AppBar {
  AppBarText(String text, {super.key})
      : super(
            elevation: 0,
            title: Text(text,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true);
}

class ElevatedText extends StatelessWidget {
  const ElevatedText(this.text, {this.onTap, super.key});

  final VoidCallback? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    final current = ElevatedButton(onPressed: onTap, child: Text(text));
    if (defaultTargetPlatform == TargetPlatform.android &&
        defaultTargetPlatform == TargetPlatform.iOS) {
      return current;
    }
    return Padding(padding: const EdgeInsets.all(10), child: current);
  }
}

void push(Widget widget) {
  showCupertinoModalPopup(
      context: navigatorKey.currentContext!, builder: (_) => widget);
}

class ColorEntry extends StatelessWidget {
  const ColorEntry(this.index, this.color,
      {this.height = 80, this.width = 80, super.key});

  final int index;
  final Color color;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) => Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: color,
      child: Text(index.toString(),
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)));
}
