/// Part of the 'stylesheet.dart' file
part of 'stylesheet.dart';

/// This class defines the styles for the Message Info Page.
class MessageInfoPageStyle {
  /// AppBar theme style
  final AppBarTheme appBarTheme;

  /// Sender chat bubble style
  final SenderChatBubbleStyle senderChatBubbleStyle;

  /// Delivered title text style
  final TextStyle deliveredTitleStyle;

  /// Delivered message title text style
  final TextStyle deliveredMsgTitleStyle;

  /// Read title text style
  final TextStyle readTitleStyle;

  /// Read message title text style
  final TextStyle readMsgTitleStyle;

  /// Delivered item style
  final ContactItemStyle deliveredItemStyle;

  /// Read item style
  final ContactItemStyle readItemStyle;

  /// Constructor for the MessageInfoPageStyle class
  /// It initializes all the styles with default values
  const MessageInfoPageStyle({
    /// AppBar theme style
    this.appBarTheme = const AppBarTheme(
      backgroundColor: Color(0xffF2F2F2),
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold, color: Color(0xff181818), fontSize: 20),
      iconTheme: IconThemeData(color: Color(0xff181818)),
      actionsIconTheme: IconThemeData(color: Color(0xff181818)),
    ),

    /// Sender chat bubble style
    this.senderChatBubbleStyle = const SenderChatBubbleStyle(),

    /// Delivered title text style
    this.deliveredTitleStyle = const TextStyle(
        fontWeight: FontWeight.w600, color: Color(0xff181818), fontSize: 18.0),

    /// Read title text style
    this.readTitleStyle = const TextStyle(
        fontWeight: FontWeight.w600, color: Color(0xff181818), fontSize: 18.0),

    /// Delivered message title text style
    this.deliveredMsgTitleStyle = const TextStyle(
        fontWeight: FontWeight.bold, color: Color(0xff7C7C7C), fontSize: 14.0),

    /// Read message title text style
    this.readMsgTitleStyle = const TextStyle(
        fontWeight: FontWeight.bold, color: Color(0xff7C7C7C), fontSize: 14.0),

    /// Delivered item style
    this.deliveredItemStyle = const ContactItemStyle(),

    /// Read item style
    this.readItemStyle = const ContactItemStyle(),
  });
}
