import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../call_modules/group_participants/group_participants_controller.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../data/utils.dart';
import '../../extensions/extensions.dart';
import '../../modules/dashboard/dashboard_widgets/contact_item.dart';

class GroupParticipantsView extends NavViewStateful<GroupParticipantsController> {
  const GroupParticipantsView({Key? key}) : super(key: key);

  @override
GroupParticipantsController createController({String? tag}) => Get.put(GroupParticipantsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.search
                ? controller.backFromSearch()
                : NavUtils.back();
          },
        ),
          title: controller.search
              ? TextField(
            onChanged: (text) {
              controller.searchListener(text);
            },
            focusNode: controller.searchFocus,
            style: const TextStyle(fontSize: 16),
            controller: controller.searchQuery,
            autofocus: true,
            decoration: InputDecoration(
                hintText: getTranslated("searchPlaceholder"), border: InputBorder.none),
          )
              : Text(getTranslated("addParticipants"),
            overflow: TextOverflow.fade,
          ), actions: [
            Visibility(
              visible: controller.isSearchVisible,
              child: IconButton(
                  onPressed: () => controller.onSearchPressed(),
                  icon: AppUtils.svgIcon(icon:searchIcon)),
            ),
            Visibility(
              visible: controller.isClearVisible,
              child: IconButton(
                  onPressed: () => controller.clearSearch(),
                  icon: const Icon(Icons.clear)),
            ),
          ],),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                      itemCount: controller.usersList.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        if (index >= controller.usersList.length &&
                            controller.usersList.isNotEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (controller.usersList.isNotEmpty) {
                          var item = controller.usersList[index];
                          return ContactItem(item: item,
                            onAvatarClick: () {
                              controller.showProfilePopup(item.obs);
                            },
                            spanTxt: controller.searchQuery.text,
                            isCheckBoxVisible: true,
                            checkValue: controller.selectedUsersJIDList.contains(item.jid),
                            onCheckBoxChange: (value) {
                              controller.onListItemPressed(item);
                            },
                            onListItemPressed: () {
                              controller.onListItemPressed(item);
                            },);
                        } else {
                          return const SizedBox();
                        }
                      });
                }),
              ),
              Obx(() {
                return InkWell(
                  onTap: () {
                    controller.makeCall();
                  },
                  child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: controller.selectedUsersJIDList.isNotEmpty ? buttonBgColor : chatTimeColor,
                          shape: BoxShape.rectangle,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(2), topRight: Radius.circular(2))
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppUtils.svgIcon(icon:
                              controller.callType.value == CallType.audio
                                  ? audioCallSmallIcon
                                  : videoCallSmallIcon,
                            ),
                            const SizedBox(width: 8,),
                            Text(getTranslated("callNowWithCount").replaceFirst("%d", "${(controller.groupCallMembersCount.value - 1)}"),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500,
                                  fontFamily: 'sf_ui'),)
                          ],
                        ),
                      )),
                );
              })
            ],
          ),
        ),
      );
    });
  }
}
