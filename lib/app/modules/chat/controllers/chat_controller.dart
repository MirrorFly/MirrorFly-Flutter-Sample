import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:io' as Io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/model/chatMessageModel.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';

import '../../../common/constants.dart';
import '../../../model/checkModel.dart';
import '../../../model/userlistModel.dart';
import '../../../routes/app_pages.dart';

class ChatController extends GetxController with GetSingleTickerProviderStateMixin{
  //TODO: Implement DashboardController

  var chatList = List<ChatMessageModel>.empty(growable: true).obs;
  late AnimationController controller;
  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  TextEditingController messageController = TextEditingController();

  FocusNode focusNode = FocusNode();

  var calendar = DateTime.now();
  Profile profile = Get.arguments as Profile;
  var base64img = ''.obs;
  var imagePath = ''.obs;

  var showEmoji = false.obs;

  var isLive = false;
  @override
  void onInit() {
    super.onInit();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    isLive = true;
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showEmoji(false);
      }
    });
    scrollController.addListener(() {
      double offset = 0.9 * scrollController.position.maxScrollExtent;

      if (scrollController.position.pixels > offset) {
        debugPrint('scrollController offset > load more');
      }
    });
    registerChatSync();
    PlatformRepo().ongoingChat(profile.jid!);
    getChatHistory(profile.jid!);
    debugPrint("==================");
    debugPrint(profile.image);
    sendReadReceipt();

  }

  @override
  void onClose() {

    scrollController.dispose();
    PlatformRepo().ongoingChat("");
    isLive = false;
    super.onClose();
  }

  @override
  void dispose() {
    controller.dispose();
    Get.delete<ChatController>();
    super.dispose();
  }

  registerChatSync() {
    var messageEvent = PlatformRepo().userChats;
    messageEvent.listen((msgData) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(msgData);
      final index = chatList.indexWhere(
          (message) => message.messageId == chatMessageModel.messageId);

      debugPrint("index of search $index");
      if (index >= 0) {
        debugPrint("already Value Exists ===> $index");
        chatList[index] = chatMessageModel;
      } else if(index == -1){
        debugPrint("value not found");
        chatList.add(chatMessageModel);
        if(isLive) {
          sendReadReceipt();
        }
      }else{
        debugPrint("Issue updating Message ==>$index");
      }

      // ChatMessageModel chatMessageModel = sendMessageModelFromJson(msgData);
      // chatList.add(chatMessageModel);
    });
  }

  sendMessage(Profile profile) {
    // z7qsc3p1lt@xmpp-preprod-sandbox.mirrorfly.com => phone
    // 1v6v8mdc0v@xmpp-preprod-sandbox.mirrorfly.com => simulator
    //7010279986@xmpp-uikit-qa.contus.us => 7010279986 // Device QA
    //9566752183@xmpp-uikit-qa.contus.us => 7010279986 // Device QA
    if (messageController.text.trim().isNotEmpty) {
      PlatformRepo()
          .sendTextMessage(messageController.text, profile.jid.toString())
          .then((value) {
        messageController.text = "";
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.add(chatMessageModel);
        // if (scrollController.hasClients) {
        //   scrollController.animateTo(
        //     0.0,
        //     curve: Curves.easeOut,
        //     duration: const Duration(milliseconds: 300),
        //   );
        // }
      });
    }
  }

  String gettime(int? timestamp) {
    DateTime now = DateTime.now();
    final DateTime date1 = timestamp == null
        ? now
        : DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = DateFormat('hh:mm a').format(date1); //yyyy-MM-dd –
    // var fm1 = DateFormat('hh:mm a').parse(formattedDate, true);
    return formattedDate;
  }
  String getChatTime(BuildContext context,int? epochTime)  {
    if(epochTime==null) return "";
    if (epochTime == 0) return "";
    var convertedTime = epochTime;// / 1000;
    //messageDate.time = convertedTime
    var hourTime = manipulateMessageTime(context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
    var currentYear = DateTime.now().year;
    calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    var time = (currentYear == calendar.year) ? DateFormat("dd-MMM").format(calendar) : DateFormat("yyyy/MM/dd").format(calendar);
    return hourTime;
  }

  String manipulateMessageTime(BuildContext context,DateTime messageDate) {
    var format = MediaQuery.of(context).alwaysUse24HourFormat ? 24 : 12;
    var hours = calendar.hour;//calendar[Calendar.HOUR]
    calendar = messageDate;
    var dateHourFormat = setDateHourFormat(format, hours);
    return DateFormat(dateHourFormat).format(messageDate);
  }
  String setDateHourFormat(int format, int hours) {
    var dateHourFormat = (format == 12) ? (hours < 10) ? "hh:mm aa" : "h:mm aa" : (hours < 10) ? "HH:mm" : "H:mm";
    return dateHourFormat;
  }

  getChatHistory(String jid) {
    PlatformRepo().getChatHistory(jid).then((value) {
      List<ChatMessageModel> chatMessageModel = chatMessageModelFromJson(value);
      chatList(chatMessageModel);
      // if (scrollController.hasClients) {
      //   scrollController.animateTo(
      //     0.0,
      //     curve: Curves.easeOut,
      //     duration: const Duration(milliseconds: 300),
      //   );
      // }
    });
  }

  getMedia(String mid) {

    return PlatformRepo().getMedia(mid).then((value) {
      // debugPrint("Media==> $value");
      CheckModel chatMessageModel = checkModelFromJson(value);
      String thumbImage = chatMessageModel.mediaChatMessage.mediaThumbImage;
      thumbImage = thumbImage.replaceAll("\n", "");
      // debugPrint("Thumbnail ==> $thumbImage");
      return thumbImage;
    });

    // return imageFromBase64String(chatMessageModel.mediaChatMessage!.mediaThumbImage!);
    // // return media;
    // return base64Decode(chatMessageModel.mediaChatMessage.mediaThumbImage);
  }


  Image imageFromBase64String(String base64String, BuildContext context) {
    var decodedBase64 = base64String.replaceAll("\n", "");
    Uint8List image = const Base64Decoder().convert(decodedBase64);
    return Image.memory(image, width: MediaQuery.of(context).size.width * 0.60, height: MediaQuery.of(context).size.height * 0.4, fit: BoxFit.cover,);
  }

  sendImageMessage(String? path, String? caption, String? replyMessageID) {
    return PlatformRepo().sendImageMessage(profile.jid!, path!, caption, replyMessageID).then((value){
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);

      return chatMessageModel;
    });

  }

  Future imagePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false,type: FileType.custom, allowedExtensions: ['jpg', 'png', 'mp4', 'mov', 'wmv', 'mkv'],);
    if (result != null && File(result.files.single.path!).existsSync()) {
      debugPrint(result.files.first.extension);
      if(result.files.first.extension == 'jpg' || result.files.first.extension == 'png') {
        debugPrint("Picked Image File");
        imagePath.value = (result.files.single.path!);
        Get.toNamed(Routes.IMAGEPREVIEW, arguments: {
          "filePath": imagePath.value,
          "userName": profile.name!
        });
      }else if(result.files.first.extension == 'mp4' || result.files.first.extension == 'mov' || result.files.first.extension == 'mkv'){
        debugPrint("Picked Video File");
        imagePath.value = (result.files.single.path!);
        Get.toNamed(Routes.VIDEO_PREVIEW, arguments: {
          "filePath": imagePath.value,
          "userName": profile.name!
        });
      }

    } else {
      // User canceled the picker
    }
  }

  sendReadReceipt() {
    PlatformRepo().sendReadReceipts(profile.jid!).then((value) {
      debugPrint("Chat Read Receipt Response ==> $value");
    });
  }

  sendVideoMessage(String videoPath, String caption, String replyMessageID) {
    return PlatformRepo().sendMediaMessage(profile.jid!, videoPath, caption, replyMessageID).then((value){
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      return chatMessageModel;
    });
  }

  checkFile(String mediaLocalStoragePath){
    return mediaLocalStoragePath.isNotEmpty && File(mediaLocalStoragePath).existsSync();
  }

  downloadMedia(String messageId) {
    PlatformRepo().mediaDownload(messageId);
  }


}
