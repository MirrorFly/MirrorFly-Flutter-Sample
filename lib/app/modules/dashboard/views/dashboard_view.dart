import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/constants.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/dashboard/views/callhistory_view.dart';
import '../../../modules/dashboard/views/recentchat_view.dart';
import '../../../stylesheet/stylesheet.dart';
import '../../../widgets/animated_floating_action.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../../common/app_localizations.dart';
import '../../../common/app_theme.dart';
import '../../../data/utils.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class DashboardView extends NavViewStateful<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
DashboardController createController({String? tag}) => Get.put(DashboardController(),tag: key?.hashCode.toString());

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
            onPopInvokedWithResult: (didPop, result) {
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
            child: Theme(
              data: Theme.of(context).copyWith(tabBarTheme: AppStyleConfig.dashBoardPageStyle.tabBarTheme,
              appBarTheme: AppStyleConfig.dashBoardPageStyle.appBarTheme,
                  floatingActionButtonTheme: AppStyleConfig.dashBoardPageStyle.floatingActionButtonThemeData),
              child: CustomSafeArea(
                child: DefaultTabController(
                  length: 2,
                  child: Builder(builder: (ctx) {
                    return Scaffold(
                        floatingActionButton: controller.isSearching.value
                            ? null
                            : Obx(() {
                                return createFab(controller.currentTab.value,ctx);
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
                                                icon: const Icon(Icons.arrow_back),
                                                onPressed: () {
                                                  controller.getBackFromSearch();
                                                },
                                              )
                                            : null,
                                    title: controller.selected.value
                                        ? controller.currentTab.value == 0
                                            ? Text((controller.selectedChats.length).toString(),style: AppStyleConfig.dashBoardPageStyle.appBarTheme.titleTextStyle,)
                                            : Text((controller.selectedCallLogs.length).toString(),style: AppStyleConfig.dashBoardPageStyle.appBarTheme.titleTextStyle)
                                        : controller.isSearching.value
                                            ? TextField(
                                                focusNode: controller.searchFocusNode,
                                                onChanged: (text) => controller.onChange(text, controller.currentTab.value),
                                                controller: controller.search,
                                                autofocus: true,
                                                decoration: InputDecoration(hintText: getTranslated("searchPlaceholder"), border: InputBorder.none,hintStyle: AppStyleConfig.dashBoardPageStyle.searchTextFieldStyle.editTextHintStyle),
                                      style: AppStyleConfig.dashBoardPageStyle.searchTextFieldStyle.editTextStyle,
                                              )
                                            : null,
                                    bottom: controller.isSearching.value
                                        ? null
                                        : TabBar(
                                            controller: controller.tabController,
                                            tabs: [
                                                Obx(() {
                                                  return tabItem(title: getTranslated("chats").toUpperCase(), count: controller.unreadCountString,tabItemStyle: AppStyleConfig.dashBoardPageStyle.tabItemStyle);
                                                }),
                                                tabItem(title: getTranslated("calls").toUpperCase(), count: controller.unreadCallCountString,tabItemStyle: AppStyleConfig.dashBoardPageStyle.tabItemStyle)
                                              ]),
                                    actions: [
                                      CustomActionBarIcons(
                                        popupMenuThemeData: AppStyleConfig.dashBoardPageStyle.popupMenuThemeData,
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
                                                icon: AppUtils.svgIcon(icon:infoIcon,colorFilter: ColorFilter.mode(Theme.of(context).appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
                                                tooltip: 'Info',
                                              ),
                                              overflowWidget: Text(getTranslated("info"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
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
                                                icon: AppUtils.svgIcon(icon:delete,colorFilter: ColorFilter.mode(Theme.of(context).appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
                                                tooltip: 'Delete',
                                              ),
                                              overflowWidget: Text(getTranslated("delete"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
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
                                                icon: AppUtils.svgIcon(icon:pin,colorFilter: ColorFilter.mode(Theme.of(context).appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
                                                tooltip: 'Pin',
                                              ),
                                              overflowWidget: Text(getTranslated("pin"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
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
                                                icon: AppUtils.svgIcon(icon:unpin,colorFilter: ColorFilter.mode(Theme.of(context).appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
                                                tooltip: 'UnPin',
                                              ),
                                              overflowWidget: Text(getTranslated("unPin"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
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
                                                icon: AppUtils.svgIcon(icon:mute,colorFilter: ColorFilter.mode(Theme.of(context).appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
                                                tooltip: 'Mute',
                                              ),
                                              overflowWidget: Text(getTranslated("mute"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
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
                                                icon: AppUtils.svgIcon(icon:unMute,colorFilter: ColorFilter.mode(Theme.of(context).appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
                                                tooltip: 'UnMute',
                                              ),
                                              overflowWidget: Text(getTranslated("unMute"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
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
                                                icon: AppUtils.svgIcon(icon:archive,colorFilter: ColorFilter.mode(Theme.of(context).appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
                                                tooltip: 'Archive',
                                              ),
                                              overflowWidget: Text(getTranslated("archived"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
                                              showAsAction: controller.archive.value ? ShowAsAction.always : ShowAsAction.gone,
                                              keyValue: 'Archived',
                                              onItemClick: () {
                                                controller.archiveChats();
                                              },
                                            ),
                                            CustomAction(
                                              visibleWidget: const Icon(Icons.mark_chat_read),
                                              overflowWidget: Text(getTranslated("markAsRead"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
                                              showAsAction: controller.read.value ? ShowAsAction.never : ShowAsAction.gone,
                                              keyValue: 'Mark as Read',
                                              onItemClick: () {
                                                controller.itemsRead();
                                              },
                                            ),
                                            CustomAction(
                                              visibleWidget: const Icon(Icons.mark_chat_unread),
                                              overflowWidget: Text(getTranslated("markAsUnread"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
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
                                                icon: AppUtils.svgIcon(icon:
                                                  searchIcon,
                                                  width: 18,
                                                  height: 18,
                                                  fit: BoxFit.contain,
                                                    colorFilter: ColorFilter.mode(Theme.of(context).appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)
                                                ),
                                                tooltip: 'Search',
                                              ),
                                              overflowWidget: Text(getTranslated("search"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
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
                                              overflowWidget: Text(getTranslated("clear"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
                                              showAsAction: controller.clearVisible.value ? ShowAsAction.always : ShowAsAction.gone,
                                              keyValue: 'Clear',
                                              onItemClick: () {
                                                controller.onClearPressed();
                                              },
                                            ),
                                            CustomAction(
                                              visibleWidget: const Icon(Icons.group_add),
                                              overflowWidget: Text(getTranslated("newGroup"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
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
                                              overflowWidget: Text(getTranslated("clearCallLog"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
                                              showAsAction:
                                                  controller.selected.value || controller.isSearching.value || controller.currentTab.value == 0 || controller.callLogList.isEmpty
                                                      ? ShowAsAction.gone
                                                      : ShowAsAction.never,
                                              keyValue: 'Clear call log',
                                              onItemClick: () =>
                                                  controller.callLogList.isNotEmpty ? controller.clearCallLog() : toToast(getTranslated("noCallLog")),
                                            ),
                                            CustomAction(
                                              visibleWidget: const Icon(Icons.settings),
                                              overflowWidget: Text(getTranslated("settings"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
                                              showAsAction:
                                                  controller.selected.value || controller.isSearching.value ? ShowAsAction.gone : ShowAsAction.never,
                                              keyValue: 'Settings',
                                              onItemClick: () {
                                                controller.gotoSettings();
                                              },
                                            ),
                                            /*CustomAction(
                                              visibleWidget: const Icon(Icons.web),
                                              overflowWidget: Text(getTranslated("web"),style:AppStyleConfig.dashBoardPageStyle.popupMenuThemeData.textStyle),
                                              showAsAction:
                                                  controller.selected.value || controller.isSearching.value ? ShowAsAction.gone : ShowAsAction.never,
                                              keyValue: 'Web',
                                              onItemClick: () => controller.webLogin(),
                                            ),*/
                                          ]),
                                    ],
                                  );
                                }),
                              ];
                            },
                            body: TabBarView(controller: controller.tabController, children: [
                              RecentChatView(controller: controller, archivedTileStyle: AppStyleConfig.dashBoardPageStyle.archivedTileStyle, recentChatItemStyle: AppStyleConfig.dashBoardPageStyle.recentChatItemStyle,noDataTextStyle: AppStyleConfig.dashBoardPageStyle.noDataTextStyle,contactItemStyle: AppStyleConfig.dashBoardPageStyle.contactItemStyle,),
                              CallHistoryView(controller: controller,callHistoryItemStyle: AppStyleConfig.dashBoardPageStyle.callHistoryItemStyle,noDataTextStyle: AppStyleConfig.dashBoardPageStyle.noDataTextStyle,
                              createMeetLinkStyle: AppStyleConfig.dashBoardPageStyle.createMeetLinkStyle,recentCallsTitleStyle: AppStyleConfig.dashBoardPageStyle.titlesTextStyle,meetBottomSheetStyle: AppStyleConfig.dashBoardPageStyle.meetBottomSheetStyle,)
                            ])));
                  }),
                ),
              ),
            ),
          ),
        ));
  }

  Widget? createScaledFab(BuildContext context) {
    // Searching for index of a tab with not 0.0 scale
    final indexOfCurrentFab = controller.tabScales.indexWhere((fabScale) => fabScale != 0);
    // If there are no fabs with non-zero opacity return nothing
    if (indexOfCurrentFab == -1) {
      return null;
    }
    // Creating fab for current index
    final fab = createFab(indexOfCurrentFab,context);
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
  Widget createFab(final int index,BuildContext context) {
    if (index == 0) {
      return FloatingActionButton(
        tooltip: "New Chat",
        heroTag: "New Chat",
        onPressed: () {
          controller.gotoContacts();
        },
        child:
        AppUtils.svgIcon(icon:
          chatFabIcon,
          width: Theme.of(context).floatingActionButtonTheme.iconSize,
          colorFilter: ColorFilter.mode(Theme.of(context).floatingActionButtonTheme.foregroundColor ?? Colors.white, BlendMode.srcIn),
        ),
      );
    }
    // Not created fab for 1 index deliberately
    if (index == 1) {
      return AnimatedFloatingAction(
        tooltip: "New Call",
        backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
        foregroundColor: Theme.of(context).floatingActionButtonTheme.foregroundColor,
        icon: AppUtils.svgIcon(icon:
          plusIcon,
          width: Theme.of(context).floatingActionButtonTheme.iconSize,
          colorFilter: ColorFilter.mode(Theme.of(context).floatingActionButtonTheme.foregroundColor ?? Colors.white, BlendMode.srcIn),
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
    return const Offstage();
  }

  Widget tabItem({required String title, required String count,required TabItemStyle tabItemStyle}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: tabItemStyle.textStyle,//const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          int.parse(count) > 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CircleAvatar(
                    backgroundColor: tabItemStyle.countIndicatorStyle.bgColor,
                    radius: 9,
                    child: Text(
                      count.toString(),
                      style: tabItemStyle.countIndicatorStyle.textStyle,//const TextStyle(fontSize: 12, color: Colors.white, fontFamily: 'sf_ui'),
                    ),
                  ),
                )
              : const Offstage()
        ],
      ),
    );
  }
}
