import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Canvas settings state
class CanvasSettings {
  final bool showGrid;
  final bool snapToGrid;
  final double gridSize;

  const CanvasSettings({
    this.showGrid = false,
    this.snapToGrid = false,
    this.gridSize = 20.0,
  });

  CanvasSettings copyWith({
    bool? showGrid,
    bool? snapToGrid,
    double? gridSize,
  }) {
    return CanvasSettings(
      showGrid: showGrid ?? this.showGrid,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      gridSize: gridSize ?? this.gridSize,
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
}

/// Canvas settings provider
final canvasSettingsProvider =
    NotifierProvider<CanvasSettingsNotifier, CanvasSettings>(() {
      return CanvasSettingsNotifier();
    });
