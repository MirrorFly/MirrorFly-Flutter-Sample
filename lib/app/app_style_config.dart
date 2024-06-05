import 'stylesheet/stylesheet.dart';

class AppStyleConfig{

  static LoginPageStyle _loginPageStyle = const LoginPageStyle();
  static DashBoardPageStyle _dashBoardPageStyle = const DashBoardPageStyle();
  static ChatPageStyle _chatPageStyle = const ChatPageStyle();
  static ChatInfoPageStyle _chatInfoPageStyle = ChatInfoPageStyle();
  static ContactListPageStyle _contactListPageStyle = ContactListPageStyle();

  static LoginPageStyle loginPageStyle = _loginPageStyle;
  static DashBoardPageStyle dashBoardPageStyle = _dashBoardPageStyle;
  static ChatPageStyle chatPageStyle = _chatPageStyle;
  static ChatInfoPageStyle chatInfoPageStyle = _chatInfoPageStyle;
  static ContactListPageStyle contactListPageStyle= _contactListPageStyle;

  static setLoginPageStyle(LoginPageStyle loginPageStyle){
    _loginPageStyle = loginPageStyle;
  }

  static setDashboardStyle(DashBoardPageStyle dashBoardPageStyle){
    _dashBoardPageStyle = dashBoardPageStyle;
  }

  static setChatPageStyle(ChatPageStyle chatPageStyle){
    _chatPageStyle = chatPageStyle;
  }

  static setChatInfoPageStyle(ChatInfoPageStyle chatInfoPageStyle){
    _chatInfoPageStyle = chatInfoPageStyle;
  }

  static setContactListPageStyle(ContactListPageStyle contactListPageStyle){
    _contactListPageStyle = contactListPageStyle;
  }

}