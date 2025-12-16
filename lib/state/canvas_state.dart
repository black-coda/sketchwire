import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sketchwire/ui/resizeable_element.dart';
import 'package:uuid/uuid.dart';

// --- Models ---

enum SketchElementType {
  text,
  button,
  input,
  container,
  image,
  circle,
  freehand,
}

class SketchElement {
  final String id;
  final SketchElementType type;
  final Offset position;
  final String? text;
  final Size? size; // For container, image, circle
  final List<Offset>? points; // For freehand
  // Add more properties as needed (color, style, etc.)

  SketchElement({
    required this.id,
    required this.type,
    required this.position,
    this.text,
    this.size,
    this.points,
  });

  SketchElement copyWith({
    String? id,
    SketchElementType? type,
    Offset? position,
    String? text,
    Size? size,
    List<Offset>? points,
  }) {
    return SketchElement(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      text: text ?? this.text,
      size: size ?? this.size,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'position': {'dx': position.dx, 'dy': position.dy},
      'text': text,
      'size': size != null
          ? {'width': size!.width, 'height': size!.height}
          : null,
      'points': points?.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
    };
  }

  factory SketchElement.fromJson(Map<String, dynamic> json) {
    return SketchElement(
      id: json['id'],
      type: SketchElementType.values.firstWhere((e) => e.name == json['type']),
      position: Offset(json['position']['dx'], json['position']['dy']),
      text: json['text'],
      size: json['size'] != null
          ? Size(json['size']['width'], json['size']['height'])
          : null,
      points: json['points'] != null
          ? (json['points'] as List)
                .map((p) => Offset(p['dx'], p['dy']))
                .toList()
          : null,
    );
  }
}

// --- State ---

class CanvasState {
  final List<SketchElement> elements;
  final String? selectedElementId;

  CanvasState({this.elements = const [], this.selectedElementId});

  CanvasState copyWith({
    List<SketchElement>? elements,
    String? selectedElementId,
  }) {
    return CanvasState(
      elements: elements ?? this.elements,
      selectedElementId:
          selectedElementId, // Nullable, so we can't use ?? easily if we want to set it to null.
      // Actually for selectedElementId, if we pass null, it might mean "keep existing" or "clear".
      // Let's use a specific sentinel or just handle it carefully.
      // For now, let's assume if it's passed, we use it. But Dart optional params are null if omitted.
      // A common pattern is to use a wrapper or just separate methods.
      // Let's stick to: if passed, update. But how to clear?
      // Let's change copyWith to accept `ValueGetter` or just separate `select` method in notifier.
      // Simpler: `selectedElementId: selectedElementId ?? this.selectedElementId` prevents clearing.
      // Let's make it `String? selectedElementId` and if it's not passed (null), we keep old.
      // To clear, we need a way. Let's just expose specific methods in Notifier for selection.
      // Or use a wrapper object `Wrapped<T>` to distinguish "not passed" from "passed null".
      // For simplicity in this prototype, I'll just rebuild the state manually in the notifier when needed.
    );
  }
}

// --- Notifier ---

class CanvasNotifier extends Notifier<CanvasState> {
  @override
  CanvasState build() {
    return CanvasState();
  }

  // Temp buffer to avoid constant state updates
  List<Offset> _tempPoints = [];
  String? _currentDrawingId;

  // Resize throttling
  int _resizeUpdateCounter = 0;

  void resetCanvas() {
    state = CanvasState();
  }

  void addElement(SketchElementType type, Offset position) {
    final id = const Uuid().v4();
    String? initialText;
    Size? initialSize;

    switch (type) {
      case SketchElementType.text:
        initialText = 'Text';
        break;
      case SketchElementType.button:
        initialText = 'Button';
        break;
      case SketchElementType.input:
        initialText = 'Input';
        break;
      case SketchElementType.container:
        initialSize = const Size(100, 100);
        break;
      case SketchElementType.image:
        initialSize = const Size(100, 100);
        break;
      case SketchElementType.circle:
        initialSize = const Size(80, 80);
        break;
      case SketchElementType.freehand:
        // Freehand elements start with no size/points, points are added during drag
        break;
    }

    final newElement = SketchElement(
      id: id,
      type: type,
      position: position,
      text: initialText,
      size: initialSize,
      points: type == SketchElementType.freehand ? [position] : null,
    );

    state = CanvasState(
      elements: [...state.elements, newElement],
      selectedElementId: id, // Auto-select new element
    );
  }

  void updateElementPosition(String id, Offset newPosition) {
    state = CanvasState(
      elements: state.elements.map((e) {
        if (e.id == id) {
          return e.copyWith(position: newPosition);
        }
        return e;
      }).toList(),
      selectedElementId: state.selectedElementId,
    );
  }

  void selectElement(String? id) {
    state = CanvasState(elements: state.elements, selectedElementId: id);
  }

  void updateElementText(String id, String newText) {
    state = CanvasState(
      elements: state.elements.map((e) {
        if (e.id == id) {
          return e.copyWith(text: newText);
        }
        return e;
      }).toList(),
      selectedElementId: state.selectedElementId,
    );
  }

  void removeElement(String id) {
    state = CanvasState(
      elements: state.elements.where((e) => e.id != id).toList(),
      selectedElementId: state.selectedElementId == id
          ? null
          : state.selectedElementId,
    );
  }

  void duplicateElement(String id) {
    final element = state.elements.firstWhere((e) => e.id == id);
    final newId = const Uuid().v4();

    // Create a copy with a new ID and offset position
    final duplicatedElement = element.copyWith(
      id: newId,
      position: element.position + const Offset(20, 20),
    );

    state = CanvasState(
      elements: [...state.elements, duplicatedElement],
      selectedElementId: newId, // Auto-select the duplicated element
    );
  }

  void updateElementSize(ResizeHandlePosition position, Offset delta) {
    if (state.selectedElementId == null) return;

    // Throttle: only update every 3rd pointer move event
    _resizeUpdateCounter++;
    if (_resizeUpdateCounter % 3 != 0) return;
    final element = state.elements.firstWhere(
      (e) => e.id == state.selectedElementId!,
    );
    final currentSize = element.size!;
    final currentPos = element.position;

    double newWidth = currentSize.width;
    double newHeight = currentSize.height;
    double newX = currentPos.dx;
    double newY = currentPos.dy;

    switch (position) {
      case ResizeHandlePosition.topLeft:
        newWidth = (currentSize.width - delta.dx).clamp(20, double.infinity);
        newHeight = (currentSize.height - delta.dy).clamp(20, double.infinity);
        newX = currentPos.dx + (currentSize.width - newWidth);
        newY = currentPos.dy + (currentSize.height - newHeight);
        break;
      case ResizeHandlePosition.topCenter:
        newHeight = (currentSize.height - delta.dy).clamp(20, double.infinity);
        newY = currentPos.dy + (currentSize.height - newHeight);
        break;
      case ResizeHandlePosition.topRight:
        newWidth = (currentSize.width + delta.dx).clamp(20, double.infinity);
        newHeight = (currentSize.height - delta.dy).clamp(20, double.infinity);
        newY = currentPos.dy + (currentSize.height - newHeight);
        break;
      case ResizeHandlePosition.centerLeft:
        newWidth = (currentSize.width - delta.dx).clamp(20, double.infinity);
        newX = currentPos.dx + (currentSize.width - newWidth);
        break;
      case ResizeHandlePosition.centerRight:
        newWidth = (currentSize.width + delta.dx).clamp(20, double.infinity);
        break;
      case ResizeHandlePosition.bottomLeft:
        newWidth = (currentSize.width - delta.dx).clamp(20, double.infinity);
        newHeight = (currentSize.height + delta.dy).clamp(20, double.infinity);
        newX = currentPos.dx + (currentSize.width - newWidth);
        break;
      case ResizeHandlePosition.bottomCenter:
        newHeight = (currentSize.height + delta.dy).clamp(20, double.infinity);
        break;
      case ResizeHandlePosition.bottomRight:
        newWidth = (currentSize.width + delta.dx).clamp(20, double.infinity);
        newHeight = (currentSize.height + delta.dy).clamp(20, double.infinity);
        break;
    }

    state = state.copyWith(
      elements: state.elements.map((e) {
        if (e.id == state.selectedElementId!) {
          return e.copyWith(
            size: Size(newWidth, newHeight),
            position: Offset(newX, newY),
          );
        }
        return e;
      }).toList(),
    );
  }

  void startResize(ResizeHandlePosition position) {
    state = state.copyWith(selectedElementId: state.selectedElementId);
  }

  void endResize() {
    // Reset counter
    _resizeUpdateCounter = 0;
    state = state.copyWith(selectedElementId: state.selectedElementId);
  }

  void startFreehand(Offset startPoint) {
    // if (state.selectedElementId == null) return;

    final id = const Uuid().v4();
    _currentDrawingId = id;
    _tempPoints = [Offset.zero];
    final newElement = SketchElement(
      id: id,
      type: SketchElementType.freehand,
      position: startPoint,
      points: [Offset.zero],
    );

    state = CanvasState(
      elements: [...state.elements, newElement],
      selectedElementId: id,
    );
  }

  // void updateFreehand(Offset point) {
  //   if (state.selectedElementId == null) return;

  //   state = state.copyWith(
  //     elements: state.elements.map((e) {
  //       if (e.id == state.selectedElementId && e.type == SketchElementType.freehand) {
  //         final relativePoint = point - e.position;
  //         return e.copyWith(
  //           points: [...?e.points, relativePoint],
  //         );
  //       }
  //       return e;
  //     }).toList(),
  //   );
  // }

  void updateFreehand(Offset point) {
    if (_currentDrawingId == null) return;

    final currentElement = state.elements.firstWhere(
      (e) => e.id == _currentDrawingId,
    );

    final relativePoint = point - currentElement.position;

    // Distance check - only add if moved enough
    if (_tempPoints.isEmpty ||
        (relativePoint - _tempPoints.last).distance > 2.0) {
      _tempPoints.add(relativePoint);

      // Update every 5 points instead of every 3
      if (_tempPoints.length % 5 == 0) {
        _updateCurrentElement();
      }
    }
  }

  void _updateCurrentElement() {
    state = state.copyWith(
      elements: state.elements.map((e) {
        if (e.id == _currentDrawingId) {
          return e.copyWith(points: List.from(_tempPoints));
        }
        return e;
      }).toList(),
    );
  }

  void endFreehand() {
    if (_currentDrawingId == null) return;

    // Calculate bounding box
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final point in _tempPoints) {
      if (point.dx < minX) minX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy > maxY) maxY = point.dy;
    }

    // Handle single point case
    if (minX == double.infinity) {
      minX = 0;
      minY = 0;
      maxX = 0;
      maxY = 0;
    }

    // Add some padding
    // minX -= 2;
    // minY -= 2;
    // maxX += 2;
    // maxY += 2;

    final boundsOffset = Offset(minX, minY);
    final size = Size(maxX - minX, maxY - minY);

    // Normalize points
    final normalizedPoints = _tempPoints.map((p) => p - boundsOffset).toList();

    // Final update with all points and new bounds
    state = state.copyWith(
      elements: state.elements.map((e) {
        if (e.id == _currentDrawingId) {
          return e.copyWith(
            position: e.position + boundsOffset,
            size: size,
            points: normalizedPoints,
          );
        }
        return e;
      }).toList(),
    );

    // Clean up
    _tempPoints = [];
    _currentDrawingId = null;
  }
}

// --- Provider ---

final canvasProvider = NotifierProvider<CanvasNotifier, CanvasState>(() {
  return CanvasNotifier();
});
