import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:path/path.dart';
import '../app_style_config.dart';
import '../call_modules/audio_level_animation.dart';
import '../call_modules/call_widgets.dart';
import '../common/constants.dart';
import '../data/helper.dart';
import '../data/utils.dart';
import '../extensions/extensions.dart';
import 'callkit_logger.dart';
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
    callkitLogger.info("#CallKitOutGoingCallView One-One Call UI Build Called");

    final String remoteTileParticipantId = !controller.isOnGoingCallViewEnable.value &&
        controller.callType.toUpperCase() == "VIDEO"
        ? controller.getLocalParticipantId()
        : controller.getRemoteParticipantsId().firstOrNull ?? "";

    callkitLogger.info("[oneToOneCallUI] remoteTileParticipantId: $remoteTileParticipantId");

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
                          key: ValueKey(remoteTileParticipantId),
                          userJID: remoteTileParticipantId,
                          fit: BoxFit.cover,
                    viewBgColor: AppColors.audioCallerBackground,
                    profileImage: getUserProfileImageWithName(
                      participantId: controller.getRemoteParticipantsId().firstOrNull ?? "",
                      scale: 1,
                    ),
                  ),

                  // Reconnecting overlay widget
                  Visibility(
                          visible: controller.callerList
                                  .firstWhereOrNull((e) =>
                                      e.identity ==
                                      controller
                                          .getRemoteParticipantIdForOneToOneCall())
                                  ?.isReconnecting ??
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
             buildMuteIcon(controller.getRemoteParticipantsId().firstWhereOrNull((id) => id.isNotEmpty) ?? "", radius: 10),

              /// Connection Quality Icon
              Visibility(
                visible: controller.callerConnectionQuality.containsKey(controller.getRemoteParticipantsId().firstWhereOrNull((id) => id.isNotEmpty) ?? ""),
                child: Positioned(
                  left: 30,
                  top: 150,
                  child: getConnectionQualityIcon(
                      controller.callerConnectionQuality[
                        controller.getRemoteParticipantsId().firstOrNull ?? ""] ??
                          FlyConnectionQuality.unknown),
                ),
              ),

              /// Speaking Indicator
              Visibility(
                visible: controller.callerConnectionQuality.containsKey(controller.getRemoteParticipantsId().firstOrNull ?? ""),
                child: Positioned(
                  left: 30,
                  top: 190,
                  child: buildSpeakingIndicatorIcon(controller.getRemoteParticipantsId().firstOrNull ?? ""),
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
                      Visibility(
                        visible: controller.callerList
                                .firstWhereOrNull((e) =>
                                    e.identity ==
                                    controller
                                        .getRemoteParticipantIdForOneToOneCall())
                                ?.flyCallStatusEvent ==
                            FlyCallStatusEvent.callHold,
                        child: const Center(
                          child: Text(
                            "On Hold",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
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
          final showInviteButton = controller.isOnGoingCallViewEnable.value;
          return Visibility(
            visible: showInviteButton,
            child: Positioned(
              top: 66,
              right: 16,
              child: IconButton(
                onPressed: () => controller.inviteParticipants(),
                icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
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

  Widget buildMuteIcon(String? participantId, {bool isLocalParticipant = false, double radius = 8}) {

    callkitLogger.info("[buildMuteIcon] Called for participantId: $participantId");

    if (participantId == null || participantId.isEmpty) {
      callkitLogger.info("[buildMuteIcon] participantId is null or empty");
      return const SizedBox.shrink();
    }

    final FlyCallParticipant? participant = controller.callerList.firstWhereOrNull((e) => e.identity == participantId);
    callkitLogger.info("[buildMuteIcon] Participant found: ${participant?.identity}, isMuted: ${participant?.isAudioMuted}");
    if (participant?.isAudioMuted == true) {
      return  CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey
        , //AppColors.audioMutedIconBgColor,
        child: AppUtils.svgIcon(
          icon: callMutedIcon,
          colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn),
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
              child: Stack(
                children: [
                  Column(
                    children: [
                      /// --- Call Info Header (Top Section) ---
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Obx(() {
                          final isOngoing = controller.isOnGoingCallViewEnable.value;
                          return Column(
                           crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (isOngoing) ...[
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  child: Text(
                                    controller.isCallModeChangedToOneToMany.value
                                        ? controller.titleAfterCallModeChange.value
                                        : controller.chatNameForGroupCall.value,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                Text(
                                  controller.callDuration.value,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
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
                                            if (controller
                                                          .callerList[index]
                                                          .isAudioMuted !=
                                                      true) ...[
                                                    buildSpeakingIndicatorIcon(
                                                        controller
                                                            .callerList[index]
                                                            .identity)
                                                  ]
                                                ],
                                              ),
                                      );
                                    }),

                                          /// Connection Quality Icon
                                    Obx(() {
                                      final String participantId = controller.callerList[index].identity;
                                      return Visibility(
                                        visible: controller.callerConnectionQuality.containsKey(controller.callerList[index].identity),
                                        child: Positioned(
                                            top: 8,
                                            left: 8,
                                            child: getConnectionQualityIcon(controller.callerConnectionQuality[participantId] ??
                                            FlyConnectionQuality.unknown,
                                        )),
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
                                      callkitLogger.info("[buildGroupGridItem] Participant: ${participant.identity}, isSelf: $isSelf, connectionState: $connectionState");
                                      if ((!isSelf && connectionState.isNotEmpty) ||( isSelf && connectionState == "Reconnecting" && connectionState.isNotEmpty)) {
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
                  Positioned(
                    right: 0,
                    child: Padding(
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
      color: Colors.black12,
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
                  useMaxSize: true
                ),
              ),

              // Reconnecting overlay widget
              Visibility(
                visible: controller.callerList
                        .firstWhereOrNull((e) => e.isLocalParticipant == true)
                        ?.isReconnecting ??
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

          // Connection Quality Icon
          Visibility(
            visible: controller.callerConnectionQuality
                .containsKey(controller.getLocalParticipantId()),
            child: Positioned(
              top: 8,
              left: 8,
              child: Obx(() {
                return SizedBox(
                  width: 18,
                  height: 18,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: IconTheme(
                      data: const IconThemeData(size: 12, color: Colors.transparent),
                      child: getConnectionQualityIcon(
                          controller.callerConnectionQuality[
                                  controller.getLocalParticipantId()] ??
                              FlyConnectionQuality.unknown),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Mute Icon
          Positioned(
            top: 8,
            right: 8,
            child: Obx(() {
              return buildMuteIcon(
                controller.getLocalParticipantId(),
                isLocalParticipant: true,
              );
            }),
          ),

          // Speaking indicator
          Positioned(
            top: 8,
            right: 8,
            child: Obx(() {
              return buildSpeakingIndicatorIcon(
                  controller.getLocalParticipantId());
            }),
          ),
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
    bool useMaxSize = false,
  }) {

    if (participantId == "") {
      callkitLogger
          .info("[getUserProfileImageWithName] participantId is empty");
      return const SizedBox();
    }

    callkitLogger.info("[getUserProfileImageWithName] Called with participantId: $participantId");
    return FutureBuilder<ProfileDetails>(
      future: isGroup == true ? getGroupProfileDetails(participantId) : getProfileDetails("$participantId@xmpp-uikit-qa.contus.us"),
      builder: (ctx, snap) {
        // Log the state of the FutureBuilder
        if (snap.connectionState == ConnectionState.waiting) {
          callkitLogger.info("[getUserProfileImageWithName] Loading profile for: $participantId");
        } else if (snap.connectionState == ConnectionState.done) {
          if (snap.hasError) {
            callkitLogger.info("[getUserProfileImageWithName] Error loading profile for $participantId → ${snap.error}");
          } else if (!snap.hasData || snap.data == null) {
            callkitLogger.info("[getUserProfileImageWithName]  No data found for participantId: $participantId");
          } else {
            callkitLogger.info("[getUserProfileImageWithName] Profile loaded: ${snap.data!.name} (${snap.data})");
          }
        }

        // When we actually have valid profile data
        if (snap.hasData && snap.data != null) {

          if(!Get.isRegistered<CallKitOutgoingCallController>()) {
            callkitLogger.info("[getUserProfileImageWithName] CallKitOutgoingCallController is not registered in GetX");
            return const SizedBox.shrink();
          }

          final bool isLocalView = participantId == controller.getLocalParticipantId();
          debugPrint(
              "[getUserProfileImageWithName] Building profile image for participantId: $participantId, getLocalParticipant: ${controller.getLocalParticipantId()}, isLocalView: $isLocalView");

          return Column(
            mainAxisSize: useMaxSize ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SizedBox(height: useMaxSize ? 18 : 0),

              buildProfileImage(
                snap.data!,
                size: AppStyleConfig.outgoingCallPageStyle.profileImageSize.width / scale,
              ),

              Obx(() {

                callkitLogger.info("[getUserProfileImageWithName] Checking if local view for participantId: "
                    "$participantId, controller.isOnGoingCallViewEnable: ${controller.isOnGoingCallViewEnable.value}, "
                    "localParticipantId: ${controller.getLocalParticipantId()}");

                return isLocalView
                    ? Padding(
                     padding: const EdgeInsets.only(top: 14, left: 8),
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
              if (controller.callType.value.toLowerCase() == CallType.video && controller.isVideoEnabled.value)
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

  /// Speaking indicator icon
  Widget buildSpeakingIndicatorIcon(String? participantId) {
    callkitLogger.info("[buildSpeakingIndicatorIcon] Called for participantId: $participantId");

    if (participantId == null || participantId.isEmpty) {
      callkitLogger.info("[buildSpeakingIndicatorIcon] participantId is null or empty");
      return const SizedBox.shrink();
    }

    return AudioLevelAnimation(
      radius: 12,
      audioLevel: controller.getAudioLevelForParticipant(participantId),
      bgColor: Colors.blue,
      dotsColor: Colors.white,
      useLiveKitAudio: true,
    );
  }

  /// Get connection quality icon
  Icon getConnectionQualityIcon(FlyConnectionQuality quality) {
    switch (quality) {
      case FlyConnectionQuality.unknown:
        callkitLogger.info("[getConnectionQualityIcon] Connection quality is unknown");
        return const Icon(Icons.signal_cellular_connected_no_internet_0_bar, color: Colors.grey);

      case FlyConnectionQuality.poor:
        callkitLogger.info("[getConnectionQualityIcon] Connection quality is poor");
        return const Icon(Icons.signal_cellular_alt_2_bar, color: Colors.red);

      case FlyConnectionQuality.good:
        callkitLogger.info("[getConnectionQualityIcon] Connection quality is good");
        return const Icon(Icons.signal_cellular_alt, color: Colors.orange);

      case FlyConnectionQuality.excellent:
        callkitLogger.info("[getConnectionQualityIcon] Connection quality is excellent");
        // for excellent, returning transparent icon to hide it
        return const Icon(Icons.signal_cellular_alt, size: 0, color: Colors.transparent);

      case FlyConnectionQuality.lost:
        callkitLogger.info("[getConnectionQualityIcon] Connection quality is lost");
        return const Icon(Icons.signal_cellular_connected_no_internet_0_bar,
            color: Colors.red);
    }
  }
}
