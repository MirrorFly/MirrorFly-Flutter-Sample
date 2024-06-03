part of 'stylesheet.dart';

class ChatInfoPageStyle{
  const ChatInfoPageStyle({
    this.appBarTheme = const AppBarTheme(),
    this.appBarTitleStyle = const TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),
    this.appBarSubTitleStyle = const TextStyle(fontWeight: FontWeight.w300,color: Colors.white,fontSize: 10),
    this.muteNotificationStyle = const MuteNotificationStyle(textStyle: TextStyle(fontWeight: FontWeight.w500,color: Color(0xff181818),fontSize: 14),
    activeColor: Colors.white,
    inactiveColor: Colors.white,
    activeToggleColor: Colors.blue,
    inactiveToggleColor: Colors.blue,
    switchBorder: Border.fromBorderSide(BorderSide(
        color: Colors.grey,
        width: 1))),
    this.optionsViewStyle = const OptionsViewStyle(titleStyle: TextStyle(fontWeight: FontWeight.w500,color: Color(0xff181818),fontSize: 14),contentStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 13)),
    this.dividerColor = Colors.grey
});
  final AppBarTheme appBarTheme;
  final TextStyle appBarTitleStyle;
  final TextStyle appBarSubTitleStyle;
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
    this.switchBorder = const Border.fromBorderSide(BorderSide(
        color: Colors.grey,
        width: 1)),
  });
  final TextStyle textStyle;

  /// The color to use on the toggle of the switch when the given value is true.
  ///
  /// If [inactiveToggleColor] is used and this property is null. the value of
  /// [Colors.white] will be used.
  final Color? activeToggleColor;

  /// The color to use on the toggle of the switch when the given value is false.
  ///
  /// If [activeToggleColor] is used and this property is null. the value of
  /// [Colors.white] will be used.
  final Color? inactiveToggleColor;
  /// The color to use on the switch when the switch is on.
  ///
  /// Defaults to [Colors.blue].
  final Color activeColor;

  /// The color to use on the switch when the switch is off.
  ///
  /// Defaults to [Colors.grey].
  final Color inactiveColor;

  /// The border of the switch.
  ///
  /// This property will give a uniform border to both states of the toggle
  ///
  /// If the [activeSwitchBorder] or [inactiveSwitchBorder] is used, this property must be null.
  final BoxBorder? switchBorder;
}

