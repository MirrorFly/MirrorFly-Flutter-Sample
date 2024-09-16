part of 'stylesheet.dart';

class GroupChatInfoPageStyle{
  const GroupChatInfoPageStyle({
    this.appBarTheme = const AppBarTheme(backgroundColor: Colors.white,shadowColor: Colors.white,surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 20),
        elevation: 0,actionsIconTheme: IconThemeData(color: Color(0xff181818))),
    this.silverAppbarTitleStyle = const TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),
    this.silverAppBarSubTitleStyle = const TextStyle(fontWeight: FontWeight.w300,color: Colors.white,fontSize: 10),
    this.silverAppBarIconColor = Colors.white,
    this.muteNotificationStyle = const MuteNotificationStyle(textStyle: TextStyle(fontWeight: FontWeight.w500,color: Color(0xff181818),fontSize: 14),
        toggleStyle: ToggleStyle(activeColor: Colors.white,
        inactiveColor: Colors.white,
        activeToggleColor: Colors.blue,
        inactiveToggleColor: Colors.grey),),
    this.groupMemberStyle = const ContactItemStyle(
        titleStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),
        descriptionStyle:TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 12),
        actionTextStyle:TextStyle(fontWeight: FontWeight.w600,color: Color(0xff4879F9),fontSize: 12)),
    this.addParticipantStyle = const ListItemStyle(
      leadingIconColor: Color(0xff181818),
      titleTextStyle: TextStyle(fontWeight: FontWeight.w500,color: Color(0xff181818),fontSize: 14),
      trailingIconColor: Color(0xff767676),
        dividerColor: Color(0xffFAFAFA)
    ),
    this.viewAllMediaStyle = const ListItemStyle(
      leadingIconColor: Color(0xff181818),
      titleTextStyle: TextStyle(fontWeight: FontWeight.w500,color: Color(0xff181818),fontSize: 14),
      trailingIconColor: Color(0xff767676),
      dividerColor: Color(0xffFAFAFA)
    ),
    this.reportGroupStyle = const ListItemStyle(
      leadingIconColor: Color(0xffFF3939),
      titleTextStyle: TextStyle(fontWeight: FontWeight.w500,color: Color(0xffFF3939),fontSize: 14),
      dividerColor: Color(0xffFAFAFA)
    ),
    this.leaveGroupStyle = const ListItemStyle(
      leadingIconColor: Color(0xffFF3939),
      titleTextStyle: TextStyle(fontWeight: FontWeight.w500,color: Color(0xffFF3939),fontSize: 14),
      dividerColor: Color(0xffFAFAFA)
    ),
});
  final AppBarTheme appBarTheme;
  final TextStyle silverAppbarTitleStyle;
  final TextStyle silverAppBarSubTitleStyle;
  final Color silverAppBarIconColor;
  final MuteNotificationStyle muteNotificationStyle;
  final ContactItemStyle groupMemberStyle;
  final ListItemStyle addParticipantStyle;
  final ListItemStyle viewAllMediaStyle;
  final ListItemStyle reportGroupStyle;
  final ListItemStyle leaveGroupStyle;
}
