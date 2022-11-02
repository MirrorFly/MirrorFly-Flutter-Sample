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
import '../../dashboard/controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  //final themeController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        controller.registerMsgListener();
        controller.getRecentChatlist();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: SvgPicture.asset(
                searchicon,
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
              onPressed: (){
                Get.toNamed(Routes.RECENTSEARCH,arguments: {"recents":controller.recentchats});
              },
            ),
            PopupMenuButton<int>(
              icon: SvgPicture.asset(moreicon, width: 3.66, height: 16.31),
              color: Colors.white,
              itemBuilder: (context) => [
                // PopupMenuItem 1
                PopupMenuItem(
                  value: 2,
                  // row with 2 children
                  child: Text(
                    "Settings",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
              offset: const Offset(0, 20),
              elevation: 2,
              // on selected we show the dialog box
              onSelected: (value) {
                // if value 1 show dialog
                if (value == 1) {
                  //_showDialog(context);
                  controller.logout();
                } else if (value == 2) {
                  Get.toNamed(Routes.SETTINGS);
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: "New Chat",
          onPressed: () {
            Get.toNamed(Routes.CONTACTS, arguments: {"forward" : false });
          },
          backgroundColor: buttonbgcolor,
          child: SvgPicture.asset(
            chatfabicon,
            width: 18,
            height: 18,
            fit: BoxFit.contain,
          ),
        ),
        body: Stack(
          children: [
            Obx(
              () => controller.recentchats.isNotEmpty
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
                          Image.asset(nochaticon, width: 200,),
                          Text(
                            'No new messages',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Any new messages will appear here',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  InkWell RecentChatItem(RecentChatData item, BuildContext context) {
    return InkWell(
      child: Container(
        child: Row(
          children: [
            Container(
                margin:
                    const EdgeInsets.only(left: 19.0, top: 10, bottom: 10, right: 10),
                child: Stack(
                  children: [
                    ImageNetwork(
                      url: item.profileImage.toString(),
                      width: 48,
                      height: 48,
                      clipoval: true,
                      errorWidget: ProfileTextImage(
                        text: item.profileName.checkNull().isEmpty
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
                padding: const EdgeInsets.only(top: 16),
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
                              SizedBox(width: Helper.forMessageTypeString(item.lastMessageType)!= "" ? 3.0 : 0.0,),
                              Expanded(
                                child: Text(
                                  Helper.forMessageTypeString(item.lastMessageType) == "" ? item.lastMessageContent.toString() : Helper.forMessageTypeString(item.lastMessageType),
                                  style: Theme.of(context).textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const AppDivider(
                      padding: 0.0,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        //GetAmamed(Routes.CHAT, arguments: controller.recentchats.value[index]);
        Get.toNamed(Routes.CHAT, arguments: controller.toChatPage(item));
           // ?.then((value) => controller.getRecentChatlist());
      },
    );
  }


}
