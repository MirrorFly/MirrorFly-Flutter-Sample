import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/widgets.dart';
import '../../../data/helper.dart';
import '../../../data/session_management.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/group/controllers/group_info_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../model/arguments.dart';
import '../../../routes/route_settings.dart';
import '../../settings/views/settings_widgets.dart';

class GroupInfoView extends NavViewStateful<GroupInfoController> {
  const GroupInfoView({Key? key}) : super(key: key);

  @override
GroupInfoController createController({String? tag}) => Get.put(GroupInfoController());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: AppStyleConfig.groupChatInfoPageStyle.appBarTheme),
      child: Scaffold(
        body: NestedScrollView(
          controller: controller.scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                  centerTitle: false,
                  snap: false,
                  pinned: true,
                  floating: false,
                  leading: Obx(()=>IconButton(
                    icon: Icon(Icons.arrow_back,color: controller.isSliverAppBarExpanded
                        ? AppStyleConfig.groupChatInfoPageStyle.silverAppBarIconColor
                        : AppBarTheme.of(context).actionsIconTheme?.color),
                    onPressed: () {
                      NavUtils.back();
                    },
                  )),
                  title: Obx(()=>Visibility(
                    visible: !controller.isSliverAppBarExpanded,
                    child: Text(controller.profile.nickName.checkNull(),
                      style: AppBarTheme.of(context).titleTextStyle,
                        /*style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        )*/),
                  )),
                  flexibleSpace: Obx(()=>FlexibleSpaceBar(
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
                                        style: controller.isSliverAppBarExpanded ? AppStyleConfig.groupChatInfoPageStyle.silverAppbarTitleStyle : AppBarTheme.of(context).titleTextStyle
                                      /*style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                        )*/ //TextStyle
                                        ),
                                    Text(getTranslated("membersCount").replaceAll("%d", "${controller.groupMembers.length}"),
                                      style: AppStyleConfig.groupChatInfoPageStyle.silverAppBarSubTitleStyle,
                                        /*style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8.0,
                                        ) *///TextStyle
                                        ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: controller.availableFeatures.value.isGroupChatAvailable.checkNull() && controller.isMemberOfGroup,
                              child: IconButton(
                                icon: AppUtils.svgIcon(icon:
                                  edit,
                                  colorFilter: ColorFilter.mode(AppStyleConfig.groupChatInfoPageStyle.silverAppBarIconColor, BlendMode.srcIn),
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
                              width: NavUtils.size.width,
                              height: 300,
                              child: Image.file(
                                File(controller.imagePath.value),
                                fit: BoxFit.fill,
                              ))
                          : ImageNetwork(
                              url: controller.profile.image.checkNull(),
                              width: NavUtils.size.width,
                              height: NavUtils.height * 0.45,
                              clipOval: false,
                              errorWidget: AppUtils.assetIcon(assetName:
                                groupImg,
                                height: NavUtils.height * 0.45,
                                width: NavUtils.size.width,
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
                      )),
                  //FlexibleSpaceBar
                  expandedHeight: NavUtils.height * 0.45,
                  //IconButton
                  actions: <Widget>[
                    Obx(()=>Visibility(
                      visible: controller.availableFeatures.value.isGroupChatAvailable.checkNull() && controller.isMemberOfGroup,
                      child: IconButton(
                        icon: AppUtils.svgIcon(icon:
                          imageEdit,
                          colorFilter: ColorFilter.mode(controller.isSliverAppBarExpanded ? AppStyleConfig.groupChatInfoPageStyle.silverAppBarIconColor : AppBarTheme.of(context).actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn),
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
                    )),
                  ],
                ),
            ];
          },
          body: SafeArea(
            child: ListView(
              children: <Widget>[
                Obx(() {
                  return ListItem(
                      title: Text(getTranslated("muteNotification"), style:  AppStyleConfig.groupChatInfoPageStyle.muteNotificationStyle.textStyle),
                      trailing: FlutterSwitch(
                        width: 40.0,
                        height: 20.0,
                        valueFontSize: 12.0,
                        toggleSize: 12.0,
                        activeColor: AppStyleConfig.groupChatInfoPageStyle.muteNotificationStyle.toggleStyle.activeColor,
                        activeToggleColor: AppStyleConfig.groupChatInfoPageStyle.muteNotificationStyle.toggleStyle.activeToggleColor,
                        inactiveToggleColor: AppStyleConfig.groupChatInfoPageStyle.muteNotificationStyle.toggleStyle.inactiveToggleColor,
                        inactiveColor: AppStyleConfig.groupChatInfoPageStyle.muteNotificationStyle.toggleStyle.inactiveColor,
                        switchBorder: Border.all(color: controller.mute ? AppStyleConfig.groupChatInfoPageStyle.muteNotificationStyle.toggleStyle.activeToggleColor : AppStyleConfig.groupChatInfoPageStyle.muteNotificationStyle.toggleStyle.inactiveToggleColor, width: 1),
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
                          leading: AppUtils.svgIcon(icon:addUser,colorFilter: ColorFilter.mode(AppStyleConfig.groupChatInfoPageStyle.addParticipantStyle.leadingIconColor, BlendMode.srcIn),),
                          title: Text(getTranslated("addParticipants"),
                              style: AppStyleConfig.groupChatInfoPageStyle.addParticipantStyle.titleTextStyle,
                              // style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)
                          ),
                          onTap: () => controller.gotoAddParticipants()),
                    )),
                Obx(() {
                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.groupMembers.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var item = controller.groupMembers[index];
                        return MemberItem(
                          itemStyle: AppStyleConfig.groupChatInfoPageStyle.groupMemberStyle,
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
                SettingListItem(leading: imageOutline,title: getTranslated("viewAllMedia"),trailing: rightArrowIcon,onTap: (){
                  controller.gotoViewAllMedia();
                }, listItemStyle: AppStyleConfig.groupChatInfoPageStyle.viewAllMediaStyle,),
                /*ListItem(
                  leading: AppUtils.svgIcon(icon:imageOutline,colorFilter: ColorFilter.mode(AppStyleConfig.groupChatInfoPageStyle.viewAllMediaStyle.leadingIconColor, BlendMode.srcIn),),
                  title: Text(getTranslated("viewAllMedia"), style: AppStyleConfig.groupChatInfoPageStyle.viewAllMediaStyle.titleTextStyle),
                  trailing: Icon(Icons.keyboard_arrow_right,color: AppStyleConfig.groupChatInfoPageStyle.viewAllMediaStyle.trailingIconColor,),
                  onTap: () => controller.gotoViewAllMedia(),
                ),*/
                SettingListItem(leading: reportGroup,title: getTranslated("reportGroup"),trailing: rightArrowIcon,onTap: (){
                  controller.reportGroup();
                }, listItemStyle: AppStyleConfig.groupChatInfoPageStyle.reportGroupStyle,),
                /*ListItem(
                  leading: AppUtils.svgIcon(icon:reportGroup,colorFilter: ColorFilter.mode(AppStyleConfig.groupChatInfoPageStyle.reportGroupStyle.leadingIconColor, BlendMode.srcIn),),
                  title: Text(getTranslated("reportGroup"), style: AppStyleConfig.groupChatInfoPageStyle.reportGroupStyle.titleTextStyle),
                  onTap: () => controller.reportGroup(),
                ),*/
                Obx(() {
                  LogMessage.d("Delete or Leave",
                      "${controller.isMemberOfGroup} ${controller.availableFeatures.value.isDeleteChatAvailable.checkNull()} ${controller.isMemberOfGroup} ${controller.leavedGroup.value}");
                  return Visibility(
                    visible: !controller.isMemberOfGroup
                        ? controller.availableFeatures.value.isDeleteChatAvailable.checkNull()
                        : (controller.isMemberOfGroup && !controller.leavedGroup.value),
                    child: SettingListItem(leading: leaveGroup,title: !controller.isMemberOfGroup ? getTranslated("deleteGroup") : getTranslated("leaveGroup"),trailing: rightArrowIcon,onTap: (){
                      controller.exitOrDeleteGroup();
                    }, listItemStyle: AppStyleConfig.groupChatInfoPageStyle.leaveGroupStyle,),/*ListItem(
                      leading: AppUtils.svgIcon(icon:
                        leaveGroup,
                        width: 18,
                        colorFilter: ColorFilter.mode(AppStyleConfig.groupChatInfoPageStyle.leaveGroupStyle.leadingIconColor, BlendMode.srcIn),
                      ),
                      title: Text(!controller.isMemberOfGroup ? getTranslated("deleteGroup") : getTranslated("leaveGroup"),
                          style: AppStyleConfig.groupChatInfoPageStyle.leaveGroupStyle.titleTextStyle),
                      onTap: () => controller.exitOrDeleteGroup(),
                    ),*/
                  );
                }),
              ],
            ),
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
              /*NavUtils.popUntil((route)=>!(route.navigator?.canPop() ?? false));
              Future.delayed(const Duration(milliseconds: 300), () {
                NavUtils.toNamed(Routes.chat, arguments: ChatViewArguments(
                    chatJid: item.jid.checkNull()));
              });*/
              NavUtils.back();
              NavUtils.back(result : item);
              // NavUtils.toNamed(Routes.CHAT, arguments: item);
              /*NavUtils.back();
              Future.delayed(const Duration(milliseconds: 300), () {
                NavUtils.back(result: item);
              });*/
            },
            visualDensity: const VisualDensity(horizontal: 0, vertical: -3)),
        ListTile(
            title: Text(
              getTranslated("viewInfo"),
              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            ),
            onTap: () {
              NavUtils.back();
              NavUtils.toNamed(Routes.chatInfo, arguments: ChatInfoArguments(chatJid:item.jid.checkNull()));
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
                    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getTranslated("areYouSureToRemove").replaceAll("%d", getName(item)), actions: [
                      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                          onPressed: () {
                            NavUtils.back();
                          },
                          child: Text(getTranslated("no").toUpperCase(), )),
                      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                          onPressed: () {
                            NavUtils.back();
                            controller.removeUser(item.jid.checkNull());
                          },
                          child: Text(getTranslated("yes").toUpperCase(), )),
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
                    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message:getTranslated("areYouSureMakeAdmin").replaceAll("%d", getName(item)), actions: [
                      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                          onPressed: () {
                            NavUtils.back();
                          },
                          child: Text(getTranslated("no").toUpperCase(), )),
                      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                          onPressed: () {
                            NavUtils.back();
                            controller.makeAdmin(item.jid.checkNull());
                          },
                          child: Text(getTranslated("yes").toUpperCase(), )),
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
              width: NavUtils.size.width,
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
