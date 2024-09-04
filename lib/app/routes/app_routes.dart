
part of 'route_settings.dart';

abstract class Routes {
  Routes._();
  static const dashboard = _Paths.dashboard;
  static const scanner = _Paths.scanner;
  static const webLoginResult = _Paths.webLoginResult;
  static const createGroup = _Paths.createGroup;
  static const groupInfo = _Paths.groupInfo;
  static const viewMedia = _Paths.viewMedia;
  // static const recentSearch = _Paths.recentSearch;
  static const login = _Paths.login;
  static const otp = _Paths.otp;
  static const countries = _Paths.countries;
  static const profile = _Paths.profile;
  static const statusList = _Paths.statusList;
  static const contacts = _Paths.contacts;
  static const chat = _Paths.chat;
  static const forwardChat = _Paths.forwardChat;
  static const chatSearch = _Paths.chatSearch;
  static const locationSent = _Paths.locationSent;
  static const imagePreview = _Paths.imagePreview;
  static const settings = _Paths.settings;
  static const blockedList = _Paths.blockedList;
  static const notification = _Paths.notification;
  static const appLock = _Paths.appLock;
  static const pin = _Paths.pin;
  static const setPin = _Paths.setPin;
  static const videoPreview = _Paths.videoPreview;
  static const videoPlay = _Paths.videoPlay;
  static const imageView = _Paths.imageView;
  static const localContact = _Paths.localContact;
  static const previewContact = _Paths.previewContact;
  static const messageInfo = _Paths.messageInfo;
  static const chatInfo = _Paths.chatInfo;
  static const deleteAccount = _Paths.deleteAccount;
  static const deleteAccountReason = _Paths.deleteAccountReason;
  static const starredMessages = _Paths.starredMessages;
  static const cameraPick = _Paths.cameraPick;
  static const adminBlocked = _Paths.adminBlocked;
  static const archivedChats = _Paths.archivedChats;
  static const chatSettings = _Paths.chatSettings;
  static const galleryPicker = _Paths.galleryPicker;
  static const mediaPreview = _Paths.mediaPreview;
  static const languages = _Paths.languages;
  static const busyStatus = _Paths.busyStatus;
  static const dataUsageSetting = _Paths.dataUsageSetting;
  static const contactSync = _Paths.contactSync;
  static const viewAllMediaPreview = _Paths.viewAllMediaPreview;
  static const addBusyStatus = _Paths.addBusyStatus;
  static const addProfileStatus = _Paths.addProfileStatus;

  //call
  static const joinCallPreview = _Paths.joinCallPreview;
  static const outGoingCallView = _Paths.outGoingCallView;
  static const onGoingCallView = _Paths.onGoingCallView;
  static const callTimeOutView = _Paths.callTimeOutView;
  static const participants = _Paths.participants;
  static const groupParticipants = _Paths.groupParticipants;
  static const callInfo = _Paths.callInfo;

}

abstract class _Paths {
  _Paths._();
  static const dashboard = '/dashboard';
  static const scanner = '/scanner';
  static const webLoginResult = '/web_logins';
  static const createGroup = '/create_group';
  static const groupInfo = '/group_info';
  static const viewMedia = '/view_all_media';
  // static const recentSearch = '/recent_search';
  static const login = '/login';
  static const otp = '/otp';
  static const countries = '/Countries';
  static const profile = '/profile';
  static const statusList = '/status_list';
  static const chat = '/chat';
  static const forwardChat = '/forward_chat';
  static const chatSearch = '/chat_search';
  static const locationSent = '/location_sent';
  static const contacts = '/contacts';
  static const imagePreview = '/image_preview';
  static const settings = '/settings';
  static const blockedList = '/blocked_list';
  static const notification = '/notification_setting';
  static const appLock = '/app_lock_settings';
  static const pin = '/pin';
  static const setPin = '/set_pin';
  static const videoPreview = '/video-preview';
  static const videoPlay = '/video-play';
  static const imageView = '/image-view';
  static const localContact = '/local-contact';
  static const previewContact = '/preview-contact';
  static const messageInfo = '/message-info';
  static const chatInfo = '/chat-info';
  static const deleteAccount = '/delete-account';
  static const deleteAccountReason = '/delete-account-reason';
  static const starredMessages = '/starred-messages';
  static const cameraPick = '/camera-pick';
  static const adminBlocked = '/adminBlocked';
  static const archivedChats = '/archivedChats';
  static const chatSettings = '/chatSettings';
  static const galleryPicker = '/gallery-picker';
  static const mediaPreview = '/media-preview';
  static const languages = '/languages';
  static const busyStatus = '/busy-status';
  static const dataUsageSetting = '/data_usage_setting';
  static const contactSync = '/contact_sync';
  static const viewAllMediaPreview = '/view-all-media-preview';
  static const addBusyStatus = '/add_busy_status';
  static const addProfileStatus = '/add_profile_status';

  //call
  static const joinCallPreview = '/joinCallPreview';
  static const outGoingCallView = '/outGoingCallView';
  static const onGoingCallView = '/onGoingCallView';
  static const callTimeOutView = '/call-timeout';
  static const participants = '/participants';
  static const groupParticipants = '/groupParticipants';
  static const callInfo = '/call-info';

}
