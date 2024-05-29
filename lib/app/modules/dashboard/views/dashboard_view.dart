import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/views/callhistory_view.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/views/recentchat_view.dart';
import 'package:mirror_fly_demo/app/widgets/animated_floating_action.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../../common/app_localizations.dart';
import '../../../common/app_theme.dart';
import '../../../data/utils.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class DashboardView extends NavView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  DashboardController createController() {
    return DashboardController();
  }

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
                                              decoration: InputDecoration(hintText: getTranslated("searchPlaceholder"), border: InputBorder.none),
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
                                                return tabItem(title: getTranslated("chats").toUpperCase(), count: controller.unreadCountString);
                                              }),
                                              tabItem(title: getTranslated("calls").toUpperCase(), count: controller.unreadCallCountString)
                                            ]),
                                  actions: [
                                    CustomActionBarIcons(
                                        availableWidth: NavUtils.size.width * 0.80,
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
                                            overflowWidget: Text(getTranslated("info")),
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
                                            overflowWidget: Text(getTranslated("delete")),
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
                                            overflowWidget: Text(getTranslated("pin")),
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
                                            overflowWidget: Text(getTranslated("unPin")),
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
                                            overflowWidget: Text(getTranslated("mute")),
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
                                            overflowWidget: Text(getTranslated("unMute")),
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
                                            overflowWidget: Text(getTranslated("archived")),
                                            showAsAction: controller.archive.value ? ShowAsAction.always : ShowAsAction.gone,
                                            keyValue: 'Archived',
                                            onItemClick: () {
                                              controller.archiveChats();
                                            },
                                          ),
                                          CustomAction(
                                            visibleWidget: const Icon(Icons.mark_chat_read),
                                            overflowWidget: Text(getTranslated("markAsRead")),
                                            showAsAction: controller.read.value ? ShowAsAction.never : ShowAsAction.gone,
                                            keyValue: 'Mark as Read',
                                            onItemClick: () {
                                              controller.itemsRead();
                                            },
                                          ),
                                          CustomAction(
                                            visibleWidget: const Icon(Icons.mark_chat_unread),
                                            overflowWidget: Text(getTranslated("markAsUnread")),
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
                                            overflowWidget: Text(getTranslated("search")),
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
                                            overflowWidget: Text(getTranslated("clear")),
                                            showAsAction: controller.clearVisible.value ? ShowAsAction.always : ShowAsAction.gone,
                                            keyValue: 'Clear',
                                            onItemClick: () {
                                              controller.onClearPressed();
                                            },
                                          ),
                                          CustomAction(
                                            visibleWidget: const Icon(Icons.group_add),
                                            overflowWidget: Text(getTranslated("newGroup")),
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
                                            overflowWidget: Text(getTranslated("clearCallLog")),
                                            showAsAction:
                                                controller.selected.value || controller.isSearching.value || controller.currentTab.value == 0
                                                    ? ShowAsAction.gone
                                                    : ShowAsAction.never,
                                            keyValue: 'Clear call log',
                                            onItemClick: () =>
                                                controller.callLogList.isNotEmpty ? controller.clearCallLog() : toToast(getTranslated("noCallLog")),
                                          ),
                                          CustomAction(
                                            visibleWidget: const Icon(Icons.settings),
                                            overflowWidget: Text(getTranslated("settings")),
                                            showAsAction:
                                                controller.selected.value || controller.isSearching.value ? ShowAsAction.gone : ShowAsAction.never,
                                            keyValue: 'Settings',
                                            onItemClick: () {
                                              controller.gotoSettings();
                                            },
                                          ),
                                          CustomAction(
                                            visibleWidget: const Icon(Icons.web),
                                            overflowWidget: Text(getTranslated("web")),
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
                            RecentChatView(controller: controller,),
                            CallHistoryView(controller: controller,)
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
}
