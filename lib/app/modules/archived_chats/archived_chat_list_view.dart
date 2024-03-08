import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import '../../common/constants.dart';
import '../../widgets/custom_action_bar_icons.dart';
import '../dashboard/widgets.dart';
import 'archived_chat_list_controller.dart';

class ArchivedChatListView extends GetView<ArchivedChatListController> {
  const ArchivedChatListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        controller.getArchivedChatsList();
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          if (controller.selected.value) {
            controller.clearAllChatSelection();
            return;
          }
          Get.back();
        },
        child: Obx(() {
          return Scaffold(
            appBar: AppBar(
              leading: controller.selected.value ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clearAllChatSelection();
                },
              ) : null,
              title: controller.selected.value
                  ? Text(
                  (controller.selectedChats.length).toString())
                  : const Text('Archived Chats'),
              actions: [
                Visibility(
                  visible: controller.selected.value,
                  child: CustomActionBarIcons(
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
                                controller.deleteChats();
                              },
                              icon: SvgPicture.asset(delete),tooltip: 'Delete',),
                          overflowWidget: const Text("Delete"),
                          showAsAction: controller.delete.value ? ShowAsAction.always : ShowAsAction.gone,
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
                              icon: SvgPicture.asset(unarchive),tooltip: 'UnArchive',),
                          overflowWidget: const Text("UnArchive"),
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
              child: Obx(() =>
                  controller.archivedChats.isNotEmpty ? ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: controller.archivedChats.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        var item = controller.archivedChats[index];
                        return Obx(() {
                          return RecentChatItem(
                            item: item,
                            onAvatarClick: (){
                              controller.getProfileDetail(context, item, index);
                            },
                            isSelected: controller.isSelected(index),
                            typingUserid: controller.typingUser(
                                item.jid.checkNull()),
                            archiveVisible: false,
                            archiveEnabled: controller.archiveEnabled.value,
                            onTap: () {
                              if (controller.selected.value) {
                                controller.selectOrRemoveChatFromList(index);
                              } else {
                                controller.toChatPage(item.jid.checkNull());
                              }
                            },
                            onLongPress: () {
                              controller.selected(true);
                              controller.selectOrRemoveChatFromList(index);
                            },
                          );
                        });
                      }) : const Center(
                    child: Text('No archived chats'),
                  )),
            ),
          );
        }),
      ),
    );
  }
}
