import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/group/controllers/group_creation_controller.dart';

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
              onPressed: ()=>controller.goToAddParticipantsPage(),
              child: const Text("NEXT",style: TextStyle(color: Colors.black),)),
        ],
      ),
      body: WillPopScope(
        onWillPop: () {
          if (controller.showEmoji.value) {
            controller.showEmoji(false);
          } else {
            Get.back();
          }
          return Future.value(false);
        },
        child: SafeArea(
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 18.0,
                        horizontal: 18.0,
                      ),
                      child: Obx(
                        () => InkWell(
                          child: controller.imagePath.value.isNotEmpty
                              ? SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: ClipOval(
                                    child: Image.file(
                                      File(controller.imagePath.value),
                                      fit: BoxFit.fill,
                                    ),
                                  ))
                              : ImageNetwork(
                                  url: controller.userImgUrl.value.checkNull(),
                                  width: 150,
                                  height: 150,
                                  clipOval: true,
                                  errorWidget: ClipOval(
                                    child: Image.asset(groupImg,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                          onTap: () {
                            if (controller.imagePath.value
                                .checkNull()
                                .isNotEmpty) {
                              Get.toNamed(Routes.imageView, arguments: {
                                'imageName': controller.groupName.text,
                                'imagePath':
                                    controller.imagePath.value.checkNull()
                              });
                            } else if (controller.userImgUrl.value
                                .checkNull()
                                .isNotEmpty) {
                              Get.toNamed(Routes.imageView, arguments: {
                                'imageName': controller.groupName.text,
                                'imageUrl':
                                    controller.userImgUrl.value.checkNull()
                              });
                            }
                          },
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
                            Helper.showAlert(message: "",content:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                                children:[
                              TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.imagePick(context);
                                  },
                                  child: const Text("Choose from Gallery",style: TextStyle(color: Colors.black),)),
                              TextButton(
                                  onPressed: () async{
                                    Get.back();
                                    controller.camera();
                                  },
                                  child: const Text("Take Photo",style: TextStyle(color: Colors.black))),
                            ] ));
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40.0,right: 20),
                      child: TextField(
                        focusNode: controller.focusNode,
                        style:
                        const TextStyle(fontSize: 14, fontWeight: FontWeight.normal,overflow: TextOverflow.visible),
                        onChanged: (_) => controller.onGroupNameChanged(),
                        maxLength: 25,
                        maxLines: 1,
                        controller: controller.groupName,
                        decoration: const InputDecoration(border: InputBorder.none,counterText:"",hintText: "Type group name here..." ),
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                        child: Obx(
                              ()=> Text(
                            controller.count.toString(),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                        ),
                      )),
                  IconButton(
                      onPressed: () {
                        controller.showHideEmoji(context);
                      },
                      icon: SvgPicture.asset(smileIcon,width: 18,height: 18,))
                ],
              ),
              const AppDivider(),
              const Text("Provide a Group Name and Icon",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
              Expanded(
                child: Obx(() {
                  if (controller.showEmoji.value) {
                    return EmojiLayout(
                        textController: controller.groupName,
                        onEmojiSelected : (cat, emoji)=>controller.onGroupNameChanged()
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
