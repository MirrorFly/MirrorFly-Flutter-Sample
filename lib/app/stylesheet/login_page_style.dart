// Part of the 'stylesheet.dart' file
part of 'stylesheet.dart';

// This class defines the styles for the login page.
class LoginPageStyle{
  // Constructor for the LoginPageStyle class
  // It initializes all the styles with default values
  const LoginPageStyle({
    // Style for the AppBar text
    this.appBarTextStyle = const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff181818),fontSize: 20),
    // Style for the body title text
    this.bodyTitleStyle = const TextStyle(fontWeight: FontWeight.w500, color: Color(0xff181818),fontSize: 15),
    // Style for the body description text
    this.bodyDescriptionStyle = const TextStyle(fontWeight: FontWeight.w300, color: Color(0xff767676),fontSize: 14),
    // Style for the selected country text
    this.selectedCountryTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff181818),fontSize: 15),
    // Style for the selected country code text
    this.selectedCountryCodeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff181818),fontSize: 15),
    // Style for the edit text field
    this.editTextFieldStyle =  const EditTextFieldStyle(editTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818),fontSize: 14),editTextHintStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff959595),fontSize: 12)),
    // Style for the footer headline text
    this.footerHeadlineStyle = const TextStyle(fontWeight: FontWeight.w300, color: Color(0xff767676),fontSize: 11),
    // Style for the terms text
    this.termsTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: AppColor.primaryColor,fontSize: 11),
    // Style for the login button
    this.loginButtonStyle = const ButtonStyle(),
  });

  // AppBar text style
  final TextStyle appBarTextStyle;
  // Body title text style
  final TextStyle bodyTitleStyle;
  // Body description text style
  final TextStyle bodyDescriptionStyle;
  // Selected country text style
  final TextStyle selectedCountryTextStyle;
  // Selected country code text style
  final TextStyle selectedCountryCodeTextStyle;
  // Edit text field style
  final EditTextFieldStyle editTextFieldStyle;
  // Footer headline text style
  final TextStyle footerHeadlineStyle;
  // Terms text style
  final TextStyle termsTextStyle;
  // Login button style
  final ButtonStyle loginButtonStyle;
}