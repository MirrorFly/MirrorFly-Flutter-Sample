part of 'stylesheet.dart';

class LocalContactPreviewPageStyle{
  const LocalContactPreviewPageStyle({
    this.appBarTheme = const AppBarTheme(backgroundColor: Color(0xffF2F2F2),
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 15),
      toolbarTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818),fontSize: 12),
      iconTheme: IconThemeData(color: Color(0xff181818)),
      actionsIconTheme: IconThemeData(color: Color(0xff181818)),),
    this.contactItemStyle = const LocalContactItem(profileImageSize: Size(40,40)),
    this.listItemStyle = const ListItemStyle(leadingIconColor: Colors.blue,titleTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818),fontSize: 13),descriptionTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818),fontSize: 12),trailingIconColor: Colors.green,),
    this.floatingActionButtonThemeData = const FloatingActionButtonThemeData(backgroundColor: AppColor.primaryColor,foregroundColor: Colors.white,elevation: 12,iconSize: 21,shape: CircleBorder())
  });
  final AppBarTheme appBarTheme;
  final LocalContactItem contactItemStyle;
  final FloatingActionButtonThemeData floatingActionButtonThemeData;
  final ListItemStyle listItemStyle;
}