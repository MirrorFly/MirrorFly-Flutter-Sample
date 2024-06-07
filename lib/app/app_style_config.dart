import 'package:flutter/material.dart';

import 'stylesheet/stylesheet.dart';

class AppStyleConfig{

  static LoginPageStyle _loginPageStyle = LoginPageStyle(loginButtonStyle: ButtonStyle(
    padding: MaterialStateProperty.resolveWith((states) => const EdgeInsets.symmetric(horizontal: 40, vertical: 10)),
      backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey; // Color when the button is disabled
        }
        return const Color(0xff3276E2); // Default color
      }),
      foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.white.withOpacity(0.5); // Text color when the button is disabled
        }
        return Colors.white; // Default text color
      }),
      textStyle: MaterialStateProperty.resolveWith<TextStyle>((Set<MaterialState> states) {
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w500); // Default text style
      })));
  static ProfileViewStyle _profileViewStyle = ProfileViewStyle(buttonStyle: ButtonStyle(
    padding: MaterialStateProperty.resolveWith((states) => const EdgeInsets.symmetric(horizontal: 55, vertical: 15)),
      backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey; // Color when the button is disabled
        }
        return const Color(0xff3276E2); // Default color
      }),
      foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.white.withOpacity(0.5); // Text color when the button is disabled
        }
        return Colors.white; // Default text color
      }),
      textStyle: MaterialStateProperty.resolveWith<TextStyle>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return TextStyle(color: Colors.white.withOpacity(0.5)); // Text color when the button is disabled
        }
        return const TextStyle(color: Colors.white); // Default text color
      })));
  static DashBoardPageStyle _dashBoardPageStyle = const DashBoardPageStyle();
  static ChatPageStyle _chatPageStyle = const ChatPageStyle();
  static ChatInfoPageStyle _chatInfoPageStyle = const ChatInfoPageStyle();
  static ContactListPageStyle _contactListPageStyle = const ContactListPageStyle();

  static LoginPageStyle loginPageStyle = _loginPageStyle;
  static ProfileViewStyle profileViewStyle = _profileViewStyle;
  static DashBoardPageStyle dashBoardPageStyle = _dashBoardPageStyle;
  static ChatPageStyle chatPageStyle = _chatPageStyle;
  static ChatInfoPageStyle chatInfoPageStyle = _chatInfoPageStyle;
  static ContactListPageStyle contactListPageStyle= _contactListPageStyle;

  static setLoginPageStyle(LoginPageStyle loginPageStyle){
    _loginPageStyle = loginPageStyle;
  }

  static setProfileViewStyle(ProfileViewStyle profileViewStyle){
    _profileViewStyle = profileViewStyle;
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