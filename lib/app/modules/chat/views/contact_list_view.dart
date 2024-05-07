import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/contact_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../widgets/custom_action_bar_icons.dart';
import '../../dashboard/widgets.dart';

class ContactListView extends StatefulWidget {
  const ContactListView(
      {super.key,
        this.messageIds,
        this.group = false,
        this.groupJid = '',
        this.enableAppBar = true,
        this.showSettings = false});
  final List<String>? messageIds;
  final bool group;
  final String groupJid;
  final bool enableAppBar;
  final bool showSettings;

  @override
  State<ContactListView> createState() => _ContactListViewState();
}

class _ContactListViewState extends State<ContactListView> {
  final ContactController controller = ContactController().get();

  @override
  void initState() {
    controller.init(context,
        messageIds: widget.messageIds,
        group: widget.group,
        groupjid: widget.groupJid);
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<ContactController>();
    super.dispose();
  }


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
        Navigator.pop(context);
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
                        ? Navigator.pop(context)
                        : controller.search
                        ? controller.backFromSearch()
                        : Navigator.pop(context);
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
                    : controller.isForward.value
                    ? Text(getTranslated("forwardTo"))
                    : controller.isCreateGroup.value
                    ? Text(
                  getTranslated("addParticipants"),
                  overflow: TextOverflow.fade,
                )
                    : Text(getTranslated("contacts")),
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
                          (controller.groupJid.value.isNotEmpty ? getTranslated("next") : getTranslated("create")).toUpperCase(),
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
                        CustomAction(
                          visibleWidget: IconButton(
                              onPressed: () {}, icon: const Icon(Icons.refresh)),
                          overflowWidget: InkWell(
                            child: Text(getTranslated("refresh")),
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
                            child: Center(child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(getTranslated("noContactsFound")),
                            ),)),
                        controller.isPageLoading.value
                            ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            )) : const Offstage(),
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
                                      return const Offstage();
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
                                          Text(getTranslated("callNowWithCount").replaceAll("%d", (controller.groupCallMembersCount.value -1).toString()),
                                            style: const TextStyle(
                                                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500,
                                                fontFamily: 'sf_ui'),)
                                        ],
                                      ),
                                    )),
                              ) : const Offstage();
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
