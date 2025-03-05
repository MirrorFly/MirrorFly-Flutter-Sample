import 'package:flutter/material.dart';

@immutable
class MentionTagElement {
  final String mentionSymbol;
  final String mention;
  final Object? data;
  final Widget? stylingWidget;
  const MentionTagElement(
      {required this.mentionSymbol,
      required this.mention,
      this.data,
      this.stylingWidget});
}
