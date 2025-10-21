import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../app_style_config.dart';
import '../call_modules/audio_level_animation.dart';
import '../call_modules/call_widgets.dart';
import '../common/constants.dart';
import '../data/helper.dart';
import '../data/session_management.dart';
import '../data/utils.dart';
import '../extensions/extensions.dart';
import 'callkit_outgoing_call_controller.dart';

class CallKitOutgoingCallView
    extends NavViewStateful<CallKitOutgoingCallController> {
  const CallKitOutgoingCallView({Key? key}) : super(key: key);

  @override
  CallKitOutgoingCallController createController({String? tag}) =>
      Get.put(CallKitOutgoingCallController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: controller.toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [

            /// Main view
            Obx(() {
              return controller.mainCallViewUserId.value.isNotEmpty
                  ? Stack(
                alignment: Alignment.center,
                children: [
                  Stack(
                    children: [
                      MirrorFlyCallView(
                        key: ValueKey(controller.mainCallViewUserId.value),
                        userJID: controller.mainCallViewUserId.value,
                        fit: BoxFit.cover,
                        viewBgColor: AppColors.audioCallerBackground,
                        profileImage: getUserProfileImageWithName(
                          participantId: controller.mainCallViewUserId.value,
                          scale: 1,
                        ),
                      ),

                      // Reconnecting overlay widget
                      Visibility(
                        visible: controller.isRemoteUserReconnecting.value,
                        child: Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.4), // semi-transparent dark shade
                            child: const Center(
                              child: Text(
                                'Reconnecting...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  if (controller.isRemoteAudioMuted.value)
                    Center(
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.mic_off_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              )
                  : const Offstage();
            }),

            /// Gradient overlay
            Obx(() => _buildGradientOverlay(controller.callType.value)),
            /// Foreground content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 40),

                  /// Call Status
                  Obx(() {
                    final isOngoing = controller.isOnGoingCallViewEnable.value;

                    return Column(
                      children: [
                        if (!isOngoing) ...[
                          Center(
                            child: Text(
                              controller.callStatus.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              controller.remoteUserName.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        if (isOngoing) ...[
                          Center(
                            child: Text(
                              controller.remoteUserName.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              controller.callDuration.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),

                  const Spacer(),

                  _buildControls(context),

                ],
              ),
            ),

            /// Local Preview / Profile Image
            Obx(() {
              if (!controller.isOnGoingCallViewEnable.value) {
                return const SizedBox.shrink();
              }
              final screenSize = MediaQuery
                  .of(context)
                  .size;
              final previewWidth = (screenSize.width * 0.25).clamp(80.0, 140.0);
              final previewHeight = previewWidth *
                  1.3; // maintain 4:3-ish aspect ratio
              final bottomOffset = controller.showControls.value
                  ? screenSize.height * 0.28
                  : screenSize.height * 0.14;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: bottomOffset,
                right: screenSize.width * 0.05,
                child: _buildLocalPreview(
                  width: previewWidth,
                  height: previewHeight,
                ),
              );
            })

          ],
        ),
      ),
    );
  }

  Widget _buildLocalPreview({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // better than circle for video
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 8,
            color: Colors.black26,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Stack(
            children: [
              MirrorFlyCallView(
                viewBgColor: AppColors.callerBackground,
                key: ValueKey(controller.secondaryCallViewUserId.value),
                userJID: controller.secondaryCallViewUserId.value,
                fit: BoxFit.cover,
                profileImage: getUserProfileImageWithName(
                  participantId: controller.secondaryCallViewUserId.value,
                  scale: 2,
                ),
              ),

              // Reconnecting overlay widget
              Visibility(
               visible: controller.isLocalUserReconnecting.value,
                child: Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4), // semi-transparent dark shade
                    child: const Center(
                      child: Text(
                        'Reconnecting...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),

          Obx(() {
            return controller.muted.value ? Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.mic_off_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ) : const Offstage();
          }),
        ],
      ),
    );
  }


  ///  Controls wrapper
  Widget _buildControls(BuildContext context) {
    return Obx(() {
      return AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        offset:
        controller.showControls.value ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: controller.showControls.value ? 1 : 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCallControls(context), // mute / video / switch
              _buildEndCallButton(), // red disconnect
            ],
          ),
        ),
      );
    });
  }

  Widget getUserProfileImageWithName(
      {required String participantId, double scale = 1.0}) {
    return FutureBuilder<ProfileDetails>(
      future: getProfileDetails(participantId),
      builder: (ctx, snap) {
        if (snap.hasData && snap.data != null) {
          final bool isLocalView =
              participantId == SessionManagement.getUserJID();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildProfileImage(
                snap.data!,
                size: AppStyleConfig
                    .outgoingCallPageStyle.profileImageSize.width /
                    scale,
              ),
              Obx(() {
                return controller.isOnGoingCallViewEnable.value &&
                    controller.localParticipantId.value == participantId
                    ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "You",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
                    : const SizedBox.shrink();
              }),
            ],
          );
        }
        return const Offstage();
      },
    );
  }

  ///  Gradient Overlay
  Widget _buildGradientOverlay(String callType) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: callType == "video"
              ? [
            Colors.transparent,
            Colors.transparent,
          ]
              : [
            const Color(0xFF1D1D35),
            Colors.transparent,
            Colors.transparent,
            const Color(0xFF1D1D35),
          ],
          stops: callType == "video"
              ? [0, 1] // fully transparent
              : [0, 0.2, 0.6, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  ///  Call Control Buttons
  Widget _buildCallControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: Obx(() =>
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCallOption(
                isActive: controller.selectedDevice.value,
                icon: Icons.volume_up,
                onTap: () async {
                  controller.changeAudioDevice();
                },
              ),
              _buildCallOption(
                isActive: controller.muted.value,
                icon: controller.muted.value ? Icons.mic_off : Icons.mic,
                onTap: controller.muteAudio,
              ),
              if (controller.callType.value.toLowerCase() == CallType.video)
                _buildCallOption(
                  isActive: true,
                  icon: !controller.isVideoEnabled.value
                      ? Icons.videocam_off
                      : Icons.videocam,
                  onTap: () {
                    controller.setCameraEnable(
                        enable: !(controller.isVideoEnabled.value));
                  },
                ),
              if (controller.callType.value.toLowerCase() == CallType.video)
                _buildCallOption(
                  isActive: false,
                  icon: controller.cameraPosition.value == CameraType.front
                      ? Icons.cameraswitch
                      : Icons.flip_camera_android,
                  onTap: controller.switchCamera,
                ),
              if (controller.callType.value.toLowerCase() == CallType.audio)
                _buildCallOption(
                  isActive: true,
                  icon: Icons.videocam_off,
                  onTap: controller.requestVideoCallSwitch,
                ),
            ],
          )),
    );
  }

  ///  End Call Button
  Widget _buildEndCallButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
      child: ElevatedButton(
          style: AppStyleConfig.ongoingCallPageStyle.disconnectButtonStyle,
          onPressed: () {
            controller.localHangup();
          },
          child: AppUtils.svgIcon(
            icon: callEndButton,
          )),
    );
  }

  ///  Call Option Button
  Widget _buildCallOption({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white10,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: isActive ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}

/*
Widget buildGridItem(CallController controller, CallUserTileStyle style) {
  return GestureDetector(
    onTap: () {
      if (controller.callType.value == CallType.video) {
        controller.isVisible(!controller.isVisible.value);
      }
    },
    child: GridView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: controller.callList.length > 2
              ? 2
              : 1, // number of items in each row
          mainAxisSpacing: 4.0, // spacing between rows
          crossAxisSpacing: 2.0, // spacing between columns
          childAspectRatio: controller.callList.length == 2 ? 1.23 : 1.0),
      padding: const EdgeInsets.all(8.0),
      // padding around the grid
      itemCount: controller.callList.length,
      // total number of items
      itemBuilder: (context, index) {
        return Stack(
          children: [
            MirrorFlyView(
                key: UniqueKey(),
                userJid: controller.callList[index].userJid?.value ?? "",
                viewBgColor:
                style.backgroundColor, //AppColors.callerTitleBackground,
                profileSize: style.profileImageSize,
                // mirror: controller.callList[index].userJid?.value == SessionManagement.getUserJID(),
                onClick: () {
                  // if(controller.callType.value==CallType.video) {
                  controller.isVisible(!controller.isVisible.value);
                  // }
                }).setBorderRadius(style.borderRadius),
            Obx(() {
              return Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (controller.callList[index].isAudioMuted.value) ...[
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: style.muteActionStyle
                            .activeBgColor, //AppColors.audioMutedIconBgColor,
                        child: AppUtils.svgIcon(
                          icon: callMutedIcon,
                          colorFilter: ColorFilter.mode(
                              style.muteActionStyle.activeIconColor,
                              BlendMode.srcIn),
                        ),
                      ),
                    ],
                    if (controller.speakingUsers.isNotEmpty &&
                        !controller.callList[index].isAudioMuted.value &&
                        !controller
                            .audioLevel(
                            controller.callList[index].userJid!.value)
                            .isNegative) ...[
                      AudioLevelAnimation(
                        radius: 12,
                        audioLevel: controller.audioLevel(
                            controller.callList[index].userJid!.value),
                        bgColor: style.speakingIndicatorStyle
                            .activeBgColor, //AppColors.speakingBg,
                        dotsColor: style.speakingIndicatorStyle.activeIconColor,
                      ),
                    ],
                  ],
                ),
              );
            }),
            Positioned(
              left: 8,
              bottom: 8,
              right: 8,
              child: Obx(() {
                // debugPrint("name changed ${controller.callList[index].userJid}");
                return FutureBuilder<String>(
                    future: CallUtils.getNameOfJid(
                        controller.callList[index].userJid!.value.checkNull()),
                    builder: (context, snapshot) {
                      if (!snapshot.hasError &&
                          snapshot.data.checkNull().isNotEmpty) {
                        return Text(
                          snapshot.data.checkNull(),
                          style: style.nameTextStyle,
                          */
/*style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),*//*

                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }
                      return const Offstage();
                    });
              }),
            ),
            Obx(() {
              debugPrint(
                  "getUserJID ${controller.callList[index].userJid} ${controller.callList[index].callStatus} current user ${controller.callList[index].userJid!.value == SessionManagement.getUserJID()}");
              return (getTileCallStatus(
                  controller.callList[index].callStatus?.value,
                  controller.callList[index].userJid!.value.checkNull(),
                  controller.isOneToOneCall)
                  .isNotEmpty)
                  ? Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(
                        0.5), // Adjust the color and opacity as needed
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                      child: Text(
                        getTileCallStatus(
                            controller.callList[index].callStatus?.value,
                            controller.callList[index].userJid!.value
                                .checkNull(),
                            controller.isOneToOneCall),
                        style: style.callStatusTextStyle,
                        // style: const TextStyle(color: Colors.white),
                      )),
                ),
              )
                  : const Offstage();
            }),
          ],
        );
      },
    ),
  );
}
*/

// void _showAudioDeviceSelector(
//     BuildContext context, CallKitOutgoingCallController controller) async {
//   final availableTypes = await controller.getAvailableTypes();
//
//   await showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (_) => Center(
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           width: 250,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: availableTypes.map((type) {
//               return ListTile(
//                 leading: Icon(
//                   type == FlyCallAudioDeviceType.speaker
//                       ? Icons.speaker_phone
//                       :  Icons.phone_android
//                 ),
//                 title: Text(type.name.capitalize!),
//                 trailing: controller.selectedDevice.value == type.value
//                     ? const Icon(Icons.check, color: Colors.green)
//                     : null,
//                 onTap: () {
//                   controller.changeAudioDevice(type.value);
//                   Navigator.of(context).pop(); // close dialog
//                 },
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     ),
//   );
// }
//
// IconData _getCurrentAudioIcon(String? type) {
//   if (type == FlyCallAudioDeviceType.speaker.value) {
//     return Icons.volume_up;
//   } else if (type == FlyCallAudioDeviceType.earpiece.value) {
//     return Icons.hearing;
//   } else {
//     return Icons.hearing;
//   }
//   // switch (type) {
//   //   case FlyCallAudioDeviceType.speaker:
//   //     return Icons.volume_up;
//   //   case FlyCallAudioDeviceType.earpiece:
//   //     return Icons.hearing;
//   //   case FlyCallAudioDeviceType.bluetooth:
//   //     return Icons.bluetooth_audio;
//   //   case FlyCallAudioDeviceType.wired:
//   //     return Icons.headset;
//   //   default:
//   //     return Icons.volume_up;
// }
