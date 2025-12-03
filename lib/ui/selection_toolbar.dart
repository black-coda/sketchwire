import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';
import '../state/canvas_state.dart';

class SelectionToolbar extends ConsumerWidget {
  final String elementId;

  const SelectionToolbar({super.key, required this.elementId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SketchyTheme.consumer(
      builder: (context, theme) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionButton(
              icon: LucideIcons.pencil,
              label: 'Edit',
              onPressed: () {
                log('Edit');
                // TODO: Handle edit
              },
            ),
            _ActionButton(
              icon: LucideIcons.copy,
              label: 'Copy',
              onPressed: () {
                log('Copy');
                // TODO: Handle duplicate
              },
            ),
            _ActionButton(
              icon: LucideIcons.trash2,
              label: 'Delete',
              onPressed: () {
                final notifier = ref.read(canvasProvider.notifier);
                // We need to check if the element is still selected/exists before removing
                // But here we just call remove.
                notifier.removeElement(elementId);
              },
              isDestructive: true,
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SketchyTheme.consumer(
      builder: (context, theme) {
        return SketchyTooltip(
          message: label,
          child: SketchyIconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: 16),
            iconSize: 32, // Slightly larger touch target
            padding: const EdgeInsets.all(4),
            color: isDestructive ? theme.errorColor : theme.primaryColor,
          ),
        );
      },
    );
  }
}
