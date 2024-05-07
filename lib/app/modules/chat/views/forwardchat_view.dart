import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/forwardchat_controller.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
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
                    LogMessage.d("text", text);
                    controller.onSearch(text);
                  },
                  style: const TextStyle(fontSize: 16),
                  controller: controller.searchQuery,
                  autofocus: true,
                  decoration: InputDecoration(
                      hintText: getTranslated("searchPlaceholder"), border: InputBorder.none),
                )
              : Text(getTranslated("forwardTo")),
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
                          child: Center(child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(getTranslated("noResultsFound")),
                          ),),
                        ),
                        Visibility(
                          visible: controller.recentChats.isNotEmpty,
                          child: searchHeader(getTranslated("recentChat"),
                              "", context),
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
                                          getRecentName(item)/*item.profileName.checkNull()*/,item.isBlocked.checkNull(),item.isGroup.checkNull());
                                    },
                                    spanTxt: controller.searchQuery.text.toString(),
                                    isCheckBoxVisible: true,
                                    isForwardMessage: true,
                                    isChecked: controller.isChecked(item.jid.checkNull()),
                                    onchange: (value) {
                                      controller.onItemSelect(item.jid.checkNull(),
                                          getRecentName(item)/*item.profileName.checkNull()*/,item.isBlocked.checkNull(),item.isGroup.checkNull());
                                    }),
                              );
                            }),
                        Visibility(
                          visible: controller.groupList.isNotEmpty,
                          child: searchHeader(getTranslated("groups"),"", context),
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
                                            name: getName(item),//item.name.checkNull(),
                                            image: item.image.checkNull(),
                                            status: data.data.checkNull(),
                                            spantext: controller.searchQuery.text.toString(),
                                            onTap: () {
                                              controller.onItemSelect(
                                                  item.jid.checkNull(),
                                                  getName(item)/*item.name.checkNull()*/,item.isBlocked.checkNull(),item.isGroupProfile.checkNull());
                                            },
                                            isCheckBoxVisible: true,
                                            isChecked: controller.isChecked(
                                                item.jid.checkNull()),
                                            onchange: (value) {
                                              controller.onItemSelect(
                                                  item.jid.checkNull(),
                                                  getName(item)/*item.name.checkNull()*/,item.isBlocked.checkNull(),item.isGroupProfile.checkNull());
                                            },
                                          blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
                                          unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),),
                                      );
                                    }else{
                                      return const SizedBox();
                                    }
                                  }
                              });
                            }),
                        Visibility(
                          visible: controller.userList.isNotEmpty,
                          child: searchHeader(getTranslated("contacts"), "", context),
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
                                        name: getName(item),
                                        image: item.image.checkNull(),
                                        status: item.status.checkNull(),
                                        spantext: controller.searchQuery.text.toString(),
                                        onTap: () {
                                          controller.onItemSelect(item.jid.checkNull(),
                                              getName(item)/*item.name.checkNull()*/,item.isBlocked.checkNull(),item.isGroupProfile.checkNull());
                                        },
                                        isCheckBoxVisible: true,
                                        isChecked: controller.isChecked(item.jid.checkNull()),
                                        onchange: (value) {
                                          controller.onItemSelect(item.jid.checkNull(),
                                              getName(item)/*item.name.checkNull()*/,item.isBlocked.checkNull(),item.isGroupProfile.checkNull());
                                        },
                                      blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
                                      unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),),
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
                    Expanded(child: controller.selectedNames.isEmpty ? Text(getTranslated("noUsersSelected"),style: const TextStyle(color: textColor)) : Text(controller.selectedNames.join(","),maxLines: 2,overflow: TextOverflow.ellipsis,style: const TextStyle(color: textColor),),),
                    Visibility(
                      visible: controller.selectedNames.isNotEmpty,
                      child: InkWell(
                        onTap: () {
                          controller.forwardMessages();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(getTranslated("next").toUpperCase(),style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
