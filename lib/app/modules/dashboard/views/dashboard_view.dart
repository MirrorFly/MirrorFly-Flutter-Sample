import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/widgets.dart';

import '../../../common/widgets.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  //final themeController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        // controller.initListeners();
        controller.checkArchiveSetting();
        controller.getRecentChatList();
      },
      child: WillPopScope(
        onWillPop: () {
          if (controller.selected.value) {
            controller.clearAllChatSelection();
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
              floatingActionButton: FloatingActionButton(
                tooltip: "New Chat",
                onPressed: () {
                  Get.toNamed(Routes.contacts, arguments: {
                    "forward": false,
                    "group": false,
                    "groupJid": ""
                  });
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
                        floating: !controller.selected.value,
                        automaticallyImplyLeading: false,
                        leading: controller.selected.value ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.clearAllChatSelection();
                          },
                        ) : null,
                        title: controller.selected.value
                            ? Text(
                            (controller.selectedChats.length).toString())
                            : null,
                        bottom: TabBar(
                            indicatorColor: buttonBgColor,
                            labelColor: buttonBgColor,
                            unselectedLabelColor: appbarTextColor,
                            tabs: [
                              Obx(() {
                                return tabItem(
                                    title: "CHATS",
                                    count: controller.unreadCountString);
                              }),
                              tabItem(title: "CALLS", count: "0")
                            ]),
                        actions: [
                          CustomActionBarIcons(
                              availableWidth: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.80,
                              // 80 percent of the screen width
                              actionWidth: 48,
                              // default for IconButtons
                              actions: [
                                CustomAction(
                                  visibleWidget: IconButton(
                                      onPressed: () {
                                        controller.chatInfo();
                                      },
                                      icon: SvgPicture.asset(infoIcon),tooltip: 'Info',),
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
                                      icon: SvgPicture.asset(delete),tooltip: 'Delete',),
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
                                      icon: SvgPicture.asset(pin),tooltip: 'Pin',),
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
                                      icon: SvgPicture.asset(unpin),tooltip: 'UnPin',),
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
                                      icon: SvgPicture.asset(mute),tooltip: 'Mute',),
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
                                      icon: SvgPicture.asset(unMute),tooltip: 'UnMute',),
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
                                      icon: SvgPicture.asset(archive),tooltip: 'Archive',),
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
                                  visibleWidget: const Icon(
                                      Icons.mark_chat_read),
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
                                  visibleWidget: const Icon(
                                      Icons.mark_chat_unread),
                                  overflowWidget: const Text("Mark as unread"),
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
                                  showAsAction: controller.selected.value
                                      ? ShowAsAction.gone
                                      : ShowAsAction.always,
                                  keyValue: 'Search',
                                  onItemClick: () {
                                    controller.gotoSearch();
                                  },
                                ),
                                CustomAction(
                                  visibleWidget: const Icon(Icons.group_add),
                                  overflowWidget: const Text("New Group     "),
                                  showAsAction: controller.selected.value
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
                                  showAsAction: controller.selected.value
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
                                  showAsAction: controller.selected.value
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
                body: TabBarView(
                    children: [chatView(context), callsView(context)]),
              )),
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

  Stack chatView(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          return Visibility(
              visible: !controller.recentChatLoding.value && controller.recentChats.isEmpty,
              child: emptyChat(context));
        }),
        Column(
          children: [
            Obx(() {
              return Visibility(
                visible: controller.archivedChats.isNotEmpty && controller.archiveSettingEnabled.value /*&& controller.archivedCount.isNotEmpty*/,
                child: ListItem(
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SvgPicture.asset(archive),
                  ),
                  title: const Text(
                    "Archived",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: controller.archivedCount != "0" ? Text(
                    controller.archivedCount,
                    style: const TextStyle(color: buttonBgColor),
                  ):null,
                  dividerPadding: EdgeInsets.zero,
                  onTap: (){
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
                      return controller.recentChatLoding.value ? const Center(child: CircularProgressIndicator(),) :
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.recentChats.length+1,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            if(index<controller.recentChats.length) {
                              var item = controller.recentChats[index];
                              return Obx(() {
                                return RecentChatItem(
                                  item: item,
                                  isSelected: controller.isSelected(index),
                                  typingUserid: controller.typingUser(
                                      item.jid.checkNull()),
                                  onTap: () {
                                    if (controller.selected.value) {
                                      controller.selectOrRemoveChatfromList(
                                          index);
                                    } else {
                                      controller.toChatPage(
                                          item.jid.checkNull());
                                    }
                                  },
                                  onLongPress: () {
                                    controller.selected(true);
                                    controller.selectOrRemoveChatfromList(
                                        index);
                                  },);
                              });
                            }else{
                              return Obx(() {
                                return Visibility(
                                  visible: controller.archivedChats.isNotEmpty && !controller.archiveSettingEnabled.value /*&& controller.archivedCount.isNotEmpty*/,
                                  child: ListItem(
                                    leading: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: SvgPicture.asset(archive),
                                    ),
                                    title: const Text(
                                      "Archived",
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    trailing: controller.archivedCount != "0" ? Text(
                                      controller.archivedCount,
                                      style: const TextStyle(color: buttonBgColor),
                                    ):null,
                                    dividerPadding: EdgeInsets.zero,
                                    onTap: (){
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
            style: Theme
                .of(context)
                .textTheme
                .titleMedium,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Any new messages will appear here',
            textAlign: TextAlign.center,
            style: Theme
                .of(context)
                .textTheme
                .titleSmall,
          ),
        ],
      ),
    );
  }

  Stack callsView(BuildContext context) {
    return Stack(
      children: [
        emptyCalls(context)
      ],
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
            style: Theme
                .of(context)
                .textTheme
                .titleMedium,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Any new calls will appear here',
            textAlign: TextAlign.center,
            style: Theme
                .of(context)
                .textTheme
                .titleSmall,
          ),
        ],
      ),
    );
  }
}
