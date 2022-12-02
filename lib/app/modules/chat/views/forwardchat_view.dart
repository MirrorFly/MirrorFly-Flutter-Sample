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
              !controller.isSearchVisible ? controller.backFromSearch() : Get.back();
            },
          ),
          title: !controller.isSearchVisible
              ? TextField(
            focusNode: controller.focusnode,
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
                  icon: SvgPicture.asset(searchIcon)),
            )
          ],
        ),
        body: Column(
          children: [
            Flexible(
              child: ListView(
                controller: controller.userlistScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Column(
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
                                item: item, context: context,onTap:() {
                                  //chat page
                                  controller.onItemClicked(item.jid.checkNull(),
                                      item.profileName.checkNull());
                                },
                                spanTxt: controller.searchQuery.text.toString(),
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
                            return FutureBuilder(
                              future: controller.getParticipantsNameAsCsv(item.jid.checkNull()),
                                builder: (cxt,data){
                                if(data.hasError){
                                  return const SizedBox();
                                }else {
                                  if (data.data != null) {
                                    return memberItem(
                                        name: item.name.checkNull(),
                                        image: item.image.checkNull(),
                                        status: data.data.checkNull(),
                                        spantext: controller.searchQuery.text.toString(),
                                        onTap: () {
                                          controller.onItemClicked(
                                              item.jid.checkNull(),
                                              item.name.checkNull());
                                        },
                                        isCheckBoxVisible: true,
                                        isChecked: controller.isChecked(
                                            item.jid.checkNull()),
                                        onchange: (value) {
                                          controller.onItemClicked(
                                              item.jid.checkNull(),
                                              item.name.checkNull());
                                        });
                                  }else{
                                    return const SizedBox();
                                  }
                                }
                            });
                          }),
                      Visibility(
                        visible: controller.userList.isNotEmpty,
                        child: searchHeader("Contacts",
                            controller.userList.length.toString(), context),
                      ),
                      Visibility(
                        visible: controller.userList.isNotEmpty,
                        child: controller.searchLoading.value ? const Center(child: CircularProgressIndicator(),) : ListView.builder(
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
                                    spantext: controller.searchQuery.text.toString(),
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
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: controller.selectedNames.isEmpty ? const Text("No Users Selected",style: TextStyle(color: textColor)) : Text(controller.selectedNames.join(","),maxLines: 2,overflow: TextOverflow.ellipsis,style: const TextStyle(color: textColor),),),
                  Visibility(
                    visible: controller.selectedNames.isNotEmpty,
                    child: InkWell(
                      onTap: () {
                        controller.forwardMessages();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("NEXT",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
                      ),
                    ),
                  )
                ],
              ),
            ),
            /*ListTile(
              leading:
                  Flexible(child: Padding(
                    padding: const EdgeInsets.only(right: 30.0),
                    child: Text(controller.selectedNames.value.join(",")),
                  )),
              trailing: InkWell(
                onTap: () {
                  controller.forwardMessages();
                },
                child: Text("NEXT",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
              ),
            )*/
          ],
        ),
      );
    });
  }
}
