import 'package:fl_scroll_view/fl_scroll_view.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 全局主题模式：默认跟随系统，可通过 [DemoThemeToggle] 切换白天 / 黑夜
final ValueNotifier<ThemeMode> demoThemeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

/// 示例条目数（仅用于方便观察滚动）
const int demoItemCount = 300;

/// 应用与 widget 测试共用的刷新指示器默认样式。
///
/// 精简文案并关闭 message，避免窄屏下 ClassicIndicator 溢出。
void configureDemoRefreshStyles() {
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
}

const List<Color> demoSeedColors = [
  Color(0xFF4F46E5),
  Color(0xFF7C3AED),
  Color(0xFF0EA5E9),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
];

const quiltedPattern = [QuiltedGridTile(2, 2), QuiltedGridTile(1, 1), QuiltedGridTile(1, 1), QuiltedGridTile(1, 2)];

const stairedPattern = [StairedGridTile(0.5, 1), StairedGridTile(0.5, 3 / 4), StairedGridTile(1.0, 10 / 4)];

const wovenPattern = [
  WovenGridTile(1),
  WovenGridTile(5 / 7, crossAxisRatio: 0.9, alignment: AlignmentDirectional.centerEnd),
];

FlEasyRefreshConfig demoRefreshConfig({
  Duration delay = const Duration(milliseconds: 900),
  FlEasyRefreshResult refreshResult = FlEasyRefreshResult.refreshSuccess,
  FlEasyRefreshResult loadResult = FlEasyRefreshResult.loadingSuccess,
}) => FlEasyRefreshConfig(
  onRefresh: (EasyRefreshController controller) async {
    await Future<void>.delayed(delay);
    return refreshResult;
  },
  onLoad: (EasyRefreshController controller) async {
    await Future<void>.delayed(delay);
    return loadResult;
  },
);

ThemeData demoTheme(Brightness brightness) {
  final ColorScheme scheme = ColorScheme.fromSeed(seedColor: demoSeedColors.first, brightness: brightness);
  final bool isDark = brightness == Brightness.dark;
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: isDark ? const Color(0xFF0B1020) : const Color(0xFFF5F6FA),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? const Color(0xFF0B1020) : const Color(0xFFF5F6FA),
      surfaceTintColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
    ),
  );
}

class AppBarText extends AppBar {
  AppBarText(String text, {super.key, List<Widget>? actions})
    : super(
        elevation: 0,
        centerTitle: true,
        title: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [...?actions, const DemoThemeToggle()],
      );
}

/// 白天 / 黑夜切换按钮，挂在各页面 AppBar 右侧
class DemoThemeToggle extends StatelessWidget {
  const DemoThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? '切换到白天' : '切换到黑夜',
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      onPressed: () => demoThemeMode.value = isDark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}

/// 一卡一色：颜色只由 [index] 决定，滚动复用也不会串色
class ColorEntry extends StatelessWidget {
  ColorEntry(this.index, this.color, {this.height = 80, this.width, this.label, Key? key})
    : super(key: key ?? ValueKey<int>(index));

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
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Text(
      label ?? '$index',
      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
    ),
  );
}

/// 综合页 / 测试共用的 sliver 标题
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: scheme.onSurface),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle!, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 页面顶部的说明卡（作为 sliver 使用）
class DemoInfoSliver extends StatelessWidget {
  const DemoInfoSliver({super.key, required this.title, required this.message, this.tags = const []});

  final String title;
  final String message;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 18, color: scheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: TextStyle(fontSize: 12, height: 1.5, color: scheme.onPrimaryContainer.withValues(alpha: 0.85)),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(spacing: 6, runSpacing: 6, children: [for (final String tag in tags) DemoPill(tag, dense: true)]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 小胶囊标签
class DemoPill extends StatelessWidget {
  const DemoPill(this.text, {super.key, this.icon, this.dense = false, this.color});

  final String text;
  final IconData? icon;
  final bool dense;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color tone = color ?? scheme.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 4 : 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withValues(alpha: 0.2)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          if (icon != null) Icon(icon, size: dense ? 12 : 14, color: tone),
          Text(
            text,
            style: TextStyle(fontSize: dense ? 10.5 : 12, color: tone, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// 统一的参数实验台：固定在页面底部，内容可滚动
class DemoDock extends StatelessWidget {
  const DemoDock({super.key, required this.title, required this.children, this.trailing});

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      elevation: 10,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune_rounded, size: 16, color: scheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: 6),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DemoParamRow extends StatelessWidget {
  const DemoParamRow({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// 单选胶囊组
class DemoChoice<T> extends StatelessWidget {
  const DemoChoice({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final MapEntry<T, String> entry in options.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: entry.key == value,
            onSelected: enabled ? (_) => onChanged(entry.key) : null,
          ),
      ],
    );
  }
}

/// 多选胶囊组
class DemoToggles extends StatelessWidget {
  const DemoToggles({super.key, required this.labels, required this.values, required this.onChanged});

  final List<String> labels;
  final List<bool> values;
  final void Function(int index, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    assert(labels.length == values.length);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (int i = 0; i < labels.length; i++)
          FilterChip(label: Text(labels[i]), selected: values[i], onSelected: (bool value) => onChanged(i, value)),
      ],
    );
  }
}

class DemoToggle extends StatelessWidget {
  const DemoToggle({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(label: Text(label), selected: value, onSelected: onChanged);
  }
}

class DemoSlider extends StatelessWidget {
  const DemoSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.display,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String? display;

  @override
  Widget build(BuildContext context) {
    return DemoParamRow(
      label: label,
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              label: display ?? value.toStringAsFixed(0),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              display ?? value.toStringAsFixed(0),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// 一行操作按钮（实验台顶部的快捷操作）
class DemoActionRow extends StatelessWidget {
  const DemoActionRow({super.key, required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < actions.length; i++) ...[if (i > 0) const SizedBox(width: 8), actions[i]],
        ],
      ),
    );
  }
}

/// 打开代码片段面板
Future<void> showCodeSheet(BuildContext context, {required String title, required String code}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      final ColorScheme scheme = Theme.of(sheetContext).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    tooltip: '复制',
                    icon: const Icon(Icons.content_copy_rounded),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: code));
                      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      code,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.55),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 刷新 / 滚动示例里通用的列表卡片
class DemoListCard extends StatelessWidget {
  const DemoListCard({
    super.key,
    required this.index,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.height = 72,
  });

  final int index;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color tone = colorAt(index);
    return SizedBox(
      height: height,
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tone, tone.withValues(alpha: 0.65)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$index',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title ?? 'Item $index', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing! else Icon(Icons.chevron_right_rounded, color: scheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DemoEmptyPlaceholder extends StatelessWidget {
  const DemoEmptyPlaceholder({super.key, this.fill = false, this.overscroll = false});

  final bool fill;
  final bool overscroll;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget content = Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: scheme.primaryContainer.withValues(alpha: 0.6), shape: BoxShape.circle),
            child: Icon(Icons.inbox_rounded, size: 34, color: scheme.primary),
          ),
          const SizedBox(height: 14),
          const Text('空数据占位', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'placeholder: DemoEmptyPlaceholder()\nplaceholderFill: $fill · fillOverscroll: $overscroll',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, height: 1.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
    if (!fill) return content;
    return Center(child: content);
  }
}

Future<void> pushPage(Widget page) {
  return Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute<void>(builder: (_) => page));
}

/// 按 index 生成稳定颜色（同一 index 永远同色）
Color colorAt(int index) {
  final int hue = (index * 47) % 360;
  final double lightness = 0.42 + (index % 5) * 0.06;
  return HSLColor.fromAHSL(1, hue.toDouble(), 0.72, lightness).toColor();
}

double masonryHeight(int index) => 60 + (index % 5) * 24;

double alignedHeight(int index) => index % 4 == 0 ? 100 : 48;
