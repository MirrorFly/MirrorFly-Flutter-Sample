import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../call_modules/participants/add_participants_controller.dart';
import '../../common/app_localizations.dart';
import '../../common/widgets.dart';
import '../../data/session_management.dart';
import '../../extensions/extensions.dart';

import '../../app_style_config.dart';
import '../../common/app_theme.dart';
import '../../common/constants.dart';
import '../../data/helper.dart';
import '../../data/utils.dart';
import '../../modules/dashboard/dashboard_widgets/contact_item.dart';
import '../../stylesheet/stylesheet.dart';
import '../call_utils.dart';
import '../call_widgets.dart';

class ParticipantsView extends NavViewStateful<AddParticipantsController> {
  const ParticipantsView({Key? key}) : super(key: key);

  @override
AddParticipantsController createController({String? tag}) => Get.put(AddParticipantsController());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(tabBarTheme: AppStyleConfig.addParticipantsPageStyle.tabBarTheme,
          appBarTheme: AppStyleConfig.addParticipantsPageStyle.appBarTheme,),
      child: CustomSafeArea(
        child: DefaultTabController(
          length: 2,
          child: Builder(builder: (ctx) {
            return Scaffold(
                body: NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      return [
                        Obx(() {
                          return SliverAppBar(
                            snap: false,
                            pinned: true,
                            leading:IconButton(
                              icon:  Icon(Icons.arrow_back, color: AppStyleConfig.addParticipantsPageStyle.appBarTheme.iconTheme?.color),
                              onPressed: () {
                                if(controller.isSearching.value) {
                                  controller.getBackFromSearch();
                                }else{
                                  NavUtils.back();
                                }
                              },
                            ),
                            title: controller.isSearching.value
                                ? TextField(
                              focusNode: controller.searchFocusNode,
                              onChanged: (text) => controller.searchListener(text),
                              controller: controller.searchQuery,
                              autofocus: true,
                              style: AppStyleConfig.addParticipantsPageStyle.searchTextFieldStyle.editTextStyle,
                              decoration: InputDecoration(hintText: getTranslated("searchPlaceholder"), border: InputBorder.none,
                              hintStyle: AppStyleConfig.addParticipantsPageStyle.searchTextFieldStyle.editTextHintStyle),
                            )
                                : null,
                            bottom: TabBar(
                                controller: controller.tabController,
                                tabs: [
                                  tabItem(title: getTranslated("participants").toUpperCase(), count: "0",style: AppStyleConfig.addParticipantsPageStyle.tabItemStyle),
                                  tabItem(title: getTranslated("addParticipants").toUpperCase(), count: "0",style: AppStyleConfig.addParticipantsPageStyle.tabItemStyle)
                                ]),
                            actions: [
                              Visibility(
                                visible:controller.currentTab.value==1,
                                child: IconButton(
                                  onPressed: () {
                                    if(controller.isSearching.value){
                                      controller.clearSearch();
                                    }else {
                                      controller.onSearchPressed();
                                    }
                                  },
                                  icon: !controller.isSearching.value ?AppUtils.svgIcon(icon:
                                    searchIcon,
                                    width: 18,
                                    height: 18,
                                    fit: BoxFit.contain,
                                    colorFilter: ColorFilter.mode(Theme.of(context).appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn),
                                  ) : Icon(Icons.clear,color: Theme.of(context).appBarTheme.actionsIconTheme?.color ?? Colors.black,),
                                  tooltip: 'Search',
                                ),
                              ),
                            ],
                          );
                        }),
                      ];
                    },
                    body: TabBarView(controller: controller.tabController,
                        children: [callParticipantsView(context,AppStyleConfig.addParticipantsPageStyle.participantItemStyle), addParticipants(context,AppStyleConfig.addParticipantsPageStyle.contactItemStyle,AppStyleConfig.addParticipantsPageStyle.noDataTextStyle,AppStyleConfig.addParticipantsPageStyle.copyMeetLinkStyle)])));
          }),
        ),
      ),
    );
  }

  Widget tabItem({required String title, required String count,TabItemStyle style = const TabItemStyle()}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: style.textStyle,
            // style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          count != "0"
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: style.countIndicatorStyle.bgColor,
                    child: Text(
                      count.toString(),
                      style: style.countIndicatorStyle.textStyle,
                      // style: const TextStyle(fontSize: 12, color: Colors.white, fontFamily: 'sf_ui'),
                    ),
                  ),
                )
              : const Offstage()
        ],
      ),
    );
  }

  Widget callParticipantsView(BuildContext context,ParticipantItemStyle style) {
    return Obx(() {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: controller.callList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            debugPrint("call list length ${controller.callList.length}");
            return SessionManagement.getUserJID() == controller.callList[index].userJid!.value.checkNull()
                ? const Offstage()
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        FutureBuilder(
                            future: getProfileDetails(controller.callList[index].userJid!.value.checkNull()),
                            builder: (ctx, snap) {
                        return snap.hasData && snap.data != null
                            ? buildProfileImage(snap.data!, size: style.profileImageSize.width)
                            : const Offstage();
                            }),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder(
                                  future: CallUtils.getNameOfJid(controller.callList[index].userJid!.value.checkNull()),
                                  builder: (ctx, snap) {
                                    return snap.hasData && snap.data != null
                                        ? Text(
                                            snap.data!,
                                            maxLines: 1,
                                            style: style.textStyle,
                                            // style: Theme.of(context).textTheme.titleMedium,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : const Offstage();
                                  }),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Obx(() {
                            return controller.callList[index].isAudioMuted.value
                                ? CircleAvatar(backgroundColor: style.actionStyle.inactiveBgColor,//AppColors.participantUnMuteColor,
                                child: AppUtils.svgIcon(icon:participantMute,colorFilter: ColorFilter.mode(style.actionStyle.inactiveIconColor, BlendMode.srcIn),))
                                : CircleAvatar(backgroundColor: style.actionStyle.activeBgColor,//Colors.transparent,
                                child: AppUtils.svgIcon(icon:participantUnMute,colorFilter: ColorFilter.mode(style.actionStyle.activeIconColor, BlendMode.srcIn),));
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Obx(() {
                            return CircleAvatar(
                          backgroundColor: controller.callList[index].isVideoMuted.value
                              ? style.actionStyle.inactiveBgColor//AppColors.participantUnMuteColor
                              : style.actionStyle.activeBgColor,//Colors.transparent,
                                child: controller.callList[index].isVideoMuted.value
                                    ? AppUtils.svgIcon(icon:participantVideoDisabled,colorFilter: ColorFilter.mode(style.actionStyle.inactiveIconColor, BlendMode.srcIn),)
                                : AppUtils.svgIcon(icon:participantVideoEnabled,colorFilter: ColorFilter.mode(style.actionStyle.activeIconColor, BlendMode.srcIn),)
                            );
                          }),
                        ),
                      ],
                    ),
                  );
          });
    });
  }

  Widget addParticipants(BuildContext context,ContactItemStyle style,TextStyle noData,CopyMeetLinkStyle copyMeetLinkStyle) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0,left: 10.0,bottom: 5.0),
            child: Text(getTranslated("meetLink"),style: copyMeetLinkStyle.titleTextStyle,),
          ),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.all(10.0),
                decoration: copyMeetLinkStyle.leadingStyle.iconDecoration,
                child: Center(child: Icon(Icons.link,color: copyMeetLinkStyle.leadingStyle.iconColor,size: 18,),),
              ),
              Expanded(child: Text(controller.meetLink.value,style: copyMeetLinkStyle.linkTextStyle,)),
              IconButton(
                onPressed: () {
                  if (controller.meetLink.value.isEmpty) return;
                  Clipboard.setData(
                      ClipboardData(text: Constants.webChatLogin + controller.meetLink.value));
                  toToast(getTranslated("linkCopied"));
                },
                icon: AppUtils.svgIcon(icon:
                    copyIcon,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                        copyMeetLinkStyle.copyIconColor, BlendMode.srcIn)
                ),
              ),
            ],
          ),
          const AppDivider(),
          Expanded(
            child: Stack(
              children: [
                Visibility(
                    visible: !controller.isPageLoading.value && controller.usersList.isEmpty,
                    child: Center(child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(getTranslated("noContactsFound"),style: noData,),
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
                              ? controller.usersList.length + (controller.groupId.isEmpty ?  1 : 0)
                              : controller.usersList.length,
                          controller: controller.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            if (index >= controller.usersList.length &&
                                controller.usersList.isNotEmpty && controller.groupId.isEmpty) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (controller.usersList.isNotEmpty) {
                              var item = controller.usersList[index];
                              return ContactItem(item: item,onAvatarClick: (){
                                // controller.showProfilePopup(item.obs);
                              },
                                spanTxt: controller.searchQuery.text,
                                isCheckBoxVisible: controller.isCheckBoxVisible,
                                checkValue: controller.selectedUsersJIDList.contains(item.jid),
                                onCheckBoxChange: (value){
                                  controller.onListItemPressed(item);
                                },onListItemPressed: (){
                                  controller.onListItemPressed(item);
                                },contactItemStyle: style,);
                            } else {
                              return const Offstage();
                            }
                          }),
                    ),
                    Obx(() {
                      return controller.groupCallMembersCount.value > 0 ? InkWell(
                        onTap: () {
                          controller.makeCall();
                        },
                        child: Container(
                            height: 50,
                            decoration: AppStyleConfig.addParticipantsPageStyle.buttonDecoration,
                            /*decoration: const BoxDecoration(
                                color: buttonBgColor,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(2), topRight: Radius.circular(2))
                            ),*/
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AppUtils.svgIcon(icon:
                                    addParticipantsInCall,
                                    colorFilter: ColorFilter.mode(AppStyleConfig.addParticipantsPageStyle.buttonIconColor, BlendMode.srcIn),
                                  ),
                                  const SizedBox(width: 8,),
                                  Text(getTranslated("selectedParticipantsToCall").replaceFirst("%d", "${(controller.groupCallMembersCount.value)}"),
                                    style: AppStyleConfig.addParticipantsPageStyle.buttonTextStyle,
                                    // style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'sf_ui'),
                                  )
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
        ],
      );
    });
  }
}
