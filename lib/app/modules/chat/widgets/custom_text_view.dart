import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/data/mention_utils.dart';
import 'package:mirror_fly_demo/app/data/textutils.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';

class CustomTextView extends StatelessWidget {
  const CustomTextView(
      {super.key,
      required this.text,
      this.searchQueryString = "",
      required this.defaultTextStyle,
      required this.linkColor,
      required this.mentionUserTextColor,
      required this.searchQueryTextColor,
      this.mentionUserIds = const [],
      this.maxLines});
  final String text;
  final String searchQueryString;
  final TextStyle defaultTextStyle;
  final Color linkColor;
  final Color mentionUserTextColor;
  final Color searchQueryTextColor;
  final List<String> mentionUserIds;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    debugPrint("buildsCustomText : $text");
    return searchQueryString.checkNull().isEmpty
        ? mentionUserIds.isNotEmpty
            ? mentionUserText()
            : getNormalText()
        : searchWidget();
  }

  Widget getNormalText() {
    var getText = CustomTextViewManager.getCustomText(text+mentionUserIds.join(",")+key.toString());
    if(getText!=null){
      return Text.rich(getText,
        maxLines: maxLines,
        style: defaultTextStyle,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,);
    }
    var normalTextSpans = TextUtils.getNormalTextSpans(key,text,mentionUserIds,defaultTextStyle,key != null ? defaultTextStyle.copyWith(
        color: linkColor,
        decoration: TextDecoration.underline,
        decorationColor: linkColor) : null);
    // LogMessage.d("normalTextSpans", normalTextSpans.children);
    return Text.rich(
      normalTextSpans,
      style: defaultTextStyle,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }

  Widget mentionUserText() {
    TextStyle? underlineStyle = defaultTextStyle.copyWith(
        color: linkColor,
        decoration: TextDecoration.underline,
        decorationColor: linkColor);
    TextStyle? mentionStyle =
        defaultTextStyle.copyWith(color: mentionUserTextColor,inherit: false);
    debugPrint("mentionUserTextColor ${mentionUserIds.join(",")}");
    var getText  = CustomTextViewManager.getCustomText(text+mentionUserIds.join(",")+key.toString());
    return getText !=null ? Text.rich(getText,
      maxLines: maxLines,
      style: defaultTextStyle,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,) : FutureBuilder(
        future: MentionUtils.getProfileDetailsOfUsername(mentionUserIds),
        builder: (context, data) {
          if(data.connectionState==ConnectionState.done && data.hasData) {
            var formattedString = MentionUtils.replaceMentionedUserText(key,text,mentionUserIds,data.data!,defaultTextStyle,underlineStyle,mentionStyle);
            return Text.rich(formattedString,
              maxLines: maxLines,
              style: defaultTextStyle,
              overflow: maxLines == null ? null : TextOverflow.ellipsis,
            );
          }else{
            return const Text("");
          }
        });
  }

  Widget searchWidget() {
    var span = CustomTextViewManager.getCustomText(text+mentionUserIds.join(",")+key.toString());
    if (span!=null) {
      var changedSearchSpans = TextUtils.getSearchedTextSpans(span.toPlainText(),searchQueryString.toLowerCase(),span,searchQueryTextColor);
      return Text.rich(
        TextSpan(children: changedSearchSpans,style: defaultTextStyle),
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
      );
    } else {
      return mentionUserIds.isNotEmpty
          ? mentionUserText()
          : getNormalText();
    }
  }
}

class CustomTextViewManager {
  static final Map<String, TextSpan> _cache = {};

  static TextSpan? getCustomText(String key){
    debugPrint("CustomTextViewManager getCustomText key : $key, value : ${_cache[key]?.children}");
    return _cache[key];
  }

  static setCustomText(String key,TextSpan text){
    _cache[key]=text;
    debugPrint("CustomTextViewManager setCustomText key : $key, value : ${text.children}");
  }
}