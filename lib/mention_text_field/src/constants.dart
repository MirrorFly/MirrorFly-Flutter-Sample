class Constants {
  /// Specifies the default character used to replace mentions within the text field.
  /// This character serves as a placeholder and ensures that mentions are distinct
  /// from regular text input. It should not be a character typically used in text
  /// input to avoid any potential conflicts or confusion. For example, if "@" is
  /// commonly used to denote mentions, this default character can be set to something
  /// else, such as "‡", to ensure that it does not appear naturally in user input.
  static const String mentionEscape = '‡';
}
