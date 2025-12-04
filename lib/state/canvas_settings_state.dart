import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Canvas settings state
class CanvasSettings {
  final bool showGrid;
  final bool snapToGrid;
  final double gridSize;
  final bool isDrawingMode;

  const CanvasSettings({
    this.showGrid = false,
    this.snapToGrid = false,
    this.gridSize = 20.0,
    this.isDrawingMode = false,
  });

  CanvasSettings copyWith({
    bool? showGrid,
    bool? snapToGrid,
    double? gridSize,
    bool? isDrawingMode,
  }) {
    return CanvasSettings(
      showGrid: showGrid ?? this.showGrid,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      gridSize: gridSize ?? this.gridSize,
      isDrawingMode: isDrawingMode ?? this.isDrawingMode,
    );
  }
}

/// Canvas settings notifier
class CanvasSettingsNotifier extends Notifier<CanvasSettings> {
  @override
  CanvasSettings build() => const CanvasSettings();

  void toggleShowGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }

  void toggleSnapToGrid() {
    state = state.copyWith(snapToGrid: !state.snapToGrid);
  }

  void updateGridSize(double size) {
    state = state.copyWith(gridSize: size);
  }

  void toggleDrawingMode() {
    state = state.copyWith(isDrawingMode: !state.isDrawingMode);
  }
}

/// Canvas settings provider
final canvasSettingsProvider =
    NotifierProvider<CanvasSettingsNotifier, CanvasSettings>(() {
      return CanvasSettingsNotifier();
    });
