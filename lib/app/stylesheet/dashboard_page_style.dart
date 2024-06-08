part of 'stylesheet.dart';

class DashBoardPageStyle {
  const DashBoardPageStyle(
      {this.appBarTheme = const AppBarTheme(backgroundColor: Color(0xffF2F2F2),
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xff181818)),
          actionsIconTheme: IconThemeData(color: Color(0xff181818)),
      ),
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
        this.popupMenuThemeData = const PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
          textStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 15),
          shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xffE8E8E8),width: 1)),
          iconColor: Color(0xff181818)
        ),
        this.contactItemStyle = const ContactItemStyle(
            profileImageSize: Size(50, 50),
            titleStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),
            descriptionStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 12),
            dividerColor: Color(0xffEBEBEB)
        ),
        this.floatingActionButtonThemeData = const FloatingActionButtonThemeData(backgroundColor: Color(0xff3276E2),foregroundColor: Colors.white,elevation: 12,iconSize: 21,shape: CircleBorder())
      });
  final AppBarTheme appBarTheme;
  final TabBarTheme tabBarTheme;
  final EditTextFieldStyle searchTextFieldStyle;
  final TabItemStyle tabItemStyle;
  final ArchivedTileStyle archivedTileStyle;
  final RecentChatItemStyle recentChatItemStyle;
  final CallHistoryItemStyle callHistoryItemStyle;
  final TextStyle noDataTextStyle;
  final PopupMenuThemeData popupMenuThemeData;
  final ContactItemStyle contactItemStyle;
  final FloatingActionButtonThemeData floatingActionButtonThemeData;
}
