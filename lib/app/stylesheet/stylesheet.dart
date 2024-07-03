import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

part 'archived_page_style.dart';
part 'chat_info_page_style.dart';
part 'groupchat_info_page_style.dart';
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
part 'message_info_page_style.dart';
part 'blocked_list_page_style.dart';
part 'starred_message_list_page_style.dart';
part 'outgoing_call_page_style.dart';
part 'call_again_page_style.dart';
part 'ongoing_call_page_style.dart';
part 'call_info_page_style.dart';
part 'add_participants_page_style.dart';
part 'dialog_style.dart';
part 'gallery_page_style.dart';
part 'local_contact_page_style.dart';
part 'local_contact_preview_page_style.dart';
part 'location_sent_page_style.dart';
part 'media_sent_preview_page_style.dart';
part 'join_call_preview_page_style.dart';

class AppStyle{

  final LoginPageStyle? loginPageStyle;
  final ProfileViewStyle? profileViewStyle;
  final DashBoardPageStyle? dashBoardPageStyle;
  final ArchivedChatsPageStyle? archivedChatsPageStyle;
  final ChatPageStyle? chatPageStyle;
  final CreateGroupPageStyle? createGroupPageStyle;
  final ChatInfoPageStyle? chatInfoPageStyle;
  final GroupChatInfoPageStyle? groupChatInfoPageStyle;
  final ContactListPageStyle? contactListPageStyle;
  final SettingsPageStyle? settingsPageStyle;
  final ViewAllMediaPageStyle? viewAllMediaPageStyle;
  final MessageInfoPageStyle? messageInfoPageStyle;
  final BlockedListPageStyle? blockedListPageStyle;
  final StarredMessageListPageStyle? starredMessageListPageStyle;
  final OutgoingCallPageStyle? outgoingCallPageStyle;
  final CallAgainPageStyle? callAgainPageStyle;
  final OngoingCallPageStyle? ongoingCallPageStyle;
  final AddParticipantsPageStyle? addParticipantsPageStyle;
  final DialogStyle? dialogStyle;

  AppStyle({
      this.loginPageStyle,
      this.profileViewStyle,
      this.dashBoardPageStyle,
      this.archivedChatsPageStyle,
      this.chatPageStyle,
      this.createGroupPageStyle,
      this.chatInfoPageStyle,
      this.groupChatInfoPageStyle,
      this.contactListPageStyle,
      this.settingsPageStyle,
      this.viewAllMediaPageStyle,
      this.messageInfoPageStyle,
      this.blockedListPageStyle,
      this.starredMessageListPageStyle,
      this.outgoingCallPageStyle,
      this.callAgainPageStyle,
      this.ongoingCallPageStyle,
      this.addParticipantsPageStyle,
      this.dialogStyle
  });
}

class AppColor{
  static const primaryColor = Color(0xff3276E2);
}