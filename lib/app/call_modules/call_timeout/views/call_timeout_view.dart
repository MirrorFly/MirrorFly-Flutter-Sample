import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../call_modules/call_utils.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../extensions/extensions.dart';
import '../../call_widgets.dart';
import '../controllers/call_timeout_controller.dart';

class CallTimeoutView extends NavViewStateful<CallTimeoutController> {
  const CallTimeoutView({Key? key}) : super(key: key);

  @override
CallTimeoutController createController({String? tag}) => Get.put(CallTimeoutController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyleConfig.callAgainPageStyle.backgroundDecoration,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                SizedBox(
                  width: NavUtils.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10,),
                      Text(getTranslated("unavailableTryAgain"),
                        style: AppStyleConfig.callAgainPageStyle.callStatusTextStyle
                        // style: const TextStyle(fontSize: 14, color: AppColors.callerStatus)
                        ),
                      const SizedBox(height: 16,),
                      Obx(() {
                        return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: FutureBuilder(future: CallUtils.getCallersName(controller.users,controller.users.length==1), builder: (ctx, snap) {
                              return snap.hasData && snap.data != null ? Text(
                                snap.data!,
                                style: AppStyleConfig.callAgainPageStyle.callerNameTextStyle,
                                //controller.calleeNames.length>3 ? "${controller.calleeNames.take(3).join(",")} and (+${controller.calleeNames.length - 3 })" : controller.calleeNames.join(","),
                                // style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
                                overflow: TextOverflow.ellipsis,) : const Offstage();
                            }));
                      }),
                      const SizedBox(
                        height: 16,
                      ),
                      Obx(() {
                        return controller.groupId.isNotEmpty ? FutureBuilder(future: getProfileDetails(controller.groupId.value), builder: (ctx, snap) {
                          return snap.hasData && snap.data != null ? buildProfileImage(snap.data!,size: AppStyleConfig.callAgainPageStyle.profileImageSize.width) : const SizedBox
                              .shrink();
                        }) : controller.users.length == 1 ? FutureBuilder(future: getProfileDetails(controller.users[0]!), builder: (ctx, snap) {
                          return snap.hasData && snap.data != null ? buildProfileImage(snap.data!,size: AppStyleConfig.callAgainPageStyle.profileImageSize.width) : const SizedBox
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
                            ) : const Offstage();
                          })),
                        );
                      }),
                      /*ClipOval(
                        child: AppUtils.assetIcon(assetName:
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
                    decoration: AppStyleConfig.callAgainPageStyle.bottomActionsContainerDecoration,//AppColors.bottomCallOptionBackground,
                    width: NavUtils.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
                      child: Obx(() {
                        return Column(
                          children: [
                            if(controller.users.length > 1) ...[Text(getTranslated("callTimeoutMessage"),
                              style: AppStyleConfig.callAgainPageStyle.bottomActionsContainerTextStyle,
                              // style: const TextStyle(color: Colors.white),
                              ),],
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
                                        shape: AppStyleConfig.callAgainPageStyle.cancelActionStyle.shape,
                                        backgroundColor: AppStyleConfig.callAgainPageStyle.cancelActionStyle.activeBgColor,
                                        onPressed: () {
                                          controller.cancelCallTimeout();
                                        },
                                        child: AppUtils.svgIcon(icon:callCancel,colorFilter: ColorFilter.mode(AppStyleConfig.callAgainPageStyle.cancelActionStyle.activeIconColor, BlendMode.srcIn),),
                                      ),
                                      const SizedBox(height: 13,),
                                      Text(getTranslated("cancel"),
                                          style: AppStyleConfig.callAgainPageStyle.actionsTitleStyle,
                                          // style: const TextStyle(fontSize: 12, color: Colors.white)
                                      )
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
                                          shape: AppStyleConfig.callAgainPageStyle.callAgainActionStyle.shape,
                                          backgroundColor: AppStyleConfig.callAgainPageStyle.callAgainActionStyle.activeBgColor,//AppColors.callAgainButtonBackground,
                                          onPressed: () {
                                            controller.callAgain();
                                          },
                                          child: controller.callType.value == CallType.audio ?
                                          AppUtils.svgIcon(icon:audioCallAgain,colorFilter: ColorFilter.mode(AppStyleConfig.callAgainPageStyle.callAgainActionStyle.activeIconColor, BlendMode.srcIn),) : AppUtils.svgIcon(icon:videoCallAgain,colorFilter: ColorFilter.mode(AppStyleConfig.callAgainPageStyle.callAgainActionStyle.activeIconColor, BlendMode.srcIn)),
                                        );
                                      }),
                                      const SizedBox(height: 13,),
                                      Text(getTranslated("callAgain"),
                                          style: AppStyleConfig.callAgainPageStyle.actionsTitleStyle,
                                          // style: const TextStyle(fontSize: 12, color: Colors.white)
                                      )
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
      ),
    );
  }
}
