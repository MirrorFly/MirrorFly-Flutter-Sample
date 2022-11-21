import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/forwardchat_controller.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../dashboard/widgets.dart';

class ForwardChatView extends GetView<ForwardChatController> {
  const ForwardChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.search ? controller.backFromSearch() : Get.back();
            },
          ),
          title: controller.search
              ? TextField(
                  onChanged: (text) {
                    controller.onSearch(text);
                  },
                  style: const TextStyle(fontSize: 16),
                  controller: controller.searchQuery,
                  autofocus: true,
                  decoration: const InputDecoration(
                      hintText: "Search...", border: InputBorder.none),
                )
              : const Text("Forward to..."),
          actions: [
            Visibility(
              visible: controller.isSearchVisible,
              child: IconButton(
                  onPressed: () => controller.onSearchPressed(),
                  icon: SvgPicture.asset(searchicon)),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Visibility(
                    visible: controller.recentChats.isNotEmpty,
                    child: searchHeader("Recent Chat",
                        controller.recentChats.length.toString(), context),
                  ),
                  ListView.builder(
                      itemCount: controller.recentChats.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var item = controller.recentChats[index];
                        return recentChatItem(
                            item,
                            context,
                            () {
                              //chat page
                              controller.onItemClicked(item.jid.checkNull(),
                                  item.profileName.checkNull());
                            },
                            isCheckBoxVisible: true,
                            isChecked: controller.isChecked(item.jid.checkNull()),
                            onchange: (value) {
                              controller.onItemClicked(item.jid.checkNull(),
                                  item.profileName.checkNull());
                            });
                      }),
                  Visibility(
                    visible: controller.groupList.isNotEmpty,
                    child: searchHeader("Groups",
                        controller.groupList.length.toString(), context),
                  ),
                  ListView.builder(
                      itemCount: controller.groupList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var item = controller.groupList[index];
                        return memberItem(
                            name: item.name.checkNull(),
                            image: item.image.checkNull(),
                            status: item.status.checkNull(),
                            onTap: () {
                              controller.onItemClicked(item.jid.checkNull(),
                                  item.name.checkNull());
                            },
                            isCheckBoxVisible: true,
                            isChecked: controller.isChecked(item.jid.checkNull()),
                            onchange: (value) {
                              controller.onItemClicked(item.jid.checkNull(),
                                  item.name.checkNull());
                            });
                      }),
                  Visibility(
                    visible: controller.userList.isNotEmpty,
                    child: searchHeader("Contacts",
                        controller.userList.length.toString(), context),
                  ),
                  Visibility(
                    visible: controller.userList.isNotEmpty,
                    child: ListView.builder(
                        controller: controller.userlistScrollController,
                        itemCount: controller.scrollable.value
                            ? controller.userList.length + 1
                            : controller.userList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index >= controller.userList.length) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            var item = controller.userList[index];
                            return memberItem(
                                name: item.name.checkNull(),
                                image: item.image.checkNull(),
                                status: item.status.checkNull(),
                                onTap: () {
                                  controller.onItemClicked(item.jid.checkNull(),
                                      item.name.checkNull());
                                },
                                isCheckBoxVisible: true,
                                isChecked: controller.isChecked(item.jid.checkNull()),
                                onchange: (value) {
                                  controller.onItemClicked(item.jid.checkNull(),
                                      item.name.checkNull());
                                });
                          }
                        }),
                  ),
                ],
              ),
            ),
            ListTile(
              leading:
                  Flexible(child: Padding(
                    padding: const EdgeInsets.only(right: 30.0),
                    child: Text(controller.selectedNames.join(",")),
                  )),
              trailing: InkWell(
                onTap: () {},
                child: Text("NEXT"),
              ),
            )
          ],
        ),
      );
    });
  }
}
