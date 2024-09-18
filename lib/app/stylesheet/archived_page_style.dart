part of 'stylesheet.dart';

class ArchivedChatsPageStyle {
  const ArchivedChatsPageStyle(
      {this.appBarTheme = const AppBarTheme(backgroundColor: Colors.white,shadowColor: Colors.white,surfaceTintColor: Colors.white,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 20),
          elevation: 0,actionsIconTheme: IconThemeData(color: Color(0xff181818))),
        this.recentChatItemStyle = const RecentChatItemStyle(),
        this.noDataTextStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14)});
  final AppBarTheme appBarTheme;
  final RecentChatItemStyle recentChatItemStyle;
  final TextStyle noDataTextStyle;
}


