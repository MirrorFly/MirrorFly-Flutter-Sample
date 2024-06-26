part of 'stylesheet.dart';

class LocationSentPageStyle{
  const LocationSentPageStyle({
    this.appBarTheme = const AppBarTheme(backgroundColor: Color(0xffF2F2F2),
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 15),
      toolbarTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818),fontSize: 12),
      iconTheme: IconThemeData(color: Color(0xff181818)),
      actionsIconTheme: IconThemeData(color: Color(0xff181818)),),
    this.titleStyle = const TextStyle(color: AppColor.primaryColor,fontSize: 14,fontWeight: FontWeight.normal),
    this.addressLine1Style = const TextStyle(color: Color(0xff181818),fontSize: 16,fontWeight: FontWeight.w700),
    this.addressLine2Style = const TextStyle(color: Color(0xff767676),fontSize: 14,fontWeight: FontWeight.normal),
    this.floatingActionButtonThemeData = const FloatingActionButtonThemeData(backgroundColor: AppColor.primaryColor,foregroundColor: Colors.white,elevation: 12,iconSize: 21,shape: CircleBorder())
  });
  final AppBarTheme appBarTheme;
  final TextStyle titleStyle;
  final TextStyle addressLine1Style;
  final TextStyle addressLine2Style;
  final FloatingActionButtonThemeData floatingActionButtonThemeData;
}