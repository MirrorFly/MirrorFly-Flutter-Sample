import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/contact_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../widgets/custom_action_bar_icons.dart';
import '../../dashboard/widgets.dart';

class ContactListView extends GetView<ContactController> {
  const ContactListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if(controller.search) {
          controller.backFromSearch();
          return;
        }
        Get.back();
      },
      child: Obx(
            () =>
            Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: controller.isForward.value
                      ? const Icon(Icons.close)
                      : const Icon(Icons.arrow_back),
                  onPressed: () {
                    controller.isForward.value
                        ? Get.back()
                        : controller.search
                        ? controller.backFromSearch()
                        : Get.back();
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
                  decoration: const InputDecoration(
                      hintText: "Search...", border: InputBorder.none),
                )
                    : controller.isForward.value
                    ? const Text("Forward to...")
                    : controller.isCreateGroup.value
                    ? const Text(
                  "Add Participants",
                  overflow: TextOverflow.fade,
                )
                    : const Text('Contacts'),
                actions: [
                  Visibility(
                    visible: controller.progressSpinner.value,
                    child: const Center(
                      child: SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(color: iconColor, strokeWidth: 2,),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: controller.isSearchVisible,
                    child: IconButton(
                        onPressed: () => controller.onSearchPressed(),
                        icon: SvgPicture.asset(searchIcon)),
                  ),
                  Visibility(
                    visible: controller.isClearVisible,
                    child: IconButton(
                        onPressed: () => controller.clearSearch(),
                        icon: const Icon(Icons.clear)),
                  ),
                  Visibility(
                    visible: controller.isCreateVisible,
                    child: TextButton(
                        onPressed: () => controller.backToCreateGroup(),
                        child: Text(
                          controller.groupJid.value.isNotEmpty ? "NEXT" : "CREATE",
                          style: const TextStyle(color: Colors.black),
                        )),
                  ),
                  Visibility(
                    visible: controller.isSearchVisible,
                    child: CustomActionBarIcons(
                      availableWidth: Get.width /
                          2, // half the screen width
                      actionWidth: 48,
                      actions: [
                        //mani said to comment this bcz this option seems not necessary for this screen
                        // CustomAction(
                        //   visibleWidget: IconButton(
                        //       onPressed: () {}, icon: const Icon(Icons.settings)),
                        //   overflowWidget: InkWell(
                        //     child: const Text("Settings"),
                        //     onTap: () => Get.toNamed(Routes.settings),
                        //   ),
                        //   showAsAction: ShowAsAction.never,
                        //   keyValue: 'Settings',
                        //   onItemClick: () {
                        //     Get.toNamed(Routes.settings);
                        //   },
                        // ),
                        CustomAction(
                          visibleWidget: IconButton(
                              onPressed: () {}, icon: const Icon(Icons.refresh)),
                          overflowWidget: InkWell(
                            child: const Text("Refresh"),
                            onTap: () {
                              Get.back();
                              controller.refreshContacts(true);
                            },
                          ),
                          showAsAction: (Constants.enableContactSync && !controller.progressSpinner.value) ? ShowAsAction
                              .never : ShowAsAction.gone,
                          keyValue: 'Refresh',
                          onItemClick: () {
                            // Get.back();
                            controller.refreshContacts(true);
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton: controller.isForward.value &&
                  controller.selectedUsersList.isNotEmpty
                  ? FloatingActionButton(
                  tooltip: "Forward",
                  onPressed: () {
                    FocusManager.instance.primaryFocus!.unfocus();
                    controller.forwardMessages();
                  },
                  backgroundColor: buttonBgColor,
                  child: const Icon(Icons.check))
                  : const SizedBox.shrink(),
              body: Obx(() {
                return RefreshIndicator(
                  key: controller.refreshIndicatorKey,
                  onRefresh: () {
                    return Future(() => controller.refreshContacts(true));
                  },
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Visibility(
                            visible: !controller.isPageLoading.value && controller.usersList.isEmpty,
                            child: const Center(child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Text("No Contacts found"),
                            ),)),
                        controller.isPageLoading.value
                            ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            )) : const SizedBox.shrink(),
                            Column(
                          children: [
                            controller.isPageLoading.value ? Expanded(child: Container()) : Expanded(
                              child: ListView.builder(
                                  itemCount: controller.scrollable.value
                                      ? controller.usersList.length + 1
                                      : controller.usersList.length,
                                  controller: controller.scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (BuildContext context, int index) {
                                    if (index >= controller.usersList.length &&
                                        controller.usersList.isNotEmpty) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (controller.usersList.isNotEmpty) {
                                      var item = controller.usersList[index];
                                      return ContactItem(item: item,onAvatarClick: (){
                                        controller.showProfilePopup(item.obs);
                                      },
                                        spanTxt: controller.searchQuery.text,
                                        isCheckBoxVisible: controller.isCheckBoxVisible,
                                        checkValue: controller.selectedUsersJIDList.contains(item.jid),
                                        onCheckBoxChange: (value){
                                          controller.onListItemPressed(item);
                                        },onListItemPressed: (){
                                          controller.onListItemPressed(item);
                                        },);
                                    } else {
                                      return const SizedBox();
                                    }
                                  }),
                            ),
                            Obx(() {
                              return controller.groupCallMembersCount.value>1 ? InkWell(
                                onTap: (){
                                  controller.makeCall();
                                },
                                child: Container(
                                    height: 50,
                                    decoration: const BoxDecoration(
                                        color: buttonBgColor,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(2), topRight: Radius.circular(2))
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        // crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          SvgPicture.asset(
                                            controller.callType.value == CallType.audio
                                                ? audioCallSmallIcon
                                                : videoCallSmallIcon,
                                          ),
                                          const SizedBox(width: 8,),
                                          Text("CALL NOW ( ${(controller.groupCallMembersCount.value -1)} )",
                                            style: const TextStyle(
                                                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500,
                                                fontFamily: 'sf_ui'),)
                                        ],
                                      ),
                                    )),
                              ) : const SizedBox.shrink();
                            })
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }),
            ),
      ),
    );
  }
}
