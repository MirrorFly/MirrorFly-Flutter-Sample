import 'package:flutter/material.dart';

import 'constants.dart';

class MirrorFlyAppTheme {
  static ThemeData theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff3276E2)),
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(),
    ),
    appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xffF2F2F2),
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xff181818)),
        titleTextStyle: TextStyle(
            color: Color(0xff181818),
            fontSize: 20,
            fontWeight: FontWeight.bold)),
    hintColor: Colors.black26,
    fontFamily: 'sf_ui',
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: buttonBgColor),
    dialogTheme: const DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey; // Color when the button is disabled
          }
          return const Color(0xff3276E2); // Default color
        }),
        foregroundColor:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.white
                .withOpacity(0.5); // Text color when the button is disabled
          }
          return Colors.white; // Default text color
        }),
        textStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return TextStyle(
                color: Colors.white.withOpacity(
                    0.5)); // Text color when the button is disabled
          }
          return const TextStyle(color: Colors.white); // Default text color
        }),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 55, vertical: 15)),
        shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
      ),
      /*ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff3276E2),
        disabledBackgroundColor: Colors.grey,
        textStyle: const TextStyle(color: Colors.white, fontSize: 14,fontWeight: FontWeight.w600),
        shape: const StadiumBorder())*/
    ),
    /*textTheme: const TextTheme(
      labelLarge: TextStyle(color: Colors.white),
      titleLarge: TextStyle(
          fontSize: 14.0, fontWeight: FontWeight.bold, fontFamily: 'sf_ui'),
      titleMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        fontFamily: 'sf_ui',
        // color: textHintColor
      ),
      titleSmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'sf_ui',
          color: textColor
      ),
    ),*/
  );

  static ThemeData light = ThemeData(
      brightness: Brightness.light,
      fontFamily: 'sf_ui',
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: CircleBorder(),
      ),
      appBarTheme: const AppBarTheme(
          color: appBarColor,
          iconTheme: IconThemeData(color: iconColor),
          titleTextStyle: TextStyle(
              color: appbarTextColor,
              fontSize: 20,
              fontWeight: FontWeight.w700)),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 20, color: Color(0xff181818)),
        displayMedium: TextStyle(fontSize: 19, color: Color(0xff181818)),
        displaySmall: TextStyle(fontSize: 18, color: Color(0xff181818)),
        headlineLarge: TextStyle(fontSize: 17, color: Color(0xff181818)),
        headlineMedium: TextStyle(fontSize: 16, color: Color(0xff181818)),
        headlineSmall: TextStyle(fontSize: 15, color: Color(0xff181818)),
        titleLarge: TextStyle(fontSize: 14, color: Color(0xff181818)), //black
        titleMedium: TextStyle(fontSize: 13, color: Color(0xff181818)),
        titleSmall: TextStyle(fontSize: 12, color: Color(0xff181818)), //gray
        bodyLarge: TextStyle(fontSize: 11, color: Color(0xff181818)),
        bodyMedium: TextStyle(fontSize: 10, color: Color(0xff181818)),
        bodySmall: TextStyle(fontSize: 9, color: Color(0xff181818)),
        labelMedium: TextStyle(fontSize: 8, color: Color(0xff181818)),
        labelSmall: TextStyle(fontSize: 7, color: Color(0xff181818)),
      ));
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
