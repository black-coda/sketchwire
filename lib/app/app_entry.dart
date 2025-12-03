import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sketchwire/theme/theme_config_state_notifier.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

import 'app.dart';

class SketchWireAppEntry extends ConsumerWidget {
  const SketchWireAppEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(sketchWireThemeConfigProvider);
    return SketchyApp(
      title: 'Sketch Wire',
      theme: themeConfig.themeData,
      themeMode: themeConfig.themeMode,
      debugShowCheckedModeBanner: false,
      home: SketchWireApp(),
    );
  }
}
