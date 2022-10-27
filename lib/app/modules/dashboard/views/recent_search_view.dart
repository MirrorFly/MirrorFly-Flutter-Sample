import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/main_controller.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/recentchat.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/controllers/recent_chat_search_controller.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../model/chatmessage_model.dart';
import '../../../model/recentSearchModel.dart';
import '../../../routes/app_pages.dart';

class RecentSearchView extends GetView<RecentChatSearchController> {
  const RecentSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconcolor),
          onPressed: () {
            Get.back();
          },
        ),
        title: TextField(
          onChanged: (text) => controller.onChange(),
          controller: controller.search,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: "Search", border: InputBorder.none),
        ),
        iconTheme: IconThemeData(color: iconcolor),
      ),
      body: Obx(() =>
          ListView.builder(
          itemCount: controller.frmRecentChatList.isNotEmpty ? controller.frmRecentChatList.length : controller.recentSearchList.length,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int position) {
            if(controller.frmRecentChatList.isNotEmpty){
              var item = controller.frmRecentChatList[position];
              //var image = controller.imagepath(item.profileImage);
              return RecentChatItem(item.value, context);
            }else {
              Log("RecentSearch",
                  controller.recentSearchList[position].toJson().toString());
              return getViewbyType(
                  controller.recentSearchList[position], context, position) ??
                  SizedBox();
            }
          }))
    );
  }

  Widget? getViewbyType(
      Rx<RecentSearch> item, BuildContext context, int position) {
    Log("searchtype", item.value.searchType.reactive.value.toString());
    switch (item.value.searchType.reactive.value.toString()) {
      case Constants.TYPE_SEARCH_RECENT:
        //viewRecentChatItem
        return viewRecentChatItem(item, context, position);
      case Constants.TYPE_SEARCH_CONTACT:
        //viewContactItem
        return viewContactItem(context,position);
      case Constants.TYPE_SEARCH_MESSAGE:
        //viewMessageItem
        return viewMessageItem(context, position);
      default:
        return SizedBox(); //viewRecentChatItem(item, context,position);
    }
  }

  Widget? viewRecentChatItem(
      Rx<RecentSearch> data, BuildContext context, int position) {
    var maincontroller = Get.find<MainController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        position == 0 ||
                controller.recentSearchList[position].value.searchType !=
                    controller.recentSearchList[position - 1].value.searchType
            ? searchHeaderbyType(data.value, context)
            : SizedBox(),
        FutureBuilder(
            future: controller.getRecentChatofJid(data.value.jid.checkNull()),
            builder: (context, snapshot) {
              var item = snapshot.data;
              return item != null
                  ? InkWell(
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                                margin: EdgeInsets.only(
                                    left: 19.0, top: 10, bottom: 10, right: 10),
                                child: Stack(
                                  children: [
                                    ImageNetwork(
                                      url: item.profileImage.checkNull(),
                                      width: 48,
                                      height: 48,
                                      clipoval: true,
                                      errorWidget: ProfileTextImage(
                                        text:
                                            item.profileName.checkNull().isEmpty
                                                ? item.nickName.checkNull()
                                                : item.profileName.checkNull(),
                                      ),
                                    ),
                                    item.unreadMessageCount.toString() != "0"
                                        ? Positioned(
                                            right: 0,
                                            child: CircleAvatar(
                                              radius: 8,
                                              child: Text(
                                                item.unreadMessageCount
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.white,
                                                    fontFamily: 'sf_ui'),
                                              ),
                                            ))
                                        : SizedBox(),
                                  ],
                                )),
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.only(top: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: spannableText(
                                              item.profileName.toString(),
                                              controller.search.text,TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'sf_ui',
                                              color: texthintcolor)),
                                          /*Text(
                                            item.profileName.toString(),
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'sf_ui',
                                                color: texthintcolor),
                                          ),*/
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0, left: 8),
                                          child: Text(
                                            maincontroller.getRecentChatTime(
                                                context, item.lastMessageTime),
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'sf_ui',
                                                color: item.unreadMessageCount
                                                            .toString() !=
                                                        "0"
                                                    ? buttonbgcolor
                                                    : textcolor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        item.unreadMessageCount.toString() !=
                                                "0"
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: CircleAvatar(
                                                  radius: 4,
                                                  backgroundColor: Colors.green,
                                                ),
                                              )
                                            : SizedBox(),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              forMessageTypeIcon(
                                                  item.lastMessageType!),
                                              SizedBox(
                                                width: forMessageTypeString(item
                                                            .lastMessageType!) !=
                                                        null
                                                    ? 3.0
                                                    : 0.0,
                                              ),
                                              Expanded(
                                                child: Text(
                                                        forMessageTypeString(item
                                                                .lastMessageType!) ??
                                                            item.lastMessageContent
                                                                .toString(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const AppDivider(
                                      padding: 0.0,
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        controller.toChatPage(data.value.jid.checkNull());
                      },
                    )
                  : SizedBox();
            }),
      ],
    );
  }

  Widget? viewMessageItem(BuildContext context, int position) {
    var maincontroller = Get.find<MainController>();
    var data = controller.recentSearchList[position].value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        position == 0 ||
                data.searchType !=
                    controller.recentSearchList[position - 1].value.searchType
            ? searchHeaderbyType(data, context)
            : SizedBox(),
        FutureBuilder(
            future: controller.getProfileandMessage(
                data.jid.checkNull(), data.mid.checkNull()),
            builder: (context, snap) {
              if (snap.hasData) {
                var profile = snap.data!.entries.first.key!;
                var item = snap.data!.entries.first.value!;
                var unreadMessageCount = "0";
                return item != null
                    ? InkWell(
                        child: Container(
                          child: Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(
                                      left: 19.0,
                                      top: 10,
                                      bottom: 10,
                                      right: 10),
                                  child: Stack(
                                    children: [
                                      ImageNetwork(
                                        url: profile.image.checkNull(),
                                        width: 48,
                                        height: 48,
                                        clipoval: true,
                                        errorWidget: ProfileTextImage(
                                          text: profile.name.checkNull().isEmpty
                                              ? profile.nickName.checkNull()
                                              : profile.name.checkNull(),
                                        ),
                                      ),
                                      unreadMessageCount.toString() != "0"
                                          ? Positioned(
                                              right: 0,
                                              child: CircleAvatar(
                                                radius: 8,
                                                child: Text(
                                                  unreadMessageCount.toString(),
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      color: Colors.white,
                                                      fontFamily: 'sf_ui'),
                                                ),
                                              ))
                                          : SizedBox(),
                                    ],
                                  )),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              profile.name.toString(),
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'sf_ui',
                                                  color: texthintcolor),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0, left: 8),
                                            child: Text(
                                              maincontroller.getRecentChatTime(
                                                  context,
                                                  item.messageSentTime),
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'sf_ui',
                                                  color: unreadMessageCount
                                                              .toString() !=
                                                          "0"
                                                      ? buttonbgcolor
                                                      : textcolor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          unreadMessageCount.toString() != "0"
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: CircleAvatar(
                                                    radius: 4,
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                )
                                              : SizedBox(),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                forMessageTypeIcon(
                                                    item.messageType!),
                                                SizedBox(
                                                  width: forMessageTypeString(item
                                                              .messageType!) !=
                                                          null
                                                      ? 3.0
                                                      : 0.0,
                                                ),
                                                Expanded(
                                                  child: forMessageTypeString(item
                                                      .messageType!) ==
                                                      null
                                                      ? spannableText(
                                                      item.messageTextContent
                                                          .toString(),
                                                      controller.search.text,Theme.of(context)
                                                      .textTheme
                                                      .titleSmall,)
                                                      : Text(
                                                    forMessageTypeString(item
                                                            .messageType!) ??
                                                        item.messageTextContent
                                                            .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const AppDivider(
                                        padding: 0.0,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        onTap: () {
                          controller.toChatPage(data.jid.checkNull());
                        },
                      )
                    : SizedBox();
              } else if (snap.hasError) {
                Log("snaperror", snap.error.toString());
              }
              return SizedBox();
            }),
      ],
    );
  }

  Widget? viewContactItem(BuildContext context,int position){
    var data = controller.recentSearchList[position].value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        position == 0 ||
            data.searchType !=
                controller.recentSearchList[position - 1].value.searchType
            ? searchHeaderbyType(data, context)
            : SizedBox(),
        FutureBuilder(
          future: controller.getProfile(data.jid.checkNull()),
          builder: (context, snapshot) {
            if(snapshot.hasData && snapshot.data !=null) {
              var item = snapshot.data!;
              return InkWell(
                child: Container(
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: 19.0,
                            top: 10,
                            bottom: 10,
                            right: 10),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                          item.image
                              .checkNull()
                              .isEmpty
                              ? iconbgcolor
                              : buttonbgcolor,
                          shape: BoxShape.circle,),
                        child: item.image
                            .checkNull()
                            .isEmpty
                            ? Icon(
                          Icons.person,
                          color: Colors.white,
                        )
                            : ImageNetwork(
                          url: item.image.toString(),
                          width: 48,
                          height: 48,
                          clipoval: true,
                          errorWidget: ProfileTextImage(
                            text: item.name
                                .checkNull()
                                .isEmpty ? item.mobileNumber.checkNull() : item.name
                                .checkNull(),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name.toString(),
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                            Text(
                              item.status.toString(),
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleSmall,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {
                  controller.toChatPage(data.jid.checkNull());
                },
              );
            }else{
              return SizedBox();
            }
          }
        ),
      ],
    );
  }

  Widget searchHeaderbyType(RecentSearch searchItem, BuildContext context) {
    var searchType = searchItem.searchType;
    var contactCount = " (${controller.filteredContactList.value.length})";
    var messageCount = " (${controller.messageCount.value})";
    var chatCount = " (${controller.chatCount.value})";
    switch (searchItem.searchType.toString()) {
      case Constants.TYPE_SEARCH_CONTACT:
        return searchHeader(searchType, contactCount, context);
      case Constants.TYPE_SEARCH_MESSAGE:
        return searchHeader(searchType, messageCount, context);
      default:
        return searchHeader(searchType, chatCount, context);
    }
  }

  Widget searchHeader(String? type, String count, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(8),
      color: dividercolor,
      child: Text.rich(TextSpan(text: type, children: [
        TextSpan(text: count, style: TextStyle(fontWeight: FontWeight.bold))
      ])),
    );
  }

  Widget spannableText(String text, String spannabletext,TextStyle? style) {
    var startIndex = text.toLowerCase().indexOf(spannabletext.toLowerCase());
    var endIndex = startIndex + spannabletext.length;
    if (startIndex != -1 && endIndex != -1) {
      var startText = text.substring(0, startIndex);
      var colorText = text.substring(startIndex, endIndex);
      var endText = text.substring(endIndex, text.length);
      Log("startText", startText);
      Log("endText", endText);
      Log("colorText", colorText);
      return Text.rich(TextSpan(
          text: startText,
          children: [
            TextSpan(text: colorText, style: TextStyle(color: Colors.blue)),
            TextSpan(
                text: endText,
                style: style)
          ],
          style: style),maxLines: 1,overflow: TextOverflow.ellipsis,);
    } else {
      return Text(
        text,
        style: style, maxLines: 1,overflow: TextOverflow.ellipsis
      );
    }
  }

  InkWell RecentChatItem(RecentChatData item, BuildContext context) {
    var maincontroller = Get.find<MainController>();
    return InkWell(
      child: Container(
        child: Row(
          children: [
            Container(
                margin:
                EdgeInsets.only(left: 19.0, top: 10, bottom: 10, right: 10),
                child: Stack(
                  children: [
                    ImageNetwork(
                      url: item.profileImage.toString(),
                      width: 48,
                      height: 48,
                      clipoval: true,
                      errorWidget: ProfileTextImage(
                        text: item.profileName.checkNull().isEmpty
                            ? item.nickName.checkNull()
                            : item.profileName.checkNull(),
                      ),
                    ),
                    item.unreadMessageCount.toString() != "0"
                        ? Positioned(
                        right: 0,
                        child: CircleAvatar(
                          radius: 8,
                          child: Text(
                            item.unreadMessageCount.toString(),
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontFamily: 'sf_ui'),
                          ),
                        ))
                        : SizedBox(),
                  ],
                )),
            Flexible(
              child: Container(
                padding: EdgeInsets.only(top: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.profileName.toString(),
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'sf_ui',
                                color: texthintcolor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0, left: 8),
                          child: Text(
                            maincontroller.getRecentChatTime(
                                context, item.lastMessageTime),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'sf_ui',
                                color: item.unreadMessageCount.toString() != "0"
                                    ? buttonbgcolor
                                    : textcolor),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        item.unreadMessageCount.toString() != "0"
                            ? Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: Colors.green,
                          ),
                        )
                            : SizedBox(),
                        Expanded(
                          child: Row(
                            children: [
                              forMessageTypeIcon(item.lastMessageType!),
                              SizedBox(width: forMessageTypeString(item.lastMessageType!)!=null ? 3.0 : 0.0,),
                              Expanded(
                                child: Text(
                                  forMessageTypeString(item.lastMessageType!) ?? item.lastMessageContent.toString(),
                                  style: Theme.of(context).textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const AppDivider(
                      padding: 0.0,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        controller.toChatPage(item.jid.checkNull());
      },
    );
  }
}
