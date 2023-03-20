import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import '../../../common/constants.dart';
import '../controllers/view_all_media_controller.dart';
import 'package:flysdk/flysdk.dart';

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
                      child: const Text(
                        "Media",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      )),
                ),
                Center(
                  child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: const Text("Docs",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16))),
                ),
                Center(
                  child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: const Text("Links",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16))),
                ),
              ]),
        ),
        body: TabBarView(children: [mediaView(), docsView(), linksView()]),
      ),
    );
  }

  Widget mediaView() {
    return Center(
      child: Obx(() {
        return controller.medialistdata.isNotEmpty
            ? ListView.builder(
                itemCount: controller.medialistdata.length,
                itemBuilder: (context, index) {
                  var header = controller.medialistdata.keys.toList()[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [headerItem(header), gridView(header)],
                  );
                })
            : const Text("No Media Found...!!!");
      }),
    );
  }

  Widget gridView(String header) {
    return GridView.builder(
        shrinkWrap: true,
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
                          File(item.mediaChatMessage!.mediaLocalStoragePath),
                          fit: BoxFit.cover,
                        )
                      : const SizedBox()),
      onTap: () {
        if (item.isImageMessage() || item.isVideoMessage()) {
          controller.openImage(gridIndex);
        } else if (item.isAudioMessage()) {
          controller.openFile(item.mediaChatMessage!.mediaLocalStoragePath);
        }
      },
    );
  }

  Widget videoItem(ChatMessageModel item) {
    return Stack(
      children: [
        controller.imageFromBase64String(
            item.mediaChatMessage!.mediaThumbImage, null,  null),
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

  Widget docsView() {
    return Center(
      child: Obx(() {
        return controller.docslistdata.isNotEmpty
            ? listView(controller.docslistdata, true)
            : const Text("No Docs Found...!!!");
      }),
    );
  }

  ListView listView(Map<String, List<MessageItem>> list, bool doc) {
    return ListView.builder(
        itemCount: list.length,
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
                            path: item.mediaChatMessage!.mediaLocalStoragePath)
                        : linkTile(list[header]![listIndex]);
                  })
            ],
          );
        });
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
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(assetName),
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
            padding: EdgeInsets.only(top: 8),
          )
        ],
      ),
      onTap: () {
        controller.openFile(path);
      },
    );
  }

  Widget linkTile(MessageItem item) {
    return InkWell(
      child: Column(
        children: [
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            decoration: const BoxDecoration(
                color: Color(0xffE2E8F7),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                Padding(
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
                )
              ],
            ),
          ),
          const AppDivider()
        ],
      ),
      onTap: () {
        launchWeb(item.linkMap!["url"]);
      },
    );
  }

  String getDocAsset(String filename) {
    if (filename.isEmpty || !filename.contains(".")) {
      return "";
    }
    switch (filename.toLowerCase().substring(filename.lastIndexOf(".") + 1)) {
      case "csv":
        return csvImage;
      case "pdf":
        return pdfImage;
      case "doc":
        return docImage;
      case "docx":
        return docxImage;
      case "txt":
        return txtImage;
      case "xls":
        return xlsImage;
      case "xlsx":
        return xlsxImage;
      case "ppt":
        return pptImage;
      case "pptx":
        return pptxImage;
      case "zip":
        return zipImage;
      case "rar":
        return rarImage;
      case "apk":
        return apkImage;
      default:
        return "";
    }
  }

  Widget linksView() {
    return Center(
      child: Obx(() {
        return controller.linklistdata.isNotEmpty
            ? listView(controller.linklistdata, false)
            : const Text("No Links Found...!!!");
      }),
    );
  }
}
