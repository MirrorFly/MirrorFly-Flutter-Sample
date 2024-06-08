part of 'stylesheet.dart';

class ChatInfoPageStyle{
  const ChatInfoPageStyle({
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
    this.optionsViewStyle = const ListItemStyle(
      leadingIconColor: Color(0xff181818),
        titleTextStyle: TextStyle(fontWeight: FontWeight.w500,color: Color(0xff181818),fontSize: 14),
        descriptionTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 13), dividerColor: Color(0xffFAFAFA)),
    this.viewAllMediaStyle = const ListItemStyle(
        leadingIconColor: Color(0xff181818),
        titleTextStyle: TextStyle(fontWeight: FontWeight.w500,color: Color(0xff181818),fontSize: 14),
        trailingIconColor: Color(0xff767676),
        dividerColor: Color(0xffFAFAFA)
    ),
    this.reportUserStyle = const ListItemStyle(
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
  final ListItemStyle optionsViewStyle;
  final ListItemStyle viewAllMediaStyle;
  final ListItemStyle reportUserStyle;

}

class MuteNotificationStyle{
  const MuteNotificationStyle({
    this.textStyle = const TextStyle(fontWeight: FontWeight.w500,color: Color(0xff181818),fontSize: 14),
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white,
    this.activeToggleColor = Colors.blue,
    this.inactiveToggleColor = Colors.grey,
  });
  final TextStyle textStyle;

  /// The color to use on the toggle of the switch when the given value is true.
  ///
  /// If [inactiveToggleColor] is used and this property is null. the value of
  /// [Colors.white] will be used.
  final Color activeToggleColor;

  /// The color to use on the toggle of the switch when the given value is false.
  ///
  /// If [activeToggleColor] is used and this property is null. the value of
  /// [Colors.white] will be used.
  final Color inactiveToggleColor;
  /// The color to use on the switch when the switch is on.
  ///
  /// Defaults to [Colors.blue].
  final Color activeColor;

  /// The color to use on the switch when the switch is off.
  ///
  /// Defaults to [Colors.grey].
  final Color inactiveColor;
}

