part of 'scroll_list_grid_page.dart';

class SliverTitle extends StatelessWidget {
  const SliverTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
      child: Container(
          alignment: Alignment.center,
          color: colorList[14],
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          )));
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
          child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 100,
        alignment: Alignment.center,
        color: Colors.grey.withValues(alpha: 0.3),
        child: const Text('Header'),
      ));
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
          child: Container(
        margin: const EdgeInsets.only(top: 10),
        height: 100,
        alignment: Alignment.center,
        color: Colors.grey.withValues(alpha: 0.3),
        child: const Text('Footer'),
      ));
}

class _FlEasyRefreshConfig extends FlEasyRefreshConfig {
  _FlEasyRefreshConfig()
      : super(onRefresh: (EasyRefreshController controller) {
          debugPrint('onRefresh');
          Future.delayed(const Duration(seconds: 2), () {
            controller(FlEasyRefreshResult.refreshSuccess);
          });
        }, onLoad: (EasyRefreshController controller) {
          debugPrint('onLoad');
          Future.delayed(const Duration(seconds: 2), () {
            controller(FlEasyRefreshResult.loadingSuccess);
          });
        });
}
