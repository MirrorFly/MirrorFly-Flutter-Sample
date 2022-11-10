import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/enums/message_enum.dart';
import 'package:mirror_fly_demo/app/model/recentchat.dart';
import 'package:mirror_fly_demo/app/modules/chat/views/contactlist_view.dart';

import '../../../common/widgets.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  //final themeController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        controller.getRecentChatlist();
        controller.initListeners();
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            bottom: TabBar(
                indicatorColor: buttonbgcolor,
                labelColor: buttonbgcolor,
                unselectedLabelColor: appbartextcolor,
                tabs: [
                  Obx(() {
                    return TabItem(
                        title: "CHATS", count: controller.unreadcount.toString());
                  }),
                  TabItem(title: "CALLS",count: "0")
                ]),
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  searchicon,
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                ),
                onPressed: () {
                  Get.toNamed(Routes.RECENTSEARCH,
                      arguments: {"recents": controller.recentchats});
                },
              ),
              CustomActionBarIcons(
                availableWidth: MediaQuery
                    .of(context)
                    .size
                    .width /
                    2, // half the screen width
                actionWidth: 48,
                actions: [
                  CustomAction(
                    visibleWidget: const Icon(Icons.group_add),
                    overflowWidget: const Text("New Group     "),
                    showAsAction: ShowAsAction.NEVER,
                    keyValue: 'New Group',
                    onItemClick: () {
                      Future.delayed(const Duration(milliseconds: 100),
                              () => Get.toNamed(Routes.CREATE_GROUP));
                    },
                  ),
                  CustomAction(
                    visibleWidget: const Icon(Icons.settings),
                    overflowWidget: const Text("Settings"),
                    showAsAction: ShowAsAction.NEVER,
                    keyValue: 'Settings',
                    onItemClick: () {
                      Future.delayed(const Duration(milliseconds: 100),
                              () => Get.toNamed(Routes.SETTINGS));
                    },
                  ),
                  CustomAction(
                    visibleWidget: const Icon(Icons.web),
                    overflowWidget: const Text("Web"),
                    showAsAction: ShowAsAction.NEVER,
                    keyValue: 'Web',
                    onItemClick: () {
                      Future.delayed(const Duration(milliseconds: 100),
                              () => Get.toNamed(Routes.SETTINGS));
                    },
                  )
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: "New Chat",
            onPressed: () {
              Get.toNamed(Routes.CONTACTS,
                  arguments: {"forward": false, "group": false,"groupJid":""});
            },
            backgroundColor: buttonbgcolor,
            child: SvgPicture.asset(
              chatfabicon,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),
          body: TabBarView(children: [ChatView(context), SizedBox()]),
        ),
      ),
    );
  }

  Widget TabItem({required String title, required String count}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          count != "0"
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CircleAvatar(
              radius: 9,
              child: Text(
                count.toString(),
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontFamily: 'sf_ui'),
              ),
            ),
          )
              : SizedBox.shrink()
        ],
      ),
    );
  }

  Stack ChatView(BuildContext context) {
    return Stack(
      children: [
        Obx(
              () =>
          controller.recentchats.isNotEmpty
              ? ListView.builder(
              itemCount: controller.recentchats.length,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                var item = controller.recentchats[index];
                //var image = controller.imagepath(item.profileImage);
                return RecentChatItem(item, context);
              })
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  nochaticon,
                  width: 200,
                ),
                Text(
                  'No new messages',
                  textAlign: TextAlign.center,
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Any new messages will appear here',
                  textAlign: TextAlign.center,
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleSmall,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  InkWell RecentChatItem(RecentChatData item, BuildContext context) {
    return InkWell(
      child: Container(
        child: Row(
          children: [
            Container(
                margin: const EdgeInsets.only(
                    left: 19.0, top: 10, bottom: 10, right: 10),
                child: Stack(
                  children: [
                    ImageNetwork(
                      url: item.profileImage.toString(),
                      width: 48,
                      height: 48,
                      clipoval: true,
                      errorWidget: item.isGroup!
                          ? ClipOval(
                        child: Image.asset(
                          groupImg,
                          height: 48,
                          width: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                          : ProfileTextImage(
                        text: item.profileName
                            .checkNull()
                            .isEmpty
                            ? item.nickName.checkNull()
                            : item.profileName.checkNull(),
                      ),
                    ),
                    item.unreadMessageCount.toString() != "0"
                        ? Positioned(
                        right: 0,
                        child: CircleAvatar(
                          radius: 8,
                          child: Text(
                            item.unreadMessageCount.toString(),
                            style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontFamily: 'sf_ui'),
                          ),
                        ))
                        : const SizedBox(),
                  ],
                )),
            Flexible(
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.profileName.toString(),
                            style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'sf_ui',
                                color: texthintcolor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0, left: 8),
                          child: Text(
                            controller.getRecentChatTime(
                                context, item.lastMessageTime),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'sf_ui',
                                color: item.unreadMessageCount.toString() != "0"
                                    ? buttonbgcolor
                                    : textcolor),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        item.unreadMessageCount.toString() != "0"
                            ? const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: Colors.green,
                          ),
                        )
                            : const SizedBox(),
                        Expanded(
                          child: Row(
                            children: [
                              Helper.forMessageTypeIcon(item.lastMessageType),
                              SizedBox(
                                width: Helper.forMessageTypeString(
                                    item.lastMessageType) !=
                                    ""
                                    ? 3.0
                                    : 0.0,
                              ),
                              Expanded(
                                child: Text(
                                  Helper.forMessageTypeString(
                                      item.lastMessageType) ==
                                      ""
                                      ? item.lastMessageContent.checkNull()
                                      : Helper.forMessageTypeString(
                                      item.lastMessageType),
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppDivider(
                      padding: EdgeInsets.only(top: 8),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        controller.toChatPage(item.jid.checkNull());
      },
    );
  }
}
