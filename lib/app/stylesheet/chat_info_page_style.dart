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
    this.optionsViewStyle = const OptionsViewStyle(titleStyle: TextStyle(fontWeight: FontWeight.w500,color: Color(0xff181818),fontSize: 14),contentStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 13)),
    this.dividerColor = Colors.grey
});
  final AppBarTheme appBarTheme;
  final TextStyle silverAppbarTitleStyle;
  final TextStyle silverAppBarSubTitleStyle;
  final Color silverAppBarIconColor;
  final MuteNotificationStyle muteNotificationStyle;
  final OptionsViewStyle optionsViewStyle;
  final Color dividerColor;
}

class OptionsViewStyle{
  const OptionsViewStyle({
    this.titleStyle = const TextStyle(fontWeight: FontWeight.w500,color: Color(0xff181818),fontSize: 14),
    this.contentStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 13),
  });
  final TextStyle titleStyle;
  final TextStyle contentStyle;

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

