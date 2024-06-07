part of 'stylesheet.dart';

class GroupChatInfoPageStyle{
  const GroupChatInfoPageStyle({
    this.appBarTheme = const AppBarTheme(backgroundColor: Colors.white,shadowColor: Colors.white,surfaceTintColor: Colors.white,
        elevation: 0,actionsIconTheme: IconThemeData(color: Color(0xff181818))),
    this.silverAppbarTitleStyle = const TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),
    this.silverAppBarSubTitleStyle = const TextStyle(fontWeight: FontWeight.w300,color: Colors.white,fontSize: 10),
    this.silverAppBarIconColor = Colors.white,
    this.muteNotificationStyle = const MuteNotificationStyle(textStyle: TextStyle(fontWeight: FontWeight.w500,color: Color(0xff181818),fontSize: 14),
        activeColor: Colors.white,
        inactiveColor: Colors.white,
        activeToggleColor: Colors.blue,
        inactiveToggleColor: Colors.grey,),
    this.optionsViewStyle = const OptionsViewStyle(titleStyle: TextStyle(fontWeight: FontWeight.w500,color: Color(0xff181818),fontSize: 14),contentStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 13)),
    this.dividerColor = Colors.grey,
    this.groupMemberStyle = const ContactItemStyle(
        titleStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),
        descriptionStyle:TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 12),
        actionTextStyle:TextStyle(fontWeight: FontWeight.w600,color: Color(0xff4879F9),fontSize: 12))
});
  final AppBarTheme appBarTheme;
  final TextStyle silverAppbarTitleStyle;
  final TextStyle silverAppBarSubTitleStyle;
  final Color silverAppBarIconColor;
  final MuteNotificationStyle muteNotificationStyle;
  final OptionsViewStyle optionsViewStyle;
  final Color dividerColor;
  final ContactItemStyle groupMemberStyle;
}
