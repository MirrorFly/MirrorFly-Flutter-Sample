part of 'stylesheet.dart';

class ProfileViewStyle{
  final AppBarTheme appBarTheme;
  final Size profileImageSize;
  final IconStyle cameraIconStyle;
  final EditTextFieldStyle nameTextFieldStyle;
  final EditTextFieldStyle emailTextFieldStyle;
  final EditTextFieldStyle mobileTextFieldStyle;
  final EditTextFieldStyle statusTextFieldStyle;
  final ElevatedButtonThemeData buttonStyle;
  final CardTheme bottomSheetCardTheme;
  final TextStyle optionStyle;
  final TextStyle optionsTextStyle;

  const ProfileViewStyle({
    this.appBarTheme = const AppBarTheme(backgroundColor: Color(0xffF2F2F2),
      centerTitle: true,
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 18),
      iconTheme: IconThemeData(color: Color(0xff181818)),
      actionsIconTheme: IconThemeData(color: Color(0xff181818)),),
    this.profileImageSize = const Size(144, 144), 
    this.cameraIconStyle = const IconStyle(iconColor: Colors.white,bgColor: Color(0xff2C2C2C),borderColor: Colors.white),
    this.nameTextFieldStyle = const EditTextFieldStyle(titleStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818)),editTextHintStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),editTextStyle: TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 16)),
    this.emailTextFieldStyle = const EditTextFieldStyle(titleStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818)),editTextHintStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),editTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 13)),
    this.mobileTextFieldStyle = const EditTextFieldStyle(titleStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818)),editTextHintStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),editTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 13)),
    this.statusTextFieldStyle = const EditTextFieldStyle(titleStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818)),editTextHintStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),editTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 13)),
    this.buttonStyle = const ElevatedButtonThemeData(),
  this.bottomSheetCardTheme = const CardTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
  ),
  this.optionStyle = const TextStyle(),
  this.optionsTextStyle = const TextStyle(fontWeight: FontWeight.bold,color: Color(0xff767676), fontSize: 14),
  });

}
