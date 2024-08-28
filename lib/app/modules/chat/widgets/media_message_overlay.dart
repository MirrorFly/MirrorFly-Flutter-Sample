import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart' hide ChatMessageModel;

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/permissions.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import '../../../stylesheet/stylesheet.dart';

class MediaMessageOverlay extends StatelessWidget {
  const MediaMessageOverlay({super.key, required this.chatMessage, this.onAudio, this.onVideo, this.progress, this.downloadUploadViewStyle = const DownloadUploadViewStyle(),});
  final ChatMessageModel chatMessage;
  final Function()? onAudio;
  final Function()? onVideo;
  final int? progress;
  final DownloadUploadViewStyle downloadUploadViewStyle;

  @override
  Widget build(BuildContext context) {

    debugPrint("getImageOverlay media exists ${MediaUtils.isMediaExists(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value)}");

    debugPrint("isMediaDownloading ${chatMessage.isMediaDownloading()}");
    debugPrint("isMediaUploading ${chatMessage.isMediaUploading()}");

    debugPrint("#Media upload status ${chatMessage.mediaChatMessage!.mediaUploadStatus.value}");
    debugPrint("#Media download status ${chatMessage.mediaChatMessage!.mediaDownloadStatus.value}");

    debugPrint("#Media if condition ${MediaUtils.isMediaExists(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value) && (!chatMessage.isMediaDownloading() && !chatMessage.isMediaUploading() && !(chatMessage.isMessageSentByMe && !chatMessage.isUploadFailed()))}");

    if (MediaUtils.isMediaExists(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value) && (!chatMessage.isMediaDownloading() && !chatMessage.isMediaUploading() && !(chatMessage.isMessageSentByMe && chatMessage.isUploadFailed()))) {
      if (chatMessage.messageType.toUpperCase() == 'VIDEO') {
        return FloatingActionButton.small(
          heroTag: chatMessage.messageId,
          onPressed: onVideo,
          backgroundColor: Colors.white,
          child: const Icon(
            Icons.play_arrow_rounded,
            // color: buttonBgColor,
          ),
        );
      } else if (chatMessage.messageType.toUpperCase() == 'AUDIO') {
        return InkWell(
          onTap: onAudio,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                  height: 30,
                  width: 30,
                  padding: const EdgeInsets.all(7),
                  child: AppUtils.svgIcon(icon:
                    chatMessage.mediaChatMessage!.isPlaying ? pauseIcon : playIcon,
                    height: 17,
                    colorFilter: ColorFilter.mode(downloadUploadViewStyle.iconStyle.iconColor, BlendMode.srcIn),
                  ))
          ),
        ); //const Icon(Icons.play_arrow_sharp);
      } else {
        return const Offstage();
      }
    } else {
      var status = 0;
      if(chatMessage.isMessageSentByMe){
        if(chatMessage.mediaChatMessage!.mediaUploadStatus.value == MediaUploadStatus.isMediaUploading || chatMessage.mediaChatMessage!.mediaDownloadStatus.value == MediaDownloadStatus.isMediaDownloading ){
          status = (chatMessage.mediaChatMessage!.mediaUploadStatus.value == MediaUploadStatus.isMediaUploading) ? MediaUploadStatus.isMediaUploading : MediaDownloadStatus.isMediaDownloading;
        }else {
          if (chatMessage.mediaChatMessage!
              .mediaLocalStoragePath.value
              .checkNull()
              .isNotEmpty) {
            if (!MediaUtils.isMediaExists(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value.checkNull())) {
              if (chatMessage.mediaChatMessage!.mediaUploadStatus.value == MediaUploadStatus.isMediaUploaded) {
                status = MediaDownloadStatus.isMediaNotDownloaded; // for uploaded and deleted in local
              } else {
                status = -1;
                //status = MediaDownloadStatus.isMediaNotDownloaded;
              }
            } else {
              status = chatMessage.mediaChatMessage!.mediaUploadStatus.value;
            }
          } else {
            status = chatMessage.mediaChatMessage!.mediaUploadStatus.value;
          }
        }
      }else{
        status = chatMessage.mediaChatMessage!.mediaDownloadStatus.value;
      }
      debugPrint("mediaStatus : $status  messageId ${chatMessage.messageId}");
      // debugPrint(
      //     "overlay status-->${chatMessage.isMessageSentByMe ? chatMessage.mediaChatMessage!.mediaUploadStatus : chatMessage.mediaChatMessage!.mediaDownloadStatus}");
      switch (status) {
        case MediaDownloadStatus.isMediaDownloaded:
        case MediaUploadStatus.isMediaUploaded:
        case MediaDownloadStatus.isStorageNotEnough:
          if (!MediaUtils.isMediaExists(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value.checkNull())) {
            return InkWell(
              child: downloadView(
                  chatMessage.mediaChatMessage!.mediaFileSize,
                  chatMessage.messageType.toUpperCase(),downloadUploadViewStyle),
              onTap: () {
                downloadMedia(chatMessage.messageId);
              },
            );
          } else {
            return const Offstage();
          }
        case MediaDownloadStatus.isMediaDownloadedNotAvailable:
        case MediaUploadStatus.isMediaUploadedNotAvailable:
          return InkWell(
            child: downloadView(
                chatMessage.mediaChatMessage!.mediaFileSize,
                chatMessage.messageType.toUpperCase(),downloadUploadViewStyle),
            onTap: () {
              downloadMedia(chatMessage.messageId);
            },
          );
        case MediaDownloadStatus.isMediaNotDownloaded:
          return InkWell(
            child: downloadView(
                chatMessage.mediaChatMessage!.mediaFileSize,
                chatMessage.messageType.toUpperCase(),downloadUploadViewStyle),
            onTap: () {
              downloadMedia(chatMessage.messageId);
            },
          );
        case MediaUploadStatus.isMediaNotUploaded:
          return InkWell(
              onTap: () {
                debugPrint("upload Media ==> ${chatMessage.messageId}");
                uploadMedia(chatMessage.messageId);
              },
              child: uploadView(chatMessage.messageType.toUpperCase(),downloadUploadViewStyle));
        case MediaDownloadStatus.isMediaDownloading:
        case MediaUploadStatus.isMediaUploading:
          return Obx(() {
            return InkWell(onTap: () {
              cancelMediaUploadOrDownload(chatMessage.messageId);
            }, child: downloadingOrUploadingView(chatMessage.messageType,
                chatMessage.mediaChatMessage!.mediaProgressStatus.value,downloadUploadViewStyle)
            );
          });
        default:
          return InkWell(
              onTap: () {
                toToast(getTranslated("mediaDoesNotExist"));
              },
              child: uploadView(chatMessage.messageType.toUpperCase(),downloadUploadViewStyle));
      }
    }
  }
}


void uploadMedia(String messageId) async {
  if (await AppUtils.isNetConnected()) {
    Mirrorfly.uploadMedia(messageId: messageId);
  } else {
    toToast(getTranslated("noInternetConnection"));
  }
}

void downloadMedia(String messageId) async {
  debugPrint("media download click");
  debugPrint("media download click--> $messageId");
  if (await AppUtils.isNetConnected()) {
    var permission = await AppPermission.getStoragePermission(permissionContent: getTranslated("writeStoragePermissionContent"),deniedContent: getTranslated("writeStoragePermissionDeniedContent"));
    if (permission) {
      debugPrint("media permission granted");
      Mirrorfly.downloadMedia(messageId: messageId);
    } else {
      debugPrint("storage permission not granted");
    }
  } else {
    toToast(getTranslated("noInternetConnection"));
  }
}



Widget uploadView(String messageType,DownloadUploadViewStyle downloadUploadViewStyle) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: messageType == 'AUDIO' || messageType == 'DOCUMENT'
        ? Container(
        height: 30,
        width: 30,
        decoration: downloadUploadViewStyle.decoration,
        /*decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(3)),*/
        padding: const EdgeInsets.all(7),
        child: AppUtils.svgIcon(icon:
          uploadIcon,
          colorFilter: ColorFilter.mode(downloadUploadViewStyle.iconStyle.iconColor, BlendMode.srcIn),
        ))
        : Container(
        height: 35,
        width: 80,
        decoration: downloadUploadViewStyle.decoration,
        /*decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.black45,
        ),*/
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppUtils.svgIcon(icon:uploadIcon,colorFilter: ColorFilter.mode(downloadUploadViewStyle.iconStyle.iconColor, BlendMode.srcIn)),
            const SizedBox(
              width: 5,
            ),
            Text(
              getTranslated("retry").toUpperCase(),
              style: downloadUploadViewStyle.textStyle,
              // style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        )),
  );
}


Widget downloadView(int mediaFileSize, String messageType,DownloadUploadViewStyle downloadUploadViewStyle) {
  return Padding(
    padding: messageType == 'AUDIO' ? const EdgeInsets.symmetric(horizontal: 8.0) : const EdgeInsets.only(left: 8),
    child: messageType == 'AUDIO' || messageType == 'DOCUMENT'
        ? Container(
        height: 28,
        width: 28,
        decoration: downloadUploadViewStyle.decoration,
        // decoration: BoxDecoration(
        //     border: Border.all(color: borderColor),
        //     borderRadius: BorderRadius.circular(3)),
        padding: const EdgeInsets.all(7),
        child: AppUtils.svgIcon(icon:
          downloadIcon,
          colorFilter: ColorFilter.mode(downloadUploadViewStyle.iconStyle.iconColor, BlendMode.srcIn)
        ))
        : Container(
        height: 31,
        width: 80,
        decoration: downloadUploadViewStyle.decoration,
        /*decoration: BoxDecoration(
          border: Border.all(
            color: textColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: Colors.black38,
        ),*/
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppUtils.svgIcon(icon:downloadIcon,colorFilter: ColorFilter.mode(downloadUploadViewStyle.iconStyle.iconColor, BlendMode.srcIn)),
            const SizedBox(
              width: 5,
            ),
            Text(
              MediaUtils.fileSize(mediaFileSize),
              style: downloadUploadViewStyle.textStyle,
              // style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        )),
  );
}


void cancelMediaUploadOrDownload(String messageId) {
  AppUtils.isNetConnected().then((value) {
    if(value){
      Mirrorfly.cancelMediaUploadOrDownload(messageId: messageId);
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  });
}

downloadingOrUploadingView(String messageType, int progress,DownloadUploadViewStyle downloadUploadViewStyle) {
  debugPrint('downloadingOrUploadingView progress $progress');
  if (messageType == MessageType.audio.value || messageType == MessageType.document.value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
          width: 30,
          height: 30,
          decoration: downloadUploadViewStyle.decoration,
          /*decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            // color: Colors.black45,
          ),*/
          child: Stack(
              alignment: Alignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppUtils.svgIcon(icon:
                  downloading,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(downloadUploadViewStyle.iconStyle.iconColor, BlendMode.srcIn),
                  // colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 2,
                    child: ProgressIndicatorTheme(
                      data: downloadUploadViewStyle.progressIndicatorThemeData,
                      child: LinearProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          progressColor,
                        ),
                        value: progress == 0 || progress == 100
                            ? null
                            : (progress / 100),
                        // minHeight: 1,
                      ),
                    ),
                  ),
                ),
              ])),
    );
  } else {
    return Container(
        height: 35,
        width: 80,
        decoration: downloadUploadViewStyle.decoration,
        /*decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.black45,
        ),*/
        child: Stack(
            alignment: Alignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppUtils.svgIcon(icon:
                downloading,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(downloadUploadViewStyle.iconStyle.iconColor, BlendMode.srcIn),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 2,
                  child: ProgressIndicatorTheme(
                    data: downloadUploadViewStyle.progressIndicatorThemeData,
                    child: LinearProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      value: progress == 0 || progress == 100
                          ? null
                          : (progress / 100),
                      // minHeight: 1,
                    ),
                  ),
                ),
              ),
            ]));
  }
}
