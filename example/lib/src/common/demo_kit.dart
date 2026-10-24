import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 示例条目数（仅用于方便观察滚动）
const int demoItemCount = 300;

const quiltedPattern = [
  QuiltedGridTile(2, 2),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 2),
];

const stairedPattern = [
  StairedGridTile(0.5, 1),
  StairedGridTile(0.5, 3 / 4),
  StairedGridTile(1.0, 10 / 4),
];

const wovenPattern = [
  WovenGridTile(1),
  WovenGridTile(
    5 / 7,
    crossAxisRatio: 0.9,
    alignment: AlignmentDirectional.centerEnd,
  ),
];

FlEasyRefreshConfig demoRefreshConfig() => FlEasyRefreshConfig(
  onRefresh: (EasyRefreshController controller) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return FlEasyRefreshResult.refreshSuccess;
  },
  onLoad: (EasyRefreshController controller) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return FlEasyRefreshResult.loadingSuccess;
  },
);

class AppBarText extends AppBar {
  AppBarText(String text, {super.key})
    : super(
        elevation: 0,
        title: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      );
}

class ElevatedText extends StatelessWidget {
  const ElevatedText(this.text, {this.onTap, super.key});

  final VoidCallback? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: onTap, child: Text(text)),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 16, 0, 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        color: Colors.blueGrey.shade800,
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// 一卡一色：颜色只由 [index] 决定，滚动复用也不会串色
class ColorEntry extends StatelessWidget {
  ColorEntry(
    this.index,
    this.color, {
    this.height = 80,
    this.width,
    this.label,
    Key? key,
  }) : super(key: key ?? ValueKey<int>(index));

  final int index;
  final Color color;
  final double height;
  final double? width;
  final String? label;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    alignment: Alignment.center,
    color: color,
    child: Text(
      label ?? '$index',
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}

Future<void> pushPage(Widget page) {
  return Navigator.of(navigatorKey.currentContext!).push(
    MaterialPageRoute<void>(builder: (_) => page),
  );
}

/// 按 index 生成稳定颜色（同一 index 永远同色）
Color colorAt(int index) {
  final hue = (index * 47) % 360;
  final lightness = 0.42 + (index % 5) * 0.06;
  return HSLColor.fromAHSL(1, hue.toDouble(), 0.72, lightness).toColor();
}

double masonryHeight(int index) => 60 + (index % 5) * 24;

double alignedHeight(int index) => index % 4 == 0 ? 100 : 48;
