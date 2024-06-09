part of 'stylesheet.dart';

class SettingsPageStyle{
  const SettingsPageStyle({
    this.appBarTheme = const AppBarTheme(backgroundColor: Color(0xffF2F2F2),
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 20),
      iconTheme: IconThemeData(color: Color(0xff181818)),
      actionsIconTheme: IconThemeData(color: Color(0xff181818)),),
    this.listItemStyle = const ListItemStyle(
      titleTextStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 15),
      leadingIconColor: Color(0xff181818),
      trailingIconColor: Color(0xff767676),
      dividerColor: Color(0xffEBEBEB)
    )
});
  final AppBarTheme appBarTheme;
  final ListItemStyle listItemStyle;
}

class ListItemStyle{
  const ListItemStyle({
    this.titleTextStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 15),
    this.descriptionTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 12),
    this.leadingIconColor = const Color(0xff181818),
    this.trailingIconColor = const Color(0xff767676),
    this.dividerColor = const Color(0xffEBEBEB)
});
  final TextStyle titleTextStyle;
  final TextStyle descriptionTextStyle;
  final Color leadingIconColor;
  final Color trailingIconColor;
  final Color dividerColor;
}