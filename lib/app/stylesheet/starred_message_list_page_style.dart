part of 'stylesheet.dart';

class StarredMessageListPageStyle{
  final AppBarTheme appBarTheme;
  final EditTextFieldStyle searchTextFieldStyle;
  final TextStyle noDataTextStyle;
  final StarredMessageUserHeaderStyle starredMessageUserHeaderStyle;
  final ReceiverChatBubbleStyle receiverChatBubbleStyle;
  final SenderChatBubbleStyle senderChatBubbleStyle;
  final PopupMenuThemeData popupMenuThemeData;

  const StarredMessageListPageStyle({
    this.appBarTheme = const AppBarTheme(backgroundColor: Colors.white,shadowColor: Colors.white,surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 20),
        elevation: 0,actionsIconTheme: IconThemeData(color: Color(0xff181818))),
    this.searchTextFieldStyle = const EditTextFieldStyle(),
    this.noDataTextStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),
    this.starredMessageUserHeaderStyle = const StarredMessageUserHeaderStyle(),
    this.senderChatBubbleStyle = const SenderChatBubbleStyle(),
    this.receiverChatBubbleStyle = const ReceiverChatBubbleStyle(),
    this.popupMenuThemeData = const PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.white,
        textStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 15),
        shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xffE8E8E8),width: 1)),
        iconColor: Color(0xff181818)
    )
});
}

class StarredMessageUserHeaderStyle{
  final Size profileImageSize;
  final TextStyle profileNameStyle;
  final TextStyle dateTextStyle;

  const StarredMessageUserHeaderStyle({
    this.profileImageSize = const Size(48, 48),
    this.profileNameStyle = const TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818), fontSize: 15),
    this.dateTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff959595),fontSize: 12,)
  });
  
}