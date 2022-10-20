import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:io' as Io;

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/model/chatMessageModel.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/constants.dart';
import '../../../data/contact_utils.dart';
import '../../../model/checkModel.dart' as checkModel;
import '../../../model/userlistModel.dart';
import '../../../routes/app_pages.dart';

class ChatController extends GetxController
    with GetSingleTickerProviderStateMixin {
  //TODO: Implement DashboardController

  var chatList = List<ChatMessageModel>.empty(growable: true).obs;
  late AnimationController controller;
  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );


  String currentpostlabel = "00:00";

  var maxduration = 100.obs;
  var currentpos = 0.obs;
  var isplaying = false.obs;
  var audioplayed = false.obs;
  // late Uint8List audiobytes;

  AudioPlayer player = AudioPlayer();

  TextEditingController messageController = TextEditingController();

  FocusNode focusNode = FocusNode();

  var calendar = DateTime.now();
  Profile profile = Get.arguments as Profile;
  var base64img = ''.obs;
  var imagePath = ''.obs;
  var filePath = ''.obs;

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

    player.onDurationChanged.listen((Duration d) { //get the duration of audio
      maxduration(d.inMilliseconds);

    });

    player.onPlayerCompletion.listen((event) {
      isplaying(false);
      audioplayed(false);
    });

    player.onAudioPositionChanged.listen((Duration  p){
      currentpos(p.inMilliseconds); //get the current position of playing audio

      int milliseconds = currentpos.value;
      //generating the duration label
      int shours = Duration(milliseconds:milliseconds).inHours;
      int sminutes = Duration(milliseconds:milliseconds).inMinutes;
      int sseconds = Duration(milliseconds:milliseconds).inSeconds;

      int rhours = shours;
      int rminutes = sminutes - (shours * 60);
      int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

      currentpostlabel = "$rhours:$rminutes:$rseconds";

    });

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
    var messageEvent = PlatformRepo().onMessageReceived;
    messageEvent.listen((msgData) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(msgData);

      chatList.add(chatMessageModel);
        if(isLive) {
          sendReadReceipt();
        }
      // if (index >= 0) {
      //   debugPrint("already Value Exists ===> $index");
      //   chatList[index] = chatMessageModel;
      // } else if(index == -1){
      //   debugPrint("value not found");
      //   chatList.add(chatMessageModel);
      //   if(isLive) {
      //     sendReadReceipt();
      //   }
      // }else{
      //   debugPrint("Issue updating Message ==>$index");
      // }

      // ChatMessageModel chatMessageModel = sendMessageModelFromJson(msgData);
      // chatList.add(chatMessageModel);
    });


    PlatformRepo().onMessageStatusUpdated.listen((msgData) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(msgData);
      final index = chatList.indexWhere(
              (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("Message Status Update index of search $index");
      if(index != -1){
        chatList[index] = chatMessageModel;
      }
    });
    PlatformRepo().onMediaStatusUpdated.listen((msgData) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(msgData);
      final index = chatList.indexWhere(
              (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("Media Status Update index of search $index");
      if(index != -1){
        chatList[index] = chatMessageModel;
      }
    });
  }

  sendMessage(Profile profile) {
    if (messageController.text.trim().isNotEmpty) {
      PlatformRepo()
          .sendTextMessage(messageController.text, profile.jid.toString())
          .then((value) {
        messageController.text = "";
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.add(chatMessageModel);
      });
    }
  }

  sendLocationMessage(Profile profile, double latitude, double longitude) {
    PlatformRepo()
        .sentLocationMessage(null, profile.jid.toString(), latitude, longitude)
        .then((value) {
      Log("Location_msg", value.toString());
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
    });
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

  String getChatTime(BuildContext context, int? epochTime) {
    if (epochTime == null) return "";
    if (epochTime == 0) return "";
    var convertedTime = epochTime; // / 1000;
    //messageDate.time = convertedTime
    var hourTime = manipulateMessageTime(
        context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
    var currentYear = DateTime.now().year;
    calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    var time = (currentYear == calendar.year)
        ? DateFormat("dd-MMM").format(calendar)
        : DateFormat("yyyy/MM/dd").format(calendar);
    return hourTime;
  }

  String manipulateMessageTime(BuildContext context, DateTime messageDate) {
    var format = MediaQuery.of(context).alwaysUse24HourFormat ? 24 : 12;
    var hours = calendar.hour; //calendar[Calendar.HOUR]
    calendar = messageDate;
    var dateHourFormat = setDateHourFormat(format, hours);
    return DateFormat(dateHourFormat).format(messageDate);
  }
  String setDateHourFormat(int format, int hours) {
    var dateHourFormat = (format == 12)
        ? (hours < 10)
            ? "hh:mm aa"
            : "h:mm aa"
        : (hours < 10)
            ? "HH:mm"
            : "H:mm";
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
      checkModel.CheckModel chatMessageModel = checkModel.checkModelFromJson(value);
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
    return Image.memory(
      image,
      width: MediaQuery.of(context).size.width * 0.60,
      height: MediaQuery.of(context).size.height * 0.4,
      fit: BoxFit.cover,
    );
  }

  sendImageMessage(String? path, String? caption, String? replyMessageID) {
    return PlatformRepo()
        .sendImageMessage(profile.jid!, path!, caption, replyMessageID)
        .then((value) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);

      return chatMessageModel;
    });

  }

  Future imagePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4', 'mov', 'wmv', 'mkv'],
    );
    if (result != null && File(result.files.single.path!).existsSync()) {
      debugPrint(result.files.first.extension);
      if (result.files.first.extension == 'jpg' ||
          result.files.first.extension == 'png') {
        debugPrint("Picked Image File");
        imagePath.value = (result.files.single.path!);
        Get.toNamed(Routes.IMAGEPREVIEW, arguments: {
          "filePath": imagePath.value,
          "userName": profile.name!
        });
      } else if (result.files.first.extension == 'mp4' ||
          result.files.first.extension == 'mov' ||
          result.files.first.extension == 'mkv') {
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
  Future documetPickUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false,type: FileType.custom, allowedExtensions: ['pdf', 'ppt', 'xls', 'doc', 'docx', 'xlsx'],);
    if (result != null && File(result.files.single.path!).existsSync()) {
      debugPrint(result.files.first.extension);
      filePath.value = (result.files.single.path!);
      sendDocumentMessage(filePath.value, "");

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
    return PlatformRepo()
        .sendMediaMessage(profile.jid!, videoPath, caption, replyMessageID)
        .then((value) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      return chatMessageModel;
    });
  }

  checkFile(String mediaLocalStoragePath) {
    return mediaLocalStoragePath.isNotEmpty &&
        File(mediaLocalStoragePath).existsSync();
  }

  downloadMedia(String messageId) {
    PlatformRepo().mediaDownload(messageId);
  }

  playAudio(String filePath) async{


    if(!isplaying.value && !audioplayed.value){
      int result = await player.play(filePath, isLocal: true);
      if(result == 1){ //play success

          isplaying(true);
          audioplayed(true);

      }else{
        print("Error while playing audio.");
      }
    }else if(audioplayed.value && !isplaying.value){
      int result = await player.resume();
      if(result == 1){ //resume success

          isplaying(true);
          audioplayed(true);

      }else{
        print("Error on resume audio.");
      }
    }else{
      int result = await player.pause();
      if(result == 1){ //pause success

          isplaying(false);

      }else{
        print("Error on pause audio.");
      }
    }


    // if(isPlaying.value){
    //   debugPrint("pause audio");
    //   // audioplayed(false);
    //
    //   isPlaying(false);
    //   // mediaChatMessage.isPlaying = false;
    //   int result = await player.pause();
    //   if (result == 1) {
    //     // success
    //     // isplaying(false);
    //   }
    // }else {
    //   debugPrint("play audio");
    //   // audioplayed(true);
    //
    //   isPlaying(true);
    //   // mediaChatMessage.isPlaying = true;
    //   int result = await player.play(filePath, isLocal: true);
    //   if (result == 1) {
    //     // success
    //     // isplaying(true);
    //   }
    // }
    // chatList.refresh();
  }

  Future<bool> askContactsPermission() async {
    final permission = await ContactUtils.getContactPermission();
    switch (permission) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.permanentlyDenied:
        return false;
      default:
        debugPrint("Contact Permission default");
        return false;
    }
  }
  Future<bool> askStoragePermission() async {
    final permission = await ContactUtils.getStoragePermission();
    switch (permission) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.permanentlyDenied:
        return false;
      default:
        debugPrint("Contact Permission default");
        return false;
    }
  }

  sendContactMessage(List<String> contactList, String contactName) {
    return PlatformRepo().sendContacts(contactList, profile.jid!, contactName).then((value){
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      return chatMessageModel;
    });
  }

  sendDocumentMessage(String documentPath, String replyMessageId) {
    PlatformRepo().sendDocument(profile.jid!, documentPath, replyMessageId).then((value){
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      return chatMessageModel;
    });
  }

  openDocument(String mediaLocalStoragePath, BuildContext context) async {
    // if (await askStoragePermission()) {
      if(mediaLocalStoragePath.isNotEmpty) {
        // final _result = await OpenFile.open(mediaLocalStoragePath);
        // debugPrint(_result.message);
        // FileView(
        //   controller: FileViewController.file(File(mediaLocalStoragePath)),
        // );
        // Get.toNamed(Routes.FILE_VIEWER, arguments: { "filePath": mediaLocalStoragePath});
        // final String filePath = testFile.absolute.path;
        // final Uri uri = Uri.file(mediaLocalStoragePath);
        //
        // if (!File(uri.toFilePath()).existsSync()) {
        //   throw '$uri does not exist!';
        // }
        // if (!await launchUrl(uri)) {
        //   throw 'Could not launch $uri';
        // }

        PlatformRepo().openFile(mediaLocalStoragePath).catchError((onError){
          final scaffold = ScaffoldMessenger.of(context);
          scaffold.showSnackBar(
            SnackBar(
              content: const Text('No supported application available to open this file format'),
              action: SnackBarAction(label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
            ),
          );
        });
      }else{
        debugPrint("media doesnot exist");
      }
    // }

  }

  pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false,type: FileType.audio);
    if (result != null && File(result.files.single.path!).existsSync()) {
      debugPrint(result.files.first.extension);
      AudioPlayer player = AudioPlayer();
      player.setUrl(result.files.single.path!);
      player.onDurationChanged.listen((Duration duration) {
        print('max duration: ${duration.inMilliseconds}');
        filePath.value = (result.files.single.path!);
        sendAudioMessage(filePath.value, "",false, duration.inMilliseconds.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  sendAudioMessage(String filePath, String messageid, bool isRecorded, String duration) {
    PlatformRepo().sendAudio(profile.jid!, filePath, messageid,isRecorded,duration).then((value){
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      return chatMessageModel;
    });
  }


}
