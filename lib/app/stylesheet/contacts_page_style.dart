part of 'stylesheet.dart';

class ContactListPageStyle{

  final AppBarTheme appBarTheme;
  final ContactItemStyle contactItemStyle;
  final EditTextFieldStyle searchTextFieldStyle;
  final TextStyle actionTextStyle;
  final TextStyle noDataTextStyle;

  const ContactListPageStyle({
    this.appBarTheme = const AppBarTheme(backgroundColor: Colors.white,shadowColor: Colors.white,surfaceTintColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xff181818)),
        actionsIconTheme: IconThemeData(color: Color(0xff181818))),
    this.searchTextFieldStyle = const EditTextFieldStyle(),
    this.actionTextStyle = const TextStyle(color: Colors.black),
    this.contactItemStyle = const ContactItemStyle(
      profileImageSize: Size(50, 50),
      titleStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),
      descriptionStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 12),
      dividerColor: Color(0xffEBEBEB)
    ),
    this.noDataTextStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff767676),fontSize: 14),
  });

}

class ContactItemStyle{
  final Size profileImageSize;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final TextStyle actionTextStyle;
  final Color spanTextColor;
  final Color dividerColor;
  final OutlinedBorder checkBoxShape;

  const ContactItemStyle({
    this.profileImageSize = const Size(50, 50),
    this.titleStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 14),
    this.descriptionStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff767676),fontSize: 12),
    this.actionTextStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff4879F9),fontSize: 12),
    this.spanTextColor = const Color(0xff4879F9),
    this.dividerColor = const Color(0xffEBEBEB),
    this.checkBoxShape = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2)), side: BorderSide(color: Color(0xffbdbdbd)))
  });
}

