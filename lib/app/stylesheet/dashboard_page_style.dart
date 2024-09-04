part of 'stylesheet.dart';

class DashBoardPageStyle {
  const DashBoardPageStyle(
      {this.appBarTheme = const AppBarTheme(backgroundColor: Color(0xffF2F2F2),
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 20),
          iconTheme: IconThemeData(color: Color(0xff181818)),
          actionsIconTheme: IconThemeData(color: Color(0xff181818)),
      ),
      this.tabBarTheme = const TabBarTheme(
          indicatorColor: AppColor.primaryColor,
          labelColor: AppColor.primaryColor,
          unselectedLabelColor: Color(0xff181818)),
      this.searchTextFieldStyle = const EditTextFieldStyle(),
      this.tabItemStyle = const TabItemStyle(),
      this.archivedTileStyle = const ArchivedTileStyle(),
      this.titlesTextStyle = const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff181818),fontSize: 14),
      this.recentChatItemStyle = const RecentChatItemStyle(),
      this.callHistoryItemStyle = const CallHistoryItemStyle(),
      this.createMeetLinkStyle = const CreateMeetLinkStyle(),
      this.meetBottomSheetStyle = const MeetBottomSheetStyle(),
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
        this.floatingActionButtonThemeData = const FloatingActionButtonThemeData(backgroundColor: AppColor.primaryColor,foregroundColor: Colors.white,elevation: 12,iconSize: 21,shape: CircleBorder())
      });
  final AppBarTheme appBarTheme;
  final TabBarTheme tabBarTheme;
  final EditTextFieldStyle searchTextFieldStyle;
  final TabItemStyle tabItemStyle;
  final ArchivedTileStyle archivedTileStyle;
  final TextStyle titlesTextStyle;
  final RecentChatItemStyle recentChatItemStyle;
  final CallHistoryItemStyle callHistoryItemStyle;
  final CreateMeetLinkStyle createMeetLinkStyle;
  final MeetBottomSheetStyle meetBottomSheetStyle;
  final TextStyle noDataTextStyle;
  final PopupMenuThemeData popupMenuThemeData;
  final ContactItemStyle contactItemStyle;
  final FloatingActionButtonThemeData floatingActionButtonThemeData;
}
