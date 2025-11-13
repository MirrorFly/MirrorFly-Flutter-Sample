import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:path/path.dart';
import '../app_style_config.dart';
import '../call_modules/call_widgets.dart';
import '../common/constants.dart';
import '../data/helper.dart';
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
    return Obx(() {
      debugPrint(
          "#CallKitOutGoingCallView Build Called, isGroupCall: ${controller.isGroupCall.value}");
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: controller.toggleControls,
          child: controller.isGroupCall.value
              ? buildGroupGridItem(context)
              : oneToOneCallUI(context),
        ),
      );
    });
  }

  /// One-to-One Call View
  Widget oneToOneCallUI(BuildContext context) {
    debugPrint("#CallKitOutGoingCallView One-One Call UI Build Called");

    return Stack(
      fit: StackFit.expand,
      children: [
        /// Main view
        Obx(() {
          return controller.callerList.isNotEmpty
              ? Stack(
            alignment: Alignment.center,
            children: [
              Stack(
                children: [
                  MirrorFlyCallView(
                    key: ValueKey(controller.getRemoteParticipantsId().first),
                    userJID: controller.getRemoteParticipantsId().first,
                    fit: BoxFit.cover,
                    viewBgColor: AppColors.audioCallerBackground,
                    profileImage: getUserProfileImageWithName(
                      participantId: controller.getRemoteParticipantsId().first,
                      scale: 1,
                    ),
                  ),

                  // Reconnecting overlay widget
                  Visibility(
                          visible: controller.callerList
                                  .firstWhere((e) =>
                                      e.identity ==
                                      controller
                                          .getRemoteParticipantIdForOneToOneCall())
                                  .isReconnecting ??
                              false,
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

              /// Mute Icon
              buildMuteIcon(controller.getRemoteParticipantsId().first)
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            controller.getOneToOneCallRemoteUserName(),
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                    if (isOngoing) ...[
                      Center(
                        child: Text(
                          controller.getOneToOneCallRemoteUserName(),
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

        /// Invite Participants Button
        Obx(() {
          final showInviteButton = controller.isOnGoingCallViewEnable.value &&
              controller.callMode.value == "ONE-TO-ONE";
          return Visibility(
            visible: showInviteButton,
            child: Positioned(
              top: 66,
              right: 16,
              child: IconButton(
                onPressed: () => controller.inviteParticipants(),
                icon: const Icon(Icons.add_call, color: Colors.white),
              ),
            ),
          );
        }),

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
    );
  }

  Widget buildMuteIcon(String? participantId) {

    debugPrint("[buildMuteIcon] Called for participantId: $participantId");

    if (participantId == null || participantId.isEmpty) {
      debugPrint("[buildMuteIcon] participantId is null or empty");
      return const SizedBox.shrink();
    }

    final FlyCallParticipant participant = controller.callerList.firstWhere((e) => e.identity == participantId);
    debugPrint("[buildMuteIcon] Participant found: ${participant.identity}, isMuted: ${participant.isAudioMuted}");
    if (participant.isAudioMuted == true) {
      return Center(
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
      );
    }
    return const SizedBox.shrink();
  }

  /// Grid view for group call participants
  Widget buildGroupGridItem(BuildContext context) {
    return Obx(() {
      final isGroupCall = controller.isGroupOnGoingCallEnabled.value;
      return Container(
        color: const Color(0xFF1D1D35),
        child: Stack(
          children: [
            _buildGradientOverlay(controller.callType.value),

            SafeArea(
              child: Column(
                children: [
                  /// --- Call Info Header (Top Section) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical:  12),
                    child: Obx(() {
                      final isOngoing = controller.isOnGoingCallViewEnable.value;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: MediaQuery.of(context).size.width / 6),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isOngoing) ...[
                                Text(
                                  controller.isCallModeChangedToOneToMany.value
                                      ? controller.titleAfterCallModeChange.value
                                      : controller.chatNameForGroupCall.value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  controller.callDuration.value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Obx(() {
                              final showInviteButton = controller.isOnGoingCallViewEnable.value;
                              return Visibility(
                                visible: showInviteButton,
                                child: IconButton(
                                  onPressed: () => controller.inviteParticipants(),
                                  icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    }),
                  ),


                  /// --- Grid or Single View (Takes remaining space) ---
                  Expanded(
                    child: Stack(

                      children: [
                        isGroupCall
                            ? GridView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                            controller.callerList.length > 2 ? 2 : 1,
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 2.0,
                            childAspectRatio:
                            controller.callerList.length == 2 ? 1.23 : 1.0,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          itemCount: controller.callerList.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                MirrorFlyCallView(
                                  key: ValueKey(controller.callerList[index].identity),
                                  userJID: controller
                                      .callerList[index].identity ??
                                      "",
                                  fit: BoxFit.cover,
                                  viewBgColor:
                                  AppColors.audioCallerBackground,
                                  profileImage: getUserProfileImageWithName(
                                    participantId: controller
                                        .callerList[index].identity,
                                    scale: 1.2,
                                  ),
                                ),
                                Obx(() {
                                  return Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if (controller.callerList[index].isAudioMuted == true) ...[
                                          CircleAvatar(
                                            radius: 10,
                                            backgroundColor: Colors.grey
                                                , //AppColors.audioMutedIconBgColor,
                                            child: AppUtils.svgIcon(
                                              icon: callMutedIcon,
                                              colorFilter: const ColorFilter.mode(
                                                  Colors.white,
                                                  BlendMode.srcIn),
                                            ),
                                          ),
                                        ],
                                        // if (controller.speakingUsers.isNotEmpty &&
                                        //     !controller.callList[index].isAudioMuted.value &&
                                        //     !controller
                                        //         .audioLevel(
                                        //         controller.callList[index].userJid!.value)
                                        //         .isNegative) ...[
                                        //   AudioLevelAnimation(
                                        //     radius: 12,
                                        //     audioLevel: controller.audioLevel(
                                        //         controller.callList[index].userJid!.value),
                                        //     bgColor: style.speakingIndicatorStyle
                                        //         .activeBgColor, //AppColors.speakingBg,
                                        //     dotsColor: style.speakingIndicatorStyle.activeIconColor,
                                        //   ),
                                        // ],
                                      ],
                                    ),
                                  );
                                }),


                                /// Name label
                                Positioned(
                                  left: 8,
                                  bottom: 8,
                                  right: 8,
                                  child: Obx(() {
                                    final name = controller.remoteUserNameMap[
                                    controller.callerList[index]
                                        .identity] ??
                                        controller
                                            .callerList[index].identity;
                                    return Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }),
                                ),

                                /// Call status overlay
                                Obx(() {
                                  final participant = controller.callerList[index];
                                  final isSelf = controller.isSelfId(id: participant.identity);
                                  final connectionState = controller.getParticipantConnectionState(
                                    participant.flyCallStatusEvent!,
                                  );
                                  debugPrint("[buildGroupGridItem] Participant: ${participant.identity}, isSelf: $isSelf, connectionState: $connectionState");
                                  if (!isSelf && connectionState.isNotEmpty) {
                                    return Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            connectionState,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const Offstage();
                                }),

                              ],
                            );
                          },
                              )
                            : Stack(
                                children: [
                                  MirrorFlyCallView(
                                    key: ValueKey(controller.groupId.value),
                                    userJID: controller.groupId.value,
                                    fit: BoxFit.cover,
                                    viewBgColor:
                                        AppColors.audioCallerBackground,
                                    profileImage: getUserProfileImageWithName(
                                      isGroup: true,
                                      participantId: controller.groupId.value,
                                      scale: 1,
                                    ),
                                  ),
                                  _buildGradientOverlay(
                                      controller.callType.value),
                                  if (!controller
                                      .isOnGoingCallViewEnable.value) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      width: double.infinity,
                                      child: Column(
                                        // mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            controller.callStatus.value,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "${controller.chatNameForGroupCall.value}\n${controller.groupCallTitle.value}",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                        ),

                        /// Gradient overlay

                        /// Controls at bottom
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildControls(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      );
    });
  }




  ///  Local Preview Widget
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
                key: ValueKey(controller.getLocalParticipantId()),
                userJID: controller.getLocalParticipantId(),
                fit: BoxFit.cover,
                profileImage: getUserProfileImageWithName(
                  participantId: controller.getLocalParticipantId(),
                  scale: 2,
                ),
              ),

              // Reconnecting overlay widget
              Visibility(
                visible: controller.callerList
                        .firstWhere((e) => e.isLocalParticipant == true)
                        .isReconnecting ??
                    false,
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
            return buildMuteIcon(controller.getLocalParticipantId());
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

  Widget getUserProfileImageWithName({
    required String participantId,
    bool? isGroup = false,
    double scale = 1.0,
  }) {
    debugPrint("[getUserProfileImageWithName] Called with participantId: $participantId");
    return FutureBuilder<ProfileDetails>(
      future: isGroup == true ? getGroupProfileDetails(participantId) : getProfileDetails("$participantId@xmpp-uikit-qa.contus.us"),
      builder: (ctx, snap) {
        // Log the state of the FutureBuilder
        if (snap.connectionState == ConnectionState.waiting) {
          debugPrint("[getUserProfileImageWithName] Loading profile for: $participantId");
        } else if (snap.connectionState == ConnectionState.done) {
          if (snap.hasError) {
            debugPrint("[getUserProfileImageWithName] Error loading profile for $participantId → ${snap.error}");
          } else if (!snap.hasData || snap.data == null) {
            debugPrint("[getUserProfileImageWithName]  No data found for participantId: $participantId");
          } else {
            debugPrint("[getUserProfileImageWithName] Profile loaded: ${snap.data!.name} (${snap.data})");
          }
        }

        // When we actually have valid profile data
        if (snap.hasData && snap.data != null) {

          final bool isLocalView = participantId == controller.getLocalParticipantId();
          debugPrint(
              "[getUserProfileImageWithName] Building profile image for participantId: $participantId, getLocalParticipant: ${controller.getLocalParticipantId()}, isLocalView: $isLocalView");

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildProfileImage(
                snap.data!,
                size: AppStyleConfig.outgoingCallPageStyle.profileImageSize.width / scale,
              ),
              Obx(() {

                debugPrint("[getUserProfileImageWithName] Checking if local view for participantId: "
                    "$participantId, controller.isOnGoingCallViewEnable: ${controller.isOnGoingCallViewEnable.value}, "
                    "localParticipantId: ${controller.getLocalParticipantId()}");

                return isLocalView
                    ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: controller.isGroupCall.value ? const SizedBox.shrink() : const Text(
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
    return Positioned.fill(
      child: Container(
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
                isActive: controller.callerList.firstWhereOrNull((e) => e.isLocalParticipant)?.isAudioMuted ?? false,
                icon: controller.callerList.firstWhereOrNull((e) => e.isLocalParticipant)?.isAudioMuted ?? false ? Icons.mic_off : Icons.mic,
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
                  icon: !controller.isVideoEnabled.value
                      ? Icons.videocam_off
                      : Icons.videocam,
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
