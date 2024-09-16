part of 'stylesheet.dart';

class CallInfoPageStyle{
  final AppBarTheme appBarTheme;
  final PopupMenuThemeData popupMenuThemeData;
  final CallHistoryItemStyle callHistoryItemStyle;
  final ContactItemStyle contactItemStyle;
  const CallInfoPageStyle({
    this.appBarTheme = const AppBarTheme(color: Colors.white,
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 20),
      iconTheme: IconThemeData(color: Color(0xff181818)),
      actionsIconTheme: IconThemeData(color: Color(0xff181818)),),
    this.popupMenuThemeData = const PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.white,
        textStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 15),
        shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xffE8E8E8),width: 1)),
        iconColor: Color(0xff181818)
    ),
    this.callHistoryItemStyle = const CallHistoryItemStyle(),
    this.contactItemStyle = const ContactItemStyle()
  });
}