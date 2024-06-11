part of 'stylesheet.dart';

class LoginPageStyle{
  const LoginPageStyle({
    this.appBarTextStyle = const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff181818),fontSize: 20),
    this.bodyTitleStyle = const TextStyle(fontWeight: FontWeight.w300, color: Color(0xff767676),fontSize: 14),
    this.bodyDescriptionStyle = const TextStyle(fontWeight: FontWeight.w500, color: Color(0xff181818),fontSize: 15),
    this.selectedCountryTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff181818),fontSize: 15),
    this.selectedCountryCodeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff181818),fontSize: 15),
    this.editTextFieldStyle =  const EditTextFieldStyle(editTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818),fontSize: 14),editTextHintStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff959595),fontSize: 12)),
    this.footerHeadlineStyle = const TextStyle(fontWeight: FontWeight.w300, color: Color(0xff767676),fontSize: 11),
    this.termsTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: AppColor.primaryColor,fontSize: 11),
    this.loginButtonStyle = const ButtonStyle(),
  });

  final TextStyle appBarTextStyle;
  final TextStyle bodyTitleStyle;
  final TextStyle bodyDescriptionStyle;
  final TextStyle selectedCountryTextStyle;
  final TextStyle selectedCountryCodeTextStyle;
  final EditTextFieldStyle editTextFieldStyle;
  final TextStyle footerHeadlineStyle;
  final TextStyle termsTextStyle;
  final ButtonStyle loginButtonStyle;

}
