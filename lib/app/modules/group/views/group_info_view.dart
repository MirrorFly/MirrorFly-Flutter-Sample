import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/group/controllers/group_info_controller.dart';

import '../../../common/constants.dart';
import '../../../routes/app_pages.dart';
import 'package:flysdk/flysdk.dart';


class GroupInfoView extends GetView<GroupInfoController> {
  const GroupInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
          controller: controller.scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              Obx(() {
                return SliverAppBar(
                  snap: false,
                  pinned: true,
                  floating: false,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: controller.isSliverAppBarExpanded
                            ? Colors.white
                            : Colors.black),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  title: Visibility(
                    visible: !controller.isSliverAppBarExpanded,
                    child: Text(controller.profile.nickName.checkNull(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        )),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 16),
                      title: Visibility(
                        visible: controller.isSliverAppBarExpanded,
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(controller.profile.nickName.checkNull(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                        ) //TextStyle
                                    ),
                                    Text("${controller.groupMembers.length} members",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8.0,
                                        ) //TextStyle
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: controller.isMemberOfGroup,
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  edit,
                                  color: Colors.white,
                                  width: 16.0,
                                  height: 16.0,
                                ),
                                tooltip: 'edit',
                                onPressed: () => controller.gotoNameEdit(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      background: controller.imagePath.value.isNotEmpty
                          ? SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 300,
                          child: Image.file(
                            File(controller.imagePath.value),
                            fit: BoxFit.fill,
                          ))
                          : ImageNetwork(
                        url: controller.profile.image.checkNull(),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: 300,
                        clipOval: false,
                        errorWidget: Image.asset(
                          groupImg,
                          height: 300,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          fit: BoxFit.fill,
                        ),
                        onTap: (){
                          if(controller.imagePath.value.isNotEmpty){
                            Get.toNamed(Routes.imageView, arguments: {
                              'imageName': controller.profile.nickName,
                              'imagePath': controller.profile.image.checkNull()
                            });
                          }else if(controller.profile.image.checkNull().isNotEmpty){
                            Get.toNamed(Routes.imageView, arguments: {
                              'imageName': controller.profile.nickName,
                              'imageUrl': controller.profile.image.checkNull()
                            });
                          }
                        },
                        isGroup: controller.profile.isGroupProfile.checkNull(),
                        blocked: controller.profile.isBlockedMe.checkNull() || controller.profile.isAdminBlocked.checkNull(),
                        unknown: (!controller.profile.isItSavedContact.checkNull() || controller.profile.isDeletedContact()),
                      ) //Images.network
                  ),
                  //FlexibleSpaceBar
                  expandedHeight: 300,
                  //IconButton
                  actions: <Widget>[
                    Visibility(
                      visible: controller.isMemberOfGroup,
                      child: IconButton(
                        icon: SvgPicture.asset(
                          imageEdit,
                          color: controller.isSliverAppBarExpanded
                              ? Colors.white
                              : Colors.black,
                        ),
                        tooltip: 'Image edit',
                        onPressed: () {
                          if (controller.isMemberOfGroup) {
                            bottomSheetView(context);
                          }else{
                            toToast("You're no longer a participant in this group");
                          }
                        },
                      ),
                    ),
                  ],
                );
              })
            ];
          },
          body: SafeArea(
            child: ListView(
              children: <Widget>[
                Obx(() {
                  return ListItem(title: const Text("Mute Notification",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)), trailing: FlutterSwitch(
                    width: 40.0,
                    height: 20.0,
                    valueFontSize: 12.0,
                    toggleSize: 12.0,
                    activeColor: Colors.white,
                    activeToggleColor: Colors.blue,
                    inactiveToggleColor: Colors.grey,
                    inactiveColor: Colors.white,
                    switchBorder: Border.all(
                        color: controller.mute ? Colors.blue : Colors.grey,
                        width: 1
                    ),
                    value: controller.mute,
                    onToggle:  (value){
                      if(controller.isMemberOfGroup) {
                        controller.onToggleChange(value);
                      }
                    },
                  ), onTap: (){
                    if(controller.isMemberOfGroup) {
                      controller.onToggleChange(!controller.mute);
                    }
                  });
                }),
                Obx(() =>
                    Visibility(
                      visible: controller.isAdmin,
                      child: ListItem(leading: SvgPicture.asset(addUser),
                          title: const Text("Add Participants",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          onTap: () => controller.gotoAddParticipants()),
                    )),
                Obx(() {
                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.groupMembers.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var item = controller.groupMembers[index];
                        return memberItem(name: item.name.checkNull(),image: item.image.checkNull(),isAdmin: item.isGroupAdmin,status: item.status.checkNull(),onTap: (){
                          if (item.jid.checkNull() !=
                              SessionManagement.getUserJID().checkNull()) {
                            showOptions(item);
                          }
                        },
                          isGroup: item.isGroupProfile.checkNull(),
                          blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
                          unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),);
                      });
                }),
                ListItem(
                  leading: SvgPicture.asset(imageOutline),
                  title: const Text("View All Media",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: ()=>controller.gotoViewAllMedia(),
                ),
                ListItem(
                  leading: SvgPicture.asset(reportGroup),
                  title: const Text("Report Group",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  onTap: () => controller.reportGroup(),
                ),
                Obx(() {
                  return ListItem(
                    leading: SvgPicture.asset(leaveGroup, width: 18,),
                    title: Text(!controller.isMemberOfGroup
                        ? "Delete Group"
                        : "Leave Group",
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    onTap: () => controller.exitOrDeleteGroup(),
                  );
                }),
              ],
            ),
          ),
        ),
    );
  }

  showOptions(Profile item) {
    Helper.showButtonAlert(actions: [
        ListTile(title: const Text("Start Chat", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),), onTap: () {
          // Get.toNamed(Routes.CHAT, arguments: item);
          Get.back();
          Future.delayed(const Duration(milliseconds: 300),(){
            Get.back(result: item);
          });
        },
        visualDensity: const VisualDensity(horizontal: 0, vertical: -3)),
        ListTile(title: const Text("View Info",style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),), onTap: () {
          Get.back();
          Get.toNamed(Routes.chatInfo, arguments: item);
        },
        visualDensity: const VisualDensity(horizontal: 0, vertical: -3)),
        Visibility(visible: controller.isAdmin,
            child: ListTile(title: const Text("Remove from Group",style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),), onTap: () {
              Get.back();
              Helper.showAlert(
                  message: "Are you sure you want to remove ${item.name}?",
                  actions: [
                    TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("NO")),
                    TextButton(
                        onPressed: () {
                          Get.back();
                          controller.removeUser(item.jid.checkNull());
                        },
                        child: const Text("YES")),
                  ]);
            },
            visualDensity: const VisualDensity(horizontal: 0, vertical: -3))),
        Visibility(
            visible: (!item.isGroupAdmin! && controller.isAdmin),
            child: ListTile(title: const Text("Make Admin", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),), onTap: () {
              Get.back();
              Helper.showAlert(message: "Are you sure you want to make ${item
                  .name} the admin?", actions: [
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text("NO")),
                TextButton(
                    onPressed: () {
                      Get.back();
                      controller.makeAdmin(item.jid.checkNull());
                    },
                    child: const Text("YES")),
              ]);
            },
            visualDensity: const VisualDensity(horizontal: 0, vertical: -3))),
      ],
    );
  }

  bottomSheetView(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return SafeArea(
            child: SizedBox(
              child: Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10,),
                      const Text("Options"),
                      const SizedBox(height: 10,),
                      TextButton(
                          onPressed: () async {
                            Get.back();
                            controller.camera();
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft),
                          child: const Text("Take Photo",
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                      TextButton(
                          onPressed: () {
                            Get.back();
                            controller.imagePicker(context);
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft),
                          child: const Text("Choose from Gallery",
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                      controller.profile.image
                          .checkNull()
                          .isNotEmpty
                          ? TextButton(
                          onPressed: () {
                            Get.back();
                            controller.removeProfileImage();
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft),
                          child: const Text(
                            "Remove Photo",
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                          ))
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
