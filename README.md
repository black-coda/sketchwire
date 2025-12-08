# SketchWire

A Flutter-based wireframing and sketching application with a hand-drawn aesthetic. Create UI mockups and sketches with a unique, sketchy design language.

![Flutter](https://img.shields.io/badge/Flutter-3.10.1+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.10.1+-blue.svg)
![License](https://img.shields.io/badge/license-Private-red.svg)

## 🎨 Features

### Core Functionality
- **Interactive Canvas**: Drag-and-drop interface for placing UI elements
- **Element Library**: Pre-built components including:
  - Text labels
  - Buttons
  - Input fields
  - Containers (rectangles)
  - Circles
  - Freehand drawing
- **Element Manipulation**:
  - Drag to reposition elements
  - 8-point resize handles (corners, edges, centers)
  - Selection and deletion
  - Text editing (double-click to edit)
- **Drawing Mode**: Freehand sketching with pen tool
- **Grid System**:
  - Toggleable grid overlay
  - Snap-to-grid functionality
  - Configurable grid size

### Design Aesthetics
- **Sketchy Design Language**: Hand-drawn, rough aesthetic using `rough_flutter`
- **Custom Cursors**: Context-aware cursors (pen for drawing, resize arrows, etc.)
- **Smooth Interactions**: Optimized rendering with throttled updates and repaint boundaries

## 🏗️ Architecture

### State Management
Built with **Riverpod** for reactive state management:

- `CanvasState`: Manages canvas elements and selection
- `CanvasSettings`: Controls grid, snap-to-grid, and drawing mode
- `ThemeConfig`: Manages sketchy theme configuration

### Project Structure

```
lib/
├── app/                    # App entry point and configuration
├── main.dart              # Application entry
├── models/                # Data models
├── screens/               # Main application screens
├── services/              # Business logic services
├── state/                 # Riverpod state management
│   ├── canvas_state.dart           # Canvas element state
│   └── canvas_settings_state.dart  # Canvas settings
├── theme/                 # Theme configuration
│   └── theme_config_state_notifier.dart
├── ui/                    # UI components
│   ├── canvas_view.dart            # Main canvas
│   ├── element_renderer.dart       # Element rendering
│   ├── grid_painter.dart           # Grid overlay
│   ├── resizeable_element.dart     # Resize handles
│   ├── selection_toolbar.dart      # Element toolbar
│   ├── settings_view.dart          # Settings panel
│   └── toolbar_view.dart           # Element toolbar
└── widgets/               # Reusable widgets
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.1 or higher
- Dart SDK 3.10.1 or higher

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sketchwire
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

   For specific platforms:
   ```bash
   flutter run -d linux    # Linux
   flutter run -d macos    # macOS
   flutter run -d windows  # Windows
   flutter run -d chrome   # Web
   ```

## 📖 Usage Guide

### Basic Workflow

1. **Adding Elements**
   - Drag elements from the left toolbar onto the canvas
   - Elements will snap to grid if snap-to-grid is enabled

2. **Selecting Elements**
   - Click on any element to select it
   - Selected elements show resize handles and a toolbar

3. **Resizing Elements**
   - Drag any of the 8 resize handles
   - Maintains minimum size of 20x20 pixels

4. **Moving Elements**
   - Click and drag selected elements
   - Respects snap-to-grid when enabled

5. **Editing Text**
   - Double-click text or button elements to edit
   - Press Enter to confirm changes

6. **Freehand Drawing**
   - Click the "Free Sketch" button in the toolbar
   - Draw freely on the canvas with the pen cursor
   - Click "Free Sketch" again to exit drawing mode

7. **Deleting Elements**
   - Select an element and click the delete button in the toolbar
   - Or use the keyboard shortcut (if implemented)

### Settings

Access settings via the settings panel:
- **Show Grid**: Toggle grid visibility
- **Snap to Grid**: Enable/disable snap-to-grid
- **Grid Size**: Adjust grid spacing (default: 20px)
- **Theme**: Switch between light/dark modes
- **Roughness**: Adjust the sketchiness of elements

## 🛠️ Key Technologies

### Dependencies

- **flutter_riverpod** (^3.0.3): State management
- **rough_flutter** (^0.1.2): Hand-drawn graphics rendering
- **sketchy_design_lang**: Custom sketchy UI components
- **lucide_icons_flutter** (^3.1.6): Icon library
- **custom_mouse_cursor** (^1.1.3): Custom cursor support
- **uuid** (^4.0.0): Unique ID generation
- **google_fonts** (^6.3.2): Typography

### Performance Optimizations

1. **Throttled Resize Updates**: Updates state every 3rd pointer event during resize (reduces from ~60 to ~20 updates/sec)
2. **RepaintBoundary**: Isolates element repaints to prevent cascading rebuilds
3. **Buffered Freehand Drawing**: Accumulates points and updates state periodically

## 🎯 Development

### Code Style

This project follows Flutter's official style guide and uses:
- `flutter_lints` for code quality
- `riverpod_lint` for Riverpod best practices
- `custom_lint` for additional linting rules

### Running Lints

```bash
flutter analyze
```

### Testing

```bash
flutter test
```

## 🐛 Known Issues & Limitations

- Undo/Redo functionality not yet implemented
- No persistence (elements are lost on app restart)
- Limited export options
- Single canvas only (no multi-page support)

## 🗺️ Roadmap

- [ ] Undo/Redo functionality
- [ ] Save/Load projects (JSON serialization)
- [ ] Export to PNG/SVG
- [ ] Multi-page support
- [ ] Component library
- [ ] Collaboration features
- [ ] Mobile support optimization

## 📝 License

This project is private and not licensed for public use.

## 🤝 Contributing

This is a private project. Contributions are not currently accepted.

## 📧 Contact

For questions or feedback, please contact the project maintainer.

---

**Built with ❤️ using Flutter and the Sketchy Design Language**
