part of 'stylesheet.dart';

class DashBoardPageStyle {
  const DashBoardPageStyle(
      {this.appBarTheme = const AppBarTheme(backgroundColor: Color(0xffF2F2F2),
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          actionsIconTheme: IconThemeData(color: Color(0xff181818))),
      this.tabBarTheme = const TabBarTheme(
          indicatorColor: Color(0xff3276E2),
          labelColor: Color(0xff3276E2),
          unselectedLabelColor: Color(0xff181818)),
      this.searchTextFieldStyle = const EditTextFieldStyle(),
      this.tabItemStyle = const TabItemStyle(),
      this.archivedTileStyle = const ArchivedTileStyle(),
      this.recentChatItemStyle = const RecentChatItemStyle(),
      this.callHistoryItemStyle = const CallHistoryItemStyle(),
        this.noDataTextStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),
      });
  final AppBarTheme appBarTheme;
  final TabBarTheme tabBarTheme;
  final EditTextFieldStyle searchTextFieldStyle;
  final TabItemStyle tabItemStyle;
  final ArchivedTileStyle archivedTileStyle;
  final RecentChatItemStyle recentChatItemStyle;
  final CallHistoryItemStyle callHistoryItemStyle;
  final TextStyle noDataTextStyle;
}
