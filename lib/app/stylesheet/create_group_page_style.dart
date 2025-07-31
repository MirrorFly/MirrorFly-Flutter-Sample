part of 'stylesheet.dart';

class CreateGroupPageStyle {
  final AppBarTheme appbarTheme;
  final TextStyle actionTextStyle;
  final Size profileImageSize;
  final IconStyle cameraIconStyle;
  final EditTextFieldStyle nameTextFieldStyle;
  final TextStyle counterTextStyle;
  final Color emojiColor;

  const CreateGroupPageStyle({
    this.appbarTheme = const AppBarTheme(
      backgroundColor: Color(0xffF2F2F2),
      centerTitle: true,
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold, color: Color(0xff181818), fontSize: 20),
      iconTheme: IconThemeData(color: Color(0xff181818)),
      actionsIconTheme: IconThemeData(color: Color(0xff181818)),
    ),
    this.actionTextStyle = const TextStyle(
        fontWeight: FontWeight.normal, color: Color(0xff181818), fontSize: 18),
    this.profileImageSize = const Size(144, 144),
    this.cameraIconStyle = const IconStyle(
        iconColor: Colors.white,
        bgColor: Color(0xff2C2C2C),
        borderColor: Colors.white),
    this.nameTextFieldStyle = const EditTextFieldStyle(
        titleStyle:
            TextStyle(fontWeight: FontWeight.normal, color: Color(0xff181818)),
        editTextHintStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xff181818),
            fontSize: 14),
        editTextStyle: TextStyle(
            fontWeight: FontWeight.w600, color: Colors.black, fontSize: 16)),
    this.emojiColor = Colors.black,
    this.counterTextStyle = const TextStyle(
      fontWeight: FontWeight.normal,
      color: Color(0xff181818),
      fontSize: 14,
    ),
  });
}
