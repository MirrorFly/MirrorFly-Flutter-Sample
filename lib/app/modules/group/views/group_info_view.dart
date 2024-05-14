import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/group/controllers/group_info_controller.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

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
                centerTitle: false,
                snap: false,
                pinned: true,
                floating: false,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: controller.isSliverAppBarExpanded ? Colors.white : Colors.black),
                  onPressed: () {
                    NavUtils.back();
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
                                  Text(getTranslated("membersCount").replaceAll("%d", "${controller.groupMembers.length}"),
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
                            visible: controller.availableFeatures.value.isGroupChatAvailable.checkNull() && controller.isMemberOfGroup,
                            child: IconButton(
                              icon: SvgPicture.asset(
                                edit,
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: Image.file(
                              File(controller.imagePath.value),
                              fit: BoxFit.fill,
                            ))
                        : ImageNetwork(
                            url: controller.profile.image.checkNull(),
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            clipOval: false,
                            errorWidget: Image.asset(
                              groupImg,
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fill,
                            ),
                            onTap: () {
                              if (controller.imagePath.value.isNotEmpty) {
                                NavUtils.toNamed(Routes.imageView,
                                    arguments: {'imageName': controller.profile.nickName, 'imagePath': controller.profile.image.checkNull()});
                              } else if (controller.profile.image.checkNull().isNotEmpty) {
                                NavUtils.toNamed(Routes.imageView,
                                    arguments: {'imageName': controller.profile.nickName, 'imageUrl': controller.profile.image.checkNull()});
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
                    visible: controller.availableFeatures.value.isGroupChatAvailable.checkNull() && controller.isMemberOfGroup,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        imageEdit,
                        colorFilter: ColorFilter.mode(controller.isSliverAppBarExpanded ? Colors.white : Colors.black, BlendMode.srcIn),
                      ),
                      tooltip: 'Image edit',
                      onPressed: () {
                        if (controller.isMemberOfGroup) {
                          bottomSheetView(context);
                        } else {
                          toToast(getTranslated("youAreNoLonger"));
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
                return ListItem(
                    title: Text(getTranslated("muteNotification"), style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: FlutterSwitch(
                      width: 40.0,
                      height: 20.0,
                      valueFontSize: 12.0,
                      toggleSize: 12.0,
                      activeColor: Colors.white,
                      activeToggleColor: Colors.blue,
                      inactiveToggleColor: Colors.grey,
                      inactiveColor: Colors.white,
                      switchBorder: Border.all(color: controller.mute ? Colors.blue : Colors.grey, width: 1),
                      value: controller.mute,
                      onToggle: (value) {
                        controller.onToggleChange(value);
                      },
                    ),
                    onTap: () {
                      controller.onToggleChange(!controller.mute);
                    });
              }),
              Obx(() => Visibility(
                    visible: controller.isAdmin,
                    child: ListItem(
                        leading: SvgPicture.asset(addUser),
                        title: Text(getTranslated("addParticipants"), style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                        onTap: () => controller.gotoAddParticipants()),
                  )),
              Obx(() {
                return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.groupMembers.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var item = controller.groupMembers[index];
                      return memberItem(
                        name: item.getName().checkNull(),
                        image: item.image.checkNull(),
                        isAdmin: item.isGroupAdmin,
                        status: item.status.checkNull(),
                        onTap: () {
                          if (item.jid.checkNull() != SessionManagement.getUserJID().checkNull()) {
                            showOptions(item,context);
                          }
                        },
                        isGroup: item.isGroupProfile.checkNull(),
                        blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
                        unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),
                      );
                    });
              }),
              ListItem(
                leading: SvgPicture.asset(imageOutline),
                title: Text(getTranslated("viewAllMedia"), style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => controller.gotoViewAllMedia(),
              ),
              ListItem(
                leading: SvgPicture.asset(reportGroup),
                title: Text(getTranslated("reportGroup"), style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500)),
                onTap: () => controller.reportGroup(),
              ),
              Obx(() {
                LogMessage.d("Delete or Leave",
                    "${controller.isMemberOfGroup} ${controller.availableFeatures.value.isDeleteChatAvailable.checkNull()} ${controller.isMemberOfGroup} ${controller.leavedGroup.value}");
                return Visibility(
                  visible: !controller.isMemberOfGroup
                      ? controller.availableFeatures.value.isDeleteChatAvailable.checkNull()
                      : (controller.isMemberOfGroup && !controller.leavedGroup.value),
                  child: ListItem(
                    leading: SvgPicture.asset(
                      leaveGroup,
                      width: 18,
                    ),
                    title: Text(!controller.isMemberOfGroup ? getTranslated("deleteGroup") : getTranslated("leaveGroup"),
                        style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500)),
                    onTap: () => controller.exitOrDeleteGroup(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  showOptions(ProfileDetails item,BuildContext context) {
    DialogUtils.showButtonAlert(
      actions: [
        ListTile(
            title: Text(
              getTranslated("startChat"),
              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            ),
            onTap: () {
              // NavUtils.toNamed(Routes.CHAT, arguments: item);
              NavUtils.back();
              Future.delayed(const Duration(milliseconds: 300), () {
                Get.back(result: item);
              });
            },
            visualDensity: const VisualDensity(horizontal: 0, vertical: -3)),
        ListTile(
            title: Text(
              getTranslated("viewInfo"),
              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            ),
            onTap: () {
              NavUtils.back();
              NavUtils.toNamed(Routes.chatInfo, arguments: item);
            },
            visualDensity: const VisualDensity(horizontal: 0, vertical: -3)),
        Obx(() {
          return Visibility(
              visible: controller.isAdmin && controller.availableFeatures.value.isGroupChatAvailable.checkNull(),
              child: ListTile(
                  title: Text(
                    getTranslated("removeFromGroup"),
                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  ),
                  onTap: () {
                    NavUtils.back();
                    if (!controller.availableFeatures.value.isGroupChatAvailable.checkNull()) {
                      DialogUtils.showFeatureUnavailable();
                      return;
                    }
                    DialogUtils.showAlert(message: getTranslated("areYouSureToRemove").replaceAll("%d", getName(item)), actions: [
                      TextButton(
                          onPressed: () {
                            NavUtils.back();
                          },
                          child: Text(getTranslated("no").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
                      TextButton(
                          onPressed: () {
                            NavUtils.back();
                            controller.removeUser(item.jid.checkNull());
                          },
                          child: Text(getTranslated("yes").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
                    ]);
                  },
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -3)));
        }),
        Obx(() {
          return Visibility(
              visible: (controller.isAdmin && controller.availableFeatures.value.isGroupChatAvailable.checkNull() && !item.isGroupAdmin!),
              child: ListTile(
                  title: Text(
                   getTranslated("makeAdmin"),
                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  ),
                  onTap: () {
                    NavUtils.back();
                    if (!controller.availableFeatures.value.isGroupChatAvailable.checkNull()) {
                      DialogUtils.showFeatureUnavailable();
                      return;
                    }
                    DialogUtils.showAlert(message:getTranslated("areYouSureMakeAdmin").replaceAll("%d", getName(item)), actions: [
                      TextButton(
                          onPressed: () {
                            NavUtils.back();
                          },
                          child: Text(getTranslated("no").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
                      TextButton(
                          onPressed: () {
                            NavUtils.back();
                            controller.makeAdmin(item.jid.checkNull());
                          },
                          child: Text(getTranslated("yes").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
                    ]);
                  },
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -3)));
        }),
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
              width: MediaQuery.of(context).size.width,
              child: Card(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(getTranslated("options")),
                      const SizedBox(
                        height: 10,
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          NavUtils.back();
                          controller.camera();
                        },
                        title: Text(
                          getTranslated("takePhoto"),
                          style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          NavUtils.back();
                          controller.imagePicker(context);
                        },
                        title: Text(
                          getTranslated("chooseFromGallery"),
                          style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      controller.profile.image.checkNull().isNotEmpty
                          ? ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              onTap: () {
                                NavUtils.back();
                                controller.removeProfileImage();
                              },
                              title: Text(
                                getTranslated("removePhoto"),
                                style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            )
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
