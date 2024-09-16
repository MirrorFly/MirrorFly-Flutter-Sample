part of 'stylesheet.dart';

class MediaSentPreviewPageStyle{
  const MediaSentPreviewPageStyle({
    this.appBarTheme = const AppBarTheme(backgroundColor: Colors.black,shadowColor: Colors.black,surfaceTintColor: Colors.black,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),
        elevation: 0,iconTheme: IconThemeData(color: Colors.white),actionsIconTheme: IconThemeData(color: Colors.white)),
    this.chatUserAppBarStyle = const ChatUserAppBarStyle(
        profileImageSize: Size(35, 35),
    ),
    this.scaffoldBackgroundColor = Colors.black,
    this.iconColor = Colors.white,
    this.textFieldStyle = const EditTextFieldStyle(editTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 15),editTextHintStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff7f7f7f),fontSize: 15)),
    this.sentIcon = const FloatingActionButtonThemeData(backgroundColor: AppColor.primaryColor,foregroundColor: Colors.white,elevation: 12,iconSize: 21,shape: CircleBorder()),
    this.nameTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff7f7f7f),fontSize: 13,),
  });
  final AppBarTheme appBarTheme;
  final Color scaffoldBackgroundColor;
  final ChatUserAppBarStyle chatUserAppBarStyle;
  final EditTextFieldStyle textFieldStyle;
  final Color iconColor;
  final FloatingActionButtonThemeData sentIcon;
  final TextStyle nameTextStyle;
}