import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/app_style_config.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/model/arguments.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/contact_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../data/utils.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../dashboard/dashboard_widgets/contact_item.dart';

class ContactListView extends NavView<ContactController> {
  const ContactListView({super.key});


  @override
  ContactController createController() {
    return ContactController();
  }

  @override
  Widget build(BuildContext context) {
    var arg = arguments as ContactListArguments;
    return Theme(
      data: ThemeData(appBarTheme: AppStyleConfig.contactListPageStyle.appBarTheme),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          if(controller.search) {
            controller.backFromSearch();
            return;
          }
          NavUtils.back();
        },
        child: Obx(
              () =>
              Scaffold(
                appBar: AppBar(
                  leading: IconButton(
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
                    style: AppStyleConfig.contactListPageStyle.searchTextFieldStyle.editTextStyle,
                    // style: const TextStyle(fontSize: 16),
                    controller: controller.searchQuery,
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText: getTranslated("searchPlaceholder"), border: InputBorder.none,
                    hintStyle: AppStyleConfig.contactListPageStyle.searchTextFieldStyle.editTextHintStyle),
                  )
                      :  arg.forGroup
                      ? Text(
                    getTranslated("addParticipants"),
                    overflow: TextOverflow.fade,
                    style: AppStyleConfig.contactListPageStyle.appBarTheme.titleTextStyle,
                  )
                      : Text(getTranslated("contacts"),style: AppStyleConfig.contactListPageStyle.appBarTheme.titleTextStyle,),
                  actions: [
                    Visibility(
                      visible: controller.progressSpinner.value,
                      child: const Center(
                        child: SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: CircularProgressIndicator(strokeWidth: 2,),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: controller.isSearchVisible,
                      child: IconButton(
                          onPressed: () => controller.onSearchPressed(),
                          icon: SvgPicture.asset(searchIcon,colorFilter: ColorFilter.mode(AppStyleConfig.contactListPageStyle.appBarTheme.actionsIconTheme!.color!, BlendMode.srcIn),)),
                    ),
                    Visibility(
                      visible: controller.isClearVisible,
                      child: IconButton(
                          onPressed: () => controller.clearSearch(),
                          icon: const Icon(Icons.clear)),
                    ),
                    Visibility(
                      visible: arg.forGroup,
                      child: TextButton(
                          onPressed: () => controller.backToCreateGroup(),
                          child: Text(
                            (arg.groupJid.isNotEmpty ? getTranslated("next") : getTranslated("create")).toUpperCase(),
                            style: const TextStyle(color: Colors.black),
                          )),
                    ),
                    Visibility(
                      visible: controller.isSearchVisible,
                      child: CustomActionBarIcons(
                        availableWidth: NavUtils.width /
                            2, // half the screen width
                        actionWidth: 48,
                        actions: [
                          CustomAction(
                            visibleWidget: IconButton(
                                onPressed: () {}, icon: const Icon(Icons.refresh)),
                            overflowWidget: InkWell(
                              child: Text(getTranslated("refresh")),
                              onTap: () {
                                NavUtils.back();
                                controller.refreshContacts(true);
                              },
                            ),
                            showAsAction: (Constants.enableContactSync && !controller.progressSpinner.value) ? ShowAsAction
                                .never : ShowAsAction.gone,
                            keyValue: 'Refresh',
                            onItemClick: () {
                              // NavUtils.back();
                              controller.refreshContacts(true);
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
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
                                child: Text(getTranslated("noContactsFound"),style: AppStyleConfig.contactListPageStyle.noDataTextStyle,),
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
                                          isCheckBoxVisible: arg.forMakeCall || arg.forGroup,
                                          checkValue: controller.selectedUsersJIDList.contains(item.jid),
                                          onCheckBoxChange: (value){
                                            controller.onListItemPressed(item);
                                          },onListItemPressed: (){
                                            controller.onListItemPressed(item);
                                          },contactItemStyle: AppStyleConfig.contactListPageStyle.contactItemStyle,);
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
                                              arg.callType == CallType.audio
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
      ),
    );
  }
}
