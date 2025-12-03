import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sketchwire/theme/utils.dart' show fontOptions;
import 'package:sketchy_design_lang/sketchy_design_lang.dart';
import '../theme/theme_config_state_notifier.dart';
import '../state/canvas_settings_state.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': LucideIcons.layoutGrid, 'label': 'Canvas Settings'},
    {'icon': LucideIcons.settings2, 'label': 'Default Properties'},
    {'icon': LucideIcons.palette, 'label': 'Design Preferences'},
    {'icon': LucideIcons.panelLeft, 'label': 'Toolbar Preferences'},
    {'icon': LucideIcons.download, 'label': 'Export Settings'},
    {'icon': LucideIcons.mousePointer2, 'label': 'Workspace Behavior'},
    {'icon': LucideIcons.keyboard, 'label': 'Keyboard Shortcuts'},
  ];

  @override
  void initState() {
    super.initState();
    for (var item in _menuItems) {
      _sectionKeys[item['label']] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String label) {
    final key = _sectionKeys[label];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1, // Slight offset from top
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(sketchWireThemeConfigProvider);
    final sketchyThemes = ref.watch(sketchyThemesProvider);

    return SketchyTheme.consumer(
      builder: (context, theme) {
        return SketchyScaffold(
          body: Row(
            children: [
              // Sidebar
              SketchyCard(
                child: Container(
                  width: 250,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // User Profile Stub
                      const _UserProfileStub(),
                      const SizedBox(height: 32),
                      // Menu Items
                      Expanded(
                        child: ListView.builder(
                          itemCount: _menuItems.length,
                          itemBuilder: (context, index) {
                            final item = _menuItems[index];
                            final isSelected = _selectedIndex == index;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedIndex = index);
                                _scrollToSection(item['label']);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                color: isSelected
                                    ? theme.primaryColor.withValues(alpha: 0.1)
                                    : const Color(0x00000000),
                                child: Row(
                                  children: [
                                    Icon(
                                      item['icon'],
                                      size: 20,
                                      color: isSelected
                                          ? theme.primaryColor
                                          : theme.textColor.withValues(
                                              alpha: 0.6,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    SketchyText(
                                      item['label'],
                                      style: TextStyle(
                                        color: isSelected
                                            ? theme.primaryColor
                                            : theme.textColor.withValues(
                                                alpha: 0.6,
                                              ),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Log Out
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.logOut,
                                size: 20,
                                color: theme.textColor.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 12),
                              SketchyText(
                                'Log Out',
                                style: TextStyle(
                                  color: theme.textColor.withValues(alpha: 0.6),
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

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          const SketchyText(
                            'Settings',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SketchyButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(LucideIcons.arrowBigLeft400),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      _buildSectionTitle(
                        'Canvas Settings',
                        key: _sectionKeys['Canvas Settings'],
                      ),
                      _buildSettingCard(
                        title: 'Show grid',
                        description:
                            'Display a grid on the canvas for alignment.',
                        trailing: _SketchySwitch(
                          value: ref.watch(canvasSettingsProvider).showGrid,
                          onChanged: (v) {
                            ref
                                .read(canvasSettingsProvider.notifier)
                                .toggleShowGrid();
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingCard(
                        title: 'Snap to grid',
                        description:
                            'Automatically align elements to the nearest grid line.',
                        trailing: _SketchySwitch(
                          value: ref.watch(canvasSettingsProvider).snapToGrid,
                          onChanged: (v) {
                            ref
                                .read(canvasSettingsProvider.notifier)
                                .toggleSnapToGrid();
                          },
                        ),
                      ),

                      const SizedBox(height: 40),
                      _buildSectionTitle(
                        'Default Element Properties',
                        key: _sectionKeys['Default Properties'],
                      ),
                      _buildSettingCard(
                        title: 'Default Roughness',
                        description: 'The hand-drawn feel of new elements.',
                        trailing: SizedBox(
                          width: 200,
                          child: Row(
                            children: [
                              Expanded(
                                child: _SketchySlider(
                                  value: themeConfig.themeData.roughness,
                                  onChanged: (v) {
                                    ref
                                        .read(
                                          sketchWireThemeConfigProvider
                                              .notifier,
                                        )
                                        .updateRoughness(v);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              SketchyText(
                                themeConfig.themeData.roughness.toStringAsFixed(
                                  2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingCard(
                        title: 'Default Stroke Width',
                        description: 'The thickness of lines for new shapes.',
                        trailing: SizedBox(
                          width: 60,
                          child: SketchyTextField(
                            controller: TextEditingController(
                              text: themeConfig.themeData.strokeWidth
                                  .toStringAsFixed(2),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              if (v.isEmpty) return;
                              if (double.parse(v) < 0) return;
                              if (double.parse(v) > 10) return;
                              ref
                                  .read(sketchWireThemeConfigProvider.notifier)
                                  .updateStrokeWidth(double.parse(v));
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      _buildSectionTitle(
                        'Design Preferences',
                        key: _sectionKeys['Design Preferences'],
                      ),
                      _buildSettingCard(
                        title: 'Theme',
                        description: 'Choose your preferred interface theme.',
                        trailing: _ThemeSelector(),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingCard(
                        title: 'Default Font',
                        description: 'The font used for new text elements.',
                        trailing: SketchyDropdownButton<String>(
                          value:
                              themeConfig.themeData.typography.body.fontFamily,
                          items: fontOptions.entries
                              .map(
                                (entry) => SketchyDropdownMenuItem<String>(
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
                                  .read(sketchWireThemeConfigProvider.notifier)
                                  .updateFontFamily(value, sketchyThemes);
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 40),
                      _buildSectionTitle(
                        'Keyboard Shortcuts',
                        key: _sectionKeys['Keyboard Shortcuts'],
                      ),
                      SketchySurface(
                        padding: const EdgeInsets.all(24),
                        strokeWidth: .8,
                        strokeColor: theme.borderColor,
                        child: Column(
                          children: [
                            _buildShortcutRow(
                              'Copy',
                              'Ctrl + C',
                              'Paste',
                              'Ctrl + V',
                            ),
                            const SizedBox(height: 16),
                            _buildShortcutRow(
                              'Cut',
                              'Ctrl + X',
                              'Undo',
                              'Ctrl + Z',
                            ),
                            const SizedBox(height: 16),
                            _buildShortcutRow(
                              'Group',
                              'Ctrl + G',
                              'Ungroup',
                              'Ctrl + Shift + G',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 16),
      child: SketchyText(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String description,
    required Widget trailing,
  }) {
    return SketchySurface(
      padding: const EdgeInsets.all(24),
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: SketchyTheme.of(context).primaryColor.withValues(alpha: 0.2),
      //   ),
      //   borderRadius: BorderRadius.circular(12),
      // ),
      child: SketchyTheme.consumer(
        builder: (context, theme) {
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SketchyText(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    SketchyText(
                      description,
                      style: TextStyle(
                        color: theme.textColor.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              trailing,
            ],
          );
        },
      ),
    );
  }

  Widget _buildShortcutRow(
    String label1,
    String key1,
    String label2,
    String key2,
  ) {
    return Row(
      children: [
        Expanded(child: _buildShortcutItem(label1, key1)),
        const SizedBox(width: 32),
        Expanded(child: _buildShortcutItem(label2, key2)),
      ],
    );
  }

  Widget _buildShortcutItem(String label, String key) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SketchyText(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: SketchyTheme.of(context).borderColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: SketchyText(
            key,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
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

class _SketchySlider extends ConsumerWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _SketchySlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SketchyTheme.consumer(
      builder: (context, theme) {
        return SketchySlider(
          value: value,
          onChanged: onChanged,
          min: 0.0,
          max: 1.0,
        );
      },
    );
  }
}

class _UserProfileStub extends StatelessWidget {
  const _UserProfileStub();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SketchyTheme.of(
                context,
              ).primaryColor.withValues(alpha: 0.1),
            ),
            child: const Icon(LucideIcons.user, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SketchyText(
                'Alex Drake',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SketchyText(
                'alex.d@sketchwire.io',
                style: TextStyle(
                  fontSize: 12,
                  color: SketchyTheme.of(
                    context,
                  ).textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(sketchWireThemeConfigProvider);
    final mode = themeState.themeMode;
    final isDark =
        mode == SketchyThemeMode.dark ||
        (mode == SketchyThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return SketchySurface(
      fillColor: isDark
          ? SketchyTheme.of(context).primaryColor
          : SketchyTheme.of(context).paperColor,
      strokeColor: SketchyTheme.of(context).borderColor.withValues(alpha: 0.1),
      strokeWidth: 1.5,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            context,
            ref,
            'Light',
            SketchyThemeMode.light,
            mode == SketchyThemeMode.light,
            isDark,
          ),
          _buildButton(
            context,
            ref,
            'Dark',
            SketchyThemeMode.dark,
            mode == SketchyThemeMode.dark,
            isDark,
          ),
          _buildButton(
            context,
            ref,
            'System',
            SketchyThemeMode.system,
            mode == SketchyThemeMode.system,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    SketchyThemeMode mode,
    bool isSelected,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(sketchWireThemeConfigProvider.notifier).updateThemeMode(mode);
      },
      child: SketchySurface(
        fillColor: isSelected
            ? SketchyTheme.of(context).primaryColor
            : SketchyTheme.of(context).paperColor,
        strokeColor: isSelected
            ? SketchyTheme.of(context).primaryColor
            : Color(0xff000000),
        strokeWidth: isSelected ? 2.5 : 1.5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SketchyText(
          label,
          style: TextStyle(
            // color: isSelected
            //     ? (isDark
            //           ? SketchyTheme.of(context).textColor
            //           : const Color(0xFFFFFFFF))
            //     : SketchyTheme.of(context).textColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
