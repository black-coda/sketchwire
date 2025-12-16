import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sketchwire/theme/utils.dart' show fontOptions;
import 'package:sketchy_design_lang/sketchy_design_lang.dart';
import '../theme/theme_config_state_notifier.dart';
import '../state/canvas_settings_state.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(sketchWireThemeConfigProvider);
    final sketchyThemes = ref.watch(sketchyThemesProvider);

    return SketchyTheme.consumer(
      builder: (context, theme) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: SketchyCard(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SketchyText(
                          'Settings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SketchyIconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(LucideIcons.x),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Canvas Settings
                            _buildSectionTitle('Canvas Settings'),
                            const SizedBox(height: 12),
                            _buildSettingRow(
                              context,
                              title: 'Show Grid',
                              description: 'Display alignment grid on canvas',
                              trailing: _SketchySwitch(
                                value: ref
                                    .watch(canvasSettingsProvider)
                                    .showGrid,
                                onChanged: (v) {
                                  ref
                                      .read(canvasSettingsProvider.notifier)
                                      .toggleShowGrid();
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSettingRow(
                              context,
                              title: 'Snap to Grid',
                              description: 'Auto-align elements to grid',
                              trailing: _SketchySwitch(
                                value: ref
                                    .watch(canvasSettingsProvider)
                                    .snapToGrid,
                                onChanged: (v) {
                                  ref
                                      .read(canvasSettingsProvider.notifier)
                                      .toggleSnapToGrid();
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSettingRow(
                              context,
                              title: 'Grid Size',
                              description: 'Spacing between grid lines',
                              trailing: SizedBox(
                                width: 80,
                                child: SketchyTextField(
                                  controller: TextEditingController(
                                    text: ref
                                        .watch(canvasSettingsProvider)
                                        .gridSize
                                        .toStringAsFixed(0),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    if (v.isEmpty) return;
                                    final size = double.tryParse(v);
                                    if (size != null &&
                                        size >= 10 &&
                                        size <= 100) {
                                      ref
                                          .read(canvasSettingsProvider.notifier)
                                          .updateGridSize(size);
                                    }
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Design Preferences
                            _buildSectionTitle('Design Preferences'),
                            const SizedBox(height: 12),
                            _buildSettingRow(
                              context,
                              title: 'Theme',
                              description: 'Interface color scheme',
                              trailing: _ThemeSelector(),
                            ),
                            const SizedBox(height: 12),
                            _buildSettingRow(
                              context,
                              title: 'Roughness',
                              description: 'Hand-drawn sketch intensity',
                              trailing: SizedBox(
                                width: 150,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SketchySlider(
                                        value: themeConfig.themeData.roughness,
                                        onChanged: (v) {
                                          ref
                                              .read(
                                                sketchWireThemeConfigProvider
                                                    .notifier,
                                              )
                                              .updateRoughness(v);
                                        },
                                        min: 0.0,
                                        max: 1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 35,
                                      child: SketchyText(
                                        themeConfig.themeData.roughness
                                            .toStringAsFixed(2),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSettingRow(
                              context,
                              title: 'Default Font',
                              description: 'Font for new text elements',
                              trailing: SketchyDropdownButton<String>(
                                value: themeConfig
                                    .themeData
                                    .typography
                                    .body
                                    .fontFamily,
                                items: fontOptions.entries
                                    .map(
                                      (entry) =>
                                          SketchyDropdownMenuItem<String>(
                                            value: entry.value,
                                            child: SketchyText(
                                              entry.key,
                                              style: theme.typography.body,
                                            ),
                                          ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    ref
                                        .read(
                                          sketchWireThemeConfigProvider
                                              .notifier,
                                        )
                                        .updateFontFamily(value, sketchyThemes);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return SketchyText(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required String title,
    required String description,
    required Widget trailing,
  }) {
    return SketchyTheme.consumer(
      builder: (context, theme) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SketchyText(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    SketchyText(
                      description,
                      style: TextStyle(
                        color: theme.textColor.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              trailing,
            ],
          ),
        );
      },
    );
  }
}

class _SketchySwitch extends ConsumerWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SketchySwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(sketchWireThemeConfigProvider).themeMode;
    final isDark =
        themeMode == SketchyThemeMode.dark ||
        (themeMode == SketchyThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value
              ? SketchyTheme.of(context).primaryColor
              : SketchyTheme.of(context).borderColor.withValues(alpha: 0.3),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: value ? 22 : 2,
              top: 2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? SketchyTheme.of(context).textColor
                      : const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(sketchWireThemeConfigProvider);
    final mode = themeState.themeMode;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          context,
          ref,
          'Light',
          SketchyThemeMode.light,
          mode == SketchyThemeMode.light,
        ),
        const SizedBox(width: 4),
        _buildButton(
          context,
          ref,
          'Dark',
          SketchyThemeMode.dark,
          mode == SketchyThemeMode.dark,
        ),
        const SizedBox(width: 4),
        _buildButton(
          context,
          ref,
          'System',
          SketchyThemeMode.system,
          mode == SketchyThemeMode.system,
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    SketchyThemeMode mode,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(sketchWireThemeConfigProvider.notifier).updateThemeMode(mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? SketchyTheme.of(context).primaryColor
              : SketchyTheme.of(context).borderColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: SketchyText(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected
                ? SketchyTheme.of(context).paperColor
                : SketchyTheme.of(context).textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
