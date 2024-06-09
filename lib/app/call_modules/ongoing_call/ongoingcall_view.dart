import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirror_fly_demo/app/call_modules/call_widgets.dart';
import 'package:mirror_fly_demo/app/call_modules/outgoing_call/call_controller.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../common/constants.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';

class OnGoingCallView extends NavViewStateful<CallController> {
  const OnGoingCallView({super.key});

  @override
CallController createController() => Get.put(CallController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.callBg,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SizedBox(
                  width: NavUtils.size.width,
                  height: NavUtils.size.height,
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
                                profileSize: 100,
                                onClick: () {
                                  // if(controller.callType.value==CallType.video) {
                                  controller.isVisible(!controller.isVisible.value);
                                  // }
                                },
                              ).setBorderRadius(const BorderRadius.all(Radius.circular(10)))
                            : const SizedBox.shrink();
                      }),
                      Obx(() {
                        return Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /*(controller.callStatus.contains(CallStatus.reconnecting) || controller.callStatus.contains(CallStatus.ringing)) && controller.layoutSwitch.value
                                    ? const Text(
                                        "${CallStatus.reconnecting}...",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : controller.callStatus.contains(CallStatus.onHold) && controller.layoutSwitch.value
                                        ? const Text(
                                            CallStatus.onHold,
                                            style: TextStyle(color: Colors.white),
                                          ):  const SizedBox.shrink(),*/
                                if (controller.callList.length > 1 &&
                                    getTileCallStatus(
                                            controller.callList
                                                .firstWhere((y) => y.userJid!.value == controller.pinnedUserJid.value)
                                                .callStatus
                                                ?.value,
                                            controller.pinnedUserJid.value.checkNull(),
                                            controller.isOneToOneCall)
                                        .isNotEmpty &&
                                    controller.layoutSwitch.value) ...[
                                  Text(
                                    getTileCallStatus(
                                        controller.callList
                                            .firstWhere((y) => y.userJid!.value == controller.pinnedUserJid.value)
                                            .callStatus
                                            ?.value,
                                        controller.pinnedUserJid.value.checkNull(),
                                        controller.isOneToOneCall),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  )
                                ],
                                if (controller.callList.length > 1 &&
                                    controller.callList
                                        .firstWhere((y) => y.userJid!.value == controller.pinnedUserJid.value)
                                        .isAudioMuted
                                        .value &&
                                    controller.layoutSwitch.value) ...[
                                  CircleAvatar(
                                    backgroundColor: AppColors.audioMutedIconBgColor,
                                    child: SvgPicture.asset(callMutedIcon),
                                  )
                                ],
                              ],
                            ));
                      }),
                    ],
                  )),
              Column(
                children: [
                  Obx(() {
                    return AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: SizedBox(
                        height: controller.isVisible.value ? 60 : 0.0,
                      ),
                    );
                  }),
                  Obx(() {
                    return !controller.layoutSwitch.value
                        ? Expanded(child: buildGridItem(controller))
                        : const SizedBox.shrink();
                  }),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    return (controller.callList.length >= 2)
                        ? Align(
                            alignment: Alignment.bottomRight,
                            child: controller.layoutSwitch.value ? buildListItem(controller) : const SizedBox.shrink(),
                          )
                        : const SizedBox.shrink();
                  }),
                  const SizedBox(
                    height: 15,
                  ),
                  Obx(() {
                    return AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: SizedBox(
                        height: controller.isVisible.value ? 135 : 0.0,
                      ),
                    );
                  })
                ],
              ),
              Obx(() {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  bottom: controller.isVisible.value ? 0.0 : -140,
                  left: 0.0,
                  right: 0.0,
                  child: buildCallOptions(),
                );
              }),
              Obx(() {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  top: controller.isVisible.value ? null : -72,
                  left: 0.0,
                  right: 0.0,
                  height: 72,
                  child: buildToolbar(context),
                );
              }),
              Positioned(
                left: 0,
                top: 0,
                child: IconButton(
                  splashRadius: 24,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildToolbar(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder(
                  future: controller.groupId.isEmpty
                      ? CallUtils.getCallersName(
                          List<String>.from(controller.callList
                              .where((p0) => p0.userJid != null && SessionManagement.getUserJID() != p0.userJid!.value)
                              .map((e) => e.userJid!.value)),
                          true)
                      : CallUtils.getNameOfJid(controller.groupId.value),
                  builder: (ctx, data) {
                    return data.data.checkNull().isEmpty ? const SizedBox.shrink() : SizedBox(
                      width: 200,
                      child: Text(
                        data.data.checkNull(),
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            IconButton(
              splashRadius: 24,
              onPressed: () {
                controller.openParticipantScreen();
              },
              icon: SvgPicture.asset(addUserCall),
            ),
            IconButton(
              splashRadius: 24,
              onPressed: () {
                controller.changeLayout();
              },
              icon: SvgPicture.asset(
                gridIcon,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            )
          ],
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
              if((controller.callType.value == CallType.video || controller.isGroupCall) && !controller.videoMuted.value)...[
                  FloatingActionButton(
                      heroTag: "switchCamera",
                      elevation: 0,
                      backgroundColor: controller.cameraSwitch.value ? Colors.white : Colors.white.withOpacity(0.3),
                      onPressed: () => controller.switchCamera(),
                      child: controller.cameraSwitch.value
                          ? SvgPicture.asset(cameraSwitchActive)
                          : SvgPicture.asset(cameraSwitchInactive),
                    ),
                SizedBox(width: rightSideWidth)
              ],
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
                backgroundColor: controller.audioOutputType.value == AudioDeviceType.receiver
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
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    maximumSize: const Size(200, 50),
                    shape: const StadiumBorder(),
                    backgroundColor: AppColors.endButton),
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
