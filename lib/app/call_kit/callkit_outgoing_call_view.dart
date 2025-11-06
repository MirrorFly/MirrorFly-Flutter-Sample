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
              ? groupCallUI(context)
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            controller.remoteUserName.value,
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

  /// Group Call View
  Widget groupCallUI(BuildContext context) {
    debugPrint("#CallKitOutGoingCallView Group Call UI Build Called");
    return Stack(
        fit: StackFit.expand, children: [
      /// Main view
      Obx(() {
        final participants = controller.callerList;
        return controller.chatNameForGroupCall.value.isNotEmpty
            ? Stack(
                  alignment: Alignment.center,
                children: [
                  controller.isGroupOnGoingCallEnabled.value
                      /// Group call is ongoing with participants joined
                      ? GridView.builder(
                          padding: const EdgeInsets.only(
                              top: 150, left: 16, right: 16, bottom: 80),
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: participants.length <= 2
                                ? 1
                                : participants.length <= 4
                                    ? 2
                                    : 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: participants.length,
                          itemBuilder: (context, index) {
                            final participant = participants[index];
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Stack(
                                  children: [
                                    MirrorFlyCallView(
                                      key: ValueKey(participant.identity),
                                      userJID: participant.identity,
                                      fit: BoxFit.cover,
                                      viewBgColor:
                                          AppColors.audioCallerBackground,
                                      profileImage: getUserProfileImageWithName(
                                        participantId: participant.identity,
                                        scale: 1.2,
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          controller
                                              .getParticipantConnectionState(
                                                  participants[index]
                                                      .flyCallStatusEvent!),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 4,
                                                color: Colors.black87,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  right: 8,
                                  child: Text(
                                    controller.remoteUserNameMap[
                                            participant.identity] ??
                                        participant.identity ??
                                        '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4,
                                          color: Colors.black87,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      /// Group call is in ringing state non of the participant joined
                      : MirrorFlyCallView(
                          key: ValueKey(controller.groupId.value),
                          userJID: controller.groupId.value,
                          fit: BoxFit.cover,
                          viewBgColor: AppColors.audioCallerBackground,
                          profileImage: getUserProfileImageWithName(
                            isGroup: true,
                            participantId: controller.groupId.value,
                            scale: 1,
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
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        "${controller.chatNameForGroupCall.value} \n ${controller.groupCallTitle.value}",
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
                        controller.chatNameForGroupCall.value,
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
    ]);
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

  Widget getUserProfileImageWithName({
    required String participantId,
    bool? isGroup = false,
    double scale = 1.0,
  }) {
    debugPrint("[getUserProfileImageWithName] Called with participantId: $participantId");
    participantId = isGroup == true ? participantId  : "$participantId@xmpp-uikit-qa.contus.us";
    return FutureBuilder<ProfileDetails>(
      future: isGroup == true ? getGroupProfileDetails(participantId) : getProfileDetails(participantId),
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
          final bool isLocalView = participantId == SessionManagement.getUserJID();
          debugPrint("[getUserProfileImageWithName] 👤 Profile Image Loaded for ${snap.data!.name}, isLocalView: $isLocalView");

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildProfileImage(
                snap.data!,
                size: AppStyleConfig.outgoingCallPageStyle.profileImageSize.width / scale,
              ),
              Obx(() {
                final isYou = controller.isOnGoingCallViewEnable.value &&
                    controller.localParticipantId.value == participantId;
                if (isYou) {
                  debugPrint("[getUserProfileImageWithName] This is YOU ($participantId)");
                }
                return isYou
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