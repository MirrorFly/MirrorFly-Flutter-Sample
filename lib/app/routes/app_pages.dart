import 'package:get/get.dart';

import '../modules/admin_blocked/adminblockedview.dart';
import '../modules/archived_chats/archived_chat_list_binding.dart';
import '../modules/archived_chats/archived_chat_list_view.dart';
import '../modules/busy_status/bindings/busy_status_binding.dart';
import '../modules/busy_status/views/busy_status_view.dart';
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
import '../modules/chat/views/forwardchat_view.dart';
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
import '../modules/gallery_picker/bindings/gallery_picker_binding.dart';
import '../modules/gallery_picker/views/gallery_picker_view.dart';
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
import '../modules/media_preview/bindings/media_preview_binding.dart';
import '../modules/media_preview/views/media_preview_view.dart';
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
import '../modules/settings/views/chat_settings/chat_settings_binding.dart';
import '../modules/settings/views/chat_settings/chat_settings_view.dart';
import '../modules/settings/views/chat_settings/language/language_binding.dart';
import '../modules/settings/views/chat_settings/language/language_list_view.dart';
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

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;
  static const profile = Routes.profile;
  static const dashboard = Routes.dashboard;
  static const chat = Routes.chat;
  static const adminBlocked = Routes.adminBlocked;

  static final routes = [
    GetPage(
        name: _Paths.otp, page: () => const OtpView(), binding: LoginBinding()),
    GetPage(
      name: _Paths.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.scanner,
      page: () => const ScannerView(),
      binding: ScannerBinding(),
    ),
    GetPage(
      name: _Paths.webLoginResult,
      page: () => const WebLoginResultView(),
      binding: ScannerBinding(),
    ),
    GetPage(
      name: _Paths.createGroup,
      page: () => const GroupCreationView(),
      binding: GroupCreationBinding(),
    ),
    GetPage(
      name: _Paths.groupInfo,
      page: () => const GroupInfoView(),
      binding: GroupInfoBinding(),
    ),
    GetPage(
      name: _Paths.viewMedia,
      page: () => const ViewAllMediaView(),
      binding: ViewAllMediaBinding(),
    ),
    GetPage(
      name: _Paths.recentSearch,
      page: () => const RecentSearchView(),
      binding: RecentSearchBinding(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.countries,
      page: () => const CountryListView(),
      binding: CountryListBinding(),
    ),
    GetPage(
      name: _Paths.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.statusList,
      page: () => const StatusListView(),
      binding: StatusListBinding(),
    ),
    GetPage(
      name: _Paths.chat,
      page: () => const ChatView(),
      // arguments: Profile(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.forwardChat,
      page: () => const ForwardChatView(),
      binding: ForwardChatBinding(),
    ),
    GetPage(
      name: _Paths.chatSearch,
      page: () => const ChatSearchView(),
    ),
    GetPage(
      name: _Paths.locationSent,
      page: () => const LocationSentView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: _Paths.contacts,
      page: () => const ContactListView(),
      binding: ContactListBinding(),
    ),
    GetPage(
      name: _Paths.imagePreview,
      page: () => const ImagePreviewView(),
      binding: ImagePreviewBinding(),
    ),
    GetPage(
      name: _Paths.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.blockedList,
      page: () => const BlockedListView(),
      binding: BlockedListBinding(),
    ),
    GetPage(
      name: _Paths.notification,
      page: () => const NotificationSettingsView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.appLock,
      page: () => const AppLockSettingsView(),
      binding: AppLockBinding(),
    ),
    GetPage(
      name: _Paths.pin,
      page: () => const PinView(),
      binding: AppLockBinding(),
    ),
    GetPage(
      name: _Paths.setPin,
      page: () => const SetPinView(),
      binding: AppLockBinding(),
    ),
    GetPage(
      name: _Paths.videoPreview,
      page: () => const VideoPreviewView(),
      binding: VideoPreviewBinding(),
    ),
    GetPage(
      name: _Paths.videoPlay,
      page: () => const VideoPlayerView(),
      binding: VideoPlayBinding(),
    ),
    GetPage(
      name: _Paths.imageView,
      page: () => const ImageViewView(),
      binding: ImageViewBinding(),
    ),
    GetPage(
      name: _Paths.localContact,
      page: () => const LocalContactView(),
      binding: LocalContactBinding(),
    ),
    GetPage(
      name: _Paths.previewContact,
      page: () => const PreviewContactView(),
      binding: PreviewContactBinding(),
    ),
    GetPage(
      name: _Paths.messageInfo,
      page: () => const MessageInfoView(),
      binding: MessageInfoBinding(),
    ),
    GetPage(
      name: _Paths.chatInfo,
      page: () => const ChatInfoView(),
      binding: ChatInfoBinding(),
    ),
    GetPage(
      name: _Paths.deleteAccount,
      page: () => const DeleteAccountView(),
      binding: DeleteAccountBinding(),
    ),
    GetPage(
      name: _Paths.deleteAccountReason,
      page: () => const DeleteAccountReasonView(),
      binding: DeleteAccountReasonBinding(),
    ),
    GetPage(
      name: _Paths.starredMessages,
      page: () => const StarredMessagesView(),
      binding: StarredMessagesBinding(),
    ),
    GetPage(
      name: _Paths.cameraPick,
      page: () => const CameraPickView(),
      binding: CameraPickBinding(),
    ),
    GetPage(
      name: _Paths.adminBlocked,
      page: () => const AdminBlockedView(),
    ),
    GetPage(
        name: _Paths.archivedChats,
        page: () => const ArchivedChatListView(),
        binding: ArchivedChatListBinding()),
    GetPage(
        name: _Paths.chatSettings,
        page: () => const ChatSettingsView(),
        binding: ChatSettingsBinding()),
    GetPage(
      name: _Paths.galleryPicker,
      page: () => const GalleryPickerView(),
      binding: GalleryPickerBinding(),
    ),
    GetPage(
      name: _Paths.mediaPreview,
      page: () => const MediaPreviewView(),
      binding: MediaPreviewBinding(),
    ),
    GetPage(
      name: _Paths.languages,
      page: () => const LanguageListView(),
      binding: LanguageListBinding(),
    ),
    GetPage(
      name: _Paths.busy_status,
      page: () => const BusyStatusView(),
      binding: BusyStatusBinding(),
    ),
  ];
}
