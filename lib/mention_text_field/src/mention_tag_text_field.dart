import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/mention_text_field/mention_tag_text_field.dart';

class MentionTagTextField extends TextField {
  MentionTagTextField({
    super.key,
    TextEditingController? controller,
    this.initialMentions = const [],
    this.onMention,
    this.mentionTagDecoration = const MentionTagDecoration(),
    super.focusNode,
    super.undoController,
    super.decoration = const InputDecoration(),
    TextInputType? keyboardType,
    super.textInputAction,
    super.textCapitalization = TextCapitalization.none,
    super.style,
    super.strutStyle,
    super.textAlign = TextAlign.start,
    super.textAlignVertical,
    super.textDirection,
    super.readOnly = false,
    @Deprecated(
      'Use `contextMenuBuilder` instead. '
      'This feature was deprecated after v3.3.0-0.5.pre.',
    )
    super.toolbarOptions,
    super.showCursor,
    super.autofocus = false,
    super.statesController,
    super.obscuringCharacter = '•',
    super.obscureText = false,
    super.autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    super.enableSuggestions = true,
    super.maxLines = 1,
    super.minLines,
    super.expands = false,
    super.maxLength,
    super.maxLengthEnforcement,
    void Function(String)? onChanged,
    super.onEditingComplete,
    super.onSubmitted,
    super.onAppPrivateCommand,
    super.inputFormatters,
    super.enabled,
    super.cursorWidth = 2.0,
    super.cursorHeight,
    super.cursorRadius,
    super.cursorOpacityAnimates,
    super.cursorColor,
    super.cursorErrorColor,
    super.selectionHeightStyle = ui.BoxHeightStyle.tight,
    super.selectionWidthStyle = ui.BoxWidthStyle.tight,
    super.keyboardAppearance,
    super.scrollPadding = const EdgeInsets.all(20.0),
    super.dragStartBehavior = DragStartBehavior.start,
    bool? enableInteractiveSelection,
    super.selectionControls,
    super.onTap,
    super.onTapAlwaysCalled = false,
    super.onTapOutside,
    super.mouseCursor,
    super.buildCounter,
    super.scrollController,
    super.scrollPhysics,
    super.autofillHints = const <String>[],
    super.contentInsertionConfiguration,
    super.clipBehavior = Clip.hardEdge,
    super.restorationId,
    super.scribbleEnabled = true,
    super.enableIMEPersonalizedLearning = true,
    super.contextMenuBuilder = _defaultContextMenuBuilder,
    super.canRequestFocus = true,
    super.spellCheckConfiguration,
    super.magnifierConfiguration,
  }) : super(
            controller: controller,
            onChanged: (value) {
              if (controller is MentionTagTextEditingController?) {
                try {
                  controller?.onChanged(value);
                  onChanged?.call(value);
                } catch (e, s) {
                  debugPrint(e.toString());
                  debugPrint(s.toString());
                }
              } else {
                onChanged?.call(value);
              }
            }) {
    if (controller is MentionTagTextEditingController?) {
      _setControllerProperties(controller, initialMentions);
    }
  }

  /// Provides the mention value whenever a mention is initiated, indicated by the mention start character
  /// (e.g., "@"), and ends when a space character is encountered.
  final void Function(String?)? onMention;

  /// Indicates the decoration related to mentions or tags
  final MentionTagDecoration mentionTagDecoration;

  /// Initial list of mentions which are present in the initial text set to textfield using _controller.text setter.
  ///
  /// Each mention in the list should be a tuple with first value as mention label present in the textfield and second value is the data associated with that mention or tag.
  ///
  /// Note: While setting initialMentions you must provide mention symbol associated with each mention. For example, ("@rowan", null) is a valid tuple and ("rowan", null) will be ignored.
  /// You don't need to add mention symbol later when setting mentions during editing using _controller.setMention, you can do _controller.setMention("rowan", null) and corresponding mention symbol will be added automatically.
  final List<(String, Object?, Widget?)> initialMentions;

  static Widget _defaultContextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  void _setControllerProperties(
      MentionTagTextEditingController? mentionController,
      List<(String, Object?, Widget?)> initialMentions) {
    if (mentionController == null) return;
    mentionController.mentionTagDecoration = mentionTagDecoration;
    mentionController.onMention = onMention;
    mentionController.initialMentions = initialMentions;
  }
}

class MentionTagTextFormField extends TextFormField {
  MentionTagTextFormField({
    super.key,
    TextEditingController? controller,
    this.initialMentions = const [],
    this.onMention,
    this.mentionTagDecoration = const MentionTagDecoration(),
    super.initialValue,
    super.focusNode,
    super.decoration = const InputDecoration(),
    super.keyboardType,
    super.textCapitalization = TextCapitalization.none,
    super.textInputAction,
    super.style,
    super.strutStyle,
    super.textDirection,
    super.textAlign = TextAlign.start,
    super.textAlignVertical,
    super.autofocus = false,
    super.readOnly = false,
    @Deprecated(
      'Use `contextMenuBuilder` instead. '
      'This feature was deprecated after v3.3.0-0.5.pre.',
    )
    super.toolbarOptions,
    super.showCursor,
    super.obscuringCharacter = '•',
    super.obscureText = false,
    super.autocorrect = true,
    super.smartDashesType,
    super.smartQuotesType,
    super.enableSuggestions = true,
    super.maxLengthEnforcement,
    super.maxLines = 1,
    super.minLines,
    super.expands = false,
    super.maxLength,
    void Function(String)? onChanged,
    super.onTap,
    super.onTapAlwaysCalled = false,
    super.onTapOutside,
    super.onEditingComplete,
    super.onFieldSubmitted,
    super.onSaved,
    super.validator,
    super.inputFormatters,
    super.enabled,
    super.cursorWidth = 2.0,
    super.cursorHeight,
    super.cursorRadius,
    super.cursorColor,
    super.cursorErrorColor,
    super.keyboardAppearance,
    super.scrollPadding = const EdgeInsets.all(20.0),
    super.enableInteractiveSelection,
    super.selectionControls,
    super.buildCounter,
    super.scrollPhysics,
    super.autofillHints,
    super.autovalidateMode,
    super.scrollController,
    super.restorationId,
    super.enableIMEPersonalizedLearning = true,
    super.mouseCursor,
    super.contextMenuBuilder = _defaultContextMenuBuilder,
    super.spellCheckConfiguration,
    super.magnifierConfiguration,
    super.undoController,
    super.onAppPrivateCommand,
    super.cursorOpacityAnimates,
    super.selectionHeightStyle = ui.BoxHeightStyle.tight,
    super.selectionWidthStyle = ui.BoxWidthStyle.tight,
    super.dragStartBehavior = DragStartBehavior.start,
    super.contentInsertionConfiguration,
    super.statesController,
    super.clipBehavior = Clip.hardEdge,
    super.scribbleEnabled = true,
    super.canRequestFocus = true,
  }) : super(
            controller: controller,
            onChanged: (value) {
              if (controller is MentionTagTextEditingController?) {
                try {
                  controller?.onChanged(value);
                  onChanged?.call(value);
                } catch (e, s) {
                  debugPrint(e.toString());
                  debugPrint(s.toString());
                }
              } else {
                onChanged?.call(value);
              }
            }) {
    if (controller is MentionTagTextEditingController?) {
      _setControllerProperties(controller, initialMentions);
    }
  }

  /// Provides the mention value whenever a mention is initiated, indicated by the mention start character
  /// (e.g., "@"), and ends when a space character is encountered.
  final void Function(String?)? onMention;

  /// Indicates the decoration related to mentions or tags
  final MentionTagDecoration mentionTagDecoration;

  /// Initial list of mentions which are present in the initial text set to textfield using _controller.text setter.
  ///
  /// Each mention in the list should be a tuple with first value as mention label present in the textfield and second value is the data associated with that mention or tag.
  ///
  /// Note: While setting initialMentions you must provide mention symbol associated with each mention. For example, ("@rowan", null) is a valid tuple and ("rowan", null) will be ignored.
  /// You don't need to add mention symbol later when setting mentions during editing using _controller.setMention, you can do _controller.setMention("rowan", null) and corresponding mention symbol will be added automatically.
  final List<(String, Object?, Widget?)> initialMentions;

  static Widget _defaultContextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  void _setControllerProperties(
      MentionTagTextEditingController? mentionController,
      List<(String, Object?, Widget?)> initialMentions) {
    if (mentionController == null) return;
    mentionController.mentionTagDecoration = mentionTagDecoration;
    mentionController.onMention = onMention;
    mentionController.initialMentions = initialMentions;
  }
}
