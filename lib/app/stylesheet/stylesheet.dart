import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

part 'archived_page_style.dart';
part 'chat_info_page_style.dart';
part 'chat_page_style.dart';
part 'contacts_page_style.dart';
part 'custom_styles.dart';
part 'dashboard_page_style.dart';
part 'login_page_style.dart';
part 'message_view_styles.dart';
part 'otp_page_style.dart';
part 'profile_view_style.dart';
part 'settings_page_style.dart';
part 'view_all_media_page_style.dart';
part 'create_group_page_style.dart';

class AppStyle{

  final LoginPageStyle loginPageStyle;
  final OTPPageStyle otpPageStyle;
  final DashBoardPageStyle dashBoardPageStyle;
  final ArchivedChatsPageStyle archivedChatsPageStyle;
  final ChatPageStyle chatPageStyle;
  final ChatInfoPageStyle chatInfoPageStyle;
  final ViewAllMediaPageStyle viewAllMediaPageStyle;

  const AppStyle({required this.loginPageStyle, required this.otpPageStyle, required this.dashBoardPageStyle, required this.archivedChatsPageStyle, required this.chatPageStyle, required this.chatInfoPageStyle, required this.viewAllMediaPageStyle});
}