part of 'stylesheet.dart';

class LocalContactPageStyle{
  const LocalContactPageStyle({
    this.appBarTheme = const AppBarTheme(backgroundColor: Color(0xffF2F2F2),
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 15),
      toolbarTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818),fontSize: 12),
      iconTheme: IconThemeData(color: Color(0xff181818)),
      actionsIconTheme: IconThemeData(color: Color(0xff181818)),),
    this.searchTextFieldStyle = const EditTextFieldStyle(),
    this.noDataTextStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),
    this.contactItemStyle = const LocalContactItem(profileImageSize: Size(35,35)),
    this.selectedContactItemStyle = const LocalContactItem(profileImageSize: Size(44,44)),
    this.floatingActionButtonThemeData = const FloatingActionButtonThemeData(backgroundColor: AppColor.primaryColor,foregroundColor: Colors.white,elevation: 12,iconSize: 21,shape: CircleBorder())
  });
  final AppBarTheme appBarTheme;
  final EditTextFieldStyle searchTextFieldStyle;
  final TextStyle noDataTextStyle;
  final LocalContactItem contactItemStyle;
  final LocalContactItem selectedContactItemStyle;
  final FloatingActionButtonThemeData floatingActionButtonThemeData;
}
class LocalContactItem{
  const LocalContactItem({
    this.profileImageSize = const Size(35, 35),
    this.titleStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),
    this.dividerColor = const Color(0xffEBEBEB)});

  final Size profileImageSize;
  final TextStyle titleStyle;
  final Color dividerColor;
}