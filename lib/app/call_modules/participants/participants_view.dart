import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/call_modules/participants/add_participants_controller.dart';

import '../../common/app_theme.dart';
import '../../common/constants.dart';
import '../../common/widgets.dart';
import '../../data/helper.dart';
import '../../modules/dashboard/widgets.dart';
import '../call_utils.dart';
import '../call_widgets.dart';

class ParticipantsView extends GetView<AddParticipantsController> {
  const ParticipantsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
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
                            icon: const Icon(Icons.arrow_back, color: iconColor),
                            onPressed: () {
                              if(controller.isSearching.value) {
                                controller.getBackFromSearch();
                              }else{
                                Get.back();
                              }
                            },
                          ),
                          title: controller.isSearching.value
                              ? TextField(
                            focusNode: controller.searchFocusNode,
                            onChanged: (text) => controller.searchListener(text),
                            controller: controller.searchQuery,
                            autofocus: true,
                            decoration: const InputDecoration(hintText: "Search...", border: InputBorder.none),
                          )
                              : null,
                          bottom: TabBar(
                              controller: controller.tabController,
                              indicatorColor: buttonBgColor,
                              labelColor: buttonBgColor,
                              unselectedLabelColor: appbarTextColor,
                              tabs: [
                                tabItem(title: "PARTICIPANTS", count: "0"),
                                tabItem(title: "ADD PARTICIPANTS", count: "0")
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
                                icon: !controller.isSearching.value ?SvgPicture.asset(
                                  searchIcon,
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.contain,
                                ) : const Icon(Icons.clear),
                                tooltip: 'Search',
                              ),
                            ),
                          ],
                        );
                      }),
                    ];
                  },
                  body: TabBarView(controller: controller.tabController,
                      children: [callParticipantsView(context), addParticipants(context)])));
        }),
      ),
    );
  }

  Widget tabItem({required String title, required String count}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          count != "0"
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CircleAvatar(
                    radius: 9,
                    child: Text(
                      count.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontFamily: 'sf_ui'),
                    ),
                  ),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget callParticipantsView(BuildContext context) {
    return Obx(() {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: controller.callList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            debugPrint("call list length ${controller.callList.length}");
            return SessionManagement.getUserJID() == controller.callList[index].userJid!.value.checkNull()
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        FutureBuilder(
                            future: getProfileDetails(controller.callList[index].userJid!.value.checkNull()),
                            builder: (ctx, snap) {
                        return snap.hasData && snap.data != null
                            ? buildProfileImage(snap.data!, size: 48)
                            : const SizedBox.shrink();
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
                                            style: Theme.of(context).textTheme.titleMedium,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : const SizedBox.shrink();
                                  }),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Obx(() {
                            return controller.callList[index].isAudioMuted.value
                                ? CircleAvatar(backgroundColor: AppColors.participantUnMuteColor, child: SvgPicture.asset(participantMute))
                                : CircleAvatar(backgroundColor: Colors.transparent, child: SvgPicture.asset(participantUnMute));
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Obx(() {
                            return CircleAvatar(
                          backgroundColor: controller.callList[index].isVideoMuted.value ? AppColors
                              .participantUnMuteColor : Colors.transparent,
                                child: SvgPicture.asset(
                              controller.callList[index].isVideoMuted.value
                                  ? participantVideoDisabled
                                  : participantVideoEnabled));
                          }),
                        ),
                      ],
                    ),
                  );
          });
    });
  }

  Widget addParticipants(BuildContext context) {
    return Obx(() {
      return Stack(
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
                        return Opacity(
                          opacity: item.isBlocked.checkNull() ? 0.3 : 1.0,
                          child: InkWell(
                            child: Row(
                              children: [
                                InkWell(
                                  child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 19.0,
                                          top: 10,
                                          bottom: 10,
                                          right: 10),
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: item.image
                                            .checkNull()
                                            .isEmpty
                                            ? iconBgColor
                                            : buttonBgColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: ImageNetwork(
                                        url: item.image.toString(),
                                        width: 48,
                                        height: 48,
                                        clipOval: true,
                                        errorWidget: getName(item) //item.nickName
                                            .checkNull()
                                            .isNotEmpty
                                            ? ProfileTextImage(
                                          text:
                                          getName(item) /*item.nickName.checkNull().isEmpty
                                                                      ? item.mobileNumber
                                                                          .checkNull()
                                                                      : item.nickName.checkNull()*/,
                                        )
                                            : const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                        blocked: item.isBlockedMe.checkNull() ||
                                            item.isAdminBlocked.checkNull(),
                                        unknown: (!item.isItSavedContact.checkNull() ||
                                            item.isDeletedContact()),
                                        isGroup: item.isGroupProfile.checkNull(),
                                      )),
                                  onTap: () {
                                    // controller.showProfilePopup(item.obs);
                                  },
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      controller.searchQuery.text.isEmpty ?
                                      Text(
                                        getName(item),
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ) :
                                      spannableText(
                                          getName(item),
                                          //item.profileName.checkNull(),
                                          controller.searchQuery.text,
                                          const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, fontFamily: 'sf_ui', color: textHintColor)),
                                      // Text(
                                      //   item.mobileNumber.toString(),
                                      //   style: Theme.of(context)
                                      //       .textTheme
                                      //       .titleSmall,
                                      // )
                                      Text(
                                        item.status.toString(),
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .titleSmall,
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.isCheckBoxVisible,
                                  child: Checkbox(
                                    value: controller.selectedUsersJIDList
                                        .contains(item.jid),
                                    onChanged: (value) {
                                      controller.onListItemPressed(item);
                                    },
                                    activeColor: AppColors.checkBoxChecked,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2),
                                        side: const BorderSide(color: AppColors.checkBoxBorder)),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              controller.onListItemPressed(item);
                            },
                          ),
                        );
                      } else {
                        return const SizedBox();
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
                      decoration: const BoxDecoration(
                          color: buttonBgColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(2), topRight: Radius.circular(2))
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              addParticipantsInCall,
                            ),
                            const SizedBox(width: 8,),
                            Text("${Constants.addParticipantsToCall} ( ${(controller.groupCallMembersCount.value)} )",
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
      );
    });
  }
}
