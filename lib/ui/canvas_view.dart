import 'package:custom_mouse_cursor/custom_mouse_cursor.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../state/canvas_state.dart';
import '../state/canvas_settings_state.dart';
import 'element_renderer.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';
import 'selection_toolbar.dart';
import 'grid_painter.dart';

class CanvasView extends ConsumerStatefulWidget {
  const CanvasView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CanvasViewState();
}

class _CanvasViewState extends ConsumerState<CanvasView> {
  CustomMouseCursor? iconCursor;

  @override
  void initState() {
    super.initState();
    _loadIconCursor();
  }

  Future<void> _loadIconCursor() async {
    iconCursor = await .icon(
      LucideIcons.pencil,
      size: 12,
      hotX: 0,
      hotY: 0,
      color: Colors.deepPurpleAccent,
    );
    if (mounted) {
      setState(() {}); // Rebuild to apply the new cursor
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);
    final notifier = ref.read(canvasProvider.notifier);
    final canvasSettings = ref.watch(canvasSettingsProvider);

    return SketchyTheme.consumer(
      builder: (context, theme) {
        return DragTarget<SketchElementType>(
          onAcceptWithDetails: (details) {
            // Convert global position to local position relative to the canvas
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            var localPosition = renderBox.globalToLocal(details.offset);

            // Snap to grid if enabled
            if (canvasSettings.snapToGrid) {
              final gridSize = canvasSettings.gridSize;
              localPosition = Offset(
                ((localPosition.dx / gridSize).round() * gridSize).toDouble(),
                ((localPosition.dy / gridSize).round() * gridSize).toDouble(),
              );
            }

            notifier.addElement(details.data, localPosition);
          },
          builder: (context, candidateData, rejectedData) {
            return MouseRegion(
              cursor: canvasSettings.isDrawingMode
                  ? (iconCursor ?? SystemMouseCursors.basic)
                  : SystemMouseCursors.basic,
              child: GestureDetector(
                onTap: () {
                  // Deselect when clicking on empty space
                  notifier.selectElement(null);
                },
                onPanStart: canvasSettings.isDrawingMode
                    ? (details) {
                        final RenderBox renderBox =
                            context.findRenderObject() as RenderBox;
                        final localPosition = renderBox.globalToLocal(
                          details.globalPosition,
                        );
                        notifier.startFreehand(localPosition);
                      }
                    : null,
                onPanUpdate: canvasSettings.isDrawingMode
                    ? (details) {
                        final RenderBox renderBox =
                            context.findRenderObject() as RenderBox;
                        final localPosition = renderBox.globalToLocal(
                          details.globalPosition,
                        );
                        notifier.updateFreehand(localPosition);
                      }
                    : null,
                onPanEnd: canvasSettings.isDrawingMode
                    ? (details) {
                        notifier.endFreehand(); // 👈 Essential!
                      }
                    : null,
                child: SketchyCard(
                  child: Stack(
                    children: [
                      // Grid pattern
                      if (canvasSettings.showGrid)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: SketchyGridPainter(
                              gridSize: canvasSettings.gridSize,
                              gridColor: theme.borderColor.withValues(
                                alpha: 0.2,
                              ),
                              roughness: theme.roughness,
                            ),
                          ),
                        ),

                      // Elements
                      ...canvasState.elements.map((element) {
                        return Positioned(
                          key: ValueKey(element.id),
                          left: element.position.dx,
                          top: element.position.dy,
                          child: RepaintBoundary(
                            child: IgnorePointer(
                              ignoring: canvasSettings.isDrawingMode,
                              child: GestureDetector(
                                onTap: () {
                                  notifier.selectElement(element.id);
                                },
                                onPanUpdate: (details) {
                                  var newPosition =
                                      element.position + details.delta;

                                  // Snap to grid if enabled
                                  if (canvasSettings.snapToGrid) {
                                    final gridSize = canvasSettings.gridSize;
                                    newPosition = Offset(
                                      ((newPosition.dx / gridSize).round() *
                                              gridSize)
                                          .toDouble(),
                                      ((newPosition.dy / gridSize).round() *
                                              gridSize)
                                          .toDouble(),
                                    );
                                  }

                                  notifier.updateElementPosition(
                                    element.id,
                                    newPosition,
                                  );
                                  // Also select it while dragging
                                  if (canvasState.selectedElementId !=
                                      element.id) {
                                    notifier.selectElement(element.id);
                                  }
                                },
                                child: ElementRenderer(
                                  element: element,
                                  isSelected:
                                      canvasState.selectedElementId ==
                                      element.id,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      // Selection Toolbar
                      if (canvasState.selectedElementId != null)
                        Builder(
                          builder: (context) {
                            // Safety check, though selectedElementId should be valid if not null.
                            // Actually, if we delete it, it might be null or invalid for a frame.
                            // But we clear selection on delete.

                            // We need to find the element.
                            try {
                              final element = canvasState.elements.firstWhere(
                                (e) => e.id == canvasState.selectedElementId,
                              );
                              return Positioned(
                                left: element.position.dx,
                                top: element.position.dy - 50, // Position above
                                child: SelectionToolbar(elementId: element.id),
                              );
                            } catch (e) {
                              return const SizedBox();
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
