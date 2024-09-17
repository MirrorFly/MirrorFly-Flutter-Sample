import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_style_config.dart';
import '../../call_modules/call_utils.dart';
import '../../call_modules/call_widgets.dart';
import '../../call_modules/outgoing_call/call_controller.dart';
import '../../extensions/extensions.dart';
import '../../stylesheet/stylesheet.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../common/constants.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';

class OnGoingCallView extends NavViewStateful<CallController> {
  const OnGoingCallView({super.key});

  @override
CallController createController({String? tag}) => Get.put(CallController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
      },
      child: Container(
        decoration: AppStyleConfig.ongoingCallPageStyle.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,//AppColors.callBg,
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
                                  viewBgColor: AppStyleConfig.ongoingCallPageStyle.pinnedCallUserTileStyle.backgroundColor,//AppColors.audioCallerBackground,
                                  profileSize: AppStyleConfig.ongoingCallPageStyle.pinnedCallUserTileStyle.profileImageSize,
                                  onClick: () {
                                    // if(controller.callType.value==CallType.video) {
                                    controller.isVisible(!controller.isVisible.value);
                                    // }
                                  },
                                ).setBorderRadius(AppStyleConfig.ongoingCallPageStyle.pinnedCallUserTileStyle.borderRadius)
                              : const Offstage();
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
                                            ):  const Offstage(),*/
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
                                      style: AppStyleConfig.ongoingCallPageStyle.pinnedCallUserTileStyle.callStatusTextStyle,
                                      // style: const TextStyle(color: Colors.white),
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
                                      backgroundColor: AppStyleConfig.ongoingCallPageStyle.pinnedCallUserTileStyle.muteActionStyle.activeBgColor,//AppColors.audioMutedIconBgColor,
                                      child: AppUtils.svgIcon(icon:callMutedIcon,colorFilter: ColorFilter.mode(AppStyleConfig.ongoingCallPageStyle.pinnedCallUserTileStyle.muteActionStyle.activeIconColor, BlendMode.srcIn),),
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
                          ? Expanded(child: buildGridItem(controller,AppStyleConfig.ongoingCallPageStyle.gridCallUserTileStyle))
                          : const Offstage();
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
                              child: controller.layoutSwitch.value ? buildListItem(controller,AppStyleConfig.ongoingCallPageStyle.listCallUserTileStyle) : const Offstage(),
                            )
                          : const Offstage();
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
                    child: buildCallOptions(AppStyleConfig.ongoingCallPageStyle.actionButtonsStyle),
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
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppStyleConfig.ongoingCallPageStyle.actionIconColor,
                    ),
                  ),
                ),
              ],
            ),
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
                    return data.data.checkNull().isEmpty ? const Offstage() : SizedBox(
                      width: 200,
                      child: Text(
                        data.data.checkNull(),
                        style: AppStyleConfig.ongoingCallPageStyle.callerNameTextStyle,
                        /*style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.0,
                        ),*/
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
              const SizedBox(
                height: 8,
              ),
              Obx(() {
                return Visibility(
                  visible: !controller.joinViaLink,
                  child: Text(
                    controller.callTimer.value,
                    style: AppStyleConfig.ongoingCallPageStyle.callDurationTextStyle,
                    /*style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.0,
                    ),*/
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
              icon: AppUtils.svgIcon(icon:addUserCall,colorFilter: ColorFilter.mode(AppStyleConfig.ongoingCallPageStyle.actionIconColor, BlendMode.srcIn),),
            ),
            IconButton(
              splashRadius: 24,
              onPressed: () {
                controller.changeLayout();
              },
              icon: AppUtils.svgIcon(icon:
                gridIcon,
                colorFilter: ColorFilter.mode(AppStyleConfig.ongoingCallPageStyle.actionIconColor, BlendMode.srcIn),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget buildCallOptions(ActionButtonStyle style) {
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
              child: AppUtils.svgIcon(icon:
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
                shape: style.shape,
                backgroundColor: controller.muted.value ? style.activeBgColor : style.inactiveBgColor,//Colors.white.withOpacity(0.3),
                onPressed: () => controller.muteAudio(),
                child: controller.muted.value
                    ? AppUtils.svgIcon(icon:
                        muteActive,
                  colorFilter: ColorFilter.mode(style.activeIconColor, BlendMode.srcIn),
                      )
                    : AppUtils.svgIcon(icon:
                        muteInactive,
                  colorFilter: ColorFilter.mode(style.inactiveIconColor, BlendMode.srcIn),
                      ),
              ),
              SizedBox(width: rightSideWidth),
              if((controller.callType.value == CallType.video || controller.isGroupCall || controller.joinViaLink) && !controller.videoMuted.value)...[
                  FloatingActionButton(
                      heroTag: "switchCamera",
                      elevation: 0,
                      shape: style.shape,
                      backgroundColor: controller.cameraSwitch.value ? style.activeBgColor : style.inactiveBgColor,//Colors.white : Colors.white.withOpacity(0.3),
                      onPressed: () => controller.switchCamera(),
                      child: controller.cameraSwitch.value
                          ? AppUtils.svgIcon(icon:cameraSwitchActive,colorFilter: ColorFilter.mode(style.activeIconColor, BlendMode.srcIn),)
                          : AppUtils.svgIcon(icon:cameraSwitchInactive,colorFilter: ColorFilter.mode(style.inactiveIconColor, BlendMode.srcIn),),
                    ),
                SizedBox(width: rightSideWidth)
              ],
              FloatingActionButton(
                heroTag: "videoMute",
                elevation: 0,
                shape: style.shape,
                backgroundColor: controller.videoMuted.value ? style.activeBgColor : style.inactiveBgColor,//Colors.white : Colors.white.withOpacity(0.3),
                onPressed: () => controller.videoMute(),
                child: controller.videoMuted.value
                    ? AppUtils.svgIcon(icon:videoInactive,colorFilter: ColorFilter.mode(style.activeIconColor, BlendMode.srcIn),)
                    : AppUtils.svgIcon(icon:videoActive,colorFilter: ColorFilter.mode(style.inactiveIconColor, BlendMode.srcIn),),
              ),
              SizedBox(
                width: rightSideWidth,
              ),
              FloatingActionButton(
                heroTag: "speaker",
                elevation: 0,
                shape: style.shape,
                backgroundColor: controller.audioOutputType.value == AudioDeviceType.receiver
                    ? style.inactiveBgColor//Colors.white.withOpacity(0.3)
                    : style.activeBgColor,//Colors.white,
                onPressed: () => controller.changeSpeaker(),
                child: controller.audioOutputType.value == AudioDeviceType.receiver
                    ? AppUtils.svgIcon(icon:speakerInactive,colorFilter: ColorFilter.mode(style.inactiveIconColor, BlendMode.srcIn),)
                    : controller.audioOutputType.value == AudioDeviceType.speaker
                        ? AppUtils.svgIcon(icon:speakerActive,colorFilter: ColorFilter.mode(style.activeIconColor, BlendMode.srcIn))
                        : controller.audioOutputType.value == AudioDeviceType.bluetooth
                            ? AppUtils.svgIcon(icon:speakerBluetooth,colorFilter: ColorFilter.mode(style.activeIconColor, BlendMode.srcIn))
                            : controller.audioOutputType.value == AudioDeviceType.headset
                                ? AppUtils.svgIcon(icon:speakerHeadset,colorFilter: ColorFilter.mode(style.activeIconColor, BlendMode.srcIn))
                                : AppUtils.svgIcon(icon:speakerActive,colorFilter: ColorFilter.mode(style.activeIconColor, BlendMode.srcIn)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
            child: ElevatedButton(
                style: AppStyleConfig.ongoingCallPageStyle.disconnectButtonStyle,
                onPressed: () {
                  controller.disconnectCall();
                },
                child: AppUtils.svgIcon(icon:
                  callEndButton,
                )),
          ),
          // )
        ],
      );
    });
  }
}
