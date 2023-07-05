import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/widgets.dart';

import '../../../common/app_theme.dart';
import '../../../common/widgets.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../chat/chat_widgets.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  //final themeController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        debugPrint('onFocusGained');
        // controller.initListeners();
        controller.checkArchiveSetting();
        controller.getRecentChatList();
      },
      child: WillPopScope(
        onWillPop: () {
          if (controller.selected.value) {
            controller.clearAllChatSelection();
            return Future.value(false);
          } else if (controller.isSearching.value) {
            controller.getBackFromSearch();
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: CustomSafeArea(
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
                floatingActionButton: controller.isSearching.value
                    ? null
                    : FloatingActionButton(
                        tooltip: "New Chat",
                        onPressed: () {
                          controller.gotoContacts();
                        },
                        backgroundColor: buttonBgColor,
                        child: SvgPicture.asset(
                          chatFabIcon,
                          width: 18,
                          height: 18,
                          fit: BoxFit.contain,
                        ),
                      ),
                body: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      Obx(() {
                        return SliverAppBar(
                          snap: false,
                          pinned: true,
                          floating: !controller.selected.value ||
                              !controller.isSearching.value,
                          automaticallyImplyLeading: false,
                          leading: controller.selected.value
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    controller.clearAllChatSelection();
                                  },
                                )
                              : controller.isSearching.value
                                  ? IconButton(
                                      icon: const Icon(Icons.arrow_back,
                                          color: iconColor),
                                      onPressed: () {
                                        controller.getBackFromSearch();
                                      },
                                    )
                                  : null,
                          title: controller.selected.value
                              ? Text(
                                  (controller.selectedChats.length).toString())
                              : controller.isSearching.value
                                  ? TextField(
                                      focusNode: controller.searchFocusNode,
                                      onChanged: (text) =>
                                          controller.onChange(text),
                                      controller: controller.search,
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                          hintText: "Search...",
                                          border: InputBorder.none),
                                    )
                                  : null,
                          bottom: controller.isSearching.value
                              ? null
                              : TabBar(
                                  indicatorColor: buttonBgColor,
                                  labelColor: buttonBgColor,
                                  unselectedLabelColor: appbarTextColor,
                                  tabs: [
                                      Obx(() {
                                        return tabItem(
                                            title: "CHATS",
                                            count:
                                                controller.unreadCountString);
                                      }),
                                      tabItem(title: "CALLS", count: "0")
                                    ]),
                          actions: [
                            CustomActionBarIcons(
                                availableWidth:
                                    MediaQuery.of(context).size.width * 0.80,
                                // 80 percent of the screen width
                                actionWidth: 48,
                                // default for IconButtons
                                actions: [
                                  CustomAction(
                                    visibleWidget: IconButton(
                                      onPressed: () {
                                        controller.chatInfo();
                                      },
                                      icon: SvgPicture.asset(infoIcon),
                                      tooltip: 'Info',
                                    ),
                                    overflowWidget: const Text("Info"),
                                    showAsAction: controller.info.value
                                        ? ShowAsAction.always
                                        : ShowAsAction.gone,
                                    keyValue: 'Info',
                                    onItemClick: () {
                                      controller.chatInfo();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget: IconButton(
                                      onPressed: () {
                                        controller.deleteChats();
                                      },
                                      icon: SvgPicture.asset(delete),
                                      tooltip: 'Delete',
                                    ),
                                    overflowWidget: const Text("Delete"),
                                    showAsAction: controller.delete.value
                                        ? ShowAsAction.always
                                        : ShowAsAction.gone,
                                    keyValue: 'Delete',
                                    onItemClick: () {
                                      controller.deleteChats();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget: IconButton(
                                      onPressed: () {
                                        controller.pinChats();
                                      },
                                      icon: SvgPicture.asset(pin),
                                      tooltip: 'Pin',
                                    ),
                                    overflowWidget: const Text("Pin"),
                                    showAsAction: controller.pin.value
                                        ? ShowAsAction.always
                                        : ShowAsAction.gone,
                                    keyValue: 'Pin',
                                    onItemClick: () {
                                      controller.pinChats();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget: IconButton(
                                      onPressed: () {
                                        controller.unPinChats();
                                      },
                                      icon: SvgPicture.asset(unpin),
                                      tooltip: 'UnPin',
                                    ),
                                    overflowWidget: const Text("UnPin"),
                                    showAsAction: controller.unpin.value
                                        ? ShowAsAction.always
                                        : ShowAsAction.gone,
                                    keyValue: 'UnPin',
                                    onItemClick: () {
                                      controller.unPinChats();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget: IconButton(
                                      onPressed: () {
                                        controller.muteChats();
                                      },
                                      icon: SvgPicture.asset(mute),
                                      tooltip: 'Mute',
                                    ),
                                    overflowWidget: const Text("Mute"),
                                    showAsAction: controller.mute.value
                                        ? ShowAsAction.always
                                        : ShowAsAction.gone,
                                    keyValue: 'Mute',
                                    onItemClick: () {
                                      controller.muteChats();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget: IconButton(
                                      onPressed: () {
                                        controller.unMuteChats();
                                      },
                                      icon: SvgPicture.asset(unMute),
                                      tooltip: 'UnMute',
                                    ),
                                    overflowWidget: const Text("UnMute"),
                                    showAsAction: controller.unmute.value
                                        ? ShowAsAction.always
                                        : ShowAsAction.gone,
                                    keyValue: 'UnMute',
                                    onItemClick: () {
                                      controller.unMuteChats();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget: IconButton(
                                      onPressed: () {
                                        controller.archiveChats();
                                      },
                                      icon: SvgPicture.asset(archive),
                                      tooltip: 'Archive',
                                    ),
                                    overflowWidget: const Text("Archived"),
                                    showAsAction: controller.archive.value
                                        ? ShowAsAction.always
                                        : ShowAsAction.gone,
                                    keyValue: 'Archived',
                                    onItemClick: () {
                                      controller.archiveChats();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget:
                                        const Icon(Icons.mark_chat_read),
                                    overflowWidget: const Text("Mark as read"),
                                    showAsAction: controller.read.value
                                        ? ShowAsAction.never
                                        : ShowAsAction.gone,
                                    keyValue: 'Mark as Read',
                                    onItemClick: () {
                                      controller.itemsRead();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget:
                                        const Icon(Icons.mark_chat_unread),
                                    overflowWidget:
                                        const Text("Mark as unread"),
                                    showAsAction: controller.unread.value
                                        ? ShowAsAction.never
                                        : ShowAsAction.gone,
                                    keyValue: 'Mark as unread',
                                    onItemClick: () {
                                      controller.itemsUnRead();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget: IconButton(
                                      onPressed: () {
                                        controller.gotoSearch();
                                      },
                                      icon: SvgPicture.asset(
                                        searchIcon,
                                        width: 18,
                                        height: 18,
                                        fit: BoxFit.contain,
                                      ),
                                      tooltip: 'Search',
                                    ),
                                    overflowWidget: const Text("Search"),
                                    showAsAction: controller.selected.value ||
                                            controller.isSearching.value
                                        ? ShowAsAction.gone
                                        : ShowAsAction.always,
                                    keyValue: 'Search',
                                    onItemClick: () {
                                      controller.gotoSearch();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget: IconButton(
                                        onPressed: () =>
                                            controller.onClearPressed(),
                                        icon: const Icon(Icons.close)),
                                    overflowWidget: const Text("Clear"),
                                    showAsAction: controller.clearVisible.value
                                        ? ShowAsAction.always
                                        : ShowAsAction.gone,
                                    keyValue: 'Clear',
                                    onItemClick: () {
                                      controller.onClearPressed();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget: const Icon(Icons.group_add),
                                    overflowWidget:
                                        const Text("New Group     "),
                                    showAsAction: controller.selected.value ||
                                            controller.isSearching.value
                                        ? ShowAsAction.gone
                                        : ShowAsAction.never,
                                    keyValue: 'New Group',
                                    onItemClick: () {
                                      controller.gotoCreateGroup();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget: const Icon(Icons.settings),
                                    overflowWidget: const Text("Settings"),
                                    showAsAction: controller.selected.value ||
                                            controller.isSearching.value
                                        ? ShowAsAction.gone
                                        : ShowAsAction.never,
                                    keyValue: 'Settings',
                                    onItemClick: () {
                                      controller.gotoSettings();
                                    },
                                  ),
                                  CustomAction(
                                    visibleWidget: const Icon(Icons.web),
                                    overflowWidget: const Text("Web"),
                                    showAsAction: controller.selected.value ||
                                            controller.isSearching.value
                                        ? ShowAsAction.gone
                                        : ShowAsAction.never,
                                    keyValue: 'Web',
                                    onItemClick: () => controller.webLogin(),
                                  )
                                ]),
                          ],
                        );
                      }),
                    ];
                  },
                  body: TabBarView(children: [
                    Obx(() {
                      return chatView(context);
                    }),
                    callsView(context)
                  ]),
                )),
          ),
        ),
      ),
    );
  }

  Widget tabItem({required String title, required String count}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          count != "0"
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CircleAvatar(
                    radius: 9,
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontFamily: 'sf_ui'),
                    ),
                  ),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget chatView(BuildContext context) {
    return controller.clearVisible.value
        ? recentSearchView(context)
        : Stack(
            children: [
              Obx(() {
                return Visibility(
                    visible: !controller.recentChatLoading.value &&
                        controller.recentChats.isEmpty &&
                        controller.archivedChats.isEmpty,
                    child: emptyChat(context));
              }),
              Column(
                children: [
                  Obx(() {
                    return Visibility(
                      visible: controller.archivedChats.isNotEmpty &&
                          controller.archiveSettingEnabled
                              .value /*&& controller.archivedCount.isNotEmpty*/,
                      child: ListItem(
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SvgPicture.asset(archive),
                        ),
                        title: const Text(
                          "Archived",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: controller.archivedCount != "0"
                            ? Text(
                                controller.archivedCount,
                                style: const TextStyle(color: buttonBgColor),
                              )
                            : null,
                        dividerPadding: EdgeInsets.zero,
                        onTap: () {
                          Get.toNamed(Routes.archivedChats);
                        },
                      ),
                    );
                  }),
                  Expanded(
                      child: /*FutureBuilder(
                  future: controller.getRecentChatList(),
                  builder: (c, d) {*/
                          Obx(() {
                    return controller.recentChatLoading.value
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: controller.recentChats.length + 2,
                            shrinkWrap: true,
                            controller: controller.historyScrollController,
                            itemBuilder: (BuildContext context, int index) {
                              if (index < controller.recentChats.length) {
                                var item = controller.recentChats[index];
                                return Obx(() {
                                  return RecentChatItem(
                                    item: item,
                                    isSelected: controller.isSelected(index),
                                    typingUserid: controller
                                        .typingUser(item.jid.checkNull()),
                                    onTap: () {
                                      if (controller.selected.value) {
                                        controller
                                            .selectOrRemoveChatfromList(index);
                                      } else {
                                        controller
                                            .toChatPage(item.jid.checkNull());
                                      }
                                    },
                                    onLongPress: () {
                                      controller.selected(true);
                                      controller
                                          .selectOrRemoveChatfromList(index);
                                    },
                                    onAvatarClick: () {
                                      controller.getProfileDetail(
                                          context, item, index);
                                    },
                                  );
                                });
                              } else if (index ==
                                  controller.recentChats.length) {
                                // Display loading indicator
                                return Obx(() {
                                  return controller.isRecentHistoryLoading.value
                                      ? const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(
                                            child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator()),
                                          ),
                                        )
                                      : const SizedBox.shrink();
                                });
                              } else {
                                return Obx(() {
                                  return Visibility(
                                    visible: controller
                                            .archivedChats.isNotEmpty &&
                                        !controller.archiveSettingEnabled
                                            .value /*&& controller.archivedCount.isNotEmpty*/,
                                    child: ListItem(
                                      leading: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: SvgPicture.asset(archive),
                                      ),
                                      title: const Text(
                                        "Archived",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      trailing: controller
                                              .archivedChats.isNotEmpty
                                          ? Text(
                                              controller.archivedChats.length
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: buttonBgColor),
                                            )
                                          : null,
                                      dividerPadding: EdgeInsets.zero,
                                      onTap: () {
                                        Get.toNamed(Routes.archivedChats);
                                      },
                                    ),
                                  );
                                });
                              }
                            });
                  })
                      // }),
                      ),
                ],
              )
            ],
          );
  }

  Widget recentSearchView(BuildContext context) {
    return ListView(
      controller: controller.userlistScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Obx(() {
          return Column(
            children: [
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
                visible: controller.userList.isNotEmpty &&
                    !controller.searchLoading.value,
                child: searchHeader(Constants.typeSearchContact,
                    controller.userList.length.toString(), context),
              ),
              Visibility(
                  visible: controller.searchLoading.value,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  )),
              Visibility(
                visible: controller.userList.isNotEmpty &&
                    !controller.searchLoading.value,
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
              name: getName(item),
              image: item.image.checkNull(),
              status: item.status.checkNull(),
              spantext: controller.search.text.toString(),
              onTap: () {
                controller.toChatPage(item.jid.checkNull());
              },
              isCheckBoxVisible: false,
              isGroup: item.isGroupProfile.checkNull(),
              blocked: item.isBlockedMe.checkNull() ||
                  item.isAdminBlocked.checkNull(),
              unknown: (!item.isItSavedContact.checkNull() ||
                  item.isDeletedContact()),
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
                                      text: getName(
                                          profile) /*profile.name
                                        .checkNull()
                                        .isEmpty
                                        ? profile.nickName.checkNull()
                                        : profile.name.checkNull(),*/
                                      ),
                                  isGroup: profile.isGroupProfile.checkNull(),
                                  blocked: profile.isBlockedMe.checkNull() ||
                                      profile.isAdminBlocked.checkNull(),
                                  unknown:
                                      (!profile.isItSavedContact.checkNull() ||
                                          profile.isDeletedContact()),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      getName(
                                          profile), //profile.name.toString(),
                                      style: const TextStyle(
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
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: getMessageIndicator(
                                              item.messageStatus.value
                                                  .checkNull(),
                                              item.isMessageSentByMe
                                                  .checkNull(),
                                              item.messageType.checkNull(),
                                              item.isMessageRecalled.value),
                                        ),
                                        item.isMessageRecalled.value
                                            ? const SizedBox.shrink()
                                            : forMessageTypeIcon(
                                                item.messageType,
                                                item.mediaChatMessage),
                                        SizedBox(
                                          width: forMessageTypeString(
                                                      item.messageType,
                                                      content: item
                                                          .mediaChatMessage
                                                          ?.mediaCaptionText
                                                          .checkNull()) !=
                                                  null
                                              ? 3.0
                                              : 0.0,
                                        ),
                                        Expanded(
                                          child: forMessageTypeString(
                                                      item.messageType,
                                                      content: item
                                                          .mediaChatMessage
                                                          ?.mediaCaptionText
                                                          .checkNull()) ==
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
                                                          item.messageType,
                                                          content: item
                                                              .mediaChatMessage
                                                              ?.mediaCaptionText
                                                              .checkNull()) ??
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
              future: getRecentChatOfJid(item.jid.checkNull()),
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

  Widget emptyChat(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            noChatIcon,
            width: 200,
          ),
          Text(
            'No new messages',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Any new messages will appear here',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  Stack callsView(BuildContext context) {
    return Stack(
      children: [emptyCalls(context)],
    );
  }

  Widget emptyCalls(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            noCallImage,
            width: 200,
          ),
          Text(
            'No call log history found',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Any new calls will appear here',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
