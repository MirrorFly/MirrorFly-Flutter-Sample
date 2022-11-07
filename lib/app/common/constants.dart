import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

//Colors
const Color appbarcolor = Color(0xffF2F2F2);
const Color iconcolor = Color(0xff181818);
const Color iconbgcolor = Color(0xff9D9D9D);
const Color appbartextcolor = Color(0xff181818);
const Color statusbarcolor = Color(0xffE5E5E5);
const Color textblackcolor = Color(0xff000000);
const Color textblack1color = Color(0xff313131);
const Color texthintcolor = Color(0xff181818);
const Color textcolor = Color(0xff767676);
const Color textbuttoncolor = Color(0xffFFFFFF);
const Color buttonbgcolor = Color(0xff3276E2);
const Color chatsentbgcolor = Color(0xffe2eafc);
const Color chatreplycontainercolor = Color(0xffD0D8EB);
const Color chatreplysendercolor = Color(0xffEFEFEF);
const Color dividercolor = Color(0XffE2E2E2);
const Color audiocolor = Color(0XffB9C1D6);
const Color audiocolordark = Color(0Xff848FAD);
const Color audiobgcolor = Color(0Xff848FAD);
const Color bottomsheetcolor = Color(0Xff242A3F);

//Assets
const String registericon = 'assets/logos/register_logo.svg';
const String statusicon = 'assets/logos/status.svg';
const String searchicon = 'assets/logos/magnifying_glass.svg';
const String chatfabicon = 'assets/logos/chat_fab.svg';
const String moreicon = 'assets/logos/shape.svg';
const String nocontactsicon = 'assets/logos/no_contacts.png';
const String nochaticon = 'assets/logos/no_messages.png';
const String profileicon = 'assets/logos/avatar.svg';
const String rightarrowicon = 'assets/logos/forward_arrow.svg';
const String chaticon = 'assets/logos/chat.svg';
const String staredmsgicon = 'assets/logos/stared message.svg';
const String notificationicon = 'assets/logos/Notifications.svg';
const String blockedicon = 'assets/logos/blocked_contacts.svg';
const String archiveicon = 'assets/logos/Archive_ic_settings.svg';
const String lockicon = 'assets/logos/lock.svg';
const String abouticon = 'assets/logos/About and Help.svg';
const String connectionicon = 'assets/logos/antenna.svg';
const String toggleofficon = 'assets/logos/toggle OFF.svg';
const String reporticon = 'assets/logos/stared message-1.svg';
const String logouticon = 'assets/logos/logout.svg';
const String pencilediticon = 'assets/logos/pencil.svg';
const String tickicon = 'assets/logos/tick.svg';
const String smileicon = 'assets/logos/smile.svg';

const String audioImg = 'assets/logos/audio.svg';
const String documentImg = 'assets/logos/document.svg';
const String cameraImg = 'assets/logos/camera.svg';
const String contactImg = 'assets/logos/contact.svg';
const String galleryImg = 'assets/logos/gallery.svg';
const String locationImg = 'assets/logos/location.svg';
const String rightArrow = 'assets/logos/right_arrow.svg';

const String downloading = 'assets/logos/downloading.svg';
const String video_play = 'assets/logos/video_play.svg';
const String audio_play = 'assets/logos/audio_play.svg';
const String audio_mic_bg = 'assets/logos/audio_mic.svg';
const String audio_mic = 'assets/logos/mic.svg';
const String audio_mic_1 = 'assets/logos/mic1.svg';
const String profile_img = 'assets/logos/profile_img.png';

const String pdf_image = 'assets/logos/pdf.svg';
const String ppt_image = 'assets/logos/ppt.svg';
const String xls_image = 'assets/logos/xls.svg';
const String xlsx_image = 'assets/logos/xlsx.svg';
const String doc_image = 'assets/logos/doc.svg';
const String apk_image = 'assets/logos/apk.svg';
const String Mcontacticon = 'assets/logos/Contact.svg';
const String Mdocumenticon = 'assets/logos/Document.svg';
const String Mimageicon = 'assets/logos/image.svg';
const String Mlocationicon = 'assets/logos/Location.svg';
const String Mvideoicon = 'assets/logos/Video.svg';
const String Maudioicon = 'assets/logos/noun_Audio_3408360.svg';
const String cornershadow = 'assets/logos/ic_baloon.png';

const String replyIcon = 'assets/logos/reply.svg';
const String forwardIcon = 'assets/logos/forward.svg';
const String deleteIcon = 'assets/logos/delete.svg';
const String cancelIcon = 'assets/logos/close.svg';
const String favouriteIcon = 'assets/logos/star.svg';
const String unfavouriteIcon = 'assets/logos/star.svg';
const String copyIcon = 'assets/logos/copy.svg';
const String infoIcon = 'assets/logos/info.svg';

const String profileImg = 'assets/logos/profile_img.png';
const String groupImg = 'assets/logos/ic_grp_bg.png';


//Strings
const imagedomin = 'https://api-uikit-qa.contus.us/api/v1/media/';


toToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      fontSize: 16.0);
}
Log(String tag,String msg){
  if (kDebugMode) {
    print("Mirrorfly : "+tag+" ==> "+msg);
  }
}
class Constants {

  static const String TAG = 'Contus Fly';
  static const String GOOGLE_MAP_KEY = "AIzaSyBaKkrQnLT4nacpKblIE5d4QK6GpaX5luQ";
  static const String GOOGLE_MAP_PACKAGE_NAME = "com.google.android.apps.maps";
  static const String PACKAGE_NAME = "com.contus.flycommons.";
  static const String ROSTER_JID = "roster_jid";
  static const String IS_LIVE_USER = "is_live_user";
  static const String IF_BLOCKED_ME = "ifBlockedMe";
  static const String BLOCKED_ME = "BlockedMe";
  static const String IS_MUTE = "is_mute";
  static const String MOBILE_NO = "mobileNumber";
  static const String EMAIL = "email";
  static const String TITLE = "title";
  static const String TITLE_MESSAGE = "Messages";
  static const String PROFILE = "profile";
  static const String SELECTED_IMAGE = "selected_image";
  static const int COUNT_ONE = 1;
  static const int COUNT_ZERO = 0;
  static const String TOTAL_PAGES = "total_pages";
  static const String IS_NEW_USER = "is_new_user";
  static const String MEDIA_URL = "url";
  static const String RESPONSE = "response";
  static const String MESSAGE = "message";
  static const String ERROR = "error";
  static const String USER_STATUS = "user_status";
  static const String USER_BUSY_STATUS = "user_busy_status";
  static const String ANDROID = "android";
  static const String IMAGE = "image";
  static const String EMPTY_STRING = "";
  static const String ENCRYPT_STRING = " Encrypted";
  static const String COMPOSING = "Composing";
  static const String GONE = "Gone";
  static const String LAST_SEEN = "lastseen";
  static const String ONLINE = "Online";
  static const String PRESENCE_AVAILABLE = "presence_available";
  static const String PRESENCE_CHANGED = "presence_changed";
  static const String FROM_SPLASH = "from_splash";
  static const String INVITE_LIST = "invite_list";
  static const String DATA = "data";
  static const String USER_LIST = "user_list";
  static const String IS_BROADCAST = "is_broadcast";
  static const String IS_UPLOAD_SUCCESS = "is_upload_success";
  static const String QUICK_SHARE = "QUICK_SHARE";
  static const String SEEN_UPDATED = "Seenupdated";
  static const String IS_ARCHIVED_SETTINGS_ENABLED = "com.contus.flycommons.is_archived_settings_enabled";
  static const int MAX_REPORT_MESSAGES_COUNT = 5;
  static const String CHATTYPE = "chatType";
  static const String FROM_USER = "from";
  static const String TO_USER = "to";
  static const String DATA_ARRAY = "data";
  static const String MESSAGE_TXT = "message";
  static const String MSG_ID = "msgId";
  static const String FILE_NAME = "filename";
  static const String MESSAGE_TYPE = "msgType";
  static const String TIME_STAMP = "timestamp";
  static const String PUBLISHER_ID = "publisherId";
  static const String NAME = "name";
  static const String PAGE = "page";
  static const String SIZE = "size";
  static const String IS_BUSY_STATUS_ENABLED = "com.contus.flycommons.is_busy_status_enabled";
  static const String XMPP_DOMAIN = "xmppDomain";
  static const String XMPP_PORT = "xmppPort";
  static const String XMPP_HOST = "xmppHost";
  static const String SIGNAL_SERVER_DOMAIN = "signalServerDomain";
  static const String CALL_ROUTING_SERVER = "callRoutingServer";
  static const String STUNS = "stuns";
  static const String TURNS = "turns";
  static const String MESSAGE_IV = "iv";
  static const String PROFILE_IV = "ivProfile";
  static const String RESPONSE_PARAMETER_STATUS = "status";
  static const String RESPONSE_PARAMETER_DATA = "data";
  static const String STATUS_CODE_SUCCESS = "200";
  static const String STATUS_CODE_SECURITY_TOKEN_ERROR = "401";
  static const String STATUS_INTERNAL_SERVER_ERROR = "500";
  static const String DEVICE_TYPE = "deviceType";
  static const String DEVICE_OS = "deviceOs";
  static const String DEVICE_OS_VERSION = "deviceOsVersion";
  static const String MODE = "mode";
  static const String USER_IDENTIFIER = "userIdentifier";
  static const String VOIP_DEVICE_TOKEN = "voipDeviceToken";
  static const String DEVICE_MODEL = "deviceModel";
  static const String APP_VERSION = "appVersion";
  static const String DESCRIPTION = "description";
  static const String FILETOKEN = "fileToken";
  static const String STATUS_CODE_NOTFOUND = "204";
  static const String BACKUP_TYPE = "chatBackupType";
  static const String BACKUP_FREQUENCY = "chatBackupFrequency";
  static const String SAME_USER = "same_user";
  static const String NOTIFICATION_NOT_WORKING_URL = "notificationHelpUrl";
  static const String LATITUDE = "latitude";
  static const String LONGITUDE = "longitude";
  static const String CHAT_MESSAGE = "chatmessage";
  static const String MESSAGE_ID = "messageId";
  static const String NETWORK_FAILURE = "network_failure";
  static const String MESSAGE_IDS = "messageIds";
  static const String OTP = "otp";
  static const String GOOGLE_TOKEN = "google_token";
  static const String MESSAGE_FROM = "messageFrom";
  static const String MESSAGE_TO = "messageTo";
  static const String TYPE = "type";
  static const String MESSAGE_TIME = "message_time";
  static const String MESSAGE_TITLE = "title";
  static const String CHAT_TYPE = "chat_type";
  static const String GROUP_VCARD = "group_vcard";
  static const String PUBLISHER_PROFILE = "publisher_profile";
  static const String ADD_FROM_INFO = "add_info_info";
  static const String DELETE_TYPE = "delete_type";
  static const String MESSAGE_FAVOURITE = "message_favourite";
  static const String MESSAGE_CONTENT = "message_content";
  static const String IS_FIRST_LOGIN = "is_first";
  static const String DOMAIN = "domain";
  static const String VIDEO_LIMIT = "videoLimit";
  static const String AUDIO_LIMIT = "audioLimit";
  static const String PROFILE_NAME = "profile_name";
  static const String CREATE_GROUP = "create_group";
  static const String CREATE_BROADCAST = "create_broadcast";
  static const String PROFILE_IMAGE = "profile_image";
  static const String USERNAME = "username";
  static const String SECRET_KEY = "password";
  static const String CURRENET_TIME_STAMP = "currentTimestamp";
  static const String LOGIN_DATA = "loginData";
  static const String STRING_DATA = "string";
  static const String CONFIG = "config";
  static const String DEVICE_TOKEN = "deviceToken";
  static const String USER_BUSY = "user_busy";
  static const String SELECTED_IMAGES = "selected_images";
  static const String SELECTED_VIDEO = "selected_video";
  static const String SELECTED_VIDEO_CAPTION = "selected_video_caption";
  static const int ACTIVITY_REQ_CODE = 111;
  static const int EDIT_REQ_CODE = 112;
  static const int PICK_CONTACT_REQ_CODE = 123;
  static const int SELECT_CONTACT_REQ_CODE = 124;
  static const int SELECT_IMAGE_REQ_CODE = 125;
  static const int SELECT_MAP_REQ_CODE = 118;
  static const int COUNTRY_REQUEST_CODE = 118;
  static const int TAKE_VIDEO = 3;
  static const int PICK_FILE = 4;
  static const int COUNT_TWO = 2;
  static const int GROUP_NAME_UPDATE = 2;
  static const int STORAGE_PERMISSION_CODE = 233;
  static const int LOCATION_PERMISSION_CODE = 234;
  static const int VIDEO_CALL_PERMISSION_CODE = 235;
  static const int CAMERA_PERMISSION_CODE = 236;
  static const int CALL_PHONE_PERMISSION_CODE = 2;
  static const int GALLERY_PERMISSION_CODE = 222;
  static const int RECORD_AUDIO_CODE = 237;
  static const int READ_CONTACTS_PERMISSION_CODE = 238;
  static const int ALL_PERMISSIONS_CODE = 239;
  static const int AUDIO_SELECTION_PERMISSIONS_CODE = 240;
  static const int ONE_SECOND = 1000;
  static const int SHORT_VIBRATE = 250;
  static const int ONE_KB = 1024;
  static const String MSG_TYPE_TEXT = "text";
  static const String MSG_TYPE_CONTACT = "contact";
  static const String MSG_TYPE_NOTIFICATION = "notification";
  static const String EXPORT_PATH = "Export files";
  static const String VIDEO_LOCAL_PATH = "Video";
  static const String VIDEO_PREFIX = "VID_";
  static const String IMAGE_PREFIX = "IMG_";
  static const String IMAGE_LOCAL_PATH = "Image";
  static const String AUDIO_LOCAL_PATH = "Audio";
  static const String FILE_LOCAL_PATH = "File";
  static const String FILE_PATH = "file_path";
  static const String COUNTRY_CODE = "countryCode";
  static const String MEDIA_ENCRYPTION = "media_encryption";
  static const String HIPAA_COMPLAINCE = "hipaa_complaince";
  static const String COUNTRY_NAME = "countryName";
  static const String POSITION = "Position";
  static const String CHAT_NAME = "text_chat_name";
  static const String MESSAGES_TO_DELETE = "messages_to_delete";
  static const String REPLY_MESSAGE_ID = "reply_message_id";
  static const String REPLY_MESSAGE_USER = "reply_message_user";
  static const String MSG_TYPE_LOCATION = "location";
  static const String MSG_TYPE_VIDEO = "video";
  static const String MSG_TYPE_AUDIO = "audio";
  static const String AUDIO_TYPE_RECORDING = "recording";
  static const String AUDIO_TYPE_FILE = "file";
  static const String MSG_TYPE_IMAGE = "image";
  static const String MSG_TYPE_AUTO_TEXT = "auto_text";
  static const String MSG_SENT = "N";
  static const String MSG_ACK = "A";
  static const String MSG_DELIVERED = "D";
  static const String MSG_SEEN = "S";
  static const bool CHAT_FROM_SENDER = true;
  static const int TYPE_ABOUT_US = 2;
  static const int TYPE_NOTIFICATION = 3;
  static const int TYPE_USER_BUSY_STATUS = 4;
  static const int NOTIFICATION_ID = 123;
  static const String MIME_TYPE_IMAGE = "image/*";
  static const String TEMP_PHOTO_FILE_NAME = "temp_photo";
  static const String ERROR_SERVER = "Server error, kindly try again later";
  static const String ERR_SELECT_CONTACT = "You are not able to select any contact";
  static const String GROUP_ID = "group_id";
  static const String GROUP_NAME = "group_name";
  static const String GROUP_PROFILE_IMAGE = "group_profile_image";
  static const String GROUP_PROFILE = "group_profile";
  static const String O = "o";
  static const String N = "n";
  static const String INFO_END_POINT = "register/info";
  static const String SETTINGS_END_POINT = "users/config";
  static const String GET_OTP_END_POINT = "requestotp";
  static const String VERIFY_TOKEN_END_POINT = "verifyuser";
  static const String REGISTER_END_POINT = "register";
  static const String REFRESH_TOKEN_ENDPOINT = "login";
  static const String MESSAGE_DELIVERY_ENDPOINT = "users/delivered";
  static const String CONTACT_SYNC_ENDPOINT = "contacts/";
  static const String NEW_CONTACT_SYNC_ENDPOINT = "contacts/syncContactsNew";
  static const String LOGOUT_ENDPOINT = "logout";
  static const String FIREBASE_TOKEN_ENDPOINT = "users/device";
  static const String CALLS_ENDPOINT = "users/calls";
  static const String USER = "user/getpassword";
  static const String BACKUP_DOWNLOAD = "backup/restore";
  static const String BACKUP_UPLOAD = "backup/";
  static const String BACKUP_CHECK = "backup/details";
  static const String IS_BACKUP_AVAILABLE = "is_backup_available";
  static const String BACKUP_FILE_SIZE = "backup_file_size";
  static const String BACKUP_FILE_DATE = "backup_file_date";
  static const String FROM_CONTACT_SYNC = "from_contact_sync";
  static const String AUTH_TOKEN = "authToken";
  static const String CONNECTING = "Connecting";
  static const String TYPE_SEARCH_RECENT = "Chats";
  static const String TYPE_SEARCH_CONTACT = "Contact";
  static const String TYPE_SEARCH_MESSAGE = "Message";
  static const int ROSTER = 1;
  static const String YOU = "You";
  static const String HINT = "hint";
  static const String MAX_UPLOAD_SIZE = "2";
  static const String MAX_FILE_UPLOAD_COUNT = "5";
  static const String TYPE_NORMAL = "normal";
  static const String TYPE_SEEN = "seen";
  static const String USER_JID = "user_jid";
  static const String IS_IMAGE = "is_image";
  static const String SENT_FROM = "sent_from";
  static const String SENT_FROM_USERNAME = "sent_from";
  static const String NOTIFY_ID = "notify_id";
  static const String MSG_TYPE_FILE = "file";
  static const String TEXT_COUNT = "text_count";
  static const int MIN_GROUP_MEMBERS = 2;
  static const int MAX_TEXT_COUNT = 139;
  static const int MAX_NAME_COUNT = 30;
  static const String FRAGMENT_TYPE = "fragment_type";
  static const String WEB_USER_TOKEN = "web_user_token";
  static const int MAX_GROUP_NAME_COUNT = 25;
  static const String ACTION_REMOVE = "admin_remove_action";
  static const String ACTION_EXIT = "admin_exit_group";
  static const String MIME_TYPE_VIDEO = "video/*";
  static const String MIME_TYPE_FILE = "application/*";
  static const String MSG_SENT_PATH = "Sent";
  static const String MSG_RECEIVED_PATH = "Received";
  static const String MSG_RECEIVED_IMAGE = "Images";
  static const String MSG_RECEIVED_VIDEO = "Videos";
  static const String MSG_RECEIVED_AUDIO = "Audio";
  static const String MSG_RECEIVED_FILE = "Files";
  static const String BACKUP_FOLDER = "Backups";
  static const String YESTERDAY = "yesterday";
  static const String TODAY = "today";
  static const String YESTERDAY_UPPER = "YESTERDAY";
  static const bool IS_MOBILE_LOGIN = true;
  static const String DIAL_CODE = "dialCode";
  static const String NOTIFICATION_ACTIVITY = "";
  static const String IS_BLOCKED = "is_blocked";
  static const String RECALL_TIME = "recallTime";
  static const String PRIVATE_TIME = "privateTime";
  static const String RECALL = "recall";
  static const String TYPE_CALL = "call";
  static const String MEDIA_CALL = "mediacall";
  static const String MISSED_CALL_COUNT = "missed_call_count";
  static const String IS_CARBON_DELIVERY_RECEIPT = "carbon";
  static const String TO_JID = "to_jid";
  static const String AUTHORIZATION_HEADER_KEY = "Authorization";
  static const String AUTHORIZATION_HEADER_PREFIX = "Bearer %s";
  static const String MUTE_NOTIFY = "mute_notification";
  static const String UN_MUTE_NOTIFY = "unmute_notification";
  static const String LOGOUT_PIN = "logOutPin";
  static const String PIN_EXPIRE_BIOMETRIC = "pin_expired_biometric";
  static const String STAR = "star";
  static const String UNSTAR = "unstar";
  static const String SHARE = "share";
  static const String FORWARD = "forward";
  static const String DELETE = "delete";
  static const String REPLY = "reply";
  static const String COPY = "copy";
  static const String INFO = "info";
  static const String FROM_FORWARD = "from_forward";
  static const String PROGRESS_PERCENTAGE = "progress_percentage";
  static const String FILE_UPLOAD_ENDPOINT = "media/";
  static const String DRIVE_BACKUP = "personal";
  static const String SERVER_BACKUP = "on-prem";
  static const String SKIP_PROFILE = "skip_profile";
  static const String CREATE_CONFERENCE = "create_conference";
  static const String RESPONSE_PARAMETER_URL = "fileToken";
  static const int DEFAULT_VIBRATE = 500;
  static const String DEFAULT_IV = "ddc0f15cc2c90fca";
  static const String DEFAULT_COUNTRY_CODE = "IN";
  static const String MIME_TYPE_AUDIO = "audio/*";
  static const String MAIL_SUBJECT = "Invite to Connect ContusFly";
  static const String YOU_ARE = "You are";
  static const String RESOURCE_NME = "Mobile";
  static  const int CONTACT_REQ_CODE = 114;
  static const String IS_FROM_NOTIFICATION = "is_from_notification";
  static const String UTF = "UTF-8";
  static const String NOTIFICATION_CHANNEL_ID = "com.contus.flycommons.notification";
  static const String INFO_COPY_TEXT_SUCCESS = "Text copied successfully to the clipboard";
  static const String DAILY = "daily";
  static const String WEEKLY = "weekly";
  static const String MONTHLY = "monthly";
  static const String LIVE_STREAM_URL = "liveStreamingSignalServer";
  static const String IS_LIVE_STREAM_ENABLED = "isLiveStreamingEnabled";
  static const String GOOGLE_TRANSLATE = "googleTranslate";
  static const String REFRESH_CALL_LOGS = "call_logs_refresh";
  static const String UNSYNCED_CALL_LOGS = "unSyncedCallLogs";
  static const String DELETE_ALL = "delete_all";
  static const String CALL_IDS = "call_ids";
  static const String TIMESTAMP = "timestamp";
  static const String INTENT_PHONE_NUMBERS = "INTENT_PHONE_NUMBERS";
  static const String USE_PROFILE_NAME = "use_profile_name";
  static const String ENABLE_MOBILE_NUMBER_LOGIN = "enable_mobile_number_login";
  static const String IS_TRIAL_LICENCE_KEY = "is_trial_licence_key";
  static const String LICENSE_KEY = "licenseKey";
  static const String BASE_URL = "com.contus.flycommons.base_url";
  static const String STORAGE_FOLDER_NAME = "folder_name";
  static const String API_KEY = "com.contus.flycommons.api_key";
  static const String MIX = "@mix.";

  static const String GROUP_EVENT = "group_events";
  static const String ARCHIVE_EVENT = "archive_events";
  static const String MESSAGE_RECEIVED = "message_received";
  static const String MESSAGE_UPDATED = "message_updated";
  static const String MEDIA_STATUS_UPDATED = "media_status_updated";
  static const String MEDIA_UPLOAD_DOWNLOAD_PROGRESS = "media_upload_download_progress";
  static const String MUTE_EVENT = "mute_event";
  static const String PIN_EVENT = "pin_event";

  static const String Terms_Conditions = "https://www.mirrorfly.com/terms-and-conditions.php";
  static const String Privacy_Policy = "https://www.mirrorfly.com/privacy-policy.php";

  static const List<String> defaultStatuslist = ["Available","Sleeping...","Urgent calls only","At the movies","I am in Mirror Fly"];
  static const List<int> defaultColorList = [
    0Xff9068BE,
    0XffE62739,
    0Xff845007,
    0Xff3A4660,
    0Xff1D1E22,
    0XffBE7D6A,
    0Xff005995,
    0Xff600473,
    0XffCD5554,
    0Xff00303F,
    0XffBE4F0C,
    0Xff4ABDAC,
    0XffFC4A1A,
    0Xff368CBF,
    0Xff7EBC59,
    0Xff201D3A,
    0Xff269CCC,
    0Xff737272,
    0Xff237107,
    0Xff52028E,
    0XffAF0D74,
    0Xff6CB883,
    0Xff0DAFA4,
    0XffA71515,
    0Xff157FA7,
    0Xff7E52B1,
    0Xff27956A,
    0Xff9A4B70,
    0XffFBBE30,
    0XffED3533,
    0Xff571C8D,
    0Xff54181C,
    0Xff9B6700,
    0Xff6E8E14,
    0Xff0752A1,
    0XffBF6421,
    0Xff00A59C,
    0Xff9F0190,
    0XffAE3A3A,
    0Xff858102,
    0Xff027E02,
    0XffF66E54
  ];
  static const String defaultstatus = "I am in Mirror Fly";

  static const int MEDIA_DOWNLOADING = 3;
  static const int MEDIA_DOWNLOADED = 4;
  static const int MEDIA_NOT_DOWNLOADED = 5;
  static const int MEDIA_DOWNLOADED_NOT_AVAILABLE = 6;
  static const int MEDIA_NOT_UPLOADED = 0;
  static const int MEDIA_UPLOADING = 1;
  static const int MEDIA_UPLOADED = 2;
  static const int MEDIA_UPLOADED_NOT_AVAILABLE = 7;


  static const double borderRadius = 27;
  static const double defaultPadding = 8;

  // static GlobalKey<AnimatedListState> audioListKey =
  // GlobalKey<AnimatedListState>();

  static const String PDF = "pdf";
  static const String PPT = "ppt";
  static const String DOC = "doc";
  static const String DOCX = "docx";
  static const String APK = "apk";
  static const String XLS = "xls";
  static const String XLXS = "xlsx";

  //Message Types
  static const String MTEXT = "TEXT";
  static const String MIMAGE = "IMAGE";
  static const String MAUDIO = "AUDIO";
  static const String MVIDEO = "VIDEO";
  static const String MCONTACT = "CONTACT";
  static const String MLOCATION = "LOCATION";
  static const String MDOCUMENT = "DOCUMENT";
  static const String MNOTIFICATION = "NOTIFICATION";
}

Future<void> launchWeb(String url) async{
  if (await canLaunchUrl(Uri.parse(url)))
    await launchUrl(Uri.parse(url));
  else
    // can't launch url, there is some error
    throw "Could not launch $url";
}

Widget forMessageTypeIcon(String MessageType) {
  switch (MessageType.toUpperCase()) {
    case Constants.MIMAGE:
      return SvgPicture.asset(
        Mimageicon,
        fit: BoxFit.contain,
      );
    case Constants.MAUDIO:
      return SvgPicture.asset(
        Maudioicon,
        fit: BoxFit.contain,
      );
    case Constants.MVIDEO:
      return SvgPicture.asset(
        Mvideoicon,
        fit: BoxFit.contain,
      );
    case Constants.MDOCUMENT:
      return SvgPicture.asset(
        Mdocumenticon,
        fit: BoxFit.contain,
      );
    case Constants.MCONTACT:
      return SvgPicture.asset(
        Mcontacticon,
        fit: BoxFit.contain,
      );
    case Constants.MLOCATION:
      return SvgPicture.asset(
        Mlocationicon,
        fit: BoxFit.contain,
      );
    default:
      return const SizedBox();
  }
}

String? forMessageTypeString(String MessageType) {
  switch (MessageType.toUpperCase()) {
    case Constants.MIMAGE:
      return "Image";
    case Constants.MAUDIO:
      return "Audio";
    case Constants.MVIDEO:
      return "Video";
    case Constants.MDOCUMENT:
      return "Document";
    case Constants.MCONTACT:
      return "Contact";
    case Constants.MLOCATION:
      return "Location";
    default:
      return null;
  }
}

Future<File> writeImageTemp(dynamic bytes, String imageName) async {
  final dir = await getTemporaryDirectory();
  await dir.create(recursive: true);
  final tempFile = File((dir.path) + "/" + imageName);
  await tempFile.writeAsBytes(bytes);
  return tempFile;
}