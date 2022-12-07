
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../routes/app_pages.dart';
import '../controllers/chat_info_controller.dart';

class ChatInfoView extends GetView<ChatInfoController> {
  const ChatInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: controller.scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          controller.silverBarHeight =
              MediaQuery
                  .of(context)
                  .size
                  .height * 0.45;
          return <Widget>[
            Obx(() {
              return SliverAppBar(
                expandedHeight: MediaQuery
                    .of(context)
                    .size
                    .height * 0.45,
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
                flexibleSpace: FlexibleSpaceBar(
                  background: ImageNetwork(
                      url: controller.profile.image.checkNull(),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.45,
                      clipOval: false,
                      errorWidget: ProfileTextImage(
                        text: controller.profile.nickName
                            .checkNull()
                            .isEmpty
                            ? controller.profile.nickName.checkNull()
                            : controller.profile.name.checkNull(),
                        radius: 0,
                        fontSize: 120,
                      ),onTap: (){
                    Get.toNamed(Routes.imageView, arguments: {
                      'imageName': controller.profile.nickName,
                      'imageUrl': controller.profile.image.checkNull()
                    });
                  },),
                  titlePadding: controller.isSliverAppBarExpanded
                      ? const EdgeInsets.symmetric(vertical: 16, horizontal: 20)
                      : const EdgeInsets.symmetric(
                      vertical: 19, horizontal: 50),
                  title: Text(controller.profile.name.checkNull(),
                      style: TextStyle(
                        color: controller.isSliverAppBarExpanded
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18.0,
                      )),
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
        body: ListView(
          children: [
            Obx(() {
              return controller.isSliverAppBarExpanded
                  ? const SizedBox.shrink()
                  : const SizedBox(height: 60);
            }),
            Obx(() {
              return listItem(
                title: const Text("Mute Notification",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                trailing: FlutterSwitch(
                    width: 40.0,
                    height: 20.0,
                    valueFontSize: 12.0,
                    toggleSize: 12.0,
                    activeColor: Colors.white,
                    activeToggleColor: Colors.blue,
                    inactiveToggleColor: Colors.grey,
                    inactiveColor: Colors.white,
                    switchBorder: Border.all(
                        color: controller.mute.value ? Colors.blue : Colors
                            .grey,
                        width: 1),
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
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Email", style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, bottom: 16),
                  child: Row(
                    children: [
                      SvgPicture.asset(emailIcon),
                      const SizedBox(width: 10,),
                      Text(controller.profile.email.checkNull(),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Mobile Number", style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, bottom: 16),
                  child: Row(
                    children: [
                      SvgPicture.asset(phoneIcon),
                      const SizedBox(width: 10,),
                      Text(controller.profile.mobileNumber.checkNull(),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Status", style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, bottom: 16),
                  child: Row(
                    children: [
                      SvgPicture.asset(statusIcon),
                      const SizedBox(width: 10,),
                      Text(controller.profile.status.checkNull(),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            listItem(
                leading: SvgPicture.asset(imageOutline),
                title: const Text("View All Media",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => {
                  controller.gotoViewAllMedia()
                } //controller.gotoViewAllMedia(),
            ),
            listItem(
                leading: SvgPicture.asset(reportUser),
                title: const Text("Report",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                onTap: () => {
                controller.reportChatOrUser()
                }
            ),
          ],
        ),
      ),
    );
  }

}
