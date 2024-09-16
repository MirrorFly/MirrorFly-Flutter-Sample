part of 'stylesheet.dart';

class ContactListPageStyle{

  final AppBarTheme appBarTheme;
  final ContactItemStyle contactItemStyle;
  final EditTextFieldStyle searchTextFieldStyle;
  final TextStyle actionTextStyle;
  final TextStyle noDataTextStyle;
  final Decoration buttonDecoration;
  final TextStyle buttonTextStyle;
  final Color buttonIconColor;
  final PopupMenuThemeData popupMenuThemeData;

  const ContactListPageStyle({
    this.appBarTheme = const AppBarTheme(backgroundColor: Colors.white,shadowColor: Colors.white,surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 20),
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
    this.buttonDecoration = const BoxDecoration(
        color: AppColor.primaryColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2), topRight: Radius.circular(2))
    ),
    this.buttonTextStyle = const TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 14, ),
    this.buttonIconColor = Colors.white,
    this.popupMenuThemeData = const PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.white,
        textStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 15),
        shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xffE8E8E8),width: 1)),
        iconColor: Color(0xff181818)
    ),
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

