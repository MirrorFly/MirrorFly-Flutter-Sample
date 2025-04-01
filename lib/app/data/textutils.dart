import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/modules/chat/widgets/custom_text_view.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class for handling text-related operations, such as determining
/// the type of text (email, mobile, website, etc.), generating styled spans,
/// and handling text interactions.
class TextUtils {
  /// Determines the type of the given text.
  ///
  /// [text] - The input text to analyze.
  /// Returns a string indicating the type: "email", "mobile", "website", or "text".
  static String getTextType(String text) {
    if (isEmail(text)) {
      return "email";
    }
    if (isValidPhoneNumber(text)) {
      return "mobile";
    }
    if (isValidURL(text.trim())) {
      return "website";
    }
    return "text";
  }

  /// Creates a list of [TextSpan] objects for the given text.
  ///
  /// [text] - The input text to style.
  /// [normalStyle] - The style for regular text.
  /// [underlineStyle] - The style for clickable text like email or URL.
  /// Returns a list of styled [TextSpan] objects.
  static List<TextSpan> getTextSpan(
      String? text,
      TextStyle? normalStyle,
      TextStyle? underlineStyle,
      ) {
    debugPrint("getTextSpan $text");
    if (isEmail(text.checkNull().trim()) ||
        isValidPhoneNumber(text.checkNull().trim()) ||
        isValidURL(text.checkNull().trim())) {
      return parseEachLetterIntoTextSpan(
        text.checkNull(),
        underlineStyle,
        recognizer: (isValidURL(text.checkNull().trim()) &&
            MessageUtils.getCallLinkFromMessage(text.checkNull().trim())
                .isNotEmpty)
            ? null
            : TapGestureRecognizer()
          ?..onTap = underlineStyle != null
              ? () {
            onTapForSpanText(text.checkNull());
          }
              : null,
      );
    } else {
      return parseEachLetterIntoTextSpan(text.checkNull(), normalStyle);
    }
  }

  /// Changes the color of spans in a list of [InlineSpan].
  ///
  /// [colorInline] - The list of spans to modify.
  /// [color] - The new color to apply.
  /// Returns a list of [TextSpan] with updated colors.
  static List<TextSpan>? changeSpanColor(
      List<InlineSpan>? colorInline,
      Color color,
      ) {
    List<TextSpan> changedSpans = [];
    if (colorInline != null) {
      for (var span in colorInline) {
        changedSpans.add(TextSpan(
          text: span.toPlainText(),
          style: span.style?.copyWith(color: color),
        ));
      }
    }
    return changedSpans;
  }

  /// Highlights the searched query within a text span.
  ///
  /// [text] - The full text to search within.
  /// [query] - The search term to highlight.
  /// [span] - The original span containing text and styles.
  /// [color] - The highlight color.
  /// Returns a list of [TextSpan] with the query highlighted.
  static List<TextSpan> getSearchedTextSpans(
      String? text,
      String query,
      TextSpan? span,
      Color color,
      ) {
    var allSpans = <TextSpan>[];
    if (text != null && query.isNotEmpty) {
      var startIndex = text.toLowerCase().indexOf(query.toLowerCase());
      LogMessage.d("startIndex", startIndex);
      if (startIndex != -1) {
        var endIndex = startIndex + query.length;
        allSpans.add(TextSpan(children: span?.children?.sublist(0, startIndex) ?? []));
        allSpans.add(TextSpan(children: changeSpanColor(span?.children?.sublist(startIndex, endIndex), color) ?? []));
        allSpans.add(TextSpan(children: span?.children?.sublist(endIndex) ?? []));
      }else{
        allSpans.add(TextSpan(children: span?.children));
      }
    }

    return allSpans;
  }

  /// Converts plain text into styled [TextSpan]s for rendering.
  ///
  /// [text] - The input text to format.
  /// [normalStyle] - The style for normal text.
  /// [underlineStyle] - The style for links or clickable text.
  /// Returns a [TextSpan] containing the entire formatted text.
  static TextSpan getNormalTextSpans(
      Key? key,
      String? text,
      List<String> mentionUserIds,
      TextStyle? normalStyle,
      TextStyle? underlineStyle,
      ) {
    var spans = <TextSpan>[];
    var splits = text?.split(" ");
    if (splits != null) {
      for (var split in splits) {
        spans.addAll(getTextSpan("$split ", normalStyle, underlineStyle));
      }
    }
    var result = TextSpan(children: spans);
    CustomTextViewManager.setCustomText((text ?? "")+mentionUserIds.join(",")+key.toString(), result);
    return result;
  }

  /// Handles on-tap events for spans, determining the appropriate action based on text type.
  ///
  /// [e] - The tapped text.
  static onTapForSpanText(String e) {
    var stringType = getTextType(e);
    debugPrint("Text span click");
    if (stringType == "website") {
      launchInBrowser(e);
    } else if (stringType == "mobile") {
      makePhoneCall(e);
    } else if (stringType == "email") {
      launchEmail(e);
    } else {
      debugPrint("No matching condition for tap action.");
    }
  }

  /// Launches a URL in the browser.
  ///
  /// [url] - The URL to open.

  static Future<void> launchInBrowser(String url) async {
    if (await AppUtils.isNetConnected()) {
      try {
        final Uri toLaunch = Uri.parse(url.trim());

        if (toLaunch.scheme != 'http' && toLaunch.scheme != 'https') {
          throw 'Unsupported URL scheme: ${toLaunch.scheme}';
        }

        final launched = await launchUrl(toLaunch, mode: LaunchMode.externalApplication);
        if (!launched) {
          throw 'Could not launch $url';
        }
      } catch (e) {
        throw 'Invalid URL: $url';
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }


  /// Initiates a phone call to the given number.
  ///
  /// [phoneNumber] - The phone number to call.
  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  /// Sends an email to the specified email address.
  ///
  /// [emailID] - The recipient's email address.
  static Future<void> launchEmail(String emailID) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: emailID);
    await launchUrl(emailLaunchUri);
  }

  /// Checks if the given text matches a country code pattern.
  ///
  /// [text] - The text to check.
  /// Returns `true` if the text is a country code, `false` otherwise.
  static bool isCountryCode(String text) {
    return RegExp(Constants.countryCodePattern).hasMatch(text);
  }

  /// Checks if the given text is a valid email address.
  ///
  /// [text] - The email to validate.
  /// Returns `true` if the text is an email, `false` otherwise.
  static bool isEmail(String text) {
    return RegExp(Constants.emailPattern, multiLine: false).hasMatch(text);
  }

  /// Checks if the given text is a valid phone number.
  ///
  /// [s] - The phone number to validate.
  /// Returns `true` if valid, `false` otherwise.
  static bool isValidPhoneNumber(String s) {
    if (s.length > 13 || s.length < 6) return false;
    return hasMatch(s, r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  }

  /// Checks if the given string is a valid URL.
  ///
  /// [url] - The string to validate as a URL.
  /// Returns `true` if the string is a valid HTTP, HTTPS, or www-prefixed URL; `false` otherwise.
  static bool isValidURL(String url) {
    final RegExp urlPattern = RegExp(
      r"^(https?:\/\/[^\s]+|www\.[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$",
      caseSensitive: false,
    );

    return urlPattern.hasMatch(url);
  }

  /// Determines if a given value matches the specified pattern.
  ///
  /// [value] - The text to check.
  /// [pattern] - The regex pattern.
  /// Returns `true` if the value matches, `false` otherwise.
  static bool hasMatch(String? value, String pattern) {
    return (value == null) ? false : RegExp(pattern).hasMatch(value);
  }

  /// Splits the text into individual characters and applies a style.
  ///
  /// [text] - The input text to style.
  /// [style] - The text style to apply.
  /// [recognizer] - An optional [GestureRecognizer] for handling taps.
  /// Returns a list of [TextSpan] objects.
  static List<TextSpan> parseEachLetterIntoTextSpan(String? text,TextStyle? style, {
    GestureRecognizer? recognizer,
  }){
    final children = <TextSpan>[];
    if(text == null){
      return children;
    }
    final runes = text.runes;

    for (int i = 0; i < runes.length; /* empty */ ) {
      int current = runes.elementAt(i);

      // we assume that everything that is not
      // in Extended-ASCII set is an emoji...
      final isEmoji = current > 255;
      final shouldBreak = isEmoji
          ? (x) => x <= 255
          : (x) => x > 255;

      final chunk = <int>[];
      while (! shouldBreak(current)) {
        chunk.add(current);
        if (++i >= runes.length) break;
        current = runes.elementAt(i);
      }
      // LogMessage.d("parseEachLetterIntoTextSpan", "chunk : $chunk, current : $current, fromCharCodes : ${String.fromCharCodes(chunk)}");
      children.addAll(
          String.fromCharCodes(chunk).characters.map((letter) =>
              TextSpan(text: letter, style: style, recognizer: recognizer))
              .toList()
      );
    }
    // LogMessage.d("parseEachLetterIntoTextSpan", children);
    return children;
  }

  static List<WidgetSpan> parseEachLetterIntoWidgetSpan(String? text,TextStyle? style){
    final children = <WidgetSpan>[];
    if(text == null){
      return children;
    }
    final runes = text.runes;

    for (int i = 0; i < runes.length; /* empty */ ) {
      int current = runes.elementAt(i);

      // we assume that everything that is not
      // in Extended-ASCII set is an emoji...
      final isEmoji = current > 255;
      final shouldBreak = isEmoji
          ? (x) => x <= 255
          : (x) => x > 255;

      final chunk = <int>[];
      while (! shouldBreak(current)) {
        chunk.add(current);
        if (++i >= runes.length) break;
        current = runes.elementAt(i);
      }
      // LogMessage.d("parseEachLetterIntoTextSpan", "chunk : $chunk, current : $current, fromCharCodes : ${String.fromCharCodes(chunk)}");
      children.addAll(
          String.fromCharCodes(chunk).characters.map((letter) =>
              WidgetSpan(alignment: PlaceholderAlignment.middle,child: Text( letter, style: style, )))
              .toList()
      );
    }
    // LogMessage.d("parseEachLetterIntoTextSpan", children);
    return children;
  }
}

