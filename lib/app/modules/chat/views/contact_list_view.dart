import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../extensions/extensions.dart';
import '../../../model/arguments.dart';
import '../../../modules/chat/controllers/contact_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../data/utils.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../dashboard/dashboard_widgets/contact_item.dart';

class ContactListView extends NavViewStateful<ContactController> {
  const ContactListView({super.key});


  @override
ContactController createController({String? tag}) => Get.put(ContactController());

  @override
  Widget build(BuildContext context) {
    var arg = arguments as ContactListArguments;
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: AppStyleConfig.contactListPageStyle.appBarTheme),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
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
                          icon: AppUtils.svgIcon(icon:searchIcon,colorFilter: ColorFilter.mode(AppStyleConfig.contactListPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn),)),
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
                            style: AppStyleConfig.contactListPageStyle.actionTextStyle,
                            // style: const TextStyle(color: Colors.black),
                          )),
                    ),
                    Visibility(
                      visible: controller.isSearchVisible,
                      child: CustomActionBarIcons(
                        availableWidth: NavUtils.width /
                            2, // half the screen width
                        actionWidth: 48,
                        popupMenuThemeData: AppStyleConfig.contactListPageStyle.popupMenuThemeData,
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
                                      decoration: AppStyleConfig.contactListPageStyle.buttonDecoration,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          // crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            AppUtils.svgIcon(icon:
                                              arg.callType == CallType.audio
                                                  ? audioCallSmallIcon
                                                  : videoCallSmallIcon,
                                              colorFilter: ColorFilter.mode(AppStyleConfig.contactListPageStyle.buttonIconColor, BlendMode.srcIn),
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
