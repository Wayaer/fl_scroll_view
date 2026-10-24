import 'package:device_preview_minus/device_preview_minus.dart';
import 'package:example/src/common/demo_kit.dart';
import 'package:example/src/home_page.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  EasyRefresh.defaultHeaderBuilder = () => const ClassicHeader(
    dragText: '请尽情拉我',
    armedText: '可以松开我了',
    readyText: '我要开始刷新了',
    processingText: '我在拼命刷新中',
    processedText: '我已经刷新完成了',
    failedText: '我刷新失败了唉',
    noMoreText: '没有更多了',
    showMessage: false,
  );
  EasyRefresh.defaultFooterBuilder = () => const ClassicFooter(
    dragText: '请尽情拉我',
    armedText: '可以松开我了',
    readyText: '我要准备加载了',
    processingText: '我在拼命加载中',
    processedText: '我已经加载完成了',
    failedText: '我加载失败了唉',
    noMoreText: '没有更多了哦',
    showMessage: false,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return DevicePreview(
      enabled: !kIsWeb ? false : true,
      defaultDevice: Devices.ios.iPhone13Mini,
      builder: (context) => MaterialApp(
        navigatorKey: navigatorKey,
        locale: DevicePreview.locale(context),
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        debugShowCheckedModeBanner: false,
        builder: (BuildContext context, Widget? child) {
          // ignore: deprecated_member_use
          return MaterialUiCompatibilityBridge(
            child: DevicePreview.appBuilder(context, child),
          );
        },
        home: Scaffold(
          appBar: AppBar(title: const Text('fl_scroll_view example')),
          body: const HomePage(),
        ),
      ),
    );
  }
}
