extension StringExtensions on String {
  /// Count the number of characters in this string.
  int countChar(String char) => char.allMatches(this).length;

  /// Reverse the string
  String get reversed => split('').reversed.join();

  /// Get the first character in the string
  String get first {
    if (isNotEmpty) {
      return substring(0, 1);
    } else {
      return '';
    }
  }

  /// Get the last character in the string
  String get last {
    if (isNotEmpty) {
      return substring(length - 1);
    } else {
      return '';
    }
  }

  /// Remove mention start symbols from the beginning of the string
  String removeMentionStart(List<String> mentionStartSymbols) {
    for (final symbol in mentionStartSymbols) {
      if (startsWith(symbol)) {
        return substring(symbol.length);
      }
    }
    return this;
  }

  /// Returns the index of space after skipping a certain amount of space.
  /// This is used to return the number of words in mentions.
  int indexOfNthSpace(int n) {
    if (n <= 0) return -1;

    int spaceCount = 0;
    for (int i = 0; i < length; i++) {
      if (this[i] == ' ') {
        spaceCount++;
        if (spaceCount == n) {
          return i;
        }
      }
    }
    return -1;
  }

  /// Checks if string has mention symbol at start
  String checkMentionSymbol(List<String> symbols) {
    if (isEmpty) {
      return '';
    }

    String firstChar = this[0];
    for (String symbol in symbols) {
      if (firstChar == symbol) {
        return symbol;
      }
    }

    return '';
  }

  String removeCharacterAtCount(String character, int count) {
    int occurrence = 0;
    int indexToRemove = -1;

    for (int i = 0; i < length; i++) {
      if (this[i] == character) {
        occurrence++;
        if (occurrence == count) {
          indexToRemove = i;
          break;
        }
      }
    }

    if (indexToRemove != -1) {
      return substring(0, indexToRemove) + substring(indexToRemove + 1);
    }

    return this;
  }
}
