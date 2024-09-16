
import 'package:flutter/material.dart';
import '../model/arguments.dart';

import '../call_modules/call_info/views/call_info_view.dart';
import '../call_modules/call_timeout/views/call_timeout_view.dart';
import '../call_modules/group_participants/group_participants_view.dart';
import '../call_modules/join_call_preview/join_call_preview_view.dart';
import '../call_modules/ongoing_call/ongoingcall_view.dart';
import '../call_modules/outgoing_call/outgoing_call_view.dart';
import '../call_modules/participants/participants_view.dart';
import '../modules/admin_blocked/adminblockedview.dart';
import '../modules/archived_chats/archived_chat_list_view.dart';
import '../modules/busy_status/views/add_busy_status_view.dart';
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
import '../modules/profile/views/add_status_view.dart';
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


Route<dynamic>? mirrorFlyRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const DashboardView(),settings: settings);
     case Routes.login:
      return MaterialPageRoute(builder: (_) => const LoginView(),settings: settings);
    case Routes.otp:
      return MaterialPageRoute(builder: (_) => const OtpView(),settings: settings);
    case Routes.dashboard:
      return MaterialPageRoute(builder: (_) => const DashboardView(),settings: settings);
    case Routes.scanner:
      return MaterialPageRoute(builder: (_) => const ScannerView(),settings: settings);
    case Routes.webLoginResult:
      return MaterialPageRoute(builder: (_) => const WebLoginResultView(),settings: settings);
    case Routes.createGroup:
      return MaterialPageRoute(builder: (_) => const GroupCreationView(),settings: settings);
    case Routes.groupInfo:
      return MaterialPageRoute(builder: (_) => const GroupInfoView(),settings: settings);
    case Routes.viewMedia:
      return MaterialPageRoute(builder: (_) => const ViewAllMediaView(),settings: settings);

    case Routes.countries:
      return MaterialPageRoute(builder: (_) => const CountryListView(),settings: settings);
    case Routes.profile:
      return MaterialPageRoute(builder: (_) => const ProfileView(),settings: settings);
    case Routes.statusList:
      return MaterialPageRoute(builder: (_) => const StatusListView(),settings: settings);
    case Routes.chat:
      final arguments = settings.arguments as ChatViewArguments;
      return MaterialPageRoute(builder: (_) => ChatView(chatViewArguments: arguments),settings: settings);
    case Routes.forwardChat:
      final arguments = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (_) => ForwardChatView(forwardMessageIds: arguments['messageIds']),settings: settings);
    case Routes.chatSearch:
      return MaterialPageRoute(builder: (_) => ChatSearchView(),settings: settings);
    case Routes.locationSent:
      return MaterialPageRoute(builder: (_) => const LocationSentView(),settings: settings);
    case Routes.contacts:
      return MaterialPageRoute(builder: (_) => const ContactListView(),settings: settings);
    case Routes.settings:
      return MaterialPageRoute(builder: (_) => const SettingsView(),settings: settings);
    case Routes.blockedList:
      return MaterialPageRoute(builder: (_) => const BlockedListView(),settings: settings);
    case Routes.notification:
      return MaterialPageRoute(builder: (_) => const NotificationSettingsView(),settings: settings);
    case Routes.appLock:
      return MaterialPageRoute(builder: (_) => const AppLockSettingsView(),settings: settings);
    case Routes.pin:
      return MaterialPageRoute(builder: (_) => const PinView(),settings: settings);
    case Routes.setPin:
      return MaterialPageRoute(builder: (_) => const SetPinView(),settings: settings);
    case Routes.videoPreview:
      return MaterialPageRoute(builder: (_) => const VideoPreviewView(),settings: settings);
    case Routes.videoPlay:
      return MaterialPageRoute(builder: (_) => const VideoPlayerView(),settings: settings);
    case Routes.imageView:
      return MaterialPageRoute(builder: (_) => const ImageViewView(),settings: settings);
    case Routes.localContact:
      return MaterialPageRoute(builder: (_) => const LocalContactView(),settings: settings);
    case Routes.previewContact:
      return MaterialPageRoute(builder: (_) => const PreviewContactView(),settings: settings);
    case Routes.messageInfo:
      return MaterialPageRoute(builder: (_) => const MessageInfoView(),settings: settings);
    case Routes.chatInfo:
      return MaterialPageRoute(builder: (_) => const ChatInfoView(),settings: settings);
    case Routes.deleteAccount:
      return MaterialPageRoute(builder: (_) => const DeleteAccountView(),settings: settings);
    case Routes.deleteAccountReason:
      return MaterialPageRoute(builder: (_) => const DeleteAccountReasonView(),settings: settings);
    case Routes.starredMessages:
      return MaterialPageRoute(builder: (_) => const StarredMessagesView(),settings: settings);
    case Routes.cameraPick:
      return MaterialPageRoute(builder: (_) => const CameraPickView(),settings: settings);
    case Routes.adminBlocked:
      return MaterialPageRoute(builder: (_) => const AdminBlockedView(),settings: settings);
    case Routes.archivedChats:
      return MaterialPageRoute(builder: (_) => const ArchivedChatListView(),settings: settings);
    case Routes.chatSettings:
      return MaterialPageRoute(builder: (_) => const ChatSettingsView(),settings: settings);
    case Routes.galleryPicker:
      return MaterialPageRoute(builder: (_) => const GalleryPickerView(),settings: settings);
    case Routes.mediaPreview:
      return MaterialPageRoute(builder: (_) => const MediaPreviewView(),settings: settings);
    case Routes.languages:
      return MaterialPageRoute(builder: (_) => const LanguageListView(),settings: settings);
    case Routes.busyStatus:
      return MaterialPageRoute(builder: (_) => const BusyStatusView(),settings: settings);
    case Routes.dataUsageSetting:
      return MaterialPageRoute(builder: (_) => const DataUsageListView(),settings: settings);
    case Routes.contactSync:
      return MaterialPageRoute(builder: (_) => const ContactSyncPage(),settings: settings);
    case Routes.viewAllMediaPreview:
      return MaterialPageRoute(builder: (_) => const ViewAllMediaPreviewView(),settings: settings);
    case Routes.addBusyStatus:
      final arguments = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (_) => AddBusyStatusView(status: arguments['status']),settings: settings);
    case Routes.addProfileStatus:
      return MaterialPageRoute(builder: (_) => const AddStatusView(),settings: settings);

    //calls
    case Routes.joinCallPreview:
      return MaterialPageRoute(builder: (_) => const JoinCallPreviewView(),settings: settings);
    case Routes.outGoingCallView:
      return MaterialPageRoute(builder: (_) => const OutGoingCallView(),settings: settings);
    case Routes.onGoingCallView:
      return MaterialPageRoute(builder: (_) => const OnGoingCallView(),settings: settings);
    case Routes.callTimeOutView:
      return MaterialPageRoute(builder: (_) => const CallTimeoutView(),settings: settings);
    case Routes.participants:
      return MaterialPageRoute(builder: (_) => const ParticipantsView(),settings: settings);
    case Routes.groupParticipants:
      return MaterialPageRoute(builder: (_) => const GroupParticipantsView(),settings: settings);
    case Routes.callInfo:
      return MaterialPageRoute(builder: (_) => const CallInfoView(),settings: settings);
    default:
      if (settings.name!.startsWith(Routes.dashboard)) {
        return MaterialPageRoute(builder: (_) => const DashboardView(),settings: settings);
      }/*else if (settings.name!.startsWith(Routes.chat)) {
        final parameters = jsonDecode(jsonEncode(Uri.parse(settings.name!).queryParameters));
        LogMessage.d("parameters", parameters);
        LogMessage.d("parameters chatJid", parameters['chatJid']);
        return MaterialPageRoute(builder: (_) => ChatView(),settings: settings);
      }*/else if (settings.name!.startsWith(Routes.contacts)) {
        return MaterialPageRoute(builder: (_) => const ContactListView(),settings: settings);
      }
      return null;
  }
}
