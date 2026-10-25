import 'dart:async';

import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> pumpApp(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('empty shrinkWrap grid does not use SliverFillRemaining', (WidgetTester tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              FlScrollListGrid.builder(
                shrinkWrap: true,
                itemCount: 0,
                itemBuilder: (BuildContext context, int index) => Text('$index')
              ),
            ]
          )
        )
      )
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('explicit placeholderFill falls back in unbounded viewport', (WidgetTester tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  FlSliverListGrid.builder(
                    itemCount: 0,
                    placeholderFill: true,
                    placeholder: const Text('empty'),
                    itemBuilder: (BuildContext context, int index) => Text('$index')
                  ),
                ]
              ),
            ]
          )
        )
      )
    );
    expect(tester.takeException(), isNull);
    expect(find.text('empty'), findsOneWidget);
  });

  testWidgets('external controller with default flags receives failed result', (WidgetTester tester) async {
    final EasyRefreshController controller = EasyRefreshController();
    addTearDown(controller.dispose);
    await pumpApp(
      tester,
      Scaffold(
        body: FlRefreshScrollView(
          refreshConfig: FlEasyRefreshConfig(
            controller: controller,
            onRefresh: (EasyRefreshController controller) async => FlEasyRefreshResult.refreshFailed
          ),
          slivers: [SliverToBoxAdapter(child: SizedBox(height: 2000))]
        )
      )
    );
    unawaited(controller.callRefresh());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    expect(controller.headerState?.result, IndicatorResult.fail);
    expect(controller.headerState?.mode, isNot(IndicatorMode.processing));
  });

  testWidgets('throwing refresh callback is marked failed and does not stick', (WidgetTester tester) async {
    final EasyRefreshController controller = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);
    addTearDown(controller.dispose);
    await pumpApp(
      tester,
      Scaffold(
        body: FlRefreshScrollView(
          refreshConfig: FlEasyRefreshConfig(
            controller: controller,
            onRefresh: (EasyRefreshController controller) async => throw StateError('boom')
          ),
          slivers: [SliverToBoxAdapter(child: SizedBox(height: 2000))]
        )
      )
    );
    unawaited(controller.callRefresh());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isStateError);
    expect(controller.headerState?.result, IndicatorResult.fail);
    expect(controller.headerState?.mode, isNot(IndicatorMode.processing));
  });

  testWidgets('masonry survives deep jumps and scrolling back', (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpApp(
      tester,
      Scaffold(
        body: CustomScrollView(
          controller: controller,
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 300)),
            SliverMasonryGrid.count(
              crossAxisCount: 2,
              childCount: 120,
              itemBuilder: (BuildContext context, int index) => SizedBox(height: 60 + index % 5 * 20)
            ),
            SliverToBoxAdapter(child: SizedBox(height: 300)),
          ]
        )
      )
    );
    final double extent = controller.position.maxScrollExtent;
    controller.jumpTo(extent * 0.7);
    await tester.pump();
    controller.jumpTo(extent * 0.2);
    await tester.pump();
    controller.jumpTo(0);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('masonry extent handles zero cross axis extent', (WidgetTester tester) async {
    await pumpApp(
      tester,
      Center(
        child: SizedBox(
          width: 0,
          height: 300,
          child: CustomScrollView(
            slivers: [
              SliverMasonryGrid.extent(
                maxCrossAxisExtent: 100,
                childCount: 5,
                itemBuilder: (BuildContext context, int index) => const SizedBox.shrink()
              ),
            ]
          )
        )
      )
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('aligned grid handles zero itemCount', (WidgetTester tester) async {
    await pumpApp(
      tester,
      CustomScrollView(
        slivers: [
          SliverAlignedGrid.count(
            crossAxisCount: 2,
            itemCount: 0,
            itemBuilder: (BuildContext context, int index) => Text('$index')
          ),
        ]
      )
    );
    expect(tester.takeException(), isNull);
  });

  test('quilted pattern rejects invalid tiles in release too', () {
    expect(
      () => SliverQuiltedGridDelegate(crossAxisCount: 2, pattern: [const QuiltedGridTile(1, 3)]),
      throwsArgumentError
    );
    expect(() => SliverQuiltedGridDelegate(crossAxisCount: 2, pattern: const []), throwsArgumentError);
  });

  test('quilted pattern supports arbitrary crossAxisCount', () {
    const List<QuiltedGridTile> pattern = [
      QuiltedGridTile(2, 2),
      QuiltedGridTile(1, 1),
      QuiltedGridTile(1, 1),
      QuiltedGridTile(1, 2),
    ];
    for (final int count in [4, 5, 6]) {
      expect(() => SliverQuiltedGridDelegate(crossAxisCount: count, pattern: pattern), returnsNormally);
    }
  });

  test('woven extent delegate relayouts when maxCrossAxisExtent changes', () {
    const List<WovenGridTile> pattern = [WovenGridTile(1)];
    final SliverWovenGridDelegate first = SliverWovenGridDelegate.extent(pattern: pattern, maxCrossAxisExtent: 100);
    final SliverWovenGridDelegate second = SliverWovenGridDelegate.extent(pattern: pattern, maxCrossAxisExtent: 200);
    expect(second.shouldRelayout(first), isTrue);
  });

  test('woven delegate compares pattern contents instead of identity', () {
    final SliverWovenGridDelegate first = SliverWovenGridDelegate.extent(
      pattern: [const WovenGridTile(1)],
      maxCrossAxisExtent: 100
    );
    final SliverWovenGridDelegate same = SliverWovenGridDelegate.extent(
      pattern: [const WovenGridTile(1)],
      maxCrossAxisExtent: 100
    );
    final SliverWovenGridDelegate different = SliverWovenGridDelegate.extent(
      pattern: [const WovenGridTile(2)],
      maxCrossAxisExtent: 100
    );
    expect(same.shouldRelayout(first), isFalse);
    expect(different.shouldRelayout(first), isTrue);
  });

  testWidgets('persistent header keeps original pinned and floating defaults', (WidgetTester tester) async {
    await pumpApp(
      tester,
      CustomScrollView(
        slivers: [FlSliverPersistentHeader(child: SizedBox(height: kToolbarHeight))]
      )
    );
    final FlSliverPersistentHeader header = tester.widget(find.byType(FlSliverPersistentHeader));
    expect(header.pinned, isTrue);
    expect(header.floating, isTrue);
  });

  test('persistent header normalizes inverted min and max heights', () {
    final FlSliverPersistentHeader header = FlSliverPersistentHeader(
      minHeight: 100,
      maxHeight: 50,
      child: const SizedBox()
    );
    final FlSliverPersistentHeaderDelegate delegate = header.delegate as FlSliverPersistentHeaderDelegate;
    expect(delegate.maxExtent, 100);
    expect(delegate.minExtent, 50);
  });

  test('aligned layout rejects find callbacks', () {
    expect(
      () => FlSliverListGrid.builder(
        layout: const ListGridLayout.aligned(),
        itemBuilder: (BuildContext context, int index) => const SizedBox(),
        findItemIndexCallback: (Key key) => null
      ),
      throwsAssertionError
    );
  });

  testWidgets('pinned header renders with semantics', (WidgetTester tester) async {
    await pumpApp(
      tester,
      CustomScrollView(
        slivers: [
          FlSliverPinnedToBoxAdapter(child: Container(height: 50)),
          SliverToBoxAdapter(child: SizedBox(height: 2000)),
        ]
      )
    );
    expect(find.byType(FlSliverPinnedToBoxAdapter), findsOneWidget);
    expect(find.byType(Semantics), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pinned and floating headers follow pull-to-refresh and pinned stays afterwards', (
    WidgetTester tester
  ) async {
    final ScrollController scroll = ScrollController();
    addTearDown(scroll.dispose);
    const ValueKey<String> persKey = ValueKey<String>('persistent-header');
    const ValueKey<String> floatingKey = ValueKey<String>('floating-header');
    const ValueKey<String> pinKey = ValueKey<String>('pinned-adapter');
    await pumpApp(
      tester,
      Scaffold(
        body: FlRefreshScrollView(
          controller: scroll,
          refreshConfig: FlEasyRefreshConfig(
            onRefresh: (EasyRefreshController controller) async => FlEasyRefreshResult.refreshSuccess
          ),
          slivers: [
            FlSliverPersistentHeader(
              pinned: true,
              floating: false,
              minHeight: 56,
              maxHeight: 56,
              child: SizedBox(key: persKey, height: 56)
            ),
            FlSliverPersistentHeader(
              pinned: false,
              floating: true,
              minHeight: 40,
              maxHeight: 40,
              child: SizedBox(key: floatingKey, height: 40)
            ),
            FlSliverPinnedToBoxAdapter(child: SizedBox(key: pinKey, height: 50)),
            SliverToBoxAdapter(child: SizedBox(height: 2000)),
          ]
        )
      )
    );
    final Finder pers = find.byKey(persKey);
    final Finder floating = find.byKey(floatingKey);
    final Finder pin = find.byKey(pinKey);
    final double persTop = tester.getTopLeft(pers).dy;
    final double floatingTop = tester.getTopLeft(floating).dy;
    final double pinTop = tester.getTopLeft(pin).dy;

    final TestGesture gesture = await tester.startGesture(tester.getCenter(find.byType(CustomScrollView)));
    await gesture.moveBy(const Offset(0, 100));
    await tester.pump();
    expect(tester.getTopLeft(pers).dy, greaterThan(persTop));
    expect(tester.getTopLeft(floating).dy, greaterThan(floatingTop));
    expect(tester.getTopLeft(pin).dy, greaterThan(pinTop));

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.getTopLeft(floating).dy, greaterThan(floatingTop));
    expect(tester.getTopLeft(pin).dy, greaterThan(pinTop));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getTopLeft(pers).dy, persTop);
    final double pinAfterScroll = tester.getTopLeft(pin).dy;
    expect(pinAfterScroll, lessThan(pinTop));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getTopLeft(pers).dy, persTop);
    expect(tester.getTopLeft(pin).dy, pinAfterScroll);
    expect(tester.takeException(), isNull);
  });
}
