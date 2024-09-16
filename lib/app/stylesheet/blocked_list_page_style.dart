part of 'stylesheet.dart';

class BlockedListPageStyle{

  final AppBarTheme appbarTheme;
  final ContactItemStyle blockedUserItemStyle;
  final TextStyle noDataTextStyle;

  const BlockedListPageStyle({
    this.appbarTheme = const AppBarTheme(backgroundColor: Colors.white,shadowColor: Colors.white,surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 20),
        elevation: 0,actionsIconTheme: IconThemeData(color: Color(0xff181818))),
    this.blockedUserItemStyle = const ContactItemStyle(
        titleStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),
        descriptionStyle:TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 12),
        actionTextStyle:TextStyle(fontWeight: FontWeight.w600,color: Color(0xff4879F9),fontSize: 12)),
    this.noDataTextStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14)
  });
}