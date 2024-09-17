import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_style_config.dart';
import '../../call_modules/call_utils.dart';
import '../../call_modules/call_widgets.dart';
import '../../call_modules/outgoing_call/outgoing_call_controller.dart';
import '../../call_modules/ripple_animation_view.dart';
import '../../common/widgets.dart';
import '../../data/helper.dart';
import '../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../common/constants.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';

class OutGoingCallView extends NavViewStateful<OutgoingCallController> {
  const OutGoingCallView({Key? key}) : super(key: key);

  @override
  OutgoingCallController createController({String? tag}) => Get.put(OutgoingCallController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyleConfig.outgoingCallPageStyle.backgroundDecoration,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,//AppStyleConfig.outgoingCallPageStyle.scaffoldBackgroundColor,//AppColors.callerBackground,
          body: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              debugPrint("clicked");
              controller.isVisible(!controller.isVisible.value);
            },
            child: Stack(
              children: [
                Obx(() {
                  return controller.callType.value == CallType.video ?
                  MirrorFlyView(
                    userJid: SessionManagement.getUserJID().checkNull(),
                    viewBgColor: AppColors.callerBackground,
                    hideProfileView: true,
                  ) :
                  const Offstage();
                }),
                Column(
                  children: [
                    Expanded(child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Obx(() {
                          return Text(
                            controller.callStatus.value,
                            style: AppStyleConfig.outgoingCallPageStyle.callStatusTextStyle,
                            // style: const TextStyle(color: AppColors.callerStatus, fontWeight: FontWeight.w100, fontSize: 14),
                          );
                        }),
                        const SizedBox(
                          height: 16,
                        ),
                        Obx(() {
                          return controller.groupId.isNotEmpty ? Padding(
                            padding: const EdgeInsets.only(left: 30.0,right: 30.0,bottom: 16.0),
                            child: FutureBuilder(future:getProfileDetails(controller.groupId.value),builder: (ctx,snap) {
                              return snap.hasData && snap.data!=null ? Text(
                                  snap.data!.getName(),
                                  style: AppStyleConfig.outgoingCallPageStyle.callerNameTextStyle
                                  // style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18)
                            ,
                            overflow: TextOverflow.ellipsis,) : const Offstage();
                        })): const Offstage();}),
                        Obx(() {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: FutureBuilder(future:CallUtils.getCallersName(controller.users,controller.users.length==1),builder: (ctx,snap) {
                              return snap.hasData && snap.data!=null ? Text(
                                  snap.data!, //controller.calleeNames.length>3 ? "${controller.calleeNames.take(3).join(",")} and (+${controller.calleeNames.length - 3 })" : controller.calleeNames.join(","),
                                style: AppStyleConfig.outgoingCallPageStyle.callerNameTextStyle
                                  // style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18)
                            ,
                            overflow: TextOverflow.ellipsis,) : const Offstage();
                        }));}),
                        const SizedBox(
                          height: 16,
                        ),
                        Obx(() {
                          return controller.groupId.isNotEmpty ? RipplesAnimation(
                            onPressed: (){},
                            child: FutureBuilder(future: getProfileDetails(controller.groupId.value), builder: (ctx, snap) {
                              return snap.hasData && snap.data != null ? buildProfileImage(snap.data!,size: AppStyleConfig.outgoingCallPageStyle.profileImageSize.width) : const Offstage();
                            }),
                          ) : controller.users.length == 1 ? RipplesAnimation(
                            onPressed: () {},
                            child: FutureBuilder(future: getProfileDetails(controller.users[0]!), builder: (ctx, snap) {
                              return snap.hasData && snap.data != null ? buildProfileImage(snap.data!,size: AppStyleConfig.outgoingCallPageStyle.profileImageSize.width) : const Offstage();
                            }),
                          ) : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                                controller.users.length > 3 ? 4 : controller.users.length, (index) =>
                            (index == 3) ? Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ProfileTextImage(
                                text: "+${(controller.users.length) - 3}",
                                radius: 45 / 2,
                                bgColor: Colors.white,
                                fontColor: Colors.grey,
                              ),
                            ) : FutureBuilder(future: getProfileDetails(controller.users[index]!), builder: (ctx, snap) {
                              return snap.hasData && snap.data != null ? Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: buildProfileImage(snap.data!, size: 45),
                              ) : const Offstage();
                            })),
                          );
                        }),
                      ],
                    )),
                    Obx(() {
                      debugPrint("audio item changed ${controller.audioOutputType.value}");
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            controller.muted.value
                                ? FloatingActionButton(
                              shape: AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.shape,
                              heroTag: "mute",
                              elevation: 0,
                              backgroundColor: AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.activeBgColor,//Colors.white,
                              onPressed: () => controller.muteAudio(),
                              child: AppUtils.svgIcon(icon:
                                muteActive,
                                colorFilter: ColorFilter.mode(AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn),
                              ),
                            )
                                : FloatingActionButton(
                              shape: AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.shape,
                              heroTag: "mute",
                              elevation: 0,
                              backgroundColor: AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.inactiveBgColor,//Colors.white.withOpacity(0.3),
                              onPressed: () => controller.muteAudio(),
                              child: AppUtils.svgIcon(icon:
                                muteInactive,
                                colorFilter: ColorFilter.mode(AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.inactiveIconColor, BlendMode.srcIn),
                              ),
                            ),
                            if(controller.callType.value == CallType.video && !controller.videoMuted.value)...[
                              FloatingActionButton(
                                shape: AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.shape,
                                heroTag: "switchCamera",
                                elevation: 0,
                                backgroundColor: controller.cameraSwitch.value ? AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.activeBgColor : AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.inactiveBgColor,
                                // backgroundColor: controller.cameraSwitch.value ? Colors.white : Colors.white.withOpacity(0.3),
                                onPressed: () => controller.switchCamera(),
                                child: controller.cameraSwitch.value
                                    ? AppUtils.svgIcon(icon:cameraSwitchActive,colorFilter: ColorFilter.mode(AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn),)
                                    : AppUtils.svgIcon(icon:cameraSwitchInactive,colorFilter: ColorFilter.mode(AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.inactiveIconColor, BlendMode.srcIn),),
                              ),
                            ],
                            FloatingActionButton(
                              shape: AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.shape,
                              heroTag: "video",
                              elevation: 0,
                              backgroundColor: controller.videoMuted.value ? AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.activeBgColor : AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.inactiveBgColor,
                              // backgroundColor: controller.videoMuted.value ? Colors.white : Colors.white.withOpacity(0.3),
                              onPressed: () => controller.videoMute(),
                              child: controller.videoMuted.value ?
                              AppUtils.svgIcon(icon:videoInactive,colorFilter: ColorFilter.mode(AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn),)
                                  : AppUtils.svgIcon(icon:
                                  videoActive,colorFilter: ColorFilter.mode(AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.inactiveIconColor, BlendMode.srcIn),),
                            ),
                            FloatingActionButton(
                              shape: AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.shape,
                              heroTag: "speaker",
                              elevation: 0,
                              backgroundColor:
                              controller.audioOutputType.value == AudioDeviceType.receiver
                                  ? AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.inactiveBgColor//Colors.white.withOpacity(0.3)
                                  : AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.activeBgColor,//Colors.white,
                              onPressed: () => controller.changeSpeaker(),
                              child: controller.audioOutputType.value == AudioDeviceType.receiver
                                  ? AppUtils.svgIcon(icon:speakerInactive,colorFilter: ColorFilter.mode(AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.inactiveIconColor, BlendMode.srcIn),)
                                  : controller.audioOutputType.value == AudioDeviceType.speaker
                                  ? AppUtils.svgIcon(icon:speakerActive,colorFilter: ColorFilter.mode(AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn))
                                  : controller.audioOutputType.value == AudioDeviceType.bluetooth
                                  ? AppUtils.svgIcon(icon:speakerBluetooth,colorFilter: ColorFilter.mode(AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn))
                                  : controller.audioOutputType.value == AudioDeviceType.headset
                                  ? AppUtils.svgIcon(icon:speakerHeadset,colorFilter: ColorFilter.mode(AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn))
                                  : AppUtils.svgIcon(icon:speakerActive,colorFilter: ColorFilter.mode(AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn)),
                            ),
                          ],
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                      child: ElevatedButton(
                        style: AppStyleConfig.outgoingCallPageStyle.disconnectButtonStyle,
                        onPressed: (){
                          controller.disconnectOutgoingCall();
                        },
                        child: AppUtils.svgIcon(icon:callEndButton),
                      )
                      /*ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              maximumSize: const Size(200, 50),
                              shape: const StadiumBorder(),
                              backgroundColor: AppColors.endButton),
                          onPressed: () {
                            controller.disconnectOutgoingCall();
                          },
                          child: AppUtils.svgIcon(icon:
                            callEndButton,
                          )),*/
                    ),
                  ],
                ),
                /*Obx(() {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    bottom: controller.isVisible.value ? 0.0 : -200,
                    left: 0.0,
                    right: 0.0,
                    height: 200,
                    child: Container(
                      color: Colors.blue,
                      child: const Center(
                        child: Text(
                          'Slide Animation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                Obx(() {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    top: controller.isVisible.value ? 0.0 : -72,
                    left: 0.0,
                    right: 0.0,
                    height: 72,
                    child: Container(
                      color: Colors.blue,
                      child: const Center(
                        child: Text(
                          'Slide Animation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  );
                }),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
