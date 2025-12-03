import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';
import '../state/canvas_state.dart';
import 'resizeable_element.dart';

class ElementRenderer extends ConsumerStatefulWidget {
  final SketchElement element;
  final bool isSelected;

  const ElementRenderer({
    super.key,
    required this.element,
    this.isSelected = false,
  });

  @override
  ConsumerState<ElementRenderer> createState() => _ElementRendererState();
}

class _ElementRendererState extends ConsumerState<ElementRenderer> {
  bool _isEditing = false;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.element.text);
  }

  @override
  void didUpdateWidget(covariant ElementRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.element.text != oldWidget.element.text && !_isEditing) {
      _textController.text = widget.element.text ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _enableEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _submitEdit() {
    ref
        .read(canvasProvider.notifier)
        .updateElementText(widget.element.id, _textController.text);
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isEditing &&
        (widget.element.type == SketchElementType.text ||
            widget.element.type == SketchElementType.button)) {
      return SizedBox(
        width: 200,
        child: SketchyTextField(
          controller: _textController,
          autofocus: true,
          onSubmitted: (_) => _submitEdit(),
        ),
      );
    }

    switch (widget.element.type) {
      case SketchElementType.text:
        child = GestureDetector(
          onDoubleTap: _enableEditing,
          child: SketchyText(
            widget.element.text ?? 'Text',
            style: const TextStyle(fontSize: 20),
          ),
        );
        break;
      case SketchElementType.button:
        child = GestureDetector(
          onDoubleTap: _enableEditing,
          child: SketchyButton(
            onPressed: () {
              log("Button Pressed");
            },
            child: SketchyText(widget.element.text ?? 'Button'),
          ),
        );
        break;
      case SketchElementType.input:
        child = SizedBox(
          width: 200,
          child: SketchyTextField(
            controller: TextEditingController(text: widget.element.text),
            onChanged: (value) {
              ref
                  .read(canvasProvider.notifier)
                  .updateElementText(widget.element.id, value);
            },
          ),
        );
        break;
      case SketchElementType.container:
        child = SketchyTheme.consumer(
          builder: (context, theme) {
            return SketchySurface(
              width: widget.element.size?.width ?? 100,
              height: widget.element.size?.height ?? 100,
              strokeColor: theme.inkColor,
              fillColor: theme.paperColor,
              createPrimitive: () =>
                  SketchyPrimitive.rectangle(fill: SketchyFill.hachure),
              child: const SizedBox(),
            );
          },
        );

        break;
      case SketchElementType.image:
        child = SketchyTheme.consumer(
          builder: (context, theme) {
            return Container(
              width: widget.element.size?.width ?? 100,
              height: widget.element.size?.height ?? 100,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.primaryColor,
                ), // TODO: Make sketchy
              ),
              child: const Center(child: SketchyText('IMG')),
            );
          },
        );
        break;
      case SketchElementType.circle:
        child = SketchyTheme.consumer(
          builder: (context, theme) {
            return SketchySurface(
              width: widget.element.size?.width ?? 100,
              height: widget.element.size?.height ?? 100,
              strokeColor: theme.inkColor,
              fillColor: theme.paperColor,

              createPrimitive: () =>
                  SketchyPrimitive.circle(fill: SketchyFill.hachure),
              child: const SizedBox(),
            );
          },
        );
        break;
    }

    // Wrap with selection indicator if selected
    if (widget.isSelected) {
      return widget.isSelected && widget.element.size != null
          ? ResizableElement(element: widget.element, child: child)
          : child;
    }

    return child;
  }
}
