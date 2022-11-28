import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/chat/views/forwardchat_view.dart';

import '../modules/camera_pick/bindings/camera_pick_binding.dart';
import '../modules/camera_pick/views/camera_pick_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/bindings/contact_binding.dart';
import '../modules/chat/bindings/forwardchat_binding.dart';
import '../modules/chat/bindings/image_preview_binding.dart';
import '../modules/chat/bindings/location_binding.dart';
import '../modules/chat/views/chat_search_view.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/chat/views/contact_list_view.dart';
import '../modules/chat/views/image_preview_view.dart';
import '../modules/chat/views/location_sent_view.dart';
import '../modules/chatInfo/bindings/chat_info_binding.dart';
import '../modules/chatInfo/views/chat_info_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/bindings/recent_search_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/dashboard/views/recent_search_view.dart';
import '../modules/delete_account/bindings/delete_account_binding.dart';
import '../modules/delete_account/views/delete_account_view.dart';
import '../modules/delete_account_reason/bindings/delete_account_reason_binding.dart';
import '../modules/delete_account_reason/views/delete_account_reason_view.dart';
import '../modules/group/bindings/group_creation_binding.dart';
import '../modules/group/bindings/group_info_binding.dart';
import '../modules/group/views/group_creation_view.dart';
import '../modules/group/views/group_info_view.dart';
import '../modules/image_view/bindings/image_view_binding.dart';
import '../modules/image_view/views/image_view_view.dart';
import '../modules/local_contact/bindings/local_contact_binding.dart';
import '../modules/local_contact/views/local_contact_view.dart';
import '../modules/login/bindings/country_binding.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/country_list_view.dart';
import '../modules/login/views/login_view.dart';
import '../modules/login/views/otp_view.dart';
import '../modules/message_info/bindings/message_info_binding.dart';
import '../modules/message_info/views/message_info_view.dart';
import '../modules/preview_contact/bindings/preview_contact_binding.dart';
import '../modules/preview_contact/views/preview_contact_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/bindings/status_list_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/status_list_view.dart';
import '../modules/scanner/scanner_binding.dart';
import '../modules/scanner/scanner_view.dart';
import '../modules/scanner/web_login_result_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/app_lock/app_lock_binding.dart';
import '../modules/settings/views/app_lock/app_lock_settings_view.dart';
import '../modules/settings/views/app_lock/pin_view.dart';
import '../modules/settings/views/app_lock/set_pin_view.dart';
import '../modules/settings/views/blocked/blocked_list_binding.dart';
import '../modules/settings/views/blocked/blocked_list_view.dart';
import '../modules/settings/views/notification/notification_binding.dart';
import '../modules/settings/views/notification/notification_settings_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/starred_messages/bindings/starred_messages_binding.dart';
import '../modules/starred_messages/views/starred_messages_view.dart';
import '../modules/video_preview/bindings/video_play_binding.dart';
import '../modules/video_preview/bindings/video_preview_binding.dart';
import '../modules/video_preview/views/video_player_view.dart';
import '../modules/video_preview/views/video_preview_view.dart';
import '../modules/view_all_media/bindings/view_all_media_binding.dart';
import '../modules/view_all_media/views/view_all_media_view.dart';

import 'package:flysdk/flysdk.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;
  static const PROFILE = Routes.PROFILE;
  static const DASHBOARD = Routes.DASHBOARD;

  static final routes = [
    GetPage(name: _Paths.OTP, page: () => const OtpView(), binding: LoginBinding()),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.SCANNER,
      page: () => const ScannerView(),
      binding: ScannerBinding(),
    ),
    GetPage(
      name: _Paths.WEBLOGINRESULT,
      page: () => const WebLoginResultView(),
      binding: ScannerBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_GROUP,
      page: () => GroupCreationView(),
      binding: GroupCreationBinding(),
    ),
    GetPage(
      name: _Paths.GROUP_INFO,
      page: () => GroupInfoView(),
      binding: GroupInfoBinding(),
    ),
    GetPage(
      name: _Paths.VIEW_MEDIA,
      page: () => const ViewAllMediaView(),
      binding: ViewAllMediaBinding(),
    ),
    GetPage(
      name: _Paths.RECENTSEARCH,
      page: () => const RecentSearchView(),
      binding: RecentSearchBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.COUNTRIES,
      page: () => const CountryListView(),
      binding: CountryListBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.STATUSLIST,
      page: () => StatusListView(),
      binding: StatusListBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => ChatView(),
      arguments: Profile(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.FORWARD_CHAT,
      page: () => const ForwardChatView(),
      binding: ForwardChatBinding(),
    ),
    GetPage(
      name: _Paths.CHATSEARCH,
      page: () => const ChatSearchView(),
    ),
    GetPage(
      name: _Paths.LOCATIONSENT,
      page: () => LocationSentView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: _Paths.CONTACTS,
      page: () => const ContactListView(),
      binding: ContactListBinding(),
    ),
    GetPage(
      name: _Paths.IMAGEPREVIEW,
      page: () => const ImagePreviewView(),
      binding: ImagePreviewBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.BLOCKEDLIST,
      page: () => const BlockedListView(),
      binding: BlockedListBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => const NotificationSettingsView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.APPLOCK,
      page: () => const AppLockSettingsView(),
      binding: AppLockBinding(),
    ),
    GetPage(
      name: _Paths.PIN,
      page: () => const PinView(),
      binding: AppLockBinding(),
    ),
    GetPage(
      name: _Paths.SET_PIN,
      page: () => const SetPinView(),
      binding: AppLockBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_PREVIEW,
      page: () => const VideoPreviewView(),
      binding: VideoPreviewBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_PLAY,
      page: () => const VideoPlayerView(),
      binding: VideoPlayBinding(),
    ),
    GetPage(
      name: _Paths.IMAGE_VIEW,
      page: () => const ImageViewView(),
      binding: ImageViewBinding(),
    ),
    GetPage(
      name: _Paths.LOCAL_CONTACT,
      page: () => const LocalContactView(),
      binding: LocalContactBinding(),
    ),
    GetPage(
      name: _Paths.PREVIEW_CONTACT,
      page: () => const PreviewContactView(),
      binding: PreviewContactBinding(),
    ),
    GetPage(
      name: _Paths.MESSAGE_INFO,
      page: () => const MessageInfoView(),
      binding: MessageInfoBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_INFO,
      page: () => const ChatInfoView(),
      binding: ChatInfoBinding(),
    ),
    GetPage(
      name: _Paths.DELETE_ACCOUNT,
      page: () => const DeleteAccountView(),
      binding: DeleteAccountBinding(),
    ),
    GetPage(
      name: _Paths.DELETE_ACCOUNT_REASON,
      page: () => const DeleteAccountReasonView(),
      binding: DeleteAccountReasonBinding(),
    ),
    GetPage(
      name: _Paths.STARRED_MESSAGES,
      page: () => const StarredMessagesView(),
      binding: StarredMessagesBinding(),
    ),
    GetPage(
      name: _Paths.CAMERA_PICK,
      page: () => const CameraPickView(),
      binding: CameraPickBinding(),
    ),
  ];
}
