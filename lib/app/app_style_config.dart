import 'package:flutter/material.dart';

import 'stylesheet/stylesheet.dart';

class AppStyleConfig{

  static LoginPageStyle _loginPageStyle = LoginPageStyle(loginButtonStyle: ButtonStyle(
    padding: WidgetStateProperty.resolveWith((states) => const EdgeInsets.symmetric(horizontal: 40, vertical: 10)),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey; // Color when the button is disabled
        }
        return const Color(0xff3276E2); // Default color
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.white.withOpacity(0.5); // Text color when the button is disabled
        }
        return Colors.white; // Default text color
      }),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w500); // Default text style
      })));
  static ProfileViewStyle _profileViewStyle = ProfileViewStyle(buttonStyle: ButtonStyle(
    padding: WidgetStateProperty.resolveWith((states) => const EdgeInsets.symmetric(horizontal: 55, vertical: 15)),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey; // Color when the button is disabled
        }
        return const Color(0xff3276E2); // Default color
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.white.withOpacity(0.5); // Text color when the button is disabled
        }
        return Colors.white; // Default text color
      }),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return TextStyle(color: Colors.white.withOpacity(0.5)); // Text color when the button is disabled
        }
        return const TextStyle(color: Colors.white); // Default text color
      })));
  static DashBoardPageStyle _dashBoardPageStyle = const DashBoardPageStyle();
  static ChatPageStyle _chatPageStyle = const ChatPageStyle();
  static CreateGroupPageStyle _createGroupPageStyle = const CreateGroupPageStyle();
  static ChatInfoPageStyle _chatInfoPageStyle = const ChatInfoPageStyle();
  static GroupChatInfoPageStyle _groupChatInfoPageStyle = const GroupChatInfoPageStyle();
  static ContactListPageStyle _contactListPageStyle = const ContactListPageStyle();
  static SettingsPageStyle _settingsPageStyle = const SettingsPageStyle();

  static LoginPageStyle loginPageStyle = _loginPageStyle;
  static ProfileViewStyle profileViewStyle = _profileViewStyle;
  static DashBoardPageStyle dashBoardPageStyle = _dashBoardPageStyle;
  static ChatPageStyle chatPageStyle = _chatPageStyle;
  static CreateGroupPageStyle createGroupPageStyle = _createGroupPageStyle;
  static ChatInfoPageStyle chatInfoPageStyle = _chatInfoPageStyle;
  static GroupChatInfoPageStyle groupChatInfoPageStyle = _groupChatInfoPageStyle;
  static ContactListPageStyle contactListPageStyle= _contactListPageStyle;
  static SettingsPageStyle settingsPageStyle= _settingsPageStyle;

  static setLoginPageStyle(LoginPageStyle loginPageStyle){
    _loginPageStyle = loginPageStyle;
  }

  static setCreateGroupPageStyle(CreateGroupPageStyle createGroupPageStyle){
    _createGroupPageStyle = createGroupPageStyle;
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

  static setGroupChatInfoPageStyle(GroupChatInfoPageStyle groupChatInfoPageStyle){
    _groupChatInfoPageStyle = groupChatInfoPageStyle;
  }

  static setContactListPageStyle(ContactListPageStyle contactListPageStyle){
    _contactListPageStyle = contactListPageStyle;
  }

  static setSettingsPageStyle(SettingsPageStyle settingsPageStyle){
    _settingsPageStyle = settingsPageStyle;
  }

}