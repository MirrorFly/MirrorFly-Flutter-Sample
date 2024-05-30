part of 'stylesheet.dart';

class ChatPageStyle {
  const ChatPageStyle(
      {this.appBarTheme = const AppBarTheme(backgroundColor: Color(0xffF2F2F2)),
        this.chatUserAppBarStyle = const ChatUserAppBarStyle(),
        this.searchTextFieldStyle = const EditTextFieldStyle()});
  final AppBarTheme appBarTheme;
  final ChatUserAppBarStyle chatUserAppBarStyle;
  final EditTextFieldStyle searchTextFieldStyle;
}

class ChatUserAppBarStyle{
  const ChatUserAppBarStyle({
    this.profileImageSize = const Size(36, 36),
    this.titleTextStyle = const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff181818),fontSize: 16),
    this.subtitleTextStyle = const TextStyle(fontWeight: FontWeight.w300, color: Color(0xff959595),fontSize: 10),
  });
  final Size profileImageSize;
  final TextStyle titleTextStyle;
  final TextStyle subtitleTextStyle;
}

class TextTypingAreaStyle{
  TextTypingAreaStyle({
    this.textFieldStyle = const EditTextFieldStyle(editTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Color(0xff181818),fontSize: 16),editTextHintStyle: TextStyle(fontWeight: FontWeight.w300, color: Color(0xff959595),fontSize: 12)),
    Decoration? decoration,
    this.dividerColor = const Color(0xff000000)}) : decoration = decoration ?? _defaultDecoration;
  final EditTextFieldStyle textFieldStyle;
  final Decoration decoration;
  final Color dividerColor;

  static final Decoration _defaultDecoration = BoxDecoration(
    border: Border.all(color: const Color(0xffC1C1C1),),
    borderRadius: const BorderRadius.all(Radius.circular(40)),
    color: Colors.white,
  );

}

class NotificationMessageViewStyle{
  NotificationMessageViewStyle({this.decoration = const BoxDecoration(
      color: Color(0xff00001F),
      borderRadius: BorderRadius.all(Radius.circular(15))),
    this.textStyle = const TextStyle(fontWeight: FontWeight.w500, color: Color(0xff565656),fontSize: 13),});
  final Decoration decoration;
  final TextStyle textStyle;
}

class TextMessageViewStyle{
  const TextMessageViewStyle({this.textStyle = const TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),
  this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11),
    this.highlightColor = Colors.orange,//while searching a message to highlight the text
  this.urlMessageColor = Colors.blue});
  final TextStyle textStyle;
  final TextStyle timeTextStyle;
  final Color highlightColor;
  final Color urlMessageColor;
}

class ImageMessageViewStyle{
  const ImageMessageViewStyle({this.captionTextViewStyle = const TextMessageViewStyle()});
  final TextMessageViewStyle captionTextViewStyle;
}


class SenderChatBubbleStyle{
 SenderChatBubbleStyle({
   this.textMessageViewStyle = const TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11)),
   Decoration? decoration,
}) : decoration = decoration ?? _defaultDecoration;
 final TextMessageViewStyle textMessageViewStyle;
 final Decoration decoration;

 static final Decoration _defaultDecoration = BoxDecoration(
     borderRadius: const BorderRadius.only(
         topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
     color: const Color(0xffE2E8F7),
     border: Border.all(color: const Color(0xffe2eafc)));
}

class ReceiverChatBubbleStyle{
  ReceiverChatBubbleStyle({
   this.textMessageViewStyle = const TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff313131),fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff959595),fontSize: 11)),
   Decoration? decoration,
 }) : decoration = decoration ?? _defaultDecoration;
 final TextMessageViewStyle textMessageViewStyle;
 final Decoration decoration;

 static final Decoration _defaultDecoration = BoxDecoration(
     borderRadius: const BorderRadius.only(
         topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
     color: Colors.white,
     border: Border.all(color: const Color(0xffDDE3E5)));
}


