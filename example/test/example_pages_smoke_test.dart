import 'package:example/src/home_page.dart';
import 'package:example/src/pages/layout_lab_page.dart';
import 'package:example/src/pages/list_options_page.dart';
import 'package:example/src/pages/nested_page.dart';
import 'package:example/src/pages/refresh_lab_page.dart';
import 'package:example/src/pages/scroll_view_lab_page.dart';
import 'package:example/src/pages/sliver_lab_page.dart';
import 'package:example/src/pages/staggered_lab_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> pumpDemo(WidgetTester tester, Widget page, {Size size = const Size(430, 900)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: page));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  expect(tester.takeException(), isNull);
}

Future<void> tapChip(WidgetTester tester, String text) async {
  final Finder finder = find.widgetWithText(FilterChip, text);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('home page renders', (WidgetTester tester) async {
    await pumpDemo(tester, const HomePage());
    expect(find.text('fl_scroll_view'), findsWidgets);
  });

  testWidgets('home page fits compact width', (WidgetTester tester) async {
    await pumpDemo(tester, const HomePage(), size: const Size(320, 640));
  });

  testWidgets('layout lab fits compact height', (WidgetTester tester) async {
    await pumpDemo(tester, const LayoutLabPage(), size: const Size(320, 640));
  });

  final Map<String, Widget> compactPages = {
    'refresh lab': const RefreshLabPage(),
    'scroll view lab': const ScrollViewLabPage(),
    'sliver lab': const SliverLabPage(),
    'list options': const ListOptionsPage(),
    'staggered lab': const StaggeredLabPage(mode: StaggeredMode.staggered),
    'nested page': const NestedPage(),
  };
  for (final MapEntry<String, Widget> entry in compactPages.entries) {
    testWidgets('${entry.key} fits compact width', (WidgetTester tester) async {
      await pumpDemo(tester, entry.value, size: const Size(320, 640));
    });
  }

  for (final DemoLayoutKind kind in DemoLayoutKind.values) {
    testWidgets('layout lab ${kind.name}', (WidgetTester tester) async {
      await pumpDemo(tester, LayoutLabPage(kind: kind));
      await tapChip(tester, '空数据');
      await tapChip(tester, 'count 模式');
      await tapChip(tester, '空数据');
    });
  }

  testWidgets('layout lab quilted columns slider stays stable', (WidgetTester tester) async {
    await pumpDemo(tester, const LayoutLabPage(kind: DemoLayoutKind.quilted));
    final Finder slider = find.byType(Slider).first;
    for (int i = 0; i < 2; i++) {
      await tester.drag(slider, const Offset(60, 0));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('sliver lab header stays stable at collapse threshold', (WidgetTester tester) async {
    await pumpDemo(tester, const SliverLabPage());
    final Finder scrollableFinder = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    );
    final ScrollableState scrollable = tester.state<ScrollableState>(scrollableFinder);
    for (double offset = 24; offset <= 44; offset += 2) {
      scrollable.position.jumpTo(offset);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'offset=$offset');
    }
  });

  testWidgets('refresh lab renders and calls', (WidgetTester tester) async {
    await pumpDemo(tester, const RefreshLabPage());
    await tester.tap(find.text('callRefresh'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('callLoad'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('scroll view lab switches axis', (WidgetTester tester) async {
    await pumpDemo(tester, const ScrollViewLabPage());
    final Finder horizontal = find.text('horizontal');
    await tester.ensureVisible(horizontal);
    await tester.pump();
    await tester.tap(horizontal);
    await tester.pump();
    expect(tester.takeException(), isNull);
    final Finder vertical = find.text('vertical');
    await tester.ensureVisible(vertical);
    await tester.pump();
    await tester.tap(vertical);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sliver lab renders', (WidgetTester tester) async {
    await pumpDemo(tester, const SliverLabPage());
  });

  testWidgets('list options shuffles and empties', (WidgetTester tester) async {
    await pumpDemo(tester, const ListOptionsPage());
    await tester.tap(find.text('打乱顺序'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    await tapChip(tester, '空数据');
  });

  for (final StaggeredMode mode in StaggeredMode.values) {
    testWidgets('staggered lab ${mode.name}', (WidgetTester tester) async {
      await pumpDemo(tester, StaggeredLabPage(mode: mode));
      if (mode != StaggeredMode.sliver) {
        final Finder extent = find.text('extent');
        await tester.ensureVisible(extent);
        await tester.pump();
        await tester.tap(extent);
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('code sheet opens', (WidgetTester tester) async {
    await pumpDemo(tester, const LayoutLabPage(kind: DemoLayoutKind.list));
    await tester.tap(find.byIcon(Icons.code_rounded));
    await tester.pumpAndSettle();
    expect(find.text('List 调用示例'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested page renders', (WidgetTester tester) async {
    await pumpDemo(tester, const NestedPage());
  });
}
