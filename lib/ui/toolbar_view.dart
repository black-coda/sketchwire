import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

import '../state/canvas_state.dart';

class ToolbarView extends StatefulWidget {
  const ToolbarView({super.key});

  @override
  State<ToolbarView> createState() => _ToolbarViewState();
}

class _ToolbarViewState extends State<ToolbarView> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isCollapsed ? 60 : 200,

      child: SketchyTheme.consumer(
        builder: (context, theme) {
          return SketchyCard(
            child: Column(
              crossAxisAlignment: .stretch,
              mainAxisAlignment: .center,
              children: [
                Expanded(
                  child: ListView(
                    // separatorBuilder: (context, index)=> SizedBox(height: 20),
                    padding: const EdgeInsets.all(8),
                    children: [
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
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              SketchyText(label, style: TextStyle(color: theme.inkColor)),
            ],
          ),
        );
      },
    );
  }
}
