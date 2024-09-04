import 'package:flutter/material.dart';

import 'stylesheet/stylesheet.dart';

class AppStyleConfig{

  static final ButtonStyle _defaultButtonStyle = ButtonStyle(
      shape: WidgetStateProperty.resolveWith((states) => const StadiumBorder()),
      padding: WidgetStateProperty.resolveWith((states) => const EdgeInsets.symmetric(horizontal: 40, vertical: 10)),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey; // Color when the button is disabled
        }
        return AppColor.primaryColor; // Default color
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.white.withOpacity(0.5); // Text color when the button is disabled
        }
        return Colors.white; // Default text color
      }),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w500); // Default text style
      }));

  static final ButtonStyle _defaultDialogButtonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        return Colors.transparent; // Default color
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        return const Color(0xff3276E2); // Default text color
      }),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
        return const TextStyle(fontSize: 14,color: Color(0xff3276E2), fontWeight: FontWeight.w600); // Default text style
      }));

  static final ButtonStyle _disconnectButtonStyle = ButtonStyle(
        shape: WidgetStateProperty.resolveWith((states) => const StadiumBorder()),
    padding: WidgetStateProperty.resolveWith((states) => EdgeInsets.zero),
    backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey; // Color when the button is disabled
      }
      return const Color(0xffff4d67); // Default color
    }),
    iconColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.withOpacity(0.5); // Color when the icon is disabled
      }
      return Colors.white; // Default color
    }),maximumSize: WidgetStateProperty.resolveWith<Size>((Set<WidgetState> states) => const Size(200, 50))
  );

  static final ButtonStyle _joinCallButtonStyle = ButtonStyle(
        shape: WidgetStateProperty.resolveWith((states) => const StadiumBorder()),
      padding: WidgetStateProperty.resolveWith((states) => const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
    backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey; // Color when the button is disabled
      }
      return const Color(0xff3276E2); // Default color
    }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.withOpacity(0.5); // Color when the icon is disabled
        }
        return Colors.white;
      }),
    iconColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.withOpacity(0.5); // Color when the icon is disabled
      }
      return Colors.white; // Default color
    }),maximumSize: WidgetStateProperty.resolveWith<Size>((Set<WidgetState> states) => const Size(200, 50)),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600); // Default text style
      })
  );

  static final ButtonStyle _joinMeetButtonStyle = ButtonStyle(
        shape: WidgetStateProperty.resolveWith((states) => const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30)))),
      padding: WidgetStateProperty.resolveWith((states) => const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
    backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey; // Color when the button is disabled
      }
      return const Color(0xff3276E2); // Default color
    }),

      foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.withOpacity(0.5); // Color when the icon is disabled
        }
        return Colors.white;
      }),
    iconColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.withOpacity(0.5); // Color when the icon is disabled
      }
      return Colors.white; // Default color
    }),maximumSize: WidgetStateProperty.resolveWith<Size>((Set<WidgetState> states) => const Size(200, 50)),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600); // Default text style
      })
  );

  static LoginPageStyle _loginPageStyle = LoginPageStyle(loginButtonStyle: _defaultButtonStyle);
  static ProfileViewStyle _profileViewStyle = ProfileViewStyle(buttonStyle: _defaultButtonStyle);
  static DashBoardPageStyle _dashBoardPageStyle = DashBoardPageStyle(meetBottomSheetStyle: MeetBottomSheetStyle(joinMeetingButtonStyle: _joinMeetButtonStyle));
  static ArchivedChatsPageStyle _archivedChatsPageStyle = const ArchivedChatsPageStyle();
  static ChatPageStyle _chatPageStyle =  ChatPageStyle(instantScheduleMeetStyle: InstantScheduleMeetStyle(meetBottomSheetStyle:MeetBottomSheetStyle(joinMeetingButtonStyle: _joinMeetButtonStyle)));
  static CreateGroupPageStyle _createGroupPageStyle = const CreateGroupPageStyle();
  static ChatInfoPageStyle _chatInfoPageStyle = const ChatInfoPageStyle();
  static GroupChatInfoPageStyle _groupChatInfoPageStyle = const GroupChatInfoPageStyle();
  static ContactListPageStyle _contactListPageStyle = const ContactListPageStyle();
  static SettingsPageStyle _settingsPageStyle = const SettingsPageStyle();
  static ViewAllMediaPageStyle _viewAllMediaPageStyle = const ViewAllMediaPageStyle();
  static MessageInfoPageStyle _messageInfoPageStyle = const MessageInfoPageStyle();
  static BlockedListPageStyle _blockedListPageStyle = const BlockedListPageStyle();
  static StarredMessageListPageStyle _starredMessageListPageStyle = const StarredMessageListPageStyle();
  static OutgoingCallPageStyle _outgoingCallPageStyle = OutgoingCallPageStyle(disconnectButtonStyle: _disconnectButtonStyle);
  static CallAgainPageStyle _callAgainPageStyle = const CallAgainPageStyle();
  static OngoingCallPageStyle _ongoingCallPageStyle = OngoingCallPageStyle(disconnectButtonStyle: _disconnectButtonStyle);
  static CallInfoPageStyle _callInfoPageStyle = const CallInfoPageStyle();
  static AddParticipantsPageStyle _addParticipantsPageStyle = const AddParticipantsPageStyle();
  static DialogStyle _dialogStyle = DialogStyle(buttonStyle: _defaultDialogButtonStyle);
  static GalleryPageStyle _galleryPageStyle = const GalleryPageStyle();
  static LocalContactPageStyle _localContactPageStyle = const LocalContactPageStyle();
  static LocalContactPreviewPageStyle _localContactPreviewPageStyle = const LocalContactPreviewPageStyle();
  static LocationSentPageStyle _locationSentPageStyle = const LocationSentPageStyle();
  static MediaSentPreviewPageStyle _mediaSentPreviewPageStyle = const MediaSentPreviewPageStyle();
  static JoinCallPreviewPageStyle _joinCallPreviewPageStyle = JoinCallPreviewPageStyle(joinCallButtonStyle: _joinCallButtonStyle);

  static LoginPageStyle loginPageStyle = _loginPageStyle;
  static ProfileViewStyle profileViewStyle = _profileViewStyle;
  static DashBoardPageStyle dashBoardPageStyle = _dashBoardPageStyle;
  static ArchivedChatsPageStyle archivedChatsPageStyle = _archivedChatsPageStyle;
  static ChatPageStyle chatPageStyle = _chatPageStyle;
  static CreateGroupPageStyle createGroupPageStyle = _createGroupPageStyle;
  static ChatInfoPageStyle chatInfoPageStyle = _chatInfoPageStyle;
  static GroupChatInfoPageStyle groupChatInfoPageStyle = _groupChatInfoPageStyle;
  static ContactListPageStyle contactListPageStyle= _contactListPageStyle;
  static SettingsPageStyle settingsPageStyle= _settingsPageStyle;
  static ViewAllMediaPageStyle viewAllMediaPageStyle= _viewAllMediaPageStyle;
  static MessageInfoPageStyle messageInfoPageStyle= _messageInfoPageStyle;
  static BlockedListPageStyle blockedListPageStyle= _blockedListPageStyle;
  static StarredMessageListPageStyle starredMessageListPageStyle = _starredMessageListPageStyle;
  static OutgoingCallPageStyle outgoingCallPageStyle = _outgoingCallPageStyle;
  static CallAgainPageStyle callAgainPageStyle = _callAgainPageStyle;
  static OngoingCallPageStyle ongoingCallPageStyle = _ongoingCallPageStyle;
  static CallInfoPageStyle callInfoPageStyle = _callInfoPageStyle;
  static AddParticipantsPageStyle addParticipantsPageStyle = _addParticipantsPageStyle;
  static DialogStyle dialogStyle = _dialogStyle;
  static GalleryPageStyle galleryPageStyle = _galleryPageStyle;
  static LocalContactPageStyle localContactPageStyle = _localContactPageStyle;
  static LocalContactPreviewPageStyle localContactPreviewPageStyle = _localContactPreviewPageStyle;
  static LocationSentPageStyle locationSentPageStyle = _locationSentPageStyle;
  static MediaSentPreviewPageStyle mediaSentPreviewPageStyle = _mediaSentPreviewPageStyle;
  static JoinCallPreviewPageStyle joinCallPreviewPageStyle = _joinCallPreviewPageStyle;

  static setAppStyle({required AppStyle appStyle}){
    loginPageStyle = appStyle.loginPageStyle ?? _loginPageStyle;
    profileViewStyle = appStyle.profileViewStyle ?? _profileViewStyle;
    dashBoardPageStyle = appStyle.dashBoardPageStyle ?? _dashBoardPageStyle;
    archivedChatsPageStyle = appStyle.archivedChatsPageStyle ?? _archivedChatsPageStyle;
    chatPageStyle = appStyle.chatPageStyle ?? _chatPageStyle;
    createGroupPageStyle = appStyle.createGroupPageStyle ?? _createGroupPageStyle;
    chatInfoPageStyle = appStyle.chatInfoPageStyle ?? _chatInfoPageStyle;
    groupChatInfoPageStyle = appStyle.groupChatInfoPageStyle ?? _groupChatInfoPageStyle;
    contactListPageStyle = appStyle.contactListPageStyle ?? _contactListPageStyle;
    settingsPageStyle = appStyle.settingsPageStyle ?? _settingsPageStyle;
    viewAllMediaPageStyle = appStyle.viewAllMediaPageStyle ?? _viewAllMediaPageStyle;
    messageInfoPageStyle = appStyle.messageInfoPageStyle ?? _messageInfoPageStyle;
    blockedListPageStyle = appStyle.blockedListPageStyle ?? _blockedListPageStyle;
    starredMessageListPageStyle = appStyle.starredMessageListPageStyle ?? _starredMessageListPageStyle;
    outgoingCallPageStyle = appStyle.outgoingCallPageStyle ?? _outgoingCallPageStyle;
    callAgainPageStyle = appStyle.callAgainPageStyle ?? _callAgainPageStyle;
    ongoingCallPageStyle = appStyle.ongoingCallPageStyle ?? _ongoingCallPageStyle;
    addParticipantsPageStyle = appStyle.addParticipantsPageStyle ?? _addParticipantsPageStyle;
    dialogStyle = appStyle.dialogStyle ?? _dialogStyle;
  }

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

  static setArchivedChatsPageStyle(ArchivedChatsPageStyle archivedChatsPageStyle){
    _archivedChatsPageStyle = archivedChatsPageStyle;
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

  static setViewAllMediaPageStyle(ViewAllMediaPageStyle viewAllMediaPageStyle){
    _viewAllMediaPageStyle = viewAllMediaPageStyle;
  }

  static setMessageInfoPageStyle(MessageInfoPageStyle messageInfoPageStyle){
    _messageInfoPageStyle = messageInfoPageStyle;
  }

  static setBlockedListPageStyle(BlockedListPageStyle blockedListPageStyle){
    _blockedListPageStyle = blockedListPageStyle;
  }

  static setStarredMessageListPageStyle(StarredMessageListPageStyle starredMessageListPageStyle){
    _starredMessageListPageStyle = starredMessageListPageStyle;
  }

  static setOutgoingCallPageStyle(OutgoingCallPageStyle outgoingCallPageStyle){
    _outgoingCallPageStyle = outgoingCallPageStyle;
  }

  static setCallAgainPageStyle(CallAgainPageStyle callAgainPageStyle){
    _callAgainPageStyle = callAgainPageStyle;
  }

  static setOngoingCallPageStyle(OngoingCallPageStyle ongoingCallPageStyle){
    _ongoingCallPageStyle = ongoingCallPageStyle;
  }

  static setCallInfoPageStyle(CallInfoPageStyle callInfoPageStyle){
    _callInfoPageStyle = callInfoPageStyle;
  }

  static setAddParticipantsPageStyle(AddParticipantsPageStyle addParticipantsPageStyle){
    _addParticipantsPageStyle = addParticipantsPageStyle;
  }

  static setDialogStyle(DialogStyle dialogStyle){
    _dialogStyle = dialogStyle;
  }

  static setGalleryPageStyle(GalleryPageStyle galleryPageStyle){
    _galleryPageStyle = galleryPageStyle;
  }

  static setLocalContactPageStyle(LocalContactPageStyle localContactPageStyle){
    _localContactPageStyle = localContactPageStyle;
  }

  static setLocalContactPreviewPageStyle(LocalContactPreviewPageStyle localContactPreviewPageStyle){
    _localContactPreviewPageStyle = localContactPreviewPageStyle;
  }

  static setLocationSentPageStyle(LocationSentPageStyle locationSentPageStyle){
    _locationSentPageStyle = locationSentPageStyle;
  }

  static setMediaSentPreviewPageStyle(MediaSentPreviewPageStyle mediaSentPreviewPageStyle){
    _mediaSentPreviewPageStyle = mediaSentPreviewPageStyle;
  }

  static setJoinCallPreviewPageStyle(JoinCallPreviewPageStyle joinCallPreviewPageStyle){
    _joinCallPreviewPageStyle = joinCallPreviewPageStyle;
  }
}