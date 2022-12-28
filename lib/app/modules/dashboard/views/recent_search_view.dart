import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/controllers/recent_chat_search_controller.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../widgets.dart';
import 'package:flysdk/flysdk.dart';

class RecentSearchView extends GetView<RecentChatSearchController> {
  const RecentSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: iconColor),
            onPressed: () {
              Get.back();
            },
          ),
          title: TextField(
            focusNode: controller.focusNode,
            onChanged: (text) => controller.onChange(text),
            controller: controller.search,
            autofocus: true,
            decoration: const InputDecoration(
                hintText: "Search", border: InputBorder.none),
          ),
          iconTheme: const IconThemeData(color: iconColor),
        ),
        body: Column(
          children: [
            Flexible(
                child: ListView(
              controller: controller.userlistScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Obx(() {
                  return Column(
                    children: [
                      Visibility(
                          visible: controller.search.text.isEmpty,
                          child: buildEarlyChatList()),
                      Visibility(
                        visible: controller.filteredRecentChatList.isNotEmpty,
                        child: searchHeader(
                            Constants.typeSearchRecent,
                            controller.filteredRecentChatList.length.toString(),
                            context),
                      ),
                      recentChatListView(),
                      Visibility(
                        visible: controller.chatMessages.isNotEmpty,
                        child: searchHeader(Constants.typeSearchMessage,
                            controller.chatMessages.length.toString(), context),
                      ),
                      filteredMessageListView(),
                      Visibility(
                        visible: controller.userList.isNotEmpty && !controller.searchLoading.value,
                        child: searchHeader(Constants.typeSearchContact,
                            controller.userList.length.toString(), context),
                      ),
                      Visibility(visible: controller.searchLoading.value,child: const Center(
                        child: CircularProgressIndicator(),
                      )),
                      Visibility(
                        visible: controller.userList.isNotEmpty && !controller.searchLoading.value,
                        child: filteredUsersListView(),
                      ),
                      Visibility(
                          visible: controller.search.text.isNotEmpty &&
                              controller.filteredRecentChatList.isEmpty &&
                              controller.chatMessages.isEmpty &&
                              controller.userList.isEmpty,
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("No data found"),
                            ),
                          ))
                    ],
                  );
                })
              ],
            ))
          ],
        )
        /*body: Obx(() =>
            ListView.builder(
            itemCount: controller.frmRecentChatList.isNotEmpty ? controller.frmRecentChatList.length : controller.recentSearchList.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int position) {
              if(controller.frmRecentChatList.isNotEmpty){
                var item = controller.frmRecentChatList[position];
                //var image = controller.image path(item.profileImage);
                return RecentChatItem(item: item.value,onTap: () {
                  controller.toChatPage(item.value.jid.checkNull());
                });
              }else {
                mirrorFlyLog("RecentSearch",
                    controller.recentSearchList[position].toJson().toString());
                return getViewByType(
                    controller.recentSearchList[position], context, position) ??
                    const SizedBox();
              }
            }))*/
        );
  }

  ListView filteredUsersListView() {
    return ListView.builder(
        itemCount: controller.scrollable.value
            ? controller.userList.length + 1
            : controller.userList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index >= controller.userList.length &&
              controller.scrollable.value) {
            return const Center(child: CircularProgressIndicator());
          } else {
            var item = controller.userList[index];
            return memberItem(
              name: item.name.checkNull().isEmpty ? (item.nickName.checkNull().isEmpty ? item.mobileNumber.checkNull() : item.nickName.checkNull()) : item.name.checkNull(),
              image: item.image.checkNull(),
              status: item.status.checkNull(),
              spantext: controller.search.text.toString(),
              onTap: () {
                controller.toChatPage(item.jid.checkNull());
              },
              isCheckBoxVisible: false,
            );
          }
        });
  }

  ListView filteredMessageListView() {
    return ListView.builder(
        itemCount: controller.chatMessages.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          var items = controller.chatMessages[index];
          return FutureBuilder(
              future: controller.getProfileAndMessage(
                  items.chatUserJid.checkNull(), items.messageId.checkNull()),
              builder: (context, snap) {
                if (snap.hasData) {
                  var profile = snap.data!.entries.first.key!;
                  var item = snap.data!.entries.first.value!;
                  var unreadMessageCount = "0";
                  return InkWell(
                    child: Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(
                                left: 19.0, top: 10, bottom: 10, right: 10),
                            child: Stack(
                              children: [
                                ImageNetwork(
                                  url: profile.image.checkNull(),
                                  width: 48,
                                  height: 48,
                                  clipOval: true,
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
                                            style: const TextStyle(
                                                fontSize: 9,
                                                color: Colors.white,
                                                fontFamily: 'sf_ui'),
                                          ),
                                        ))
                                    : const SizedBox(),
                              ],
                            )),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: spannableText(
                                        profile.name.toString(),
                                        controller.search.text,
                                        const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'sf_ui',
                                            color: textHintColor),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 16.0, left: 8),
                                      child: Text(
                                        getRecentChatTime(context,
                                            item.messageSentTime.toInt()),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'sf_ui',
                                            color:
                                                unreadMessageCount.toString() !=
                                                        "0"
                                                    ? buttonBgColor
                                                    : textColor),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    unreadMessageCount.toString() != "0"
                                        ? const Padding(
                                            padding:
                                                EdgeInsets.only(right: 8.0),
                                            child: CircleAvatar(
                                              radius: 4,
                                              backgroundColor: Colors.green,
                                            ),
                                          )
                                        : const SizedBox(),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          forMessageTypeIcon(item.messageType),
                                          SizedBox(
                                            width: forMessageTypeString(
                                                        item.messageType) !=
                                                    null
                                                ? 3.0
                                                : 0.0,
                                          ),
                                          Expanded(
                                            child: forMessageTypeString(
                                                        item.messageType) ==
                                                    null
                                                ? spannableText(
                                                    item.messageTextContent
                                                        .toString(),
                                                    controller.search.text,
                                                    Theme.of(context)
                                                        .textTheme
                                                        .titleSmall,
                                                  )
                                                : Text(
                                                    forMessageTypeString(
                                                            item.messageType) ??
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
                                const AppDivider()
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    onTap: () {
                      controller.toChatPage(items.chatUserJid.checkNull());
                    },
                  );
                } else if (snap.hasError) {
                  mirrorFlyLog("snap error", snap.error.toString());
                }
                return const SizedBox();
              });
        });
  }

  ListView recentChatListView() {
    return ListView.builder(
        itemCount: controller.filteredRecentChatList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          var item = controller.filteredRecentChatList[index];
          return FutureBuilder(
              future: controller.getRecentChatofJid(item.jid.checkNull()),
              builder: (context, snapshot) {
                var item = snapshot.data;
                return item != null
                    ? RecentChatItem(
                        item: item,
                        spanTxt: controller.search.text,
                        onTap: () {
                          controller.toChatPage(item.jid.checkNull());
                        },
                      )
                    : const SizedBox();
              });
        });
  }

  ListView buildEarlyChatList() {
    return ListView.builder(
        itemCount: controller.frmRecentChatList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int position) {
          var item = controller.frmRecentChatList[position];
          //var image = controller.image path(item.profileImage);
          return RecentChatItem(
              item: item.value,
              onTap: () {
                controller.toChatPage(item.value.jid.checkNull());
              });
        });
  }

  Widget? getViewByType(
      Rx<RecentSearch> item, BuildContext context, int position) {
    mirrorFlyLog(
        "search type", item.value.searchType.reactive.value.toString());
    switch (item.value.searchType.reactive.value.toString()) {
      case Constants.typeSearchRecent:
        //viewRecentChatItem
        return viewRecentChatItem(item, context, position);
      case Constants.typeSearchContact:
        //viewContactItem
        return viewContactItem(context, position);
      case Constants.typeSearchMessage:
        //viewMessageItem
        return viewMessageItem(context, position);
      default:
        return const SizedBox(); //viewRecentChatItem(item, context,position);
    }
  }

  Widget? viewRecentChatItem(
      Rx<RecentSearch> data, BuildContext context, int position) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        position == 0 ||
                controller.recentSearchList[position].value.searchType !=
                    controller.recentSearchList[position - 1].value.searchType
            ? searchHeaderByType(data.value, context)
            : const SizedBox(),
        FutureBuilder(
            future: controller.getRecentChatofJid(data.value.jid.checkNull()),
            builder: (context, snapshot) {
              var item = snapshot.data;
              return item != null
                  ? RecentChatItem(
                      item: item,
                      spanTxt: controller.search.text,
                      onTap: () {
                        controller.toChatPage(data.value.jid.checkNull());
                      },
                    )
                  : const SizedBox();
            }),
      ],
    );
  }

  Widget? viewMessageItem(BuildContext context, int position) {
    var data = controller.recentSearchList[position].value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        position == 0 ||
                data.searchType !=
                    controller.recentSearchList[position - 1].value.searchType
            ? searchHeaderByType(data, context)
            : const SizedBox(),
        FutureBuilder(
            future: controller.getProfileAndMessage(
                data.jid.checkNull(), data.mid.checkNull()),
            builder: (context, snap) {
              if (snap.hasData) {
                var profile = snap.data!.entries.first.key!;
                var item = snap.data!.entries.first.value!;
                var unreadMessageCount = "0";
                return InkWell(
                  child: Row(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(
                              left: 19.0, top: 10, bottom: 10, right: 10),
                          child: Stack(
                            children: [
                              ImageNetwork(
                                url: profile.image.checkNull(),
                                width: 48,
                                height: 48,
                                clipOval: true,
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
                                          style: const TextStyle(
                                              fontSize: 9,
                                              color: Colors.white,
                                              fontFamily: 'sf_ui'),
                                        ),
                                      ))
                                  : const SizedBox(),
                            ],
                          )),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: spannableText(
                                      profile.name.toString(),
                                      controller.search.text,
                                      const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'sf_ui',
                                          color: textHintColor),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 16.0, left: 8),
                                    child: Text(
                                      getRecentChatTime(context,
                                          item.messageSentTime.toInt()),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'sf_ui',
                                          color:
                                              unreadMessageCount.toString() !=
                                                      "0"
                                                  ? buttonBgColor
                                                  : textColor),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  unreadMessageCount.toString() != "0"
                                      ? const Padding(
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: CircleAvatar(
                                            radius: 4,
                                            backgroundColor: Colors.green,
                                          ),
                                        )
                                      : const SizedBox(),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        forMessageTypeIcon(item.messageType),
                                        SizedBox(
                                          width: forMessageTypeString(
                                                      item.messageType) !=
                                                  null
                                              ? 3.0
                                              : 0.0,
                                        ),
                                        Expanded(
                                          child: forMessageTypeString(
                                                      item.messageType) ==
                                                  null
                                              ? spannableText(
                                                  item.messageTextContent
                                                      .toString(),
                                                  controller.search.text,
                                                  Theme.of(context)
                                                      .textTheme
                                                      .titleSmall,
                                                )
                                              : Text(
                                                  forMessageTypeString(
                                                          item.messageType) ??
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
                              const AppDivider()
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    controller.toChatPage(data.jid.checkNull());
                  },
                );
              } else if (snap.hasError) {
                mirrorFlyLog("snap error", snap.error.toString());
              }
              return const SizedBox();
            }),
      ],
    );
  }

  Widget? viewContactItem(BuildContext context, int position) {
    var data = controller.recentSearchList[position].value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        position == 0 ||
                data.searchType !=
                    controller.recentSearchList[position - 1].value.searchType
            ? searchHeaderByType(data, context)
            : const SizedBox(),
        FutureBuilder(
            future: controller.getProfile(data.jid.checkNull()),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                var item = snapshot.data!;
                return InkWell(
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            left: 19.0, top: 10, bottom: 10, right: 10),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: item.image.checkNull().isEmpty
                              ? iconBgColor
                              : buttonBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: item.image.checkNull().isEmpty
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                              )
                            : ImageNetwork(
                                url: item.image.toString(),
                                width: 48,
                                height: 48,
                                clipOval: true,
                                errorWidget: ProfileTextImage(
                                  text: item.name.checkNull().isEmpty
                                      ? item.mobileNumber.checkNull()
                                      : item.name.checkNull(),
                                ),
                              ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            spannableText(
                              item.name.toString(),
                              controller.search.text,
                              Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              item.status.toString(),
                              style: Theme.of(context).textTheme.titleSmall,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    controller.toChatPage(data.jid.checkNull());
                  },
                );
              } else {
                return const SizedBox();
              }
            }),
      ],
    );
  }

  Widget searchHeaderByType(RecentSearch searchItem, BuildContext context) {
    var searchType = searchItem.searchType;
    var contactCount = "${controller.filteredContactList.length}";
    var messageCount = "${controller.messageCount.value}";
    var chatCount = "${controller.chatCount.value}";
    switch (searchItem.searchType.toString()) {
      case Constants.typeSearchContact:
        return searchHeader(searchType, contactCount, context);
      case Constants.typeSearchMessage:
        return searchHeader(searchType, messageCount, context);
      default:
        return searchHeader(searchType, chatCount, context);
    }
  }
}
