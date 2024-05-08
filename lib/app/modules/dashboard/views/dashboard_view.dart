import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_highlighted_text.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/widgets.dart';
import 'package:mirror_fly_demo/app/widgets/animated_floating_action.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_plugin/model/call_log_model.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
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
    // Mirrorfly.setEventListener(this);
    return FocusDetector(
        onFocusGained: () {
          debugPrint('onFocusGained');
          // controller.initListeners();
          controller.checkArchiveSetting();
          // controller.getRecentChatList();
        },
        child: Obx(
          () => PopScope(
            canPop: !(controller.selected.value || controller.isSearching.value),
            onPopInvoked: (didPop) {
              if (didPop) {
                return;
              }
              if (controller.selected.value) {
                controller.clearAllChatSelection();
                return;
              } else if (controller.isSearching.value) {
                controller.getBackFromSearch();
                return;
              }
            },
            child: CustomSafeArea(
              child: DefaultTabController(
                length: 2,
                child: Builder(builder: (ctx) {
                  return Scaffold(
                      floatingActionButton: controller.isSearching.value
                          ? null
                          : Obx(() {
                              return createFab(controller.currentTab.value);
                            }),
                      body: NestedScrollView(
                          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                            return [
                              Obx(() {
                                return SliverAppBar(
                                  snap: false,
                                  pinned: true,
                                  floating: !controller.selected.value || !controller.isSearching.value,
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
                                              icon: const Icon(Icons.arrow_back, color: iconColor),
                                              onPressed: () {
                                                controller.getBackFromSearch();
                                              },
                                            )
                                          : null,
                                  title: controller.selected.value
                                      ? controller.currentTab.value == 0
                                          ? Text((controller.selectedChats.length).toString())
                                          : Text((controller.selectedCallLogs.length).toString())
                                      : controller.isSearching.value
                                          ? TextField(
                                              focusNode: controller.searchFocusNode,
                                              onChanged: (text) => controller.onChange(text, controller.currentTab.value),
                                              controller: controller.search,
                                              autofocus: true,
                                              decoration: const InputDecoration(hintText: "Search...", border: InputBorder.none),
                                            )
                                          : null,
                                  bottom: controller.isSearching.value
                                      ? null
                                      : TabBar(
                                          controller: controller.tabController,
                                          indicatorColor: buttonBgColor,
                                          labelColor: buttonBgColor,
                                          unselectedLabelColor: appbarTextColor,
                                          tabs: [
                                              Obx(() {
                                                return tabItem(title: "CHATS", count: controller.unreadCountString);
                                              }),
                                              tabItem(title: "CALLS", count: controller.unreadCallCountString)
                                            ]),
                                  actions: [
                                    CustomActionBarIcons(
                                        availableWidth: MediaQuery.of(context).size.width * 0.80,
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
                                            showAsAction: controller.info.value ? ShowAsAction.always : ShowAsAction.gone,
                                            keyValue: 'Info',
                                            onItemClick: () {
                                              controller.chatInfo();
                                            },
                                          ),
                                          CustomAction(
                                            visibleWidget: IconButton(
                                              onPressed: () {
                                                controller.currentTab.value == 0 ? controller.deleteChats() : controller.deleteCallLog();
                                              },
                                              icon: SvgPicture.asset(delete),
                                              tooltip: 'Delete',
                                            ),
                                            overflowWidget: const Text("Delete"),
                                            showAsAction: controller.availableFeatures.value.isDeleteChatAvailable.checkNull()
                                                ? controller.delete.value
                                                    ? ShowAsAction.always
                                                    : ShowAsAction.gone
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
                                            showAsAction: controller.pin.value ? ShowAsAction.always : ShowAsAction.gone,
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
                                            showAsAction: controller.unpin.value ? ShowAsAction.always : ShowAsAction.gone,
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
                                            showAsAction: controller.mute.value ? ShowAsAction.always : ShowAsAction.gone,
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
                                            showAsAction: controller.unmute.value ? ShowAsAction.always : ShowAsAction.gone,
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
                                            showAsAction: controller.archive.value ? ShowAsAction.always : ShowAsAction.gone,
                                            keyValue: 'Archived',
                                            onItemClick: () {
                                              controller.archiveChats();
                                            },
                                          ),
                                          CustomAction(
                                            visibleWidget: const Icon(Icons.mark_chat_read),
                                            overflowWidget: const Text("Mark as read"),
                                            showAsAction: controller.read.value ? ShowAsAction.never : ShowAsAction.gone,
                                            keyValue: 'Mark as Read',
                                            onItemClick: () {
                                              controller.itemsRead();
                                            },
                                          ),
                                          CustomAction(
                                            visibleWidget: const Icon(Icons.mark_chat_unread),
                                            overflowWidget: const Text("Mark as unread"),
                                            showAsAction: controller.unread.value ? ShowAsAction.never : ShowAsAction.gone,
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
                                            showAsAction: controller.availableFeatures.value.isRecentChatSearchAvailable.checkNull()
                                                ? controller.selected.value || controller.isSearching.value
                                                    ? ShowAsAction.gone
                                                    : ShowAsAction.always
                                                : ShowAsAction.gone,
                                            keyValue: 'Search',
                                            onItemClick: () {
                                              controller.gotoSearch();
                                            },
                                          ),
                                          CustomAction(
                                            visibleWidget: IconButton(onPressed: () => controller.onClearPressed(), icon: const Icon(Icons.close)),
                                            overflowWidget: const Text("Clear"),
                                            showAsAction: controller.clearVisible.value ? ShowAsAction.always : ShowAsAction.gone,
                                            keyValue: 'Clear',
                                            onItemClick: () {
                                              controller.onClearPressed();
                                            },
                                          ),
                                          CustomAction(
                                            visibleWidget: const Icon(Icons.group_add),
                                            overflowWidget: const Text("New Group     "),
                                            showAsAction: controller.availableFeatures.value.isGroupChatAvailable.checkNull()
                                                ? controller.selected.value || controller.isSearching.value
                                                    ? ShowAsAction.gone
                                                    : ShowAsAction.never
                                                : ShowAsAction.gone,
                                            keyValue: 'New Group',
                                            onItemClick: () {
                                              controller.gotoCreateGroup();
                                            },
                                          ),
                                          CustomAction(
                                            visibleWidget: const Icon(Icons.web),
                                            overflowWidget: const Text("Clear call log"),
                                            showAsAction:
                                                controller.selected.value || controller.isSearching.value || controller.currentTab.value == 0
                                                    ? ShowAsAction.gone
                                                    : ShowAsAction.never,
                                            keyValue: 'Clear call log',
                                            onItemClick: () =>
                                                controller.callLogList.isNotEmpty ? controller.clearCallLog() : toToast(Constants.noCallLog),
                                          ),
                                          CustomAction(
                                            visibleWidget: const Icon(Icons.settings),
                                            overflowWidget: const Text("Settings"),
                                            showAsAction:
                                                controller.selected.value || controller.isSearching.value ? ShowAsAction.gone : ShowAsAction.never,
                                            keyValue: 'Settings',
                                            onItemClick: () {
                                              controller.gotoSettings();
                                            },
                                          ),
                                          CustomAction(
                                            visibleWidget: const Icon(Icons.web),
                                            overflowWidget: const Text("Web"),
                                            showAsAction:
                                                controller.selected.value || controller.isSearching.value ? ShowAsAction.gone : ShowAsAction.never,
                                            keyValue: 'Web',
                                            onItemClick: () => controller.webLogin(),
                                          ),
                                        ]),
                                  ],
                                );
                              }),
                            ];
                          },
                          body: TabBarView(controller: controller.tabController, children: [
                            Obx(() {
                              return chatView(ctx);
                            }),
                            callsView(ctx)
                          ])));
                }),
              ),
            ),
          ),
        ));
  }

  Widget? createScaledFab() {
    // Searching for index of a tab with not 0.0 scale
    final indexOfCurrentFab = controller.tabScales.indexWhere((fabScale) => fabScale != 0);
    // If there are no fabs with non-zero opacity return nothing
    if (indexOfCurrentFab == -1) {
      return null;
    }
    // Creating fab for current index
    final fab = createFab(indexOfCurrentFab);
    // If no fab created return nothing
    /*if (fab == null) {
      return null;
    }*/
    final currentFabScale = controller.tabScales[indexOfCurrentFab];
    // Scale created fab with
    // You can use different Widgets to create different effects of switching
    // fabs. E.g. you can use Opacity widget or Transform.translate to create
    // custom animation effects
    return Transform.scale(scale: currentFabScale, child: fab);
  }

  // Create fab for provided index
  // You can skip creating fab for any indexes you want
  Widget createFab(final int index) {
    if (index == 0) {
      return FloatingActionButton(
        tooltip: "New Chat",
        heroTag: "New Chat",
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
      );
    }
    // Not created fab for 1 index deliberately
    if (index == 1) {
      return AnimatedFloatingAction(
        tooltip: "New Call",
        icon: SvgPicture.asset(
          plusIcon,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          fit: BoxFit.contain,
        ),
        audioCallOnPressed: () {
          controller.gotoContacts(forCalls: true, callType: CallType.audio);
        },
        videoCallOnPressed: () {
          controller.gotoContacts(forCalls: true, callType: CallType.video);
        },
      );
      /*return FloatingActionButton(
        tooltip: "New Call",
        heroTag: "New Call",
        onPressed: () {
          controller.gotoContacts();
        },
        backgroundColor: buttonBgColor,
        child: SvgPicture.asset(
          plusIcon,
          width: 24,
          height: 24,
          color: Colors.white,
          fit: BoxFit.contain,
        ),
      );*/
    }
    return const SizedBox.shrink();
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
          int.parse(count) > 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CircleAvatar(
                    backgroundColor: buttonBgColor,
                    radius: 9,
                    child: Text(
                      count.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontFamily: 'sf_ui'),
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
                    visible: !controller.recentChatLoading.value && controller.recentChats.isEmpty && controller.archivedChats.isEmpty,
                    child: emptyChat(context));
              }),
              Column(
                children: [
                  Visibility(
                    visible: Constants.enableTopic,
                    child: SizedBox(
                      height: 40,
                      child: Obx(() {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.topics.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                controller.onTopicsTap(index);
                              },
                              child: Obx(() {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0), // Specify the border radius
                                    side: (controller.topicId.value == controller.topics[index].topicId)
                                        ? const BorderSide(
                                            color: Colors.blue, // Specify the border color
                                            width: 2.0, // Specify the border width
                                          )
                                        : BorderSide.none,
                                  ),
                                  color: Colors.grey[100],
                                  margin: const EdgeInsets.all(4.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(controller.topics[index].topicName.checkNull()),
                                  ),
                                );
                              }),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                  /*Visibility(
              visible: Constants.enableTopic,
              child: SizedBox(
                child: Obx(() {
                  return controller.topics.isNotEmpty ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Specify the border radius
                      ),
                      color: Colors.grey[100],
                      margin: const EdgeInsets.all(4.0),
                      child: ListTile(
                        title: Text(controller.topics[0].topicName.checkNull()),
                        subtitle: Text(controller.topics[0].metaData["description"]),
                      )
                  ) : const SizedBox.shrink();
                }),
              ),),*/
                  Obx(() {
                    return Visibility(
                      visible:
                          controller.archivedChats.isNotEmpty && controller.archiveSettingEnabled.value /*&& controller.archivedCount.isNotEmpty*/,
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
                  Expanded(child: Obx(() {
                    return controller.recentChatLoading.value
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
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
                                    typingUserid: controller.typingUser(item.jid.checkNull()),
                                    onTap: () {
                                      if (controller.selected.value) {
                                        controller.selectOrRemoveChatfromList(index);
                                      } else {
                                        controller.toChatPage(item.jid.checkNull());
                                      }
                                    },
                                    onLongPress: () {
                                      controller.selected(true);
                                      controller.selectOrRemoveChatfromList(index);
                                    },
                                    onAvatarClick: () {
                                      controller.getProfileDetail(context, item, index);
                                    },
                                  );
                                });
                              } else if (index == controller.recentChats.length) {
                                // Display loading indicator
                                return Obx(() {
                                  return controller.isRecentHistoryLoading.value
                                      ? const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(
                                            child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
                                          ),
                                        )
                                      : const SizedBox.shrink();
                                });
                              } else {
                                return Obx(() {
                                  return Visibility(
                                    visible: controller.archivedChats.isNotEmpty &&
                                        !controller.archiveSettingEnabled.value /*&& controller.archivedCount.isNotEmpty*/,
                                    child: ListItem(
                                      leading: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: SvgPicture.asset(archive),
                                      ),
                                      title: const Text(
                                        "Archived",
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      trailing: controller.archivedChats.isNotEmpty
                                          ? Text(
                                              controller.archivedChats.length.toString(),
                                              style: const TextStyle(color: buttonBgColor),
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
                child: searchHeader(Constants.typeSearchRecent, controller.filteredRecentChatList.length.toString(), context),
              ),
              recentChatSearchListView(),
              Visibility(
                visible: controller.chatMessages.isNotEmpty,
                child: searchHeader(Constants.typeSearchMessage, controller.chatMessages.length.toString(), context),
              ),
              filteredMessageListView(),
              Visibility(
                visible: controller.userList.isNotEmpty && !controller.searchLoading.value,
                child: searchHeader(Constants.typeSearchContact, controller.userList.length.toString(), context),
              ),
              Visibility(
                  visible: controller.searchLoading.value,
                  child: const Center(
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
                      child: Text(Constants.noDataFound),
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
        itemCount: controller.scrollable.value ? controller.userList.length + 1 : controller.userList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index >= controller.userList.length && controller.scrollable.value) {
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
              blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
              unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),
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
              future: controller.getProfileAndMessage(items.chatUserJid.checkNull(), items.messageId.checkNull()),
              builder: (context, snap) {
                if (snap.hasData) {
                  var profile = snap.data!.entries.first.key!;
                  var item = snap.data!.entries.first.value!;
                  var unreadMessageCount = "0";
                  return InkWell(
                    child: Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(left: 19.0, top: 10, bottom: 10, right: 10),
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
                                  blocked: profile.isBlockedMe.checkNull() || profile.isAdminBlocked.checkNull(),
                                  unknown: (!profile.isItSavedContact.checkNull() || profile.isDeletedContact()),
                                ),
                                unreadMessageCount.toString() != "0"
                                    ? Positioned(
                                        right: 0,
                                        child: CircleAvatar(
                                          radius: 8,
                                          child: Text(
                                            unreadMessageCount.toString(),
                                            style: const TextStyle(fontSize: 9, color: Colors.white, fontFamily: 'sf_ui'),
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
                                      getName(profile), //profile.name.toString(),
                                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, fontFamily: 'sf_ui', color: textHintColor),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0, left: 8),
                                    child: Text(
                                      getRecentChatTime(context, item.messageSentTime.toInt()),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'sf_ui',
                                          color: unreadMessageCount.toString() != "0" ? buttonBgColor : textColor),
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
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: getMessageIndicator(item.messageStatus.value.checkNull(), item.isMessageSentByMe.checkNull(),
                                              item.messageType.checkNull(), item.isMessageRecalled.value),
                                        ),
                                        item.isMessageRecalled.value
                                            ? const SizedBox.shrink()
                                            : forMessageTypeIcon(item.messageType, item.mediaChatMessage),
                                        SizedBox(
                                          width:
                                              forMessageTypeString(item.messageType, content: item.mediaChatMessage?.mediaCaptionText.checkNull()) !=
                                                      null
                                                  ? 3.0
                                                  : 0.0,
                                        ),
                                        Expanded(
                                          child:
                                              forMessageTypeString(item.messageType, content: item.mediaChatMessage?.mediaCaptionText.checkNull()) ==
                                                      null
                                                  ? spannableText(
                                                      item.messageTextContent.toString(),
                                                      controller.search.text,
                                                      Theme.of(context).textTheme.titleSmall,
                                                    )
                                                  : Text(
                                                      forMessageTypeString(item.messageType,
                                                              content: item.mediaChatMessage?.mediaCaptionText.checkNull()) ??
                                                          item.messageTextContent.toString(),
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
                  LogMessage.d("snap error", snap.error.toString());
                }
                return const SizedBox();
              });
        });
  }

  ListView recentChatSearchListView() {
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
            Constants.noChats,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            Constants.noChatsMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  Stack callsView(BuildContext context) {
    return Stack(
      children: [
        Obx(
          () => controller.callLogList.isEmpty ? emptyCalls(context) : callLogView(context, controller.callLogList),
        )
        // emptyCalls(context)
      ],
    );
  }

  Widget callLogView(BuildContext context, List<CallLogData> callLogList) {
    if (callLogList.isEmpty) {
      if (controller.loading.value) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ));
      } else if (controller.error.value) {
        return const Center(child: Text("Error"));
      }
    }
    return ListView.builder(
        controller: controller.callLogScrollController,
        itemCount: callLogList.length,
        itemBuilder: (context, index) {
          var item = callLogList[index];
          if (index == callLogList.length) {
            if (controller.error.value) {
              return const Center(child: Text("Error"));
            } else {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ));
            }
          }
          return item.callMode == CallMode.oneToOne && (item.userList == null || item.userList!.length < 2)
              ? Obx(() => ListTile(
                    leading: FutureBuilder(
                        future: getProfileDetails(item.callState == 1 ? item.toUser! : item.fromUser!),
                        builder: (context, snap) {
                          return snap.hasData && snap.data != null
                              ? ImageNetwork(
                                  url: snap.data!.image!,
                                  width: 48,
                                  height: 48,
                                  clipOval: true,
                                  errorWidget: getName(snap.data!) //item.nickName
                                          .checkNull()
                                          .isNotEmpty
                                      ? ProfileTextImage(text: getName(snap.data!))
                                      : const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                  isGroup: false,
                                  blocked: false,
                                  unknown: false,
                                )
                              : const SizedBox.shrink();
                        }),
                    title: FutureBuilder(
                        future: getProfileDetails(item.callState == 1 ? item.toUser! : item.fromUser!),
                        builder: (context, snap) {
                          return snap.hasData && snap.data != null && controller.search.text.isNotEmpty
                              ? CallHighlightedText(content: snap.data!.name!, searchString: controller.search.text.trim())
                              : snap.hasData && snap.data != null && controller.search.text.isEmpty
                                  ? Text(
                                      snap.data!.name!,
                                      style: const TextStyle(color: Colors.black),
                                    )
                                  : const SizedBox.shrink();
                        }),
                    subtitle: SizedBox(
                      child: callLogTime(
                          "${getCallLogDateFromTimestamp(item.callTime!, "dd-MMM")}  ${getChatTime(context, item.callTime)}", item.callState),
                    ),
                    trailing: SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            getCallLogDuration(item.startTime!, item.endTime!),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          callIcon(item.callType, item, item.callMode, []),
                        ],
                      ),
                    ),
                    selectedTileColor: controller.isLogSelected(index) ? Colors.grey[400] : null,
                    selected: controller.isLogSelected(index),
                    onLongPress: () {
                      controller.selectedLog(true);
                      controller.selectOrRemoveCallLogFromList(index);
                    },
                    onTap: () {
                      if (controller.selectedLog.value) {
                        controller.selectOrRemoveCallLogFromList(index);
                      } else {
                        controller.toChatPage(item.callState == CallState.outgoingCall ? item.toUser! : item.fromUser!);
                      }
                    },
                  ))
              : Obx(() => ListTile(
                    leading: item.groupId.checkNull().isEmpty
                        ? ClipOval(
                            child: Image.asset(
                              groupImg,
                              height: 48,
                              width: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : FutureBuilder(
                            future: getProfileDetails(item.groupId!),
                            builder: (context, snap) {
                              return snap.hasData && snap.data != null
                                  ? ImageNetwork(
                                      url: snap.data!.image!,
                                      width: 48,
                                      height: 48,
                                      clipOval: true,
                                      errorWidget: ClipOval(
                                        child: Image.asset(
                                          groupImg,
                                          height: 48,
                                          width: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      isGroup: false,
                                      blocked: false,
                                      unknown: false,
                                    )
                                  : ClipOval(
                                      child: Image.asset(
                                        groupImg,
                                        height: 48,
                                        width: 48,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                            }),
                    title: item.groupId.checkNull().isEmpty
                        ? FutureBuilder(
                            future: CallUtils.getCallLogUserNames(item.userList!, item),
                            builder: (context, snap) {
                              if (snap.hasData) {
                                return controller.search.text.isNotEmpty
                                    ? CallHighlightedText(content: snap.data!, searchString: controller.search.text.trim())
                                    : Text(
                                        snap.data!,
                                        style: const TextStyle(color: Colors.black),
                                      );
                              } else {
                                return const SizedBox.shrink();
                              }
                            })
                        : FutureBuilder(
                            future: getProfileDetails(item.groupId!),
                            builder: (context, snap) {
                              if (snap.hasData) {
                                return controller.search.text.isNotEmpty
                                    ? CallHighlightedText(content: snap.data!.name!, searchString: controller.search.text.trim())
                                    : Text(
                                        snap.data!.name!,
                                        style: const TextStyle(color: Colors.black),
                                      );
                              } else {
                                return const SizedBox.shrink();
                              }
                            }),
                    subtitle: SizedBox(
                      child: callLogTime(
                          "${getCallLogDateFromTimestamp(item.callTime!, "dd-MMM")}  ${getChatTime(context, item.callTime)}", item.callState),
                    ),
                    trailing: SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            getCallLogDuration(item.startTime!, item.endTime!),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          callIcon(item.callType, item, item.callMode, item.userList),
                        ],
                      ),
                    ),
                    selectedTileColor: controller.isLogSelected(index) ? Colors.grey[400] : null,
                    selected: controller.isLogSelected(index),
                    onLongPress: () {
                      controller.selectedLog(true);
                      controller.selectOrRemoveCallLogFromList(index);
                    },
                    onTap: () {
                      if (controller.selectedLog.value) {
                        controller.selectOrRemoveCallLogFromList(index);
                      } else {
                        controller.toCallInfo(item);
                      }
                    },
                  ));
        });
  }

  Widget emptyCalls(BuildContext context) {
    return !controller.callLogSearchLoading.value
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  noCallImage,
                  width: 200,
                ),
                Text(
                  Constants.noCallLogs,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  Constants.noCallLogsMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: callsSubText),
                ),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  Widget callIcon(String? callType, CallLogData item, String? callMode, List<String>? userList) {
    List<String>? localUserList = [];
    if (item.callState == CallState.missedCall || item.callState == CallState.incomingCall) {
      localUserList.addAll(item.userList!);
      if (!item.userList!.contains(item.fromUser)) {
        localUserList.add(item.fromUser!);
      }
    } else {
      localUserList.addAll(item.userList!);
    }
    return callType!.toLowerCase() == CallType.video
        ? IconButton(
            onPressed: () {
              callMode == CallMode.oneToOne
                  ? controller.makeVideoCall(item.callState == CallState.missedCall
                      ? item.fromUser
                      : item.callState == CallState.incomingCall
                          ? item.fromUser
                          : item.toUser)
                  : controller.makeCall(localUserList, callType, item);
            },
            icon: SvgPicture.asset(
              videoCallIcon,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
          )
        : IconButton(
            onPressed: () {
              callMode == CallMode.oneToOne
                  ? controller.makeVoiceCall(item.callState == CallState.missedCall
                      ? item.fromUser
                      : item.callState == CallState.incomingCall
                          ? item.fromUser
                          : item.toUser)
                  : controller.makeCall(localUserList, callType, item);
            },
            icon: SvgPicture.asset(
              audioCallIcon,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ));
  }

  // @override
  // void onMessageReceivedEvent(String message) {
  //   debugPrint("onMessageReceivedEvent $message");
  // }
  //
  // @override
  // void onMessageStatusUpdatedEvent(status) {
  //
  // }
}
