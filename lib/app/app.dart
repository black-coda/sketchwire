import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';
import '../state/canvas_state.dart';
import '../ui/canvas_view.dart';
import '../ui/toolbar_view.dart';

import '../ui/settings_view.dart';

class SketchWireApp extends ConsumerStatefulWidget {
  const SketchWireApp({super.key});

  @override
  ConsumerState<SketchWireApp> createState() => _SketchWireAppState();
}

class _SketchWireAppState extends ConsumerState<SketchWireApp> {
  @override
  Widget build(BuildContext context) {
    return SketchyScaffold(
      appBar: SketchyAppBar(
        title: SketchyText('SketchWire'),
        actions: [
          SketchyButton(
            onPressed: () {
              Navigator.of(context).push(
                SketchyPageRoute(builder: (context) => const SettingsView()),
              );
            },
            child: const Icon(LucideIcons.settings),
          ),
          SketchyButton(
            onPressed: () {
              final state = ref.read(canvasProvider);
              final jsonList = state.elements.map((e) => e.toJson()).toList();
              print('Exported JSON: $jsonList');
              // In a real app, we would save to file or show a dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const SketchyText('Exported JSON'),
                  content: SingleChildScrollView(
                    child: SketchyText(jsonList.toString()),
                  ),
                  actions: [
                    SketchyButton(
                      onPressed: () => Navigator.pop(context),
                      child: const SketchyText('Close'),
                    ),
                  ],
                ),
              );
            },
            child: Row(
              children: [
                const SketchyText('Export JSON'),
                const Icon(LucideIcons.download),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          const ToolbarView(),
          SizedBox(width: 16),
          Expanded(child: const CanvasView()),
        ],
      ),
    );
  }
}
