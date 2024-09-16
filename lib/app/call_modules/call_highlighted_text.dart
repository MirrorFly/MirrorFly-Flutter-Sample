import 'package:flutter/material.dart';
import '../../app/common/constants.dart';

class CallHighlightedText extends StatelessWidget {
  final String searchString;
  final String content;

  const CallHighlightedText({
    Key? key,
    required this.searchString,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matches = searchString.isEmpty ? <RegExpMatch>[] : RegExp(searchString, caseSensitive: false).allMatches(content).toList();
    final parts = <InlineSpan>[];
    if (matches.isEmpty) {
      parts.add(TextSpan(text: content));
    } else {
      var i = 0;
      var matchIndex = 0;
      while (true) {
        if (matchIndex >= matches.length) {
          final end = content.substring(matches.last.end);
          if (end.isNotEmpty) {
            parts.add(TextSpan(text: content.substring(matches.last.end)));
          }
          break;
        }
        final match = matches[matchIndex];
        if (match.start > i) {
          final slice = content.substring(i, match.start);
          parts.add(TextSpan(text: slice));
          i = match.start;
          continue;
        }
        final slice = content.substring(match.start, match.end);
        parts.add(TextSpan(
          text: slice,
          style: const TextStyle(fontWeight: FontWeight.bold, color: buttonBgColor),
        ));
        matchIndex += 1;
        i = match.end;
      }
    }

    return Text.rich(
      TextSpan(
        children: parts,
      ),
    );
  }
}