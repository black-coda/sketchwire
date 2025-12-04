import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

import '../state/canvas_state.dart';
import '../state/canvas_settings_state.dart';

class ToolbarView extends ConsumerStatefulWidget {
  const ToolbarView({super.key});

  @override
  ConsumerState<ToolbarView> createState() => _ToolbarViewState();
}

class _ToolbarViewState extends ConsumerState<ToolbarView> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isCollapsed ? 60 : 200,

      child: SketchyTheme.consumer(
        builder: (context, theme) {
          return SketchyCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: .stretch,
              mainAxisAlignment: .center,
              children: [
                Expanded(
                  child: ListView(
                    // separatorBuilder: (context, index)=> SizedBox(height: 20),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildResetCanvasButton(),
                      _buildDrawingToggle(ref),
                      const SketchyDivider(),
                      _buildToolItem(
                        SketchElementType.text,
                        'Text',
                        LucideIcons.typeOutline,
                      ),
                      _buildToolItem(
                        SketchElementType.button,
                        'Button',
                        LucideIcons.gamepadDirectional,
                      ),
                      _buildToolItem(
                        SketchElementType.input,
                        'Input',
                        LucideIcons.textCursor,
                      ),
                      _buildToolItem(
                        SketchElementType.container,
                        'Container',
                        LucideIcons.squareDashed,
                      ),
                      _buildToolItem(
                        SketchElementType.image,
                        'Image',
                        LucideIcons.image,
                      ),
                      _buildToolItem(
                        SketchElementType.circle,
                        'Circle',
                        LucideIcons.circle,
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: Icon(
                    _isCollapsed
                        ? LucideIcons.panelLeftOpen
                        : LucideIcons.panelLeftClose,
                  ),
                  onPressed: () {
                    setState(() {
                      _isCollapsed = !_isCollapsed;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolItem(SketchElementType type, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Draggable<SketchElementType>(
        data: type,
        feedback: Opacity(
          opacity: 0.7,
          child: SizedBox(
            width: 150, // Fixed width for feedback
            child: SketchyCard(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(icon),
                    const SizedBox(width: 12),
                    SketchyText(label),
                  ],
                ),
              ),
            ),
          ),
        ),
        child: _buildToolContent(label, icon),
      ),
    );
  }

  Widget _buildResetCanvasButton() {
    return GestureDetector(
      onTap:
          // icon: Icon(LucideIcons.refreshCcw),
          ref.read(canvasProvider.notifier).resetCanvas,
      child: _buildToolContent("Reset", LucideIcons.circlePower),
    );
  }

  Widget _buildToolContent(String label, IconData icon) {
    if (_isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Icon(icon),
      );
    }
    return SketchyTheme.consumer(
      builder: (context, theme) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: SketchyTooltip(
            message: label,
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                SketchyText(label, style: TextStyle(color: theme.inkColor)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawingToggle(WidgetRef ref) {
    final settings = ref.watch(canvasSettingsProvider);
    final isDrawing = settings.isDrawingMode;

    return GestureDetector(
      onTap: () {
        ref.read(canvasSettingsProvider.notifier).toggleDrawingMode();
      },
      child: SketchyTheme.consumer(
        builder: (context, theme) {
          return Container(
            child: Column(
              mainAxisAlignment: .center,
              mainAxisSize: .min,
              children: [
                _buildToolContent(
                  'Free Sketch',
                  isDrawing ? LucideIcons.pencil : LucideIcons.pencilLine,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
