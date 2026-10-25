import 'dart:async';

import 'package:example/src/common/demo_kit.dart';

/// 让测试使用与 App 相同的刷新指示器默认样式，避免在窄屏下复现上游溢出。
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  configureDemoRefreshStyles();
  await testMain();
}
