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
      Key? key,
      String text,
      List<String> mentionUserIds,
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
    int index = 0;
    for (var word in splits) {
      if (TextUtils.hasMatch(word, mentionRegex.pattern)) {
        // debugPrint("formatMentionTextSpan ${profileDetails[index].getName()} $index $word");
        var mentionSpans = formatMentionTextSpan(
            word, profileDetails, defaultStyle, underlineStyle, mentionStyle,index);
        spans.addAll(mentionSpans);
        index++;
      } else {
        spans.addAll(TextUtils.getTextSpan(word, defaultStyle, underlineStyle));
        spans.add(const TextSpan(text: " "));
      }
    }
    var result = TextSpan(children: spans);
    var list = mentionUserIds.join(",");
    if(defaultStyle!=null && underlineStyle != null && mentionStyle != null) {
      CustomTextViewManager.setCustomText(text + list+key.toString(), result);
    }
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
      int index
      ) {
    // int index = 0;
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;
    mentionRegex.allMatches(input).forEach((match) {
      // Add regular text before the mention.
      if (match.start > lastMatchEnd) {
        spans.addAll(TextUtils.parseEachLetterIntoTextSpan(
            input.substring(lastMatchEnd, match.start), defaultStyle));
      }

      // Add the mention text with style and recognizer.
      if (index < replacements.length && replacements.length>index) {
        // debugPrint("replacements[index].getName() ${replacements[index].getName()} $index");
        spans.addAll(TextUtils.parseEachLetterIntoTextSpan(
          "@${replacements[index].name} ",
          mentionStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              debugPrint('Tapped on: ${replacements[index]}');
            },
        ));
        // index++;
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

  /// Retrieves profile details for the given list of mentioned users.
  ///
  /// [mentionedUsers] - List of usernames to retrieve profile details for.
  /// Returns a [Future] containing a list of [ProfileDetails].
  static Future<List<ProfileDetails>> getProfileDetailsOfUsername(
      List<String> mentionedUsers,
      ) async {
    if(mentionedUsers.isEmpty){
      return [];
    }
    var profileDetails = <ProfileDetails>[];
    for (var username in mentionedUsers) {
      var jid = await Mirrorfly.getJid(username: username);
      var profile = await getProfileDetails(jid.checkNull());
      profileDetails.add(profile);
    }
    return profileDetails;
  }

}

