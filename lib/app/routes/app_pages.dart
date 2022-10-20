import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/chat/views/locationsent_view.dart';

import '../model/userlistModel.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/bindings/contact_binding.dart';
import '../modules/chat/bindings/image_preview_binding.dart';
import '../modules/chat/bindings/location_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/chat/views/contactlist_view.dart';
import '../modules/chat/views/image_preview_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/file_viewer/bindings/file_viewer_binding.dart';
import '../modules/file_viewer/views/file_viewer_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/image_view/bindings/image_view_binding.dart';
import '../modules/image_view/views/image_view_view.dart';
import '../modules/local_contact/bindings/local_contact_binding.dart';
import '../modules/local_contact/views/local_contact_view.dart';
import '../modules/login/bindings/country_binding.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/countrylist_view.dart';
import '../modules/login/views/login_view.dart';
import '../modules/preview_contact/bindings/preview_contact_binding.dart';
import '../modules/preview_contact/views/preview_contact_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/bindings/statuslist_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/statuslist_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/video_preview/bindings/VideoPlayBinding.dart';
import '../modules/video_preview/bindings/video_preview_binding.dart';
import '../modules/video_preview/views/video_player_view.dart';
import '../modules/video_preview/views/video_preview_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;
  static const DASHBOARD = Routes.DASHBOARD;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
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
      name: _Paths.LOCATIONSENT,
      page: () => LocationSentView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: _Paths.CONTACTS,
      page: () => ContactListView(),
      binding: ContactListBinding(),
    ),
    GetPage(
      name: _Paths.IMAGEPREVIEW,
      page: () => const ImagePreviewView(),
      binding: ImagePreviewBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_PREVIEW,
      page: () => VideoPreviewView(),
      binding: VideoPreviewBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_PLAY,
      page: () => VideoPlayerView(),
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
  ];
}
