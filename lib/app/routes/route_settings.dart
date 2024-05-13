import 'package:flutter/material.dart';

import '../call_modules/call_info/views/call_info_view.dart';
import '../call_modules/call_timeout/views/call_timeout_view.dart';
import '../call_modules/group_participants/group_participants_view.dart';
import '../call_modules/ongoing_call/ongoingcall_view.dart';
import '../call_modules/outgoing_call/outgoing_call_view.dart';
import '../call_modules/participants/participants_view.dart';
import '../modules/admin_blocked/adminblockedview.dart';
import '../modules/archived_chats/archived_chat_list_view.dart';
import '../modules/busy_status/views/busy_status_view.dart';
import '../modules/camera_pick/views/camera_pick_view.dart';
import '../modules/chat/views/chat_search_view.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/chat/views/contact_list_view.dart';
import '../modules/chat/views/forwardchat_view.dart';
import '../modules/chat/views/location_sent_view.dart';
import '../modules/chatInfo/views/chat_info_view.dart';
import '../modules/contact_sync/views/contact_sync_view.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/delete_account/views/delete_account_view.dart';
import '../modules/delete_account_reason/views/delete_account_reason_view.dart';
import '../modules/gallery_picker/views/gallery_picker_view.dart';
import '../modules/group/views/group_creation_view.dart';
import '../modules/group/views/group_info_view.dart';
import '../modules/image_view/views/image_view_view.dart';
import '../modules/local_contact/views/local_contact_view.dart';
import '../modules/login/views/country_list_view.dart';
import '../modules/login/views/login_view.dart';
import '../modules/login/views/otp_view.dart';
import '../modules/media_preview/views/media_preview_view.dart';
import '../modules/message_info/views/message_info_view.dart';
import '../modules/preview_contact/views/preview_contact_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/status_list_view.dart';
import '../modules/scanner/scanner_view.dart';
import '../modules/scanner/web_login_result_view.dart';
import '../modules/settings/views/app_lock/app_lock_settings_view.dart';
import '../modules/settings/views/app_lock/pin_view.dart';
import '../modules/settings/views/app_lock/set_pin_view.dart';
import '../modules/settings/views/blocked/blocked_list_view.dart';
import '../modules/settings/views/chat_settings/chat_settings_view.dart';
import '../modules/settings/views/chat_settings/datausage/datausage_list_view.dart';
import '../modules/settings/views/chat_settings/language/language_list_view.dart';
import '../modules/settings/views/notification/notification_settings_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/starred_messages/views/starred_messages_view.dart';
import '../modules/video_preview/views/video_player_view.dart';
import '../modules/video_preview/views/video_preview_view.dart';
import '../modules/view_all_media/views/view_all_media_view.dart';
import '../modules/view_all_media_preview/views/view_all_media_preview_view.dart';

part 'app_routes.dart';


Route<dynamic> mirrorFlyRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.login:
      return MaterialPageRoute(builder: (_) => const LoginView());
    case Routes.otp:
      return MaterialPageRoute(builder: (_) => const OtpView());
    case Routes.dashboard:
      return MaterialPageRoute(builder: (_) => const DashboardView());
    case Routes.scanner:
      return MaterialPageRoute(builder: (_) => const ScannerView());
    case Routes.webLoginResult:
      return MaterialPageRoute(builder: (_) => const WebLoginResultView());
    case Routes.createGroup:
      return MaterialPageRoute(builder: (_) => const GroupCreationView());
    case Routes.groupInfo:
      return MaterialPageRoute(builder: (_) => const GroupInfoView());
    case Routes.viewMedia:
      return MaterialPageRoute(builder: (_) => const ViewAllMediaView());

    case Routes.countries:
      return MaterialPageRoute(builder: (_) => const CountryListView());
    case Routes.profile:
      return MaterialPageRoute(builder: (_) => const ProfileView());
    case Routes.statusList:
      return MaterialPageRoute(builder: (_) => const StatusListView());
    case Routes.chat:
      final arguments = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (_) => ChatView(jid: arguments['jid']));
    case Routes.forwardChat:
      final arguments = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (_) => ForwardChatView(forwardMessageIds: arguments['forwardMessageIds']));
    case Routes.chatSearch:
      return MaterialPageRoute(builder: (_) => ChatSearchView());
    case Routes.locationSent:
      return MaterialPageRoute(builder: (_) => const LocationSentView());
    case Routes.contacts:
      return MaterialPageRoute(builder: (_) => const ContactListView());
    case Routes.settings:
      return MaterialPageRoute(builder: (_) => const SettingsView());
    case Routes.blockedList:
      return MaterialPageRoute(builder: (_) => const BlockedListView());
    case Routes.notification:
      return MaterialPageRoute(builder: (_) => const NotificationSettingsView());
    case Routes.appLock:
      return MaterialPageRoute(builder: (_) => const AppLockSettingsView());
    case Routes.pin:
      return MaterialPageRoute(builder: (_) => const PinView());
    case Routes.setPin:
      return MaterialPageRoute(builder: (_) => const SetPinView());
    case Routes.videoPreview:
      return MaterialPageRoute(builder: (_) => const VideoPreviewView());
    case Routes.videoPlay:
      return MaterialPageRoute(builder: (_) => const VideoPlayerView());
    case Routes.imageView:
      return MaterialPageRoute(builder: (_) => const ImageViewView());
    case Routes.localContact:
      return MaterialPageRoute(builder: (_) => const LocalContactView());
    case Routes.previewContact:
      return MaterialPageRoute(builder: (_) => const PreviewContactView());
    case Routes.messageInfo:
      return MaterialPageRoute(builder: (_) => const MessageInfoView());
    case Routes.chatInfo:
      final arguments = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (_) => ChatInfoView(jid: arguments['jid']));
    case Routes.deleteAccount:
      return MaterialPageRoute(builder: (_) => const DeleteAccountView());
    case Routes.deleteAccountReason:
      return MaterialPageRoute(builder: (_) => const DeleteAccountReasonView());
    case Routes.starredMessages:
      return MaterialPageRoute(builder: (_) => const StarredMessagesView());
    case Routes.cameraPick:
      return MaterialPageRoute(builder: (_) => CameraPickView());
    case Routes.adminBlocked:
      return MaterialPageRoute(builder: (_) => const AdminBlockedView());
    case Routes.archivedChats:
      return MaterialPageRoute(builder: (_) => ArchivedChatListView());
    case Routes.chatSettings:
      return MaterialPageRoute(builder: (_) => const ChatSettingsView());
    case Routes.galleryPicker:
      return MaterialPageRoute(builder: (_) => const GalleryPickerView());
    case Routes.mediaPreview:
      return MaterialPageRoute(builder: (_) => const MediaPreviewView());
    case Routes.languages:
      return MaterialPageRoute(builder: (_) => const LanguageListView());
    case Routes.busyStatus:
      return MaterialPageRoute(builder: (_) => const BusyStatusView());
    case Routes.dataUsageSetting:
      return MaterialPageRoute(builder: (_) => const DataUsageListView());
    case Routes.contactSync:
      return MaterialPageRoute(builder: (_) => const ContactSyncPage());
    case Routes.viewAllMediaPreview:
      return MaterialPageRoute(builder: (_) => const ViewAllMediaPreviewView());

    //calls
    case Routes.outGoingCallView:
      return MaterialPageRoute(builder: (_) => const OutGoingCallView());
    case Routes.onGoingCallView:
      return MaterialPageRoute(builder: (_) => const OnGoingCallView());
    case Routes.callTimeOutView:
      return MaterialPageRoute(builder: (_) => const CallTimeoutView());
    case Routes.participants:
      return MaterialPageRoute(builder: (_) => const ParticipantsView());
    case Routes.groupParticipants:
      return MaterialPageRoute(builder: (_) => const GroupParticipantsView());
    case Routes.callInfo:
      return MaterialPageRoute(builder: (_) => const CallInfoView());
    default:
      return MaterialPageRoute(builder: (_) => const LoginView());
  }
}
