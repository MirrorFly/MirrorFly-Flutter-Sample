import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import '../../app_style_config.dart';
import '../../common/app_localizations.dart';
import '../../data/utils.dart';
import '../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/model/recent_chat.dart';

import '../../common/constants.dart';
import '../../widgets/custom_action_bar_icons.dart';
import '../dashboard/widgets.dart';
import 'archived_chat_list_controller.dart';

class ArchivedChatListView extends NavViewStateful<ArchivedChatListController> {
  const ArchivedChatListView(
      {super.key,
      this.enableAppBar = true,
      this.showChatDeliveryIndicator = true});
  final bool enableAppBar;
  final bool showChatDeliveryIndicator;

  @override
  ArchivedChatListController createController({String? tag}) =>
      Get.put(ArchivedChatListController());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          appBarTheme: AppStyleConfig.archivedChatsPageStyle.appBarTheme),
      child: FocusDetector(
        onFocusGained: () {
          controller.getArchivedChatsList();
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            if (controller.selected.value) {
              controller.clearAllChatSelection();
              return;
            }
            Navigator.pop(context);
          },
          child: Obx(() {
            return Scaffold(
              appBar: AppBar(
                leading: controller.selected.value
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clearAllChatSelection();
                        },
                      )
                    : null,
                title: controller.selected.value
                    ? Text((controller.selectedChats.length).toString())
                    : Text(getTranslated("archivedChats")),
                actions: [
                  Visibility(
                    visible: controller.selected.value,
                    child: CustomActionBarIcons(
                        availableWidth: NavUtils.size.width * 0.80,
                        // 80 percent of the screen width
                        actionWidth: 48,
                        // default for IconButtons
                        actions: [
                          CustomAction(
                            visibleWidget: IconButton(
                              onPressed: () {
                                controller.deleteChats();
                              },
                              icon: AppUtils.svgIcon(icon: delete),
                              tooltip: 'Delete',
                            ),
                            overflowWidget: Text(getTranslated("delete")),
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
                                controller.muteChats();
                              },
                              icon: AppUtils.svgIcon(
                                  icon: mute,
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context)
                                              .appBarTheme
                                              .actionsIconTheme
                                              ?.color ??
                                          Colors.black,
                                      BlendMode.srcIn)),
                              tooltip: 'Mute',
                            ),
                            overflowWidget: Text(getTranslated("mute")),
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
                              icon: AppUtils.svgIcon(
                                  icon: unMute,
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context)
                                              .appBarTheme
                                              .actionsIconTheme
                                              ?.color ??
                                          Colors.black,
                                      BlendMode.srcIn)),
                              tooltip: 'UnMute',
                            ),
                            overflowWidget: Text(getTranslated("unMute")),
                            showAsAction: controller.unMute.value
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
                                controller.unArchiveSelectedChats();
                              },
                              icon: AppUtils.svgIcon(
                                  icon: unarchive,
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context)
                                              .appBarTheme
                                              .actionsIconTheme
                                              ?.color ??
                                          Colors.black,
                                      BlendMode.srcIn)),
                              tooltip: 'UnArchive',
                            ),
                            overflowWidget: Text(getTranslated("unArchive")),
                            showAsAction: ShowAsAction.always,
                            keyValue: 'UnArchive',
                            onItemClick: () {
                              controller.unArchiveSelectedChats();
                            },
                          ),
                        ]),
                  )
                ],
              ),
              body: SafeArea(
                child: Obx(() => controller.archivedChats.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: controller.archivedChats.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          var item = controller.archivedChats[index];
                          return Obx(() {
                            return RecentChatItem(
                              recentChatItemStyle: AppStyleConfig
                                  .archivedChatsPageStyle.recentChatItemStyle,
                              item: item,
                              onAvatarClick: (RecentChatData chatItem) {
                                controller.getProfileDetail(
                                    context, item, index);
                              },
                              isSelected: controller.isSelected(index),
                              typingUserid:
                                  controller.typingUser(item.jid.checkNull()),
                              archiveVisible: false,
                              archiveEnabled: controller.archiveEnabled.value,
                              onTap: (RecentChatData chatItem) {
                                if (controller.selected.value) {
                                  controller.selectOrRemoveChatFromList(index);
                                } else {
                                  controller.toChatPage(item.jid.checkNull());
                                }
                              },
                              onLongPress: (RecentChatData chatItem) {
                                controller.selected(true);
                                controller.selectOrRemoveChatFromList(index);
                              },
                            );
                          });
                        })
                    : Center(
                        child: Text(
                          getTranslated("noArchivedChats"),
                          style: AppStyleConfig
                              .archivedChatsPageStyle.noDataTextStyle,
                        ),
                      )),
              ),
            );
          }),
        ),
      ),
    );
  }
}
