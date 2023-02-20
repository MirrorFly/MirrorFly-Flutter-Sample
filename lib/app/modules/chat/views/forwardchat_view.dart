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
                  onChanged: (text) {
                    mirrorFlyLog("text", text);
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
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                child: ListView(
                  controller: controller.userlistScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Column(
                      children: [
                        Visibility(
                          visible: !controller.searchLoading.value && controller.recentChats.isEmpty && controller.groupList.isEmpty && controller.userList.isEmpty,
                          child: const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text('No Results found'),
                          ),),
                        ),
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
                              return Opacity(
                                opacity: item.isBlocked.checkNull() ? 0.3 : 1.0,
                                child: RecentChatItem(
                                    item: item,onTap:() {
                                      //chat page
                                      controller.onItemSelect(item.jid.checkNull(),
                                          item.profileName.checkNull(),item.isBlocked.checkNull());
                                    },
                                    spanTxt: controller.searchQuery.text.toString(),
                                    isCheckBoxVisible: true,
                                    isForwardMessage: true,
                                    isChecked: controller.isChecked(item.jid.checkNull()),
                                    onchange: (value) {
                                      controller.onItemSelect(item.jid.checkNull(),
                                          item.profileName.checkNull(),item.isBlocked.checkNull());
                                    }),
                              );
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
                                      return Opacity(
                                        opacity: item.isBlocked.checkNull() ? 0.3 : 1.0,
                                        child: memberItem(
                                            name: item.name.checkNull(),
                                            image: item.image.checkNull(),
                                            status: data.data.checkNull(),
                                            spantext: controller.searchQuery.text.toString(),
                                            onTap: () {
                                              controller.onItemSelect(
                                                  item.jid.checkNull(),
                                                  item.name.checkNull(),item.isBlocked.checkNull());
                                            },
                                            isCheckBoxVisible: true,
                                            isChecked: controller.isChecked(
                                                item.jid.checkNull()),
                                            onchange: (value) {
                                              controller.onItemSelect(
                                                  item.jid.checkNull(),
                                                  item.name.checkNull(),item.isBlocked.checkNull());
                                            }),
                                      );
                                    }else{
                                      return const SizedBox();
                                    }
                                  }
                              });
                            }),
                        Visibility(
                          visible: controller.userList.isNotEmpty,
                          child: searchHeader("Contacts",
                              controller.userList.isNotEmpty ? controller.userList.length.toString() : "", context),
                        ),
                        Visibility(
                          visible: controller.searchLoading.value || controller.contactLoading.value,
                          child: const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularProgressIndicator(),
                          ),),
                        ),
                        /*Visibility(
                          visible: !controller.searchLoading.value && controller.userList.isEmpty,
                          child: const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('No Contacts found'),
                          ),),
                        ),*/
                        Visibility(
                          visible: controller.userList.isNotEmpty,
                          child: controller.searchLoading.value ? const SizedBox.shrink() : ListView.builder(
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
                                  return Opacity(
                                    opacity: item.isBlocked.checkNull() ? 0.3 : 1.0,
                                    child: memberItem(
                                        name: item.name.checkNull(),
                                        image: item.image.checkNull(),
                                        status: item.status.checkNull(),
                                        spantext: controller.searchQuery.text.toString(),
                                        onTap: () {
                                          controller.onItemSelect(item.jid.checkNull(),
                                              item.name.checkNull(),item.isBlocked.checkNull());
                                        },
                                        isCheckBoxVisible: true,
                                        isChecked: controller.isChecked(item.jid.checkNull()),
                                        onchange: (value) {
                                          controller.onItemSelect(item.jid.checkNull(),
                                              item.name.checkNull(),item.isBlocked.checkNull());
                                        }),
                                  );
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
        ),
      );
    });
  }
}
