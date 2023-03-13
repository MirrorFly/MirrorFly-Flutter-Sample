import 'package:flutter/material.dart';
import 'constants.dart';

class MirrorFlyAppTheme {
  static ThemeData theme = ThemeData(
    appBarTheme: const AppBarTheme(
        color: appBarColor,
        iconTheme: IconThemeData(color: iconColor),
        titleTextStyle: TextStyle(
            color: appbarTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
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
          color: textHintColor),
      titleSmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'sf_ui',
          color: textColor),
    ),
  );
}
class CustomSafeArea extends StatelessWidget {
  final Widget child;
  final Color? color;

  const CustomSafeArea({Key? key, required this.child, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? appBarColor,
      child: SafeArea(
        child: child,
      ),
    );
  }
}