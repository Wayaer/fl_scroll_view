import 'package:example/src/common/demo_kit.dart';
import 'package:example/src/home_page.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  configureDemoRefreshStyles();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: demoThemeMode,
      builder: (BuildContext context, ThemeMode themeMode, Widget? child) => MaterialApp(
        title: 'FlScrollView',
        navigatorKey: navigatorKey,
        theme: demoTheme(Brightness.light),
        darkTheme: demoTheme(Brightness.dark),
        themeMode: themeMode,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}
