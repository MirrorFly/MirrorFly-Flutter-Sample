import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/group/controllers/groupcreation_controller.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../routes/app_pages.dart';

class GroupCreationView extends GetView<GroupCreationController> {
  const GroupCreationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Group',
        ),
        actions: [
          TextButton(
              onPressed: () {
              },
              child: const Text("NEXT",style: TextStyle(color: Colors.black),)),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0,horizontal: 18.0,),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Obx(
                            () => InkWell(
                          child: controller.imagepath.value.isNotEmpty
                              ? SizedBox(
                              width: 150,
                              height: 150,
                              child: ClipOval(
                                child: Image.file(
                                  File(controller.imagepath.value),
                                  fit: BoxFit.fill,
                                ),
                              ))
                              : ImageNetwork(
                            url: controller.userImgUrl.value
                                .checkNull(),
                            width: 150,
                            height: 150,
                            clipoval: true,
                            errorWidget: controller.name.value
                                .checkNull()
                                .isNotEmpty
                                ? ProfileTextImage(
                              fontsize: 40,
                              text: controller.name.value
                                  .checkNull(),
                              radius: 75,
                            )
                                : null,
                          ),
                          onTap: () {
                            if (controller.imagepath.value
                                .checkNull()
                                .isNotEmpty) {
                              Get.toNamed(Routes.IMAGE_VIEW, arguments: {
                                'imageName': controller.groupName.text,
                                'imagePath':
                                controller.imagepath.value.checkNull()
                              });
                            } else if (controller.userImgUrl.value
                                .checkNull()
                                .isNotEmpty) {
                              Get.toNamed(Routes.IMAGE_VIEW, arguments: {
                                'imageName': controller.groupName.text,
                                'imageurl': imagedomin +
                                    controller.userImgUrl.value
                                        .checkNull()
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Obx(
                        () => Positioned(
                      right: 18,
                      bottom: 18,
                      child: InkWell(
                        onTap: controller.loading.value
                            ? null
                            : () {
                          //BottomSheetView(context);
                        },
                        child: Image.asset(
                          'assets/logos/camera_profile_change.png',
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40.0,right: 20),
                      child: TextField(
                        style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.normal,overflow: TextOverflow.visible),
                        //onChanged: (_) => controller.onChanged(),
                        maxLength: 25,
                        maxLines: 1,
                        //controller: controller.addstatuscontroller,
                        decoration: InputDecoration(border: InputBorder.none,counterText:"",hintText: "Type group name here..." ),
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      padding: EdgeInsets.all(4.0),
                      child: Center(
                        child: Obx(
                              ()=> Text(
                            controller.count.toString(),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                        ),
                      )),
                  IconButton(
                      onPressed: () {
                        /*if (!controller.showEmoji.value) {
                                FocusScope.of(context).unfocus();
                                controller.focusNode.canRequestFocus = false;
                              }
                              Future.delayed(const Duration(milliseconds: 500), () {
                                controller.showEmoji(!controller.showEmoji.value);
                              });*/
                      },
                      icon: SvgPicture.asset(smileicon,width: 18,height: 18,))
                ],
              ),
            ),
            AppDivider(padding: 0,),
            Text("Provide a Group Name and Icon",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),)
          ],
        ),
      ),
    );
  }
}
