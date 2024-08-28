
part of 'utils.dart';

class AppUtils{
  AppUtils._();
  static Future<bool> isNetConnected() async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    return isConnected;
  }

  static String getMapImageUrl(double latitude, double longitude,String googleMapKey) {
    // var googleMapKey = Get
    //     .find<MainController>()
    //     .googleMapKey; //Env.googleMapKey;//Constants.googleMapKey;
    return ("https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=13&size=300x200&markers=color:red|$latitude,$longitude&key=$googleMapKey");
  }

  static openDocument(String path) async {
    // if (await askStoragePermission()) {
    if (MediaUtils.isMediaExists(path)) {
      final result = await OpenFile.open(path);
      debugPrint(result.message);
      if (result.message.contains("file does not exist")) {
        toToast(getTranslated("unableToOpen"));
      } else if (result.message.contains('No APP found to open this file')) {
        toToast(getTranslated("youMayNotProperApp"));
      }
    } else {
      toToast(getTranslated("mediaDoesNotExist"));
      debugPrint("media does not exist");
    }
  }

  static Future<void> launchWeb(Uri uri) async {
    if (await AppUtils.isNetConnected()) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw "Could not launch $uri";
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  static Future<void> launchInWebViewOrVC(String url, String title) async {
    if (await AppUtils.isNetConnected()) {
      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: WebViewConfiguration(
            headers: <String, String>{'my_header_key': title}),
      )) {
        throw Exception('Could not launch $url');
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  /// * Build initials with given name.
  /// * @parameter Name instance of Profile name
  /// * return initials of the name.
  static String getInitials(String name){
      String string = "";
      // debugPrint("str.characters.length ${str}");
      if (name.characters.length >= 2) {
        if (name.trim().contains(" ")) {
          var st = name.trim().split(" ");
          string = st[0].characters.take(1).toUpperCase().toString() +
              st[1].characters.take(1).toUpperCase().toString();
        } else {
          string = name.characters.take(2).toUpperCase().toString();
        }
      } else {
        string = name;
      }
      return string;
  }

  static Tuple2<StringBuffer,bool> getActualMemberName(StringBuffer string){
    // LogMessage.d("getActualMemberName","${string} string length ${string.length} characters ${string.toString().characters.length}");
    return (string.toString().characters.length > Constants.maxNameLength) ?
    Tuple2(
      StringBuffer("${string.toString().characters.take(Constants.maxNameLength)}..."),
      false
    )
    :
    Tuple2(string, true);
  }

  static Future<Tuple2<String, ProfileDetails>> getNameAndProfileDetails(String jid) async {
    var profileDetails = await getProfileDetails(jid);
    var name = profileDetails.getName();
    return Tuple2(name, profileDetails);
  }

  static Map getExceptionMap(String code,String message){
    var map = {};
    map["code"]=code;
    map["message"]=message;
    return map;
  }

  static String returnEmptyStringIfNull(dynamic value) {
    return value ?? '';
  }

  /// Checks the current header id with previous header id
  /// @param position Position of the current item
  /// @return boolean True if header changed, else false
  static bool isDateChanged(int position, List<ChatMessageModel> mChatData) {
    // try {
    var prePosition = position + 1;
    var size = mChatData.length - 1;
    if (position == size) {
      return true;
    } else {
      if (prePosition <= size && position <= size) {
        var currentHeaderId = mChatData[position].messageSentTime.toInt();
        var previousHeaderId = mChatData[prePosition].messageSentTime.toInt();
        return currentHeaderId != previousHeaderId;
      }
    }
    return false;
  }

  static String? groupedDateMessage(int index, List<ChatMessageModel> chatList) {
    if(index.isNegative){
      return null;
    }
    if (index == chatList.length - 1) {
      return DateTimeUtils.getDateHeaderMessage(messageSentTime: chatList.last.messageSentTime);
    } else {
      return (isDateChanged(index, chatList) &&
          (DateTimeUtils.getDateHeaderMessage(messageSentTime: chatList[index + 1].messageSentTime) !=
              DateTimeUtils.getDateHeaderMessage(messageSentTime: chatList[index].messageSentTime)))
          ? DateTimeUtils.getDateHeaderMessage(messageSentTime: chatList[index].messageSentTime)
          : null;
    }
  }

  static SvgPicture svgIcon({required String icon, BoxFit fit = BoxFit.contain, ColorFilter? colorFilter, double? width, double? height}) {
    return SvgPicture.asset(icon, fit: fit, colorFilter: colorFilter, width: width, height: height, package: iconPackageName,);
  }

  static Image assetIcon({required String assetName, double? height, double? width, BoxFit fit = BoxFit.cover}) {
    return Image.asset(
      assetName,
      height: height,
      width: width,
      fit: fit, package: iconPackageName
    );
  }

}