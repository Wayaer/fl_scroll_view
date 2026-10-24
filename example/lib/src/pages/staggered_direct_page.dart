import 'package:example/src/common/demo_kit.dart';
import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

/// 直接使用库导出的独立滚动组件（非 FlScrollListGrid 封装）
enum StaggeredDirectKind { masonryView, alignedView, staggeredGrid }

class StaggeredDirectPage extends StatelessWidget {
  const StaggeredDirectPage(this.kind, {super.key});

  final StaggeredDirectKind kind;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarText(_title),
      body: switch (kind) {
        StaggeredDirectKind.masonryView => MasonryGridView.count(
          padding: const EdgeInsets.all(10),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: demoItemCount,
          itemBuilder: (_, int index) => ColorEntry(
            index,
            colorAt(index),
            height: masonryHeight(index),
          ),
        ),
        StaggeredDirectKind.alignedView => AlignedGridView.count(
          padding: const EdgeInsets.all(10),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: demoItemCount,
          itemBuilder: (_, int index) => ColorEntry(
            index,
            colorAt(index),
            height: alignedHeight(index),
          ),
        ),
        // StaggeredGrid 一次性构建全部 tile，不宜用 demoItemCount(300)
        StaggeredDirectKind.staggeredGrid => SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: StaggeredGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (int i = 0; i < 48; i++)
                StaggeredGridTile.count(
                  crossAxisCellCount: i.isEven ? 2 : 1,
                  mainAxisCellCount: i % 3 == 0 ? 2 : 1,
                  child: ColorEntry(i, colorAt(i)),
                ),
            ],
          ),
        ),
      },
    );
  }

  String get _title => switch (kind) {
    StaggeredDirectKind.masonryView => 'MasonryGridView',
    StaggeredDirectKind.alignedView => 'AlignedGridView',
    StaggeredDirectKind.staggeredGrid => 'StaggeredGrid',
  };
}
