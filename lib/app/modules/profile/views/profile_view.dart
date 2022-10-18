import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';

import '../../../common/cropimage.dart';
import '../../../common/widgets.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile',style: TextStyle(color: appbartextcolor),),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                Center(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Obx(
                            ()=> controller.userImgUrl.value.isEmpty ? Image.asset(
                              'assets/logos/profile_img.png',
                              height: 150,
                              width: 150,
                            ) : ImageNetwork(url:controller.userImgUrl.value,width:150, height: 150,clipoval: true,),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: InkWell(
                          onTap: (){
                            controller.ImagePicker(context);
                          },
                          child: Image.asset(
                          'assets/logos/camera_profile_change.png',
                          height: 40,
                        ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                TextField(
                  onChanged: (value) => controller.changed.value =true,
                  textAlign: TextAlign.center,
                  controller: controller.profileName,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter User Name',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20,),
                const Text('Email',style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),),
                const SizedBox(height: 10,),
                TextField(
                  onChanged: (value) => controller.changed.value =true,
                  controller: controller.profileEmail,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Email Id',
                    icon: SvgPicture.asset('assets/logos/email.svg'),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const AppDivider(padding: 0.0,),
                const SizedBox(height: 20,),
                const Text('Mobile Number',style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),),
                const SizedBox(height: 10,),
                TextField(
                  onChanged: (value) => controller.changed.value =true,
                  controller: controller.profileMobile,
                  enabled: false,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Mobile Number',
                    icon: SvgPicture.asset('assets/logos/phone.svg'),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const AppDivider(padding: 0.0,),
                const SizedBox(height: 20,),
                const Text('Status',style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),),
                const SizedBox(height: 10,),
                /*TextField(
                  onChanged: (value) => controller.changed.value =true,
                  controller: controller.profileStatus,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'I’m in Mirrorfly',
                    icon: InkWell(child: SvgPicture.asset('assets/logos/status.svg'),onTap: (){
                      Get.toNamed(Routes.STATUSLIST)?.then((value){
                        if(value!=null){
                          controller.profileStatus.text = value;
                        }
                      });
                    },),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),*/
                Obx(()=> ListTile(
                  contentPadding:EdgeInsets.zero,title: Text(controller.profileStatus.value),leading: SvgPicture.asset('assets/logos/status.svg'),
                onTap: (){
                  Get.toNamed(Routes.STATUSLIST,arguments: {'status':controller.profileStatus.value})?.then((value){
                    if(value!=null){
                      controller.profileStatus.value = value;
                    }
                  });
                },)),
                const AppDivider(padding: 0.0,),
                Center(
                  child: Obx(
                    ()=> controller.loading.value ?  CircularProgressIndicator() : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          textStyle: const TextStyle(fontSize: 14),
                          shape: const StadiumBorder()),
                      onPressed: controller.changed.value || !controller.loading.value ? () {
                        if(!controller.loading.value) {
                          controller.save();
                        }
                      } : null,
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
