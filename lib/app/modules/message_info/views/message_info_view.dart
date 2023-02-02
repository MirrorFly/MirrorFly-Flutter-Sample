import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flysdk/flysdk.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import '../../../common/constants.dart';
import '../../../routes/app_pages.dart';
import '../../chat/chat_widgets.dart';

//import '../../chat/views/message_content.dart';
import '../controllers/message_info_controller.dart';

class MessageInfoView extends GetView<MessageInfoController> {
  const MessageInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Message Info'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery
                              .of(context)
                              .size
                              .width * 0.6),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10)),
                          color: chatSentBgColor,
                          border: Border.all(color: chatSentBgColor)),
                      child: Obx(() {
                        return Column(
                          children: [
                            (controller.chatMessage[0].replyParentChatMessage ==
                                null)
                                ? const SizedBox.shrink()
                                : ReplyMessageHeader(
                                chatMessage: controller.chatMessage[0]),
                            SenderHeader(
                                isGroupProfile: controller.isGroupProfile,
                                chatList: controller.chatMessage,
                                index: 0),
                            //getMessageContent(index, context, chatList),
                            MessageContent(chatList: controller.chatMessage,
                              index: 0,
                              handleMediaUploadDownload: handleMediaUploadDownload,
                              currentPos: controller.currentPos.value,
                              maxDuration: controller.maxDuration.value,)
                            //MessageHeader(chatList: controller.chatMessage, isTapEnabled: false,),
                            //MessageContent(chatList: controller.chatMessage, isTapEnabled: false,),
                          ],
                        );
                      }),
                    ),
                  ),
                  statusView(context),
                ],
              ),
            ),
          ),
        ));
  }

  Widget statusView(BuildContext context) {
    return controller.isGroupProfile ? Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppDivider(),
          ListItem(
            leading: !controller.visibleDeliveredList.value ? SvgPicture
                .asset(icExpand) : SvgPicture.asset(icCollapse),
            title: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 15.0, vertical: 10.0),
              child: Text("Delivered to ${controller.messageDeliveredList
                  .length} of ${controller.statusCount.value}",
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,),
            ), onTap: () {
            controller.onDeliveredClick();
          },),
          Visibility(
              visible: controller.visibleDeliveredList.value,
              child: controller.messageDeliveredList.isNotEmpty ? ListView
                  .builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.messageDeliveredList.length,
                  itemBuilder: (cxt, index) {
                    var member = controller.messageDeliveredList[index]
                        .memberProfileDetails!;
                    return memberItem(name: member.name.checkNull(),
                        image: member.image.checkNull(),
                        status: controller.chatDate(context,
                            controller.messageDeliveredList[index]),
                        onTap: () {});
                  }) : emptyDeliveredSeen(
                  context, 'Message sent, not delivered yet')),
          const AppDivider(),
          ListItem(
            leading: !controller.visibleReadList.value ? SvgPicture.asset(
                icExpand) : SvgPicture.asset(icCollapse),
            title: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 15.0, vertical: 10.0),
              child: Text(
                "Read by ${controller.messageReadList.length} of ${controller
                    .statusCount.value}",
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,),
            ), onTap: () {
            controller.onReadClick();
          },),
          Visibility(
              visible: controller.visibleReadList.value,
              child: controller.messageReadList.isNotEmpty ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.messageReadList.length,
                  itemBuilder: (cxt, index) {
                    var member = controller.messageReadList[index]
                        .memberProfileDetails!;
                    return memberItem(name: member.name.checkNull(),
                        image: member.image.checkNull(),
                        status: controller.chatDate(context,
                            controller.messageDeliveredList[index]),
                        onTap: () {});
                  }) : emptyDeliveredSeen(context, "Your message is not read")),
          const AppDivider(),
        ],
      );
    }) :
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          "Delivered",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(
          height: 10,
        ),
        Obx(() {
          return Text(controller.deliveredTime.value == ""
              ? "Message sent, not delivered yet"
              : controller.getChatTime(
              context, int.parse(controller.deliveredTime.value)));
        }),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
        const Text(
          "Read",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(
          height: 10,
        ),
        Obx(() {
          return Text(controller.readTime.value == ""
              ? "Your message is not read"
              : controller.getChatTime(
              context, int.parse(controller.readTime.value)));
        }),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
      ],
    );
  }

  Widget emptyDeliveredSeen(BuildContext context, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            noChatIcon,
            width: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.0, color: Color(0xff7C7C7C)),
            ),
          ),
        ],
      ),
    );
  }

  handleMediaUploadDownload(int mediaDownloadStatus,
      ChatMessageModel chatList) {
    switch (chatList.isMessageSentByMe
        ? chatList.mediaChatMessage?.mediaUploadStatus
        : mediaDownloadStatus) {
      case Constants.mediaDownloaded:
      case Constants.mediaUploaded:
        if (chatList.messageType.toUpperCase() == 'VIDEO') {
          if (controller.checkFile(
              chatList.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatList.mediaChatMessage!.mediaDownloadStatus ==
                  Constants.mediaDownloaded ||
                  chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaUploaded ||
                  chatList.isMessageSentByMe)) {
            Get.toNamed(Routes.videoPlay, arguments: {
              "filePath": chatList.mediaChatMessage!.mediaLocalStoragePath,
            });
          }
        }
        if (chatList.messageType.toUpperCase() == 'AUDIO') {
          if (controller.checkFile(
              chatList.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatList.mediaChatMessage!.mediaDownloadStatus ==
                  Constants.mediaDownloaded ||
                  chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaUploaded ||
                  chatList.isMessageSentByMe)) {
            // debugPrint("audio click1");
            chatList.mediaChatMessage!.isPlaying = controller.isPlaying.value;
            controller.playAudio(chatList.mediaChatMessage!.mediaLocalStoragePath);
            // playAudio(chatList.mediaChatMessage!.mediaLocalStoragePath,
            //     chatList.mediaChatMessage!.mediaFileName);
          } else {
            debugPrint("condition failed");
          }
        }
        break;

      case Constants.mediaDownloadedNotAvailable:
      case Constants.mediaNotDownloaded:
      //download
        debugPrint("Download");
        debugPrint(chatList.messageId);
        chatList.mediaChatMessage!.mediaDownloadStatus =
            Constants.mediaDownloading;
        controller.downloadMedia(chatList.messageId);
        break;
      case Constants.mediaUploadedNotAvailable:
      //upload
        break;
      case Constants.mediaNotUploaded:
      case Constants.mediaDownloading:
      case Constants.mediaUploading:
      return InkWell(
        onTap: (){
          cancelMediaUploadOrDownload(chatList.messageId);
        },
        child: uploadingView(chatList.messageId),
      );
        // return uploadingView();
    // break;
    }
  }

  playAudio(String filePath, String mediaFileName) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  controller.playAudio(filePath);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      audioMicBg,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    Obx(() {
                      return controller.isPlaying.value
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow);
                    }),
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mediaFileName,
                      maxLines: 2,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      // width: 168,
                      child: SliderTheme(
                        data: SliderThemeData(
                          thumbColor: audioColorDark,
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 5),
                        ),
                        child: Obx(() {
                          return Slider(
                            value:
                            double.parse(controller.currentPos.toString()),
                            min: 0,
                            activeColor: audioColorDark,
                            inactiveColor: audioColor,
                            max: double.parse(
                                controller.maxDuration.value.toString()),
                            divisions: controller.maxDuration.value,
                            label: controller.currentPostLabel,
                            onChanged: (double value) async {},
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
