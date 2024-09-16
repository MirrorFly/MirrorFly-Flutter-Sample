import '../routes/route_settings.dart';

//Need to delete//


// import '../modules/dashboard/bindings/recent_search_binding.dart';
// import '../modules/dashboard/views/recent_search_view.dart';

// part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;
  static const profile = Routes.profile;
  static const dashboard = Routes.dashboard;
  static const contactSync = Routes.contactSync;
  static const chat = Routes.chat;
  static const adminBlocked = Routes.adminBlocked;
  static const outgoingCall = Routes.outGoingCallView;
  static const onGoingCall = Routes.onGoingCallView;

/*  static final routes = [
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
    *//*GetPage(
      name: _Paths.recentSearch,
      page: () => const RecentSearchView(),
      binding: RecentSearchBinding(),
    ),*//*
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
      name: _Paths.busyStatus,
      page: () => const BusyStatusView(),
      binding: BusyStatusBinding(),
    ),
    GetPage(
      name: _Paths.dataUsageSetting,
      page: () => const DataUsageListView(),
      binding: DataUsageListBinding(),
    ),
    GetPage(
      name: _Paths.contactSync,
      page: () => const ContactSyncPage(),
      binding: ContactSyncBinding(),
    ),
    GetPage(
      name: _Paths.viewAllMediaPreview,
      page: () => const ViewAllMediaPreviewView(),
      binding: ViewAllMediaPreviewBinding(),
    ),

    //calls
    GetPage(
      name: _Paths.outGoingCallView,
      page: () => const OutGoingCallView(),
      binding: OutGoingCallBinding(),
    ),
    GetPage(
      name: _Paths.onGoingCallView,
      page: () => const OnGoingCallView(),
      binding: OutGoingCallBinding(),
    ),
    GetPage(
      name: _Paths.callTimeOutView,
      page: () => const CallTimeoutView(),
      binding: CallTimeoutBinding(),
    ),
    GetPage(
      name: _Paths.participants,
      page: () => const ParticipantsView(),
      binding: ParticipantsBinding(),
    ),
    GetPage(
      name: _Paths.groupParticipants,
      page: () => const GroupParticipantsView(),
      binding: GroupParticipantsBinding(),
    ),
    GetPage(
      name: _Paths.callInfo,
      page: () => const CallInfoView(),
      binding: CallInfoBinding(),
    ),
  ];*/
}
