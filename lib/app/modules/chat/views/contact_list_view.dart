import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/contact_controller.dart';

import '../../../common/de_bouncer.dart';
import '../../../common/widgets.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/custom_action_bar_icons.dart';

class ContactListView extends GetView<ContactController> {
  const ContactListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deBouncer = DeBouncer(milliseconds: 700);
    return Obx(
      () => Scaffold(
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
              deBouncer.run(() {
                controller.searchListener(text);
              });
            },
            style: const TextStyle(fontSize: 16),
            controller: controller.searchQuery,
            autofocus: true,
            decoration: const InputDecoration(
                hintText: "Search...", border: InputBorder.none),
          ): controller.isForward.value
              ? const Text("Forward to...") : controller.isCreateGroup.value
              ? const Text("Add Participants",overflow: TextOverflow.fade,)
              : const Text('Contacts'),
          actions: [
            Visibility(
              visible: controller.isSearchVisible,
              child: IconButton(
                  onPressed: ()=> controller.onSearchPressed(),
                  icon: SvgPicture.asset(searchIcon)),
            ),
            Visibility(
              visible: controller.isClearVisible,
              child: IconButton(
                  onPressed: () => controller.backFromSearch(),
                  icon: const Icon(Icons.clear)),
            ),
            Visibility(
              visible: controller.isCreateVisible,
              child: TextButton(
                  onPressed: () =>controller.backToCreateGroup(),
                  child: Text(
                    controller.groupJid.value.isNotEmpty ? "NEXT" : "CREATE", style: const TextStyle(color: Colors.black),)),
            ),
            Visibility(
              visible: controller.isSearchVisible,
              child: CustomActionBarIcons(
                availableWidth: MediaQuery
                    .of(context)
                    .size
                    .width / 2, // half the screen width
                actionWidth: 48,
                actions: [
                  CustomAction(
                    visibleWidget: IconButton(
                        onPressed: () {

                        },
                        icon: const Icon(Icons.settings)),
                    overflowWidget: InkWell(child: const Text("Settings"),
                      onTap: () => Get.toNamed(Routes.settings),),
                    showAsAction: ShowAsAction.never,
                    keyValue: 'Settings',
                    onItemClick: () {
                      Get.toNamed(Routes.settings);
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: controller.isForward.value && controller.selectedUsersList.isNotEmpty ? FloatingActionButton(
          tooltip: "Forward",
          onPressed: () {
            FocusManager.instance.primaryFocus!.unfocus();
            controller.forwardMessages();
          },
          backgroundColor: buttonBgColor,
          child: const Icon(Icons.check)
        ) : const SizedBox.shrink(),
        body: Obx(() {
          return controller.isPageLoading.value
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: controller.scrollable.value
                      ? controller.usersList.length + 1
                      : controller.usersList.length,
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= controller.usersList.length) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      var item = controller.usersList[index];
                      return InkWell(
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 19.0, top: 10, bottom: 10, right: 10),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: item.image.checkNull().isEmpty
                                    ? iconBgColor
                                    : buttonBgColor,
                                shape: BoxShape.circle,
                              ),
                              child:ImageNetwork(
                                      url: item.image.toString(),
                                      width: 48,
                                      height: 48,
                                      clipOval: true,
                                      errorWidget: item.name.checkNull().isNotEmpty ? ProfileTextImage(
                                        text: item.name.checkNull().isEmpty
                                            ? item.mobileNumber.checkNull()
                                            : item.name.checkNull(),
                                      ) : const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    )
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name.toString().checkNull() == "" ? item.nickName.toString() : item.name.toString(),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    item.mobileNumber.toString(),
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  )
                                ],
                              ),
                            ),
                            const Spacer(),
                            Visibility(
                              visible: controller.isCheckBoxVisible,
                                  child: Checkbox(
                                      value: controller.selectedUsersJIDList.contains(item.jid),
                                      onChanged: (value){
                                        controller.onListItemPressed(item);
                                      },
                                    ),
                                ),
                          ],
                        ),
                        onTap: () {
                          controller.onListItemPressed(item);
                        },
                      );
                    }
                  });
        }),
      ),
    );
  }
}
