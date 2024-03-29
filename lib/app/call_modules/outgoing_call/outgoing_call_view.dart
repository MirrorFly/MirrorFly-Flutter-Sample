import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirror_fly_demo/app/call_modules/call_widgets.dart';
import 'package:mirror_fly_demo/app/call_modules/outgoing_call/call_controller.dart';
import 'package:mirror_fly_demo/app/call_modules/ripple_animation_view.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';

import '../../common/constants.dart';
import '../../data/session_management.dart';

class OutGoingCallView extends GetView<CallController> {
  const OutGoingCallView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.callerBackground,
      body: SafeArea(
        child: InkWell(
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
                const SizedBox.shrink();
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
                          style: const TextStyle(
                              color: AppColors.callerStatus, fontWeight: FontWeight.w100, fontSize: 14),
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
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18)
                          ,
                          overflow: TextOverflow.ellipsis,) : const SizedBox.shrink();
                      })): const SizedBox.shrink();}),
                      Obx(() {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: FutureBuilder(future:CallUtils.getCallersName(controller.users,controller.users.length==1),builder: (ctx,snap) {
                            return snap.hasData && snap.data!=null ? Text(
                                snap.data!, //controller.calleeNames.length>3 ? "${controller.calleeNames.take(3).join(",")} and (+${controller.calleeNames.length - 3 })" : controller.calleeNames.join(","),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18)
                          ,
                          overflow: TextOverflow.ellipsis,) : const SizedBox.shrink();
                      }));}),
                      const SizedBox(
                        height: 16,
                      ),
                      Obx(() {
                        return controller.groupId.isNotEmpty ? RipplesAnimation(
                          onPressed: (){},
                          child: FutureBuilder(future: getProfileDetails(controller.groupId.value), builder: (ctx, snap) {
                            return snap.hasData && snap.data != null ? buildProfileImage(snap.data!) : const SizedBox
                                .shrink();
                          }),
                        ) : controller.users.length == 1 ? RipplesAnimation(
                          onPressed: () {},
                          child: FutureBuilder(future: getProfileDetails(controller.users[0]!), builder: (ctx, snap) {
                            return snap.hasData && snap.data != null ? buildProfileImage(snap.data!) : const SizedBox
                                .shrink();
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
                            ) : const SizedBox.shrink();
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
                            heroTag: "mute",
                            elevation: 0,
                            backgroundColor: Colors.white,
                            onPressed: () => controller.muteAudio(),
                            child: SvgPicture.asset(
                              muteActive,
                            ),
                          )
                              : FloatingActionButton(
                            heroTag: "mute",
                            elevation: 0,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            onPressed: () => controller.muteAudio(),
                            child: SvgPicture.asset(
                              muteInactive,
                            ),
                          ),
                          if(controller.callType.value == CallType.video && !controller.videoMuted.value)...[
                            FloatingActionButton(
                              heroTag: "switchCamera",
                              elevation: 0,
                              backgroundColor: controller.cameraSwitch.value ? Colors.white : Colors.white.withOpacity(
                                  0.3),
                              onPressed: () => controller.switchCamera(),
                              child: controller.cameraSwitch.value
                                  ? SvgPicture.asset(cameraSwitchActive)
                                  : SvgPicture.asset(cameraSwitchInactive),
                            ),
                          ],
                          FloatingActionButton(
                            heroTag: "video",
                            elevation: 0,
                            backgroundColor: controller.videoMuted.value ? Colors.white : Colors.white.withOpacity(0.3),
                            onPressed: () => controller.videoMute(),
                            child: controller.videoMuted.value ? SvgPicture.asset(videoInactive) : SvgPicture.asset(
                                videoActive),
                          ),
                          FloatingActionButton(
                            heroTag: "speaker",
                            elevation: 0,
                            backgroundColor:
                            controller.audioOutputType.value == AudioDeviceType.receiver
                                ? Colors.white.withOpacity(0.3)
                                : Colors.white,
                            onPressed: () => controller.changeSpeaker(),
                            child: controller.audioOutputType.value == AudioDeviceType.receiver
                                ? SvgPicture.asset(speakerInactive)
                                : controller.audioOutputType.value == AudioDeviceType.speaker
                                ? SvgPicture.asset(speakerActive)
                                : controller.audioOutputType.value == AudioDeviceType.bluetooth
                                ? SvgPicture.asset(speakerBluetooth)
                                : controller.audioOutputType.value == AudioDeviceType.headset
                                ? SvgPicture.asset(speakerHeadset)
                                : SvgPicture.asset(speakerActive),
                          ),
                        ],
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            maximumSize: const Size(200, 50),
                            shape: const StadiumBorder(),
                            backgroundColor: AppColors.endButton),
                        onPressed: () {
                          controller.disconnectOutgoingCall();
                        },
                        child: SvgPicture.asset(
                          callEndButton,
                        )),
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
    );
  }
}
