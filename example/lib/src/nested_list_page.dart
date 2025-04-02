import 'package:example/main.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/material.dart';

class NestedScrollViewPage extends StatelessWidget {
  const NestedScrollViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('NestedScrollView'),
        body: NestedScrollView(
          headerSliverBuilder:
              (BuildContext context, bool innerBoxIsScrolled) => [
            FlSliverPersistentHeader(
                maxHeight: 100,
                minHeight: 0,
                child: Container(
                    color: Colors.blue,
                    alignment: Alignment.center,
                    child: const Text('FlSliverPersistentHeader',
                        textAlign: TextAlign.center))),
            FlSliverPinnedToBoxAdapter(
                child: Container(
                    color: Colors.greenAccent,
                    height: 100,
                    alignment: Alignment.center,
                    child: const Text('FlSliverPinnedToBoxAdapter',
                        textAlign: TextAlign.center)))
          ],
          body: CustomScrollView(slivers: [
            SliverList.builder(
                itemCount: colorList.length,
                itemBuilder: (_, int index) {
                  return ColorEntry(index, colorList[index]);
                }),
          ]),
        ));
  }
}
