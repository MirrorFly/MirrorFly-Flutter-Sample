import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../data/helper.dart';
import '../../../extensions/extensions.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';
import '../../settings/views/settings_widgets.dart';
import '../controllers/chat_info_controller.dart';

class ChatInfoView extends NavViewStateful<ChatInfoController> {
  const ChatInfoView({super.key});

  @override
ChatInfoController createController({String? tag}) => Get.put(ChatInfoController());


  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: AppStyleConfig.chatInfoPageStyle.appBarTheme,),
      child: Scaffold(
        body: !controller.argument.disableAppbar
            ? NestedScrollView(
          controller: controller.scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            controller.silverBarHeight = NavUtils.height * 0.45;
            return <Widget>[
              Obx(() {
                return SliverAppBar(
                  centerTitle: false,
                  titleSpacing: 0.0,
                  expandedHeight: NavUtils.height * 0.45,
                  snap: false,
                  pinned: true,
                  floating: false,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: controller.isSliverAppBarExpanded
                            ? AppStyleConfig.chatInfoPageStyle.silverAppBarIconColor
                            : AppBarTheme.of(context).actionsIconTheme?.color),
                    onPressed: () {
                      NavUtils.back();
                    },
                  ),
                  title: Visibility(
                    visible: !controller.isSliverAppBarExpanded,
                    child: Text(controller.profile.getName(),
                        style: AppBarTheme.of(context).titleTextStyle,
                        /*style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        )*/
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    background: ImageNetwork(
                      url: controller.profile.image.checkNull(),
                      width: NavUtils.width,
                      height: NavUtils.height * 0.45,
                      clipOval: false,
                      errorWidget: ProfileTextImage(
                        text: controller.profile.getName(),
                        radius: 0,
                        fontSize: 120,
                      ),
                      onTap: () {
                        if (controller.profile.image!.isNotEmpty && !(controller.profile
                            .isBlockedMe.checkNull() || controller.profile.isAdminBlocked
                            .checkNull()) && !(!controller.profile.isItSavedContact
                            .checkNull() || controller.profile.isDeletedContact())) {
                          NavUtils.toNamed(Routes.imageView, arguments: {
                            'imageName': getName(controller.profile),
                            'imageUrl': controller.profile.image.checkNull()
                          });
                        }
                      },
                      isGroup: controller.profile.isGroupProfile.checkNull(),
                      blocked: controller.profile.isBlockedMe.checkNull() || controller.profile.isAdminBlocked.checkNull(),
                      unknown: (!controller.profile.isItSavedContact.checkNull() || controller.profile.isDeletedContact()),
                    ),
                    // titlePadding: controller.isSliverAppBarExpanded
                    //     ? const EdgeInsets.symmetric(vertical: 16, horizontal: 20)
                    //     : const EdgeInsets.symmetric(
                    //     vertical: 19, horizontal: 50),
                    titlePadding: const EdgeInsets.only(left: 16),

                    title: Visibility(
                      visible: controller.isSliverAppBarExpanded,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(getName(controller.profile),
                                style: controller.isSliverAppBarExpanded ? AppStyleConfig.chatInfoPageStyle.silverAppbarTitleStyle : AppBarTheme.of(context).titleTextStyle
                                /*TextStyle(
                                  color: controller.isSliverAppBarExpanded
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 18.0,
                                )*/
                            ),
                            Obx(() {
                              return Text(controller.userPresenceStatus.value,
                                  style: AppStyleConfig.chatInfoPageStyle.silverAppBarSubTitleStyle,
                                  /*style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.0,
                                  ) *///TextStyle
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                      StretchMode.fadeTitle
                    ],
                  ),
                );
              }),
            ];
          },
          body: infoContent(),
        ) : SafeArea(child: infoContent()),
      ),
    );
  }

  Widget infoContent(){
    return ListView(
      children: [
        /*Obx(() {
          return controller.isSliverAppBarExpanded
              ? const Offstage()
              : const SizedBox(height: 60);
        }),*/
        Obx(() {
          return listItem(
            title: Text(getTranslated("muteNotification"),
                style: AppStyleConfig.chatInfoPageStyle.muteNotificationStyle.textStyle,
                /*style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)*/
            ),
            trailing: FlutterSwitch(
                width: 40.0,
                height: 20.0,
                valueFontSize: 12.0,
                toggleSize: 12.0,
                activeColor: AppStyleConfig.chatInfoPageStyle.muteNotificationStyle.toggleStyle.activeColor,
                activeToggleColor: AppStyleConfig.chatInfoPageStyle.muteNotificationStyle.toggleStyle.activeToggleColor,
                inactiveToggleColor: AppStyleConfig.chatInfoPageStyle.muteNotificationStyle.toggleStyle.inactiveToggleColor,
                inactiveColor: AppStyleConfig.chatInfoPageStyle.muteNotificationStyle.toggleStyle.inactiveColor,
                switchBorder: Border.all(color: controller.mute.value ? AppStyleConfig.chatInfoPageStyle.muteNotificationStyle.toggleStyle.activeToggleColor : AppStyleConfig.chatInfoPageStyle.muteNotificationStyle.toggleStyle.inactiveToggleColor, width: 1),
                value: controller.mute.value,
                onToggle: (value) =>
                {
                  controller.onToggleChange(value)
                }
            ), onTap: () {
            controller.onToggleChange(!controller.mute.value);
          },
          );
        }),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(getTranslated("email"),
                  style: AppStyleConfig.chatInfoPageStyle.optionsViewStyle.titleTextStyle,
                  /*style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)*/
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 16),
              child: Row(
                children: [
                  AppUtils.svgIcon(icon:emailIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatInfoPageStyle.optionsViewStyle.leadingIconColor, BlendMode.srcIn),),
                  const SizedBox(width: 10,),
                  Obx(() {
                    return Text(controller.profile.email.checkNull(),
                        style: AppStyleConfig.chatInfoPageStyle.optionsViewStyle.descriptionTextStyle,
                        /*style: const TextStyle(
                            fontSize: 13,
                            color: textColor,
                            fontWeight: FontWeight.w500)*/
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(getTranslated("mobileNumber"),
                  style: AppStyleConfig.chatInfoPageStyle.optionsViewStyle.titleTextStyle,
                  /*style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)*/
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 16),
              child: Row(
                children: [
                  AppUtils.svgIcon(icon:phoneIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatInfoPageStyle.optionsViewStyle.leadingIconColor, BlendMode.srcIn),),
                  const SizedBox(width: 10,),
                  Obx(() {
                    return Text(controller.profile.mobileNumber.checkNull(),
                        style: AppStyleConfig.chatInfoPageStyle.optionsViewStyle.descriptionTextStyle,
                        /*style: const TextStyle(
                            fontSize: 13,
                            color: textColor,
                            fontWeight: FontWeight.w500)*/
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(getTranslated("status"),
                  style: AppStyleConfig.chatInfoPageStyle.optionsViewStyle.titleTextStyle,
                  /*style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)*/
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 16),
              child: Row(
                children: [
                  AppUtils.svgIcon(icon:statusIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatInfoPageStyle.optionsViewStyle.leadingIconColor, BlendMode.srcIn),),
                  const SizedBox(width: 10,),
                  Obx(() {
                    return Text(controller.profile.status.checkNull(),
                        style: AppStyleConfig.chatInfoPageStyle.optionsViewStyle.descriptionTextStyle,
                        /*style: const TextStyle(
                            fontSize: 13,
                            color: textColor,
                            fontWeight: FontWeight.w500)*/
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        SettingListItem(leading: imageOutline,title: getTranslated("viewAllMedia"),trailing: rightArrowIcon,onTap: (){
          controller.gotoViewAllMedia();
        }, listItemStyle: AppStyleConfig.chatInfoPageStyle.viewAllMediaStyle,),
        SettingListItem(leading: reportUser,title: getTranslated("report"),onTap: (){
          controller.reportChatOrUser();
        }, listItemStyle: AppStyleConfig.chatInfoPageStyle.viewAllMediaStyle,),
        /*listItem(
            leading: AppUtils.svgIcon(icon:imageOutline,),
            title: Text(getTranslated("viewAllMedia"),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () =>
            {
              controller.gotoViewAllMedia()
            } //controller.gotoViewAllMedia(),
        ),*/
        /*listItem(
            leading: AppUtils.svgIcon(icon:reportUser),
            title: Text(getTranslated("report"),
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            onTap: () =>
            {
              controller.reportChatOrUser()
            }
        ),*/
      ],
    );
  }
}
