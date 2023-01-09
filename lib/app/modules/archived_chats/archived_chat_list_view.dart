import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import '../../common/constants.dart';
import '../../widgets/custom_action_bar_icons.dart';
import '../dashboard/widgets.dart';
import 'archived_chat_list_controller.dart';

class ArchivedChatListView extends GetView<ArchivedChatListController> {
  const ArchivedChatListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (controller.selected.value) {
          controller.clearAllChatSelection();
          return Future.value(false);
        }
        return Future.value(true);
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
                              controller.unArchiveSelectedChats();
                            },
                            icon: SvgPicture.asset(unarchive)),
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
                          isSelected: controller.isSelected(index),
                          typingUserid: controller.typingUser(
                              item.jid.checkNull()),
                          archiveVisible: false,
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
                        );
                      });
                    }) : const Center(
                  child: Text('No archived chats'),
                )),
          ),
        );
      }),
    );
  }
}
