part of 'stylesheet.dart';

class GalleryPageStyle{
  const GalleryPageStyle({
    this.appBarTheme = const AppBarTheme(backgroundColor: Color(0xffF2F2F2),
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 20),
      iconTheme: IconThemeData(color: Color(0xff181818)),
      actionsIconTheme: IconThemeData(color: Color(0xff181818)),),
    this.buttonDecoration = const BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      border: Border.fromBorderSide(BorderSide(color: Colors.blue, width: 1.5)),
    ),
  });
  final AppBarTheme appBarTheme;
  final Decoration buttonDecoration;
}
