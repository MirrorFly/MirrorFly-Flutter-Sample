part of 'stylesheet.dart';

class OTPPageStyle{
  OTPPageStyle({
    this.appBarTheme = const AppBarTheme(titleTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff181818),fontSize: 20),centerTitle: true,
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      iconTheme: IconThemeData(color: Color(0xff181818)),
      actionsIconTheme: IconThemeData(color: Color(0xff181818)),),
    this.bodyTitleStyle = const TextStyle(fontWeight: FontWeight.w300, color: Color(0xff767676),fontSize: 14),
    this.bodyDescriptionStyle = const TextStyle(fontWeight: FontWeight.w500, color: Color(0xff181818),fontSize: 15),
    OTPTextFieldStyle? otpTextFieldStyle,
    this.verifyOtpButtonStyle = const ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(AppColor.primaryColor),
            padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.symmetric(
                horizontal: 40, vertical: 10)),
            shape: WidgetStatePropertyAll(StadiumBorder()),
            textStyle: WidgetStatePropertyAll<TextStyle?>(TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500),)
        )
    ),
    this.changeNumberTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xffFF0000),fontSize: 12),
    this.resendOtpTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff181818),fontSize: 12),
  }): otpTextFieldStyle = otpTextFieldStyle ?? _defaultOtpTextFieldStyle;

  final AppBarTheme appBarTheme;
  final TextStyle bodyTitleStyle;
  final TextStyle bodyDescriptionStyle;
  final OTPTextFieldStyle otpTextFieldStyle;
  final ElevatedButtonThemeData verifyOtpButtonStyle;
  final TextStyle changeNumberTextStyle;
  final TextStyle resendOtpTextStyle;


  static final OTPTextFieldStyle _defaultOtpTextFieldStyle = OTPTextFieldStyle(otpFieldStyle: OtpFieldStyle());
}