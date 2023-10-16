import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_widgets.dart';
import 'package:mirror_fly_demo/app/call_modules/outgoing_call/call_controller.dart';
import 'package:mirror_fly_demo/app/model/call_user_list.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../common/constants.dart';

class OnGoingCallView extends GetView<CallController> {
  const OnGoingCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: AppColors.callBg,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: [
                      Obx(() {
                        debugPrint("controller.pinnedUserJid ${controller.pinnedUserJid}");
                        return controller.pinnedUserJid.value.isNotEmpty && controller.layoutSwitch.value
                            ? MirrorFlyView(
                                    key: UniqueKey(),
                                    userJid: controller.pinnedUserJid.value,
                                    alignProfilePictureCenter: false,
                                    showSpeakingRipple: controller.callType.value == CallType.audio,
                                    viewBgColor: AppColors.audioCallerBackground,
                                    profileSize: 100)
                                .setBorderRadius(const BorderRadius.all(Radius.circular(10)))
                            : const SizedBox.shrink();
                      }),
                      Obx(() {
                        return Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                controller.callStatus.contains(CallStatus.reconnecting) && controller.layoutSwitch.value
                                    ? const Text(
                                        "${CallStatus.reconnecting}...",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : controller.callStatus.contains(CallStatus.onHold) && controller.layoutSwitch.value
                                        ? const Text(
                                            CallStatus.onHold,
                                            style: TextStyle(color: Colors.white),
                                          ):  const SizedBox.shrink(),
                                if (controller.callStatus.contains(CallStatus.reconnecting) || controller.callStatus.contains(CallStatus.onHold))...[
                                    const SizedBox(
                                        height: 10,
                                      )],
                                if(controller.callList.length > 1 && controller.callList[0].isAudioMuted.value && controller.layoutSwitch.value)...[
                                    CircleAvatar(
                                        backgroundColor: AppColors.audioMutedIconBgColor,
                                        child: SvgPicture.asset(callMutedIcon),
                                      )],
                              ],
                            ));
                      }),
                    ],
                  )),
              Obx(() {
                return controller.callList.length >= 2
                    ? AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        left: 0,
                        right: 10,
                        bottom: controller.layoutSwitch.value ? controller.isVisible.value ? 200 : 0 : null,
                        top: controller.layoutSwitch.value ? 0 : controller.isVisible.value ? 60: 0,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: buildCallItem(controller),
                        ),
                      )
                    : const SizedBox.shrink();
              }),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  debugPrint("InkWell");
                  controller.isVisible(!controller.isVisible.value);
                },
              ),
              Obx(() {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  bottom: controller.isVisible.value ? 0.0 : -200,
                  left: 0.0,
                  right: 0.0,
                  child: buildCallOptions(),
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
                  child: buildToolbar(context),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildToolbar(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                controller.openParticipantScreen();
              },
              icon: SvgPicture.asset(addUserCall),
            ),
            IconButton(
              onPressed: () {
                controller.changeLayout();
              },
              icon: SvgPicture.asset(gridIcon,color: Colors.white,),
            )

          ],
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() {
                return SizedBox(
                  width: 200,
                  child: Text(
                    controller.callTitle.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.0,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
              const SizedBox(
                height: 8,
              ),
              Obx(() {
                return Text(
                  controller.callTimer.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                  ),
                );
              }),
            ],
          ),
        )
      ],
    );
  }

  Widget buildCallOptions() {
    double rightSideWidth = 15;
    controller.callType.value == CallType.video ? rightSideWidth = 20 : rightSideWidth = 30;
    return Obx(() {
      return Column(
        children: [
          /*InkWell(
            onTap: () {
              controller.showCallOptions();
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                callOptionsUpArrow,
                width: 30,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),*/
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: "mute",
                elevation: 0,
                backgroundColor: controller.muted.value ? Colors.white : Colors.white.withOpacity(0.3),
                onPressed: () => controller.muteAudio(),
                child: controller.muted.value
                    ? SvgPicture.asset(
                        muteActive,
                      )
                    : SvgPicture.asset(
                        muteInactive,
                      ),
              ),
              SizedBox(width: rightSideWidth),
              controller.callType.value == CallType.video && !controller.videoMuted.value
                  ? FloatingActionButton(
                      heroTag: "switchCamera",
                      elevation: 0,
                      backgroundColor: controller.cameraSwitch.value ? Colors.white : Colors.white.withOpacity(0.3),
                      onPressed: () => controller.switchCamera(),
                      child: controller.cameraSwitch.value ? SvgPicture.asset(cameraSwitchActive) : SvgPicture.asset(cameraSwitchInactive),
                    )
                  : const SizedBox.shrink(),
              controller.callType.value == CallType.video && !controller.videoMuted.value ? SizedBox(width: rightSideWidth) : const SizedBox.shrink(),
              FloatingActionButton(
                heroTag: "videoMute",
                elevation: 0,
                backgroundColor: controller.videoMuted.value ? Colors.white : Colors.white.withOpacity(0.3),
                onPressed: () => controller.videoMute(),
                child: controller.videoMuted.value ? SvgPicture.asset(videoInactive) : SvgPicture.asset(videoActive),
              ),
              SizedBox(
                width: rightSideWidth,
              ),
              FloatingActionButton(
                heroTag: "speaker",
                elevation: 0,
                backgroundColor: controller.audioOutputType.value == AudioDeviceType.receiver ? Colors.white.withOpacity(0.3) : Colors.white,
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
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero, maximumSize: const Size(200, 50), shape: const StadiumBorder(), backgroundColor: AppColors.endButton),
                onPressed: () {
                  controller.disconnectCall();
                },
                child: SvgPicture.asset(
                  callEndButton,
                )),
          ),
          // )
        ],
      );
    });
  }
}
