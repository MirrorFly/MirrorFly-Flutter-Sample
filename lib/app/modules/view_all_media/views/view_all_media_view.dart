import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import '../../../common/constants.dart';
import '../../../model/chat_message_model.dart';
import '../../../model/group_media_model.dart';
import '../controllers/view_all_media_controller.dart';

class ViewAllMediaView extends GetView<ViewAllMediaController> {
  const ViewAllMediaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(controller.name),
          centerTitle: false,
          bottom: TabBar(
              indicatorColor: buttonBgColor,
              labelColor: buttonBgColor,
              unselectedLabelColor: appbarTextColor,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: [
                Center(
                  child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        getTranslated("media", context),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      )),
                ),
                Center(
                  child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(getTranslated("docs", context),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16))),
                ),
                Center(
                  child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(getTranslated("links", context),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16))),
                ),
              ]),
        ),
        body: TabBarView(children: [mediaView(context), docsView(context), linksView(context)]),
      ),
    );
  }

  Widget mediaView(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        return controller.medialistdata.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.medialistdata.length,
                        itemBuilder: (context, index) {
                          var header =
                              controller.medialistdata.keys.toList()[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [headerItem(header), gridView(header)],
                          );
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(getTranslated("mediaCount", context)
                        .replaceFirst("%p", "${controller.imageCount}")
                        .replaceFirst("%v", "${controller.videoCount}")
                        .replaceFirst("%a", "${controller.audioCount}")),
                  ],
                ),
              )
            : Center(child: Text(getTranslated("noMediaFound", context)));
      }),
    );
  }

  Widget gridView(String header) {
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.medialistdata[header]!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (context, gridIndex) {
          var item = controller.medialistdata[header]![gridIndex].chatMessage;
          return gridItem(item, gridIndex);
        });
  }

  Widget headerItem(String header) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
      child: Text(
        header,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xff323232)),
      ),
    );
  }

  Widget gridItem(ChatMessageModel item, int gridIndex) {
    return InkWell(
      child: Container(
          margin: const EdgeInsets.only(right: 3),
          color: item.isAudioMessage()
              ? const Color(0xff97A5C7)
              : Colors.transparent,
          child: item.isAudioMessage()
              ? audioItem(item)
              : item.isVideoMessage()
                  ? videoItem(item)
                  : item.isImageMessage()
                      ? Image.file(
                          File(item
                              .mediaChatMessage!.mediaLocalStoragePath.value),
                          fit: BoxFit.cover,
                        )
                      : const SizedBox()),
      onTap: () {
        if (item.isImageMessage() || item.isVideoMessage()) {
          controller.openImage(gridIndex);
        } else if (item.isAudioMessage()) {
          controller
              .openFile(item.mediaChatMessage!.mediaLocalStoragePath.value);
        }
      },
    );
  }

  Widget videoItem(ChatMessageModel item) {
    return Stack(
      children: [
        controller.imageFromBase64String(
            item.mediaChatMessage!.mediaThumbImage, null, null),
        Center(
          child: SvgPicture.asset(videoWhite),
        )
      ],
    );
  }

  Widget audioItem(ChatMessageModel item) {
    return Center(
      child: SvgPicture.asset(
          item.mediaChatMessage!.isAudioRecorded ? audioMic1 : audioWhite),
    );
  }

  Widget docsView(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        return controller.docslistdata.isNotEmpty
            ? listView(controller.docslistdata, true,context)
            : Center(child: Text(getTranslated("noDocsFound", context)));
      }),
    );
  }

  Widget listView(Map<String, List<MessageItem>> list, bool doc,BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var header = list.keys.toList()[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    headerItem(header),
                    ListView.builder(
                        itemCount: list[header]!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, listIndex) {
                          var item = list[header]![listIndex].chatMessage;
                          return doc
                              ? docTile(
                                  assetName: getDocAsset(
                                      item.mediaChatMessage!.mediaFileName),
                                  title: item.mediaChatMessage!.mediaFileName,
                                  subtitle: getFileSizeText(item
                                      .mediaChatMessage!.mediaFileSize
                                      .toString()),
                                  //item.mediaChatMessage!.mediaFileSize.readableFileSize(base1024: false),
                                  date: getDateFromTimestamp(
                                      item.messageSentTime.toInt(), "d/MM/yy"),
                                  path: item.mediaChatMessage!
                                      .mediaLocalStoragePath.value)
                              : linkTile(list[header]![listIndex]);
                        }),
                  ],
                );
              }),
          const SizedBox(
            height: 10,
          ),
          doc
              ? Text(getTranslated("docCount", context).replaceFirst("%d", "${controller.documentCount}"))
              : Text(getTranslated("linkCount", context).replaceFirst("%d", "${controller.linkCount}"))
        ],
      ),
    );
  }

  Widget docTile(
      {required String assetName,
      required String title,
      required String subtitle,
      required String date,
      required String path}) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SvgPicture.asset(
                  assetName,
                  width: 20,
                  height: 20,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Text(date, style: const TextStyle(fontSize: 11)),
              )),
            ],
          ),
          const AppDivider(
            padding: EdgeInsets.only(top: 8, bottom: 8),
          )
        ],
      ),
      onTap: () {
        controller.openFile(path);
      },
    );
  }

  Widget linkTile(MessageItem item) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          decoration: const BoxDecoration(
              color: Color(0xffE2E8F7),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  launchWeb(item.linkMap!["url"]);
                },
                child: Container(
                  decoration: const BoxDecoration(
                      color: Color(0xffD0D8EB),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      (item.chatMessage.isImageMessage() ||
                              item.chatMessage.isVideoMessage())
                          ? ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8)),
                              child: controller.imageFromBase64String(
                                  item.chatMessage.mediaChatMessage!
                                      .mediaThumbImage,
                                  70,
                                  70),
                            )
                          : Container(
                              height: 70,
                              width: 70,
                              decoration: const BoxDecoration(
                                  color: Color(0xff97A5C7),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8))),
                              child: Center(
                                child: SvgPicture.asset(linkImage),
                              ),
                            ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.linkMap!["url"],
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              item.linkMap!["host"],
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ))
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  controller.navigateMessage(item.chatMessage);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 2.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          (item.chatMessage.isTextMessage())
                              ? item.chatMessage.messageTextContent!
                              : (item.chatMessage.isImageMessage() ||
                                      item.chatMessage.isVideoMessage())
                                  ? item.chatMessage.mediaChatMessage!
                                      .mediaCaptionText
                                  : Constants.emptyString,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xff7889B3)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_right,
                        color: Color(0xff7185b5),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        const AppDivider()
      ],
    );
  }

  Widget linksView(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        return controller.linklistdata.isNotEmpty
            ? listView(controller.linklistdata, false,context)
            : Center(child: Text(getTranslated("noLinksFound", context)));
      }),
    );
  }
}
