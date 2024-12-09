import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/textutils.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/modules/chat/widgets/custom_text_view.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

class MentionedUser {
  final String userId;
  final String displayName;

  MentionedUser({required this.userId, required this.displayName});
}

/// Utility class for handling mentions in text.
class MentionUtils {
  /// Regular expression to match mentions in the format @[username].
  static final RegExp mentionRegex = RegExp(r'[@]\[(.*?)\]');

  /// Checks if a given text contains a mention.
  ///
  /// [text] - The input text to check.
  /// Returns `true` if the text contains a mention, `false` otherwise.
  static bool isMention(String text) {
    return mentionRegex.hasMatch(text);
  }

  /// Replaces mentions in the given text with styled [TextSpan]s.
  ///
  /// [text] - The input text containing mentions.
  /// [profileDetails] - List of profile details to replace mentions.
  /// [defaultStyle] - The style for normal text.
  /// [underlineStyle] - The style for underlined text.
  /// [mentionStyle] - The style for mentions.
  /// Returns a [TextSpan] containing the entire styled text.
  static TextSpan replaceMentionedUserText(
      String text,
      List<ProfileDetails> profileDetails,
      TextStyle? defaultStyle,
      TextStyle? underlineStyle,
      TextStyle? mentionStyle,
      ) {
    if (text.isEmpty) {
      return const TextSpan(children: []);
    }

    List<TextSpan> spans = [];
    var splits = text.split(" ");
    for (var word in splits) {
      if (TextUtils.hasMatch(word, mentionRegex.pattern)) {
        var mentionSpans = formatMentionTextSpan(
            word, profileDetails, defaultStyle, underlineStyle, mentionStyle);
        spans.addAll(mentionSpans);
      } else {
        spans.addAll(TextUtils.getTextSpan(word, defaultStyle, underlineStyle));
        spans.add(const TextSpan(text: " "));
      }
    }
    var result = TextSpan(children: spans);
    CustomTextViewManager.setCustomText(text, result);
    return result;
  }

  /// Formats a mention in the text with a specific style.
  ///
  /// [input] - The input text containing mentions.
  /// [replacements] - List of profile details for replacing mentions.
  /// [defaultStyle] - The style for normal text.
  /// [underlineStyle] - The style for underlined text.
  /// [mentionStyle] - The style for mentions.
  /// Returns a list of [TextSpan] objects with the formatted mentions.
  static List<TextSpan> formatMentionTextSpan(
      String input,
      List<ProfileDetails> replacements,
      TextStyle? defaultStyle,
      TextStyle? underlineStyle,
      TextStyle? mentionStyle,
      ) {
    int index = 0;
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    mentionRegex.allMatches(input).forEach((match) {
      // Add regular text before the mention.
      if (match.start > lastMatchEnd) {
        spans.addAll(setSpanForEachLetter(
            input.substring(lastMatchEnd, match.start), defaultStyle));
      }

      // Add the mention text with style and recognizer.
      if (index < replacements.length) {
        spans.addAll(setSpanForEachLetter(
          "@${replacements[index].getName()} ",
          mentionStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              debugPrint('Tapped on: ${replacements[index]}');
            },
        ));
        index++;
      } else {
        var str = match.group(0) ?? "";
        spans.addAll(TextUtils.getTextSpan(str, defaultStyle, underlineStyle));
      }

      lastMatchEnd = match.end;
    });

    // Add remaining text after the last match.
    if (lastMatchEnd < input.length) {
      spans.addAll(TextUtils.getTextSpan(
          input.substring(lastMatchEnd), defaultStyle, underlineStyle));
    }
    return spans;
  }

  /// Splits the text into individual characters and applies a style.
  ///
  /// [text] - The input text to style.
  /// [style] - The text style to apply.
  /// [recognizer] - An optional [GestureRecognizer] for handling taps.
  /// Returns a list of [TextSpan] objects.
  static List<TextSpan> setSpanForEachLetter(
      String text,
      TextStyle? style, {
        GestureRecognizer? recognizer,
      }) {
    return text
        .split("")
        .map((letter) =>
        TextSpan(text: letter, style: style, recognizer: recognizer))
        .toList();
  }

  /// Retrieves profile details for the given list of mentioned users.
  ///
  /// [mentionedUsers] - List of usernames to retrieve profile details for.
  /// Returns a [Future] containing a list of [ProfileDetails].
  static Future<List<ProfileDetails>> getProfileDetailsOfUsername(
      List<String> mentionedUsers,
      ) async {
    var profileDetails = <ProfileDetails>[];
    for (var username in mentionedUsers) {
      var jid = await Mirrorfly.getJid(username: username);
      var profile = await getProfileDetails(jid.checkNull());
      profileDetails.add(profile);
    }
    return profileDetails;
  }

  /// Formats a text with mentions into a styled [TextSpan].
  ///
  /// [text] - The input text containing mentions.
  /// [mentionedUsers] - List of mentioned users with their details.
  /// [defaultStyle] - The style for normal text.
  /// [mentionStyle] - The style for mentions.
  /// Returns a [TextSpan] with styled mentions.
  static TextSpan formatMentionText(
      String text,
      List<MentionedUser> mentionedUsers,
      TextStyle defaultStyle,
      TextStyle mentionStyle,
      ) {
    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in mentionRegex.allMatches(text)) {
      // Extract mention details
      // final matchText = match.group(0)!; // Full match like "@[username]"
      final mentionDisplayName = match.group(1)!; // Username inside brackets
      final mentionedUser = mentionedUsers.firstWhere(
            (user) => user.displayName == mentionDisplayName,
        orElse: () =>
            MentionedUser(displayName: mentionDisplayName, userId: ''),
      );

      // Add text before the mention as a normal span
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: defaultStyle));
      }

      // Add the mention span
      spans.add(TextSpan(
        text: '@${mentionedUser.displayName}',
        style: mentionStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            debugPrint('Tapped on mention: ${mentionedUser.userId}');
          },
      ));

      lastMatchEnd = match.end;
    }

    // Add remaining text after the last mention
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
          text: text.substring(lastMatchEnd), style: defaultStyle));
    }

    return TextSpan(children: spans, style: defaultStyle);
  }

  /// Converts a text with mentions to plain text.
  ///
  /// [text] - The input text containing mentions.
  /// [mentionedUsers] - List of mentioned users.
  /// Returns a plain text version of the input.
  static String getMentionedPlainText(
      String text,
      List<MentionedUser> mentionedUsers,
      ) {
    return text.replaceAllMapped(mentionRegex, (match) {
      final mentionDisplayName = match.group(1)!;
      return '@$mentionDisplayName';
    });
  }
}

