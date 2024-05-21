import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../extensions/extensions.dart';
import '../../call_widgets.dart';
import '../controllers/call_timeout_controller.dart';

class CallTimeoutView extends NavView<CallTimeoutController> {
  const CallTimeoutView({Key? key}) : super(key: key);

  @override
  CallTimeoutController createController() {
    return CallTimeoutController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.callOptionBackground,
        body: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10,),
                    Text(getTranslated("unavailableTryAgain"), style: const TextStyle(
                        fontSize: 14, color: AppColors.callerStatus),),
                    const SizedBox(height: 16,),
                    Obx(() {
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: FutureBuilder(future: CallUtils.getCallersName(controller.users,controller.users.length==1), builder: (ctx, snap) {
                            return snap.hasData && snap.data != null ? Text(
                              snap.data!,
                              //controller.calleeNames.length>3 ? "${controller.calleeNames.take(3).join(",")} and (+${controller.calleeNames.length - 3 })" : controller.calleeNames.join(","),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18)
                              ,
                              overflow: TextOverflow.ellipsis,) : const SizedBox.shrink();
                          }));
                    }),
                    const SizedBox(
                      height: 16,
                    ),
                    Obx(() {
                      return controller.groupId.isNotEmpty ? FutureBuilder(future: getProfileDetails(controller.groupId.value), builder: (ctx, snap) {
                        return snap.hasData && snap.data != null ? buildProfileImage(snap.data!) : const SizedBox
                            .shrink();
                      }) : controller.users.length == 1 ? FutureBuilder(future: getProfileDetails(controller.users[0]!), builder: (ctx, snap) {
                        return snap.hasData && snap.data != null ? buildProfileImage(snap.data!) : const SizedBox
                            .shrink();
                      }) : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            controller.users.length > 3 ? 4 : controller.users.length, (index) =>
                        (index == 3) ? ProfileTextImage(
                          text: "+${controller.users.length - 3}",
                          radius: 45 / 2,
                          bgColor: Colors.white,
                          fontColor: Colors.grey,
                        ) : FutureBuilder(future: getProfileDetails(controller.users[index]!), builder: (ctx, snap) {
                          return snap.hasData && snap.data != null ? Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: buildProfileImage(snap.data!, size: 45),
                          ) : const SizedBox.shrink();
                        })),
                      );
                    }),
                    /*ClipOval(
                      child: Image.asset(
                        groupImg,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),*/
                  ],
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: AppColors.bottomCallOptionBackground,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
                    child: Obx(() {
                      return Column(
                        children: [
                          if(controller.users.length > 1) ...[Text(getTranslated("callTimeoutMessage"), style: const TextStyle(color: Colors.white),),],
                          if(controller.users.length > 1) ...[const SizedBox(height: 20,),],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => controller.cancelCallTimeout(),
                                child: Column(
                                  children: [
                                    FloatingActionButton(
                                      heroTag: "cancelTimeout",
                                      elevation: 0,
                                      backgroundColor: Colors.white,
                                      onPressed: () {
                                        controller.cancelCallTimeout();
                                      },
                                      child: SvgPicture.asset(callCancel),
                                    ),
                                    const SizedBox(height: 13,),
                                    Text(getTranslated("cancel"), style: const TextStyle(
                                        fontSize: 12, color: Colors.white))
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => controller.callAgain(),
                                child: Column(
                                  children: [
                                    Obx(() {
                                      return FloatingActionButton(
                                        heroTag: "callAgain",
                                        elevation: 0,
                                        backgroundColor: AppColors.callAgainButtonBackground,
                                        onPressed: () {
                                          controller.callAgain();
                                        },
                                        child: controller.callType.value == CallType.audio ?
                                        SvgPicture.asset(audioCallAgain) : SvgPicture
                                            .asset(videoCallAgain),
                                      );
                                    }),
                                    const SizedBox(height: 13,),
                                    Text(getTranslated("callAgain"), style: const TextStyle(
                                        fontSize: 12, color: Colors.white))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}
