part of 'stylesheet.dart';

class ChatInfoPageStyle {
  const ChatInfoPageStyle({
    this.appBarTheme = const AppBarTheme(
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff181818),
            fontSize: 20),
        elevation: 0,
        actionsIconTheme: IconThemeData(color: Color(0xff181818))),
    this.silverAppbarTitleStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontSize: 18,
      shadows: [
        Shadow(
          offset: Offset(1, 1), // Shadow position
          blurRadius: 4, // Shadow blur radius
          color: Color(0x7F2E2E2E), // Shadow color
        ),
      ],
    ),
    this.silverAppBarSubTitleStyle = const TextStyle(
      fontWeight: FontWeight.w300,
      color: Colors.white,
      fontSize: 10,
      shadows: [
        Shadow(
          offset: Offset(1, 1), // Shadow position
          blurRadius: 2, // Shadow blur radius
          color: Color(0x7F2E2E2E), // Shadow color
        ),
      ],
    ),
    this.silverAppBarIconColor = Colors.white,
    this.muteNotificationStyle = const MuteNotificationStyle(
        textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xff181818),
            fontSize: 14),
        toggleStyle: ToggleStyle(
          activeColor: Colors.white,
          inactiveColor: Colors.white,
          activeToggleColor: Colors.blue,
          inactiveToggleColor: Colors.grey,
        )),
    this.optionsViewStyle = const ListItemStyle(
        leadingIconColor: Color(0xff181818),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xff181818),
            fontSize: 14),
        descriptionTextStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: Color(0xff767676),
            fontSize: 13),
        dividerColor: Color(0xffFAFAFA)),
    this.viewAllMediaStyle = const ListItemStyle(
        leadingIconColor: Color(0xff181818),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xff181818),
            fontSize: 14),
        trailingIconColor: Color(0xff767676),
        dividerColor: Color(0xffFAFAFA)),
    this.reportUserStyle = const ListItemStyle(
        leadingIconColor: Color(0xffFF3939),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xffFF3939),
            fontSize: 14),
        dividerColor: Color(0xffFAFAFA)),
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

class MuteNotificationStyle {
  const MuteNotificationStyle(
      {this.textStyle = const TextStyle(
          fontWeight: FontWeight.w500, color: Color(0xff181818), fontSize: 14),
      this.toggleStyle = const ToggleStyle(
        activeColor: Colors.white,
        inactiveColor: Colors.white,
        activeToggleColor: Colors.blue,
        inactiveToggleColor: Colors.grey,
      )});
  final TextStyle textStyle;
  final ToggleStyle toggleStyle;
}
