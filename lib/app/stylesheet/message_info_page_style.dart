part of 'stylesheet.dart';

class MessageInfoPageStyle{

  final AppBarTheme appBarTheme;
  final SenderChatBubbleStyle senderChatBubbleStyle;
  final TextStyle deliveredTitleStyle;
  final TextStyle deliveredMsgTitleStyle;
  final TextStyle readTitleStyle;
  final TextStyle readMsgTitleStyle;
  final ContactItemStyle deliveredItemStyle;
  final ContactItemStyle readItemStyle;

  const MessageInfoPageStyle({
    this.appBarTheme = const AppBarTheme(color: Colors.white,
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleTextStyle: TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 18),
      iconTheme: IconThemeData(color: Color(0xff181818)),
      actionsIconTheme: IconThemeData(color: Color(0xff181818)),),
    this.senderChatBubbleStyle = const SenderChatBubbleStyle(),
    this.deliveredTitleStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 18.0),
    this.readTitleStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 18.0),
    this.deliveredMsgTitleStyle = const TextStyle(fontWeight: FontWeight.bold,color: Color(0xff7C7C7C),fontSize: 14.0),
    this.readMsgTitleStyle = const TextStyle(fontWeight: FontWeight.bold,color: Color(0xff7C7C7C),fontSize: 14.0),
    this.deliveredItemStyle = const ContactItemStyle(),
    this.readItemStyle = const ContactItemStyle(),
  });
}