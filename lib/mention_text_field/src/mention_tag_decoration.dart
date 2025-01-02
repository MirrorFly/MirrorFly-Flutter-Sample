import 'package:flutter/material.dart';

class MentionTagDecoration {
  const MentionTagDecoration({
    this.mentionStart = const ['@', '#'],
    this.mentionBreak = ' ',
    this.maxWords = 1,
    this.mentionTextStyle =
        const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
    this.allowDecrement = true,
    this.allowEmbedding = false,
    this.showMentionStartSymbol = true,
  }) : assert(
          maxWords == null ? true : maxWords > 0,
          "maxWords must be greater than 0 or null",
        );

  /// Indicates the start point of mention or tag.
  final List<String> mentionStart;

  /// Default character to place after mention.
  /// In case of tags if you don't want any space you can set this empty string.
  final String mentionBreak;

  /// TextStyle of mentioned or tagged text.
  final TextStyle mentionTextStyle;

  /// The max amount of words a mention can have, must be greater than zero or null.
  /// In case of null, any number of words will be considered. That means onMention callback will send all the words after mention symbol unless you call setMention.
  final int? maxWords;

  /// Allow mentions to remove in decrement.
  ///
  /// e.g If textfield has this text, "I am @rowan" pressing back space will result "I am @rowa" if this property is set to true.
  /// The mention will be remove and you'll receive mention call back "@rowa" in onMention callback.
  ///
  /// If this property is set to false, whole mention will be removed on single backspace.
  final bool allowDecrement;

  /// If this value is set to true onMention callback will return the string even if start symbol is in the middle of text.
  ///
  /// e.g. If textfield has "example@gmail.com", setting this property true will cause the onMention callback to return "@gmail.com".
  /// By defualt this property is false, onMention callback won't return if mention start symbol is in the middle of text.
  ///
  /// In short, false value will cause the onMention callback to give mentions only if mention start symbol has a space behind it.
  final bool allowEmbedding;

  /// Wether to show mention start symbol with your mentions in the textfield or not.
  final bool showMentionStartSymbol;
}
