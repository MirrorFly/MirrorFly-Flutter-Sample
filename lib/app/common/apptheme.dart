import 'package:flutter/material.dart';
import 'constants.dart';

class apptheme {
  static ThemeData theme = ThemeData(
    appBarTheme: const AppBarTheme(
        color: appbarcolor,
        iconTheme: IconThemeData(color: iconcolor),
        titleTextStyle: TextStyle(
            color: appbartextcolor,
            fontSize: 20,
            fontWeight: FontWeight.normal,
            fontFamily: 'sf_ui')),
    hintColor: Colors.black26,
    fontFamily: 'sf_ui',
    textTheme: const TextTheme(
      titleLarge: TextStyle(
          fontSize: 14.0, fontWeight: FontWeight.bold, fontFamily: 'sf_ui'),
      titleMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
          fontFamily: 'sf_ui',
          color: texthintcolor),
      titleSmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'sf_ui',
          color: textcolor),
    ),
  );
}
