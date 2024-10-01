import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/widgets.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../../../stylesheet/stylesheet.dart';

import '../../../common/constants.dart';
import '../../../model/chat_message_model.dart';
import '../../../model/group_media_model.dart';
import '../controllers/view_all_media_controller.dart';

class ViewAllMediaView extends NavViewStateful<ViewAllMediaController> {
  const ViewAllMediaView({Key? key}) : super(key: key);

  @override
ViewAllMediaController createController({String? tag}) => Get.put(ViewAllMediaController());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: AppStyleConfig.viewAllMediaPageStyle.appBarTheme,tabBarTheme: AppStyleConfig.viewAllMediaPageStyle.tabBarTheme),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: FutureBuilder(
              future: getProfileDetails(controller.arguments.chatJid),
              builder: (context,data) {
                if(data.data != null) {
                  return Text(data.data!.getName());
                }
                return const Offstage();
              }
            ),
            centerTitle: false,
            bottom: TabBar(
                indicatorWeight: 2,
                tabs: [
                  Center(
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          getTranslated("media"),
                          // style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        )),
                  ),
                  Center(
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(getTranslated("docs"),
                            // style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                        )),
                  ),
                  Center(
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(getTranslated("links"),
                            // style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                        )),
                  ),
                ]),
          ),
          body: TabBarView(children: [
            mediaView(context,AppStyleConfig.viewAllMediaPageStyle.groupedMediaItem),
            docsView(context,AppStyleConfig.viewAllMediaPageStyle.groupedMediaItem),
            linksView(context,AppStyleConfig.viewAllMediaPageStyle.groupedMediaItem)
          ]),
        ),
      ),
    );
  }

  Widget mediaView(BuildContext context,GroupedMediaItemStyle groupedMediaItemStyle) {
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
                            children: [headerItem(header,groupedMediaItemStyle.titleStyle), gridView(header,groupedMediaItemStyle)],
                          );
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(getTranslated("mediaCount")
                        .replaceFirst("%p", "${controller.imageCount}")
                        .replaceFirst("%v", "${controller.videoCount}")
                        .replaceFirst("%a", "${controller.audioCount}"),style: AppStyleConfig.viewAllMediaPageStyle.noDataTextStyle,),
                  ],
                ),
              )
            : Center(child: Text(getTranslated("noMediaFound"),style: AppStyleConfig.viewAllMediaPageStyle.noDataTextStyle,));
      }),
    );
  }

  Widget gridView(String header,GroupedMediaItemStyle groupedMediaItemStyle) {
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
          return gridItem(item, gridIndex,groupedMediaItemStyle);
        });
  }

  Widget headerItem(String header,TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
      child: Text(
        header,
        style: style,
        /*style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xff323232)),*/
      ),
    );
  }

  Widget gridItem(ChatMessageModel item, int gridIndex,GroupedMediaItemStyle groupedMediaItemStyle) {
    return InkWell(
      child: Container(
          margin: const EdgeInsets.only(right: 3),
          color: item.isAudioMessage()
              ? groupedMediaItemStyle.mediaAudioItemStyle.bgColor//const Color(0xff97A5C7)
              : Colors.transparent,
          child: item.isAudioMessage()
              ? audioItem(item,groupedMediaItemStyle.mediaAudioItemStyle)
              : item.isVideoMessage()
                  ? videoItem(item,groupedMediaItemStyle.mediaVideoItemStyle)
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

  Widget videoItem(ChatMessageModel item,MediaItemStyle mediaItemStyle) {
    return Stack(
      children: [
        controller.imageFromBase64String(
            item.mediaChatMessage!.mediaThumbImage, null, null),
        Center(
          child: AppUtils.svgIcon(icon:videoWhite,colorFilter: ColorFilter.mode(mediaItemStyle.iconColor, BlendMode.srcIn),),
        )
      ],
    );
  }

  Widget audioItem(ChatMessageModel item,MediaItemStyle mediaItemStyle) {
    return Center(
      child: AppUtils.svgIcon(icon:
          item.mediaChatMessage!.isAudioRecorded ? audioMic1 : audioWhite,
      colorFilter: ColorFilter.mode(mediaItemStyle.iconColor, BlendMode.srcIn),),
    );
  }

  Widget docsView(BuildContext context,GroupedMediaItemStyle groupedMediaItemStyle) {
    return SafeArea(
      child: Obx(() {
        return controller.docslistdata.isNotEmpty
            ? listView(controller.docslistdata, true,context,groupedMediaItemStyle)
            : Center(child: Text(getTranslated("noDocsFound"),style: AppStyleConfig.viewAllMediaPageStyle.noDataTextStyle,));
      }),
    );
  }

  Widget listView(Map<String, List<MessageItem>> list, bool doc,BuildContext context,GroupedMediaItemStyle groupedMediaItemStyle) {
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
                    headerItem(header,groupedMediaItemStyle.titleStyle),
                    ListView.builder(
                        itemCount: list[header]!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, listIndex) {
                          var item = list[header]![listIndex].chatMessage;
                          return doc
                              ? docTile(
                                  assetName: MessageUtils.getDocAsset(
                                      item.mediaChatMessage!.mediaFileName),
                                  title: item.mediaChatMessage!.mediaFileName,
                                  subtitle: MediaUtils.fileSize(item
                                      .mediaChatMessage!.mediaFileSize),
                                  //item.mediaChatMessage!.mediaFileSize.readableFileSize(base1024: false),
                                  date: DateTimeUtils.convertTimeStampToDateString(
                                      item.messageSentTime.toInt(), "d/MM/yy"),
                                  path: item.mediaChatMessage!
                                      .mediaLocalStoragePath.value,documentItemStyle: groupedMediaItemStyle.documentItemStyle)
                              : linkTile(list[header]![listIndex],groupedMediaItemStyle.linkItemStyle);
                        }),
                  ],
                );
              }),
          const SizedBox(
            height: 10,
          ),
          doc
              ? Text(getTranslated("docCount").replaceFirst("%d", "${controller.documentCount}"))
              : Text(getTranslated("linkCount").replaceFirst("%d", "${controller.linkCount}"))
        ],
      ),
    );
  }

  Widget docTile(
      {required String assetName,
      required String title,
      required String subtitle,
      required String date,
      required String path,required DocumentItemStyle documentItemStyle}) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: AppUtils.svgIcon(icon:
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
                        style: documentItemStyle.titleTextStyle,
                        // style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        subtitle,
                        style: documentItemStyle.sizeTextStyle,
                        // style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Text(date, style: documentItemStyle.dateTextStyle,
                    // style: const TextStyle(fontSize: 11)
                ),
              )),
            ],
          ),
          AppDivider(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            color: documentItemStyle.dividerColor,
          )
        ],
      ),
      onTap: () {
        controller.openFile(path);
      },
    );
  }

  Widget linkTile(MessageItem item,LinkItemStyle linkItemStyle) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          decoration: linkItemStyle.outerDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  AppUtils.launchWeb(Uri.parse(item.linkMap!["url"]));
                },
                child: Container(
                  decoration: linkItemStyle.innerDecoration,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      (item.chatMessage.isImageMessage() ||
                              item.chatMessage.isVideoMessage())
                          ? ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  bottomLeft: Radius.circular(6)),
                              child: controller.imageFromBase64String(
                                  item.chatMessage.mediaChatMessage!
                                      .mediaThumbImage,
                                  70,
                                  70),
                            )
                          : Container(
                              height: 70,
                              width: 70,
                              decoration: linkItemStyle.iconDecoration,
                              child: Center(
                                child: AppUtils.svgIcon(icon:linkImage,colorFilter: ColorFilter.mode(linkItemStyle.iconColor, BlendMode.srcIn),),
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
                              style: linkItemStyle.titleTextStyle,
                              // style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              item.linkMap!["host"],
                              style: linkItemStyle.descriptionTextStyle,
                              // style: const TextStyle(fontSize: 10),
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
                          // style: const TextStyle(fontSize: 13, color: Color(0xff7889B3)),
                          style: linkItemStyle.linkTextStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: linkItemStyle.linkTextStyle.color,
                        // color: Color(0xff7185b5),
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

  Widget linksView(BuildContext context,GroupedMediaItemStyle groupedMediaItemStyle) {
    return SafeArea(
      child: Obx(() {
        return controller.linklistdata.isNotEmpty
            ? listView(controller.linklistdata, false,context,groupedMediaItemStyle)
            : Center(child: Text(getTranslated("noLinksFound")));
      }),
    );
  }
}
