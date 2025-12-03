import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sketchwire/ui/resizeable_element.dart';
import 'package:uuid/uuid.dart';

// --- Models ---

enum SketchElementType { text, button, input, container, image, circle }

class SketchElement {
  final String id;
  final SketchElementType type;
  final Offset position;
  final String? text;
  final Size? size; // For container, image, circle
  // Add more properties as needed (color, style, etc.)

  SketchElement({
    required this.id,
    required this.type,
    required this.position,
    this.text,
    this.size,
  });

  SketchElement copyWith({
    String? id,
    SketchElementType? type,
    Offset? position,
    String? text,
    Size? size,
  }) {
    return SketchElement(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      text: text ?? this.text,
      size: size ?? this.size,
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
    }

    final newElement = SketchElement(
      id: id,
      type: type,
      position: position,
      text: initialText,
      size: initialSize,
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

  void updateElementSize(ResizeHandlePosition position, Offset delta) {
    if (state.selectedElementId == null) return;
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
            // position: Offset(newX, newY),
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
    state = state.copyWith(selectedElementId: state.selectedElementId);
  }
}

// --- Provider ---

final canvasProvider = NotifierProvider<CanvasNotifier, CanvasState>(() {
  return CanvasNotifier();
});
