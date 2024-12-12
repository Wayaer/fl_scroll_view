import 'package:device_preview_minus/device_preview_minus.dart';
import 'package:example/src/nested_list_page.dart';
import 'package:example/src/scroll_list_page.dart';
import 'package:example/src/scroll_view_page.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DevicePreview(
      enabled: kIsWeb,
      defaultDevice: Devices.ios.iPhone13Mini,
      builder: (context) => MaterialApp(
          locale: DevicePreview.locale(context),
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          builder: (BuildContext context, Widget? child) {
            return DevicePreview.appBuilder(context, child);
          },
          home: Scaffold(
              appBar: AppBar(title: const Text('FlScrollView')),
              body: const HomePage()))));
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          ElevatedText('RefreshScrollView',
              onTap: () => push(const RefreshScrollViewPage())),
          ElevatedText('ExtendedSliverPersistentHeader',
              onTap: () => push(const FlSliverPersistentHeaderPage())),
          ElevatedText('NestedList', onTap: () => push(const NestedListPage())),
          ElevatedText('ScrollList', onTap: () => push(const ScrollListPage())),
          ElevatedText('ScrollList.builder',
              onTap: () => push(const ScrollListBuilderPage())),
          ElevatedText('ScrollList.builder separated',
              onTap: () => push(const ScrollListSeparatedPage())),
          ElevatedText('ScrollList.builder GridStyle.none',
              onTap: () => push(const ScrollListGridPage(GridStyle.none))),
          ElevatedText('ScrollList.builder GridStyle.masonry',
              onTap: () => push(const ScrollListGridPage(GridStyle.masonry))),
          ElevatedText('ScrollList.builder GridStyle.aligned',
              onTap: () => push(const ScrollListGridPage(GridStyle.aligned))),
          ElevatedText('ScrollList.count',
              onTap: () => push(const ScrollListCountPage())),
          ElevatedText('ScrollList.builder placeholder',
              onTap: () => push(const ScrollListPlaceholderPage())),
        ]);
  }

  void push(Widget widget) {
    showCupertinoModalPopup(context: context, builder: (_) => widget);
  }
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
