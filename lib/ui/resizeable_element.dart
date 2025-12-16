import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/canvas_state.dart';

enum ResizeHandlePosition {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

class ResizeHandle extends StatelessWidget {
  const ResizeHandle({
    super.key,
    required this.position,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final ResizeHandlePosition position;
  final VoidCallback onDragStart;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnd;

  MouseCursor _getCursor() {
    switch (position) {
      case ResizeHandlePosition.topLeft:
      case ResizeHandlePosition.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case ResizeHandlePosition.topRight:
      case ResizeHandlePosition.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case ResizeHandlePosition.topCenter:
      case ResizeHandlePosition.bottomCenter:
        return SystemMouseCursors.resizeUpDown;
      case ResizeHandlePosition.centerLeft:
      case ResizeHandlePosition.centerRight:
        return SystemMouseCursors.resizeLeftRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _getCursor(),
      child: Listener(
        onPointerDown: (_) => onDragStart(),
        onPointerMove: (event) => onDragUpdate(event.delta),
        onPointerUp: (_) => onDragEnd(),
        onPointerCancel: (_) => onDragEnd(),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.purple,
            border: Border.all(color: Colors.purple, width: 2),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class PositionResizeHandle extends StatelessWidget {
  const PositionResizeHandle({
    super.key,
    required this.position,
    required this.notifier,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  final ResizeHandlePosition position;
  final CanvasNotifier notifier;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: ResizeHandle(
        position: position,
        onDragStart: () => notifier.startResize(position),
        onDragUpdate: (delta) => notifier.updateElementSize(position, delta),
        onDragEnd: () => notifier.endResize(),
      ),
    );
  }
}

class ResizableElement extends ConsumerWidget {
  const ResizableElement({
    super.key,
    required this.child,
    required this.element,
  });

  final Widget child;
  final SketchElement element;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = element.size!;
    final canvasNotifier = ref.read(canvasProvider.notifier);

    // We add padding around the element to accommodate the resize handles
    // which are positioned outside the element bounds.
    // This ensures they are within the hit test area.
    const handlePadding = 12.0;

    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: SizedBox(
        width: size.width + (handlePadding * 2),
        height: size.height + (handlePadding * 2),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: handlePadding,
              left: handlePadding,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: child,
              ),
            ),
            PositionResizeHandle(
              position: ResizeHandlePosition.topLeft,
              notifier: canvasNotifier,
              top: 0,
              left: 0,
            ),
            PositionResizeHandle(
              position: ResizeHandlePosition.topRight,
              notifier: canvasNotifier,
              top: 0,
              right: 0,
            ),
            PositionResizeHandle(
              position: ResizeHandlePosition.bottomLeft,
              notifier: canvasNotifier,
              bottom: 0,
              left: 0,
            ),
            PositionResizeHandle(
              position: ResizeHandlePosition.bottomRight,
              notifier: canvasNotifier,
              bottom: 0,
              right: 0,
            ),
            PositionResizeHandle(
              position: ResizeHandlePosition.topCenter,
              notifier: canvasNotifier,
              top: 0,
              left: (size.width + (handlePadding * 2)) / 2 - 6,
            ),
            PositionResizeHandle(
              position: ResizeHandlePosition.bottomCenter,
              notifier: canvasNotifier,
              bottom: 0,
              left: (size.width + (handlePadding * 2)) / 2 - 6,
            ),
            PositionResizeHandle(
              position: ResizeHandlePosition.centerLeft,
              notifier: canvasNotifier,
              top: (size.height + (handlePadding * 2)) / 2 - 6,
              left: 0,
            ),
            PositionResizeHandle(
              position: ResizeHandlePosition.centerRight,
              notifier: canvasNotifier,
              top: (size.height + (handlePadding * 2)) / 2 - 6,
              right: 0,
            ),
          ],
        ),
      ),
    );
  }
}
