part of 'stylesheet.dart';

class OTPPageStyle{
  OTPPageStyle({
    this.appBarTheme = const AppBarTheme(titleTextStyle: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff181818),fontSize: 20),centerTitle: true),
    this.bodyTitleStyle = const TextStyle(fontWeight: FontWeight.w300, color: Color(0xff767676),fontSize: 14),
    this.bodyDescriptionStyle = const TextStyle(fontWeight: FontWeight.w500, color: Color(0xff181818),fontSize: 15),
    OTPTextFieldStyle? otpTextFieldStyle,
    ElevatedButtonThemeData? verifyOtpButtonStyle,
    this.changeNumberTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xffFF0000),fontSize: 12),
    this.resendOtpTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff181818),fontSize: 12),
  }) : verifyOtpButtonStyle = verifyOtpButtonStyle ?? _defaultLoginButtonStyle , otpTextFieldStyle = otpTextFieldStyle ?? _defaultOtpTextFieldStyle;

  final AppBarTheme appBarTheme;
  final TextStyle bodyTitleStyle;
  final TextStyle bodyDescriptionStyle;
  final OTPTextFieldStyle otpTextFieldStyle;
  final ElevatedButtonThemeData verifyOtpButtonStyle;
  final TextStyle changeNumberTextStyle;
  final TextStyle resendOtpTextStyle;

  static final ElevatedButtonThemeData _defaultLoginButtonStyle = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff3276E2),
        padding: const EdgeInsets.symmetric(
            horizontal: 40, vertical: 10),
        textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500),
        shape: const StadiumBorder()),
  );

  static final OTPTextFieldStyle _defaultOtpTextFieldStyle = OTPTextFieldStyle(otpFieldStyle: OtpFieldStyle());
}