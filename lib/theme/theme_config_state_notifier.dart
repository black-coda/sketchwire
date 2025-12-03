import 'package:flutter/foundation.dart' show Brightness;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

// state

class SketchWireThemeState {
  final SketchyThemeData themeData;
  final SketchyThemeMode themeMode;

  SketchWireThemeState({required this.themeData, required this.themeMode});

  // create copywith method

  /// Returns a new theme with the provided overrides.
  SketchWireThemeState copyWith({
    SketchyThemeData? themeData,
    SketchyThemeMode? themeMode,
  }) => SketchWireThemeState(
    themeData: themeData ?? this.themeData,
    themeMode: themeMode ?? this.themeMode,
  );
}

class SketchWireThemeConfigNotifier
    extends StateNotifier<SketchWireThemeState> {
  SketchWireThemeConfigNotifier(this.ref)
    : super(
        SketchWireThemeState(
          themeData: SketchyThemeData.fromTheme(
            ref.read(sketchyThemesProvider),
            roughness: 0.5,
            textCase: TextCase.titleCase,
            brightness: Brightness.light,
          ),
          themeMode: SketchyThemeMode.system,
        ),
      );

  final Ref ref;

  void updateRoughness(double value) {
    state = state.copyWith(
      themeData: state.themeData.copyWith(roughness: value),
    );
  }

  void updateStrokeWidth(double value) {
    state = state.copyWith(
      themeData: state.themeData.copyWith(strokeWidth: value),
    );
  }

  void updateTheme(SketchyThemes theme) {
    final brightness = state.themeMode == SketchyThemeMode.dark
        ? Brightness.dark
        : Brightness.light;
    final data = SketchyThemeData.fromTheme(
      theme,
      roughness: state.themeData.roughness,
      brightness: brightness,
      textCase: state.themeData.textCase,
    );
    state = state.copyWith(themeMode: state.themeMode, themeData: data);
  }

  void updateFontFamily(String fontFamily, SketchyThemes theme) {
    final brightness = state.themeMode == SketchyThemeMode.dark
        ? Brightness.dark
        : Brightness.light;
    final data = SketchyThemeData.fromTheme(
      theme,
      roughness: state.themeData.roughness,
      brightness: brightness,
      textCase: state.themeData.textCase,
    );

    state = state.copyWith(
      themeData: state.themeData.copyWith(
        typography: data.typography.copyWith(
          headline: data.typography.headline.copyWith(fontFamily: fontFamily),
          title: data.typography.title.copyWith(fontFamily: fontFamily),
          body: data.typography.body.copyWith(fontFamily: fontFamily),
          caption: data.typography.caption.copyWith(fontFamily: fontFamily),
          label: data.typography.label.copyWith(fontFamily: fontFamily),
        ),
      ),
    );
  }

  void updateTextCase(TextCase textCase) {
    state = state.copyWith(
      themeData: state.themeData.copyWith(textCase: textCase),
    );
  }

  void updateThemeMode(SketchyThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }
}

// state provider

final sketchWireThemeConfigProvider =
    StateNotifierProvider<SketchWireThemeConfigNotifier, SketchWireThemeState>((
      ref,
    ) {
      return SketchWireThemeConfigNotifier(ref);
    });

class SketchyThemesNotifier extends StateNotifier<SketchyThemes> {
  SketchyThemesNotifier() : super(SketchyThemes.monochrome);

  void update(SketchyThemes value) {
    state = value;
  }
}

final sketchyThemesProvider =
    StateNotifierProvider<SketchyThemesNotifier, SketchyThemes>((ref) {
      return SketchyThemesNotifier();
    });
