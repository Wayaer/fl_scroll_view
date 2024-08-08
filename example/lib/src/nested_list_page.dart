import 'package:example/main.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/material.dart';

class NestedListPage extends StatelessWidget {
  const NestedListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('nested list'),
        body: Column(children: [
          Expanded(
              child: ScrollList.builder(
                  placeholder: Container(
                      color: Colors.amber,
                      alignment: Alignment.center,
                      child: const Text('placeholderFill = true \n placeholder',
                          textAlign: TextAlign.center)),
                  itemCount: 0,
                  separatorBuilder: (_, int index) {
                    return Text('s$index');
                  },
                  itemBuilder: (_, int index) {
                    return ColorEntry(index, colorList[index]);
                  })),
          const Divider(),
          Expanded(
              flex: 2,
              child: CustomScrollView(slivers: [
                SliverList.builder(
                    itemCount: colorList.sublist(0, 4).length,
                    itemBuilder: (_, int index) {
                      return ColorEntry(index, colorList[index]);
                    }),
                SliverToBoxAdapter(
                    child: ScrollList.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        placeholder: Container(
                            color: Colors.amber,
                            alignment: Alignment.center,
                            child: const Text(
                                'CustomScrollView Nested ScrollList\nplaceholder',
                                textAlign: TextAlign.center)),
                        itemCount: 0,
                        itemBuilder: (_, int index) {
                          return ColorEntry(index, colorList[index]);
                        })),
                SliverList.builder(
                    itemCount: colorList.sublist(0, 4).length,
                    itemBuilder: (_, int index) {
                      return ColorEntry(index, colorList[index]);
                    }),
              ])),
        ]));
  }
}
