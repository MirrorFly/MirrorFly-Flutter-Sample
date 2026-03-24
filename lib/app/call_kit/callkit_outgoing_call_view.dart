import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../app_style_config.dart';
import '../call_modules/audio_level_animation.dart';
import '../call_modules/call_widgets.dart';
import '../common/constants.dart';
import '../common/widgets.dart';
import '../data/helper.dart';
import '../data/utils.dart';
import '../extensions/extensions.dart';
import '../routes/route_settings.dart';
import '../stylesheet/stylesheet.dart';
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
      debugPrint("#CallKitOutGoingCallView Build Called, isGroupCall");
      return PopScope(
        canPop: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: ColoredBox(
              color: AppColors.audioCallerBackground,
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: controller.toggleControls,
                  child: Stack(
                    children: [

                      /// Call UI (background)
                      controller.callerList.length >= 3
                          ? groupCallUI(context)
                          : oneToOneCallUI(context),

                    ],
                  )
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget mfCallViewRendering({required String participantId,
    double profileImageSize = 105,
    bool isMainView = false,
    double borderRadius = 15,
    Alignment profileImageAlignment = Alignment.center}) {
    bool isGroupCall = controller.groupId.value.isNotEmpty;
    return Obx(() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          alignment: Alignment.center,
          children: [
            MirrorFlyCallView(
              // key: UniqueKey(),
              viewBgColor: isMainView ? const Color(0xFF0D2852) : const Color(
                  0xFF1C2535),
              userJID: participantId,
              fit: BoxFit.cover,
              profileImage: _buildTileImage(
                  isGroupCall: isGroupCall,
                  participantId: participantId,
                  profileImageSize: profileImageSize,
                  profileImageAlignment: profileImageAlignment),
              profileImageAlignment: profileImageAlignment,
              onTap: () {
                // controller.videoSwap();
              },
            ),

            // On Hold overlay widget
            Visibility(
              visible: (controller.callerList
                  .firstWhereOrNull((e) => e.identity == participantId)
                  ?.flyCallStatusEvent == FlyCallStatusEvent.callHold &&
                  !(controller.callerList
                      .firstWhereOrNull((e) => e.identity == participantId)
                      ?.isReconnecting ?? false)),
              child: Center(
                child: Text(
                  "On Hold",
                  style: AppStyleConfig
                      .ongoingCallPageStyle.callStatusTextStyle,
                ),
              ),
            ),

            // Reconnecting overlay widget
            Visibility(
              visible: controller.callerList
                  .firstWhereOrNull((e) => e.identity == participantId)
                  ?.isReconnecting ?? false,
              child: Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black.withOpacity(
                        0.4), // semi-transparent dark shade
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 230,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            'Reconnecting...',
                            style: AppStyleConfig.ongoingCallPageStyle
                                .callStatusTextStyle.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Status overlay widget for non-main views during ringing/connecting states
            Positioned.fill(
              child: Obx(() {
                final participant = controller.callerList
                    .firstWhereOrNull((e) => e.identity == participantId);
                final statusEvent = participant?.flyCallStatusEvent;

                if (![
                  FlyCallStatusEvent.calling,
                  FlyCallStatusEvent.tryingToConnect,
                  FlyCallStatusEvent.ringing,
                  FlyCallStatusEvent.connecting
                ].contains(statusEvent) || isMainView) {
                  return const Offstage();
                }

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black.withOpacity(
                        0.4), // semi-transparent dark shade
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Center(
                    child: Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      statusEvent == FlyCallStatusEvent.tryingToConnect
                          ? 'Trying to connect...'
                          :
                      statusEvent == FlyCallStatusEvent.calling ? 'Calling...' :
                      statusEvent == FlyCallStatusEvent.ringing ? 'Ringing...' :
                      statusEvent == FlyCallStatusEvent.connecting
                          ? 'Connecting...'
                          : '',
                      style: AppStyleConfig.ongoingCallPageStyle
                          .callStatusTextStyle.copyWith(fontSize: 12),
                    ),
                  ),
                );
              }),
            ),


            // Connection Quality Icon
            Visibility(
              visible: controller.callerConnectionQuality.containsKey(
                  participantId),
              child: Positioned(
                top: 12,
                left: 12,
                child: Obx(() {
                  return SizedBox(
                    width: 18,
                    height: 18,
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: IconTheme(
                        data: const IconThemeData(
                            size: 12, color: Colors.transparent),
                        child: getConnectionQualityIcon(
                            controller.callerConnectionQuality[
                            controller
                                .getLocalParticipant()
                                ?.identity ?? ""] ??
                                FlyConnectionQuality.unknown),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Mute Status Icon
            isMainView ?
            Center(
              child: Obx(() {
                return Visibility(
                  visible: controller.callerList
                      .firstWhereOrNull((e) => e.identity == participantId)
                      ?.isAudioMuted ?? false,
                  child: SizedBox(
                    width: 35,
                    height: 35,
                    child: Material(
                      shape: AppStyleConfig.outgoingCallPageStyle
                          .actionButtonsStyle.shape,
                      color: Colors.transparent,
                      elevation: 0,
                      child: Center(
                        child: AppUtils.svgIcon(
                          icon: callMutedIconTransparent,
                          colorFilter: ColorFilter.mode(
                            AppStyleConfig.outgoingCallPageStyle
                                .actionButtonsStyle.activeBgColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),

                  ),
                );
              }),
            ) :
            Positioned(
              top: 12,
              right: 12,
              child: Obx(() {
                return Visibility(
                  visible: controller.callerList
                      .firstWhereOrNull((e) => e.identity == participantId)
                      ?.isAudioMuted ?? false,
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: Material(
                      shape: AppStyleConfig.outgoingCallPageStyle
                          .actionButtonsStyle.shape,
                      color: Colors.transparent,
                      elevation: 0,
                      child: Center(
                        child: AppUtils.svgIcon(
                          icon: callMutedIconTransparent,
                          colorFilter: ColorFilter.mode(
                            AppStyleConfig.outgoingCallPageStyle
                                .actionButtonsStyle.activeBgColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),

                  ),
                );
              }),
            ),

            // Speaking indicator
            Positioned(
              top: isMainView ? 45 : 10,
              right: isMainView ? 15 : 10,
              child: Obx(() {
                return AudioLevelAnimation(
                  radius: 8,
                  audioLevel: controller.getAudioLevelForParticipant(
                      participantId),
                  bgColor: const CallUserTileStyle().speakingIndicatorStyle
                      .activeBgColor,
                  //AppColors.speakingBg,
                  dotsColor: const CallUserTileStyle()
                      .speakingIndicatorStyle.activeIconColor,
                  useLiveKitAudio: true,
                );
              }),
            ),

            isMainView ? const Offstage() : Positioned(
              left: 8,
              bottom: 8,
              right: 8,
              child: Obx(() {
                final name = controller.remoteUserNameMap[participantId] ??
                    participantId;
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

          ],
        ),
      );
    });
  }

  Widget callingScreen() {
    final remoteUserID = controller.getRemoteParticipantIdForOneToOneCall();
    final localUserID = controller
        .getLocalParticipant()
        ?.identity ?? "";
    callkitLogger.info(
        "#CallKitOutGoingCallView CallingScreen Build Called, remoteUserID: $remoteUserID");
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF152134),
            Color(0xFF0D2852),
            Color(0xFF152134),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(180),
        ),
      ),
      child: (remoteUserID.isNotEmpty || localUserID.isNotEmpty)
          ? mfCallViewRendering(
          participantId: controller.callType.value.toUpperCase() == "VIDEO"
              ? localUserID
              : remoteUserID,
          isMainView: true,
          profileImageAlignment: Alignment.topCenter)
          : const Offstage(),
    );
  }

  Widget callConnectedScreen({required BuildContext buildContext}) {
    callkitLogger.info(
        "#CallKitOutGoingCallView CallConnectedScreen Build Called");
    return Container(
        color: AppColors.audioCallerBackground,
        child: Stack(
          children: [
            mfCallViewRendering(participantId: controller
                .getRemoteParticipantIdForOneToOneCall(),
                isMainView: true,
                borderRadius: 0,
                profileImageAlignment: Alignment.topCenter),

            Obx(() {
              if (!controller.isOnGoingCallViewEnable.value) {
                return const SizedBox.shrink();
              }

              final screenSize = MediaQuery
                  .of(buildContext)
                  .size;
              // final previewWidth = (screenSize.width * 0.32).clamp(100.0, 180.0);
              // final previewHeight = previewWidth * 1.3; // maintain 4:3-ish aspect ratio
              final bottomOffset = controller.showControls.value
                  ? screenSize.height * 0.20
                  : screenSize.height * 0.06;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: bottomOffset,
                right: screenSize.width * 0.0015,
                child: SizedBox(
                  height: 140,
                  width: 120,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: mfCallViewRendering(participantId: controller
                        .getLocalParticipant()
                        ?.identity ?? "",
                        profileImageSize: 55,
                        borderRadius: 15),
                  ),
                ),
              );
            })
          ],
        )
    );
  }

  Widget callHeader({required BuildContext context, required isGroupCall}) {
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //PIP view button
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 10),
                child: InkWell(
                  onTap: () {
                    controller.goToPIP();
                  },
                  child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Call Status (Ringing / Connecting etc.)
                    if (!controller.isOnGoingCallViewEnable.value &&
                        controller.currentCallMode.value != "MEET") ...[
                      Center(
                        child: Text(controller.callStatus.value,
                          style: AppStyleConfig
                              .ongoingCallPageStyle.callStatusTextStyle,
                        ),
                      ),
                    ],
                    Center(
                      child: Text(
                        controller.callerNames.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textAlign: TextAlign.center,
                        style: AppStyleConfig.ongoingCallPageStyle
                            .callStatusTextStyle,
                      ),
                    ),
                  ],
                ),
              ),

              // const Spacer(),

              //Invite Button
              SizedBox(
                width: 48,
                child: Obx(() {
                  final showInviteButton = controller.isOnGoingCallViewEnable
                      .value && controller.callKind != FlyCallKind.sip;
                  return Visibility(
                    visible: showInviteButton,
                    child: InkWell(
                      onTap: () {
                        controller.inviteParticipants();
                      },
                      child: const Icon(
                        Icons.person_outline_sharp,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  );
                }),
              ),

            ],
          ),

          // Call Duration
          if (controller.isOnGoingCallViewEnable.value ||
              controller.currentCallMode.value == "MEET") ...[
            const SizedBox(height: 16,),
            Center(
              child: Text(controller.callDuration.value,
                style: AppStyleConfig
                    .ongoingCallPageStyle.callStatusTextStyle,
              ),
            ),
          ],

        ],
      );
    });
  }

  /// One-to-One Call View
  Widget oneToOneCallUI(BuildContext context) {
    callkitLogger.info("#CallKitOutGoingCallView One-One Call UI Build Called");
    return Stack(
        fit: StackFit.expand,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              callHeader(context: context, isGroupCall: false),
              Expanded(
                child: Obx(() {
                  return !controller.isOnGoingCallViewEnable.value
                      ? callingScreen()
                      : callConnectedScreen(buildContext: context);
                }),

              ),
            ],
          ),

          /// Controls at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildControls(context),),
        ]
    );
  }

  /// Group Call View
  Widget groupCallUI(BuildContext context) {
    callkitLogger.info("#CallKitOutGoingCallView Group Call UI Build Called");
    return Stack(
        fit: StackFit.expand,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              callHeader(context: context,
                  isGroupCall: controller.groupId.value.isNotEmpty),

              Expanded(
                child: Obx(() {
                  return !controller.isOnGoingCallViewEnable.value
                      ? callingScreen()
                      : Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: GridView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                          controller.callerList.length > 2 ? 2 : 1,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 2.0,
                          childAspectRatio:
                          controller.callerList.length == 2 ? 1.24 : 1.0,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        itemCount: controller.callerList.length,
                        itemBuilder: (context, index) {
                          return mfCallViewRendering(participantId: controller
                              .callerList[index].identity,
                              profileImageSize: 80,
                              borderRadius: 15);
                        }),
                  );
                }),
              ),
            ],
          ),

          /// Controls at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildControls(context),),
        ]
    );
  }


  Widget buildMuteIcon(String? participantId, {double radius = 8}) {
    callkitLogger.info(
        "[buildMuteIcon] Called for participantId: $participantId");

    if (participantId == null || participantId.isEmpty) {
      callkitLogger.info("[buildMuteIcon] participantId is null or empty");
      return const SizedBox.shrink();
    }

    final FlyCallParticipant? participant = controller.callerList
        .firstWhereOrNull((e) => e.identity == participantId);
    callkitLogger.info("[buildMuteIcon] Participant found: ${participant
        ?.identity}, isMuted: ${participant?.isAudioMuted}");

    if (participant?.isAudioMuted == null) {
      return const SizedBox.shrink();
    }

    final style = AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle;
    final bool isMuted = participant!.isAudioMuted!;

    return Visibility(
      visible: isMuted,
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Material(
          shape: style.shape,
          color: Colors.transparent,
          elevation: 0,
          child: Center(
            child: AppUtils.svgIcon(
              icon: callMutedIconTransparent,
              colorFilter: ColorFilter.mode(
                style.activeBgColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),

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

  Widget _buildProfileImageForUser(
      {required String participantId, double size = 48, required bool isGroupProfile}) {
    return FutureBuilder(
      future: isGroupProfile
          ? getGroupProfileDetails(
          CallUtils.getJidFromUserId(userId: participantId, isGroup: true))
          : getProfileDetails(
          CallUtils.getJidFromUserId(userId: participantId, isGroup: false)),
      builder: (ctx, snap) {
        if (snap.hasData && snap.data != null) {
          return buildProfileImage(snap.data!, size: size);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  ///  Call Control Buttons
  Widget _buildCallControls(BuildContext context) {
    final bool showCameraSwitch =
        controller.isVideoEnabled.value &&
            controller.callKind != FlyCallKind.sip;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 10, top: 0),
      child: Obx(() =>
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// Audio Mute UnMute Button
              _buildAudioMuteUI(
                isMuted: controller.isAudioMuted.value,
                onTap: () {
                  final bool enable = !(controller.isAudioMuted.value);
                  callkitLogger.info(
                      "[_buildCallControls] Local participant found enable: $enable");
                  controller.setMicroPhoneEnabled(enabled: enable);
                },
              ),

              const SizedBox(width: 24),

              /// Camera Switch Button
              if (showCameraSwitch) ...[
                _buildCameraSwitchUI(
                  isActive:
                  controller.cameraPosition.value != CameraType.front,
                  onTap: controller.switchCamera,
                ),
                const SizedBox(width: 24),
              ],

              /// Video Mute UnMute Button
              if(controller.callKind != FlyCallKind.sip)
                _buildVideoMuteUI(
                  isVideoEnabled: controller.isVideoEnabled.value,
                  onTap: () {
                    controller.setCameraEnable(
                      enable: !(controller.isVideoEnabled.value),
                    );
                  },
                ),
              const SizedBox(width: 24),

              /// Audio Device Selector Button
              _buildAudioRoutingControl(
                onTap: () async {
                  callkitLogger.info(
                      "[_buildCallControls] Audio device selector tapped, current output: ${controller
                          .selectedDeviceType.value}");
                  _showAudioDeviceSelector(context);
                },
              ),

            ],
          )),
    );
  }

  ///  End Call Button
  Widget _buildEndCallButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
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

  /// ---------------------------------
  /// Audio controller
  /// ---------------------------------
  _AudioRoutingUIConfig _getAudioRoutingUI() {
    final device = controller.selectedDeviceType.value;
    var type = FlyAudioDeviceType.fromString(device);
    switch (type) {
      case FlyAudioDeviceType.speaker:
        return const _AudioRoutingUIConfig(
          icon: speakerActive,
          isActive: true,
        );

      case FlyAudioDeviceType.bluetooth:
        return const _AudioRoutingUIConfig(
          icon: speakerBluetooth,
          isActive: true,
        );

      case FlyAudioDeviceType.headset:
        return const _AudioRoutingUIConfig(
          icon: speakerHeadset,
          isActive: true,
        );

      default:
        return const _AudioRoutingUIConfig(
          icon: speakerInactive,
          isActive: false,
        );
    }
  }

  /// ---------------------------------
  /// Audio routing controller
  /// --------------------------------
  Widget _buildAudioRoutingControl(
      {required VoidCallback onTap, double size = 52}) {
    final style = AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle;
    final ui = _getAudioRoutingUI();

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: SizedBox(
        height: size,
        width: size,
        child: Material(
          shape: style.shape,
          elevation: 0,
          color: ui.isActive
              ? style.activeBgColor
              : style.inactiveBgColor,
          child: Center(
            child: AppUtils.svgIcon(
              icon: ui.icon,
              colorFilter: ColorFilter.mode(
                ui.isActive
                    ? style.activeIconColor
                    : style.inactiveIconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------------------------
  /// Video mute controller
  /// --------------------------------
  Widget _buildVideoMuteUI(
      {required bool isVideoEnabled, required VoidCallback onTap, double size = 52}) {
    final style =
        AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        elevation: 0,
        shape: style.shape,
        color: isVideoEnabled
            ? style.inactiveBgColor
            : style.activeBgColor,
        child: InkWell(
          customBorder: style.shape,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Center(
            child: AppUtils.svgIcon(
              icon: isVideoEnabled ? videoActive : videoInactive,
              colorFilter: ColorFilter.mode(
                isVideoEnabled
                    ? style.inactiveIconColor
                    : style.activeIconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------------------------
  /// Camera switch controller
  /// --------------------------------
  Widget _buildCameraSwitchUI(
      {required bool isActive, required VoidCallback onTap, double size = 52,}) {
    final style =
        AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        elevation: 0,
        shape: style.shape,
        color: isActive
            ? style.activeBgColor
            : style.inactiveBgColor,
        child: InkWell(
          customBorder: style.shape,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Center(
            child: AppUtils.svgIcon(
              icon: isActive
                  ? cameraSwitchActive
                  : cameraSwitchInactive,
              colorFilter: ColorFilter.mode(
                isActive
                    ? style.activeIconColor
                    : style.inactiveIconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------------------------
  /// Audio mute controller
  /// --------------------------------
  Widget _buildAudioMuteUI(
      {required bool isMuted, required VoidCallback onTap, double size = 52,}) {
    final style =
        AppStyleConfig.outgoingCallPageStyle.actionButtonsStyle;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        elevation: 0,
        shape: style.shape,
        color: isMuted
            ? style.activeBgColor
            : style.inactiveBgColor,
        child: InkWell(
          customBorder: style.shape,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Center(
            child: AppUtils.svgIcon(
              icon: isMuted ? muteActive : muteInactive,
              colorFilter: ColorFilter.mode(
                isMuted
                    ? style.activeIconColor
                    : style.inactiveIconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }


  /// Get connection quality icon
  Icon getConnectionQualityIcon(FlyConnectionQuality quality) {
    switch (quality) {
      case FlyConnectionQuality.unknown:
        callkitLogger.info(
            "[getConnectionQualityIcon] Connection quality is unknown");
        return const Icon(Icons.signal_cellular_connected_no_internet_0_bar,
            color: Colors.grey, size: 18);

      case FlyConnectionQuality.poor:
        callkitLogger.info(
            "[getConnectionQualityIcon] Connection quality is poor");
        return const Icon(
            Icons.signal_cellular_alt_2_bar, color: Colors.red, size: 18);

      case FlyConnectionQuality.good:
        callkitLogger.info(
            "[getConnectionQualityIcon] Connection quality is good");
        return const Icon(
            Icons.signal_cellular_alt, color: Colors.orange, size: 18);

      case FlyConnectionQuality.excellent:
        callkitLogger.info(
            "[getConnectionQualityIcon] Connection quality is excellent");
        // for excellent, returning transparent icon to hide it
        return const Icon(
            Icons.signal_cellular_alt, size: 0, color: Colors.transparent);

      case FlyConnectionQuality.lost:
        callkitLogger.info(
            "[getConnectionQualityIcon] Connection quality is lost");
        return const Icon(Icons.signal_cellular_connected_no_internet_0_bar,
            color: Colors.red, size: 18);
    }
  }

  ///
  ///
  void _showAudioDeviceSelector(BuildContext context) async {
    await controller.getAvailableAudioOutputDevices();
    callkitLogger.info(
        "[_showAudioDeviceSelector] Available audio devices: ${controller
            .availableTypes.map((e) => e.toMap()).toList()}");

    final bool isSpeakerOnlyAvailable = controller.availableTypes.length == 1 &&
        controller.availableTypes.any((e) =>
        e.type ==
            FlyAudioDeviceType.speaker);
    final bool isEarpieceOnlyAvailable = controller.availableTypes.length ==
        1 && controller.availableTypes.any((e) =>
    e.type ==
        FlyAudioDeviceType.receiver);
    final bool onlyEarpieceAndSpeakerAvailable = controller.availableTypes
        .length == 2 &&
        controller.availableTypes.any((e) =>
        e.type == FlyAudioDeviceType.receiver) &&
        controller.availableTypes.any((e) =>
        e.type == FlyAudioDeviceType.speaker);
    final bool isVideoCallAndNoExternalDeviceConnected = controller.callType
        .value == "video" && controller.availableTypes.length == 1;

    callkitLogger.info(
        "[_showAudioDeviceSelector] Available onlyEarpieceAndSpeakerAvailable: $onlyEarpieceAndSpeakerAvailable"
            "isVideoCallAndNoExternalDeviceConnected: $isVideoCallAndNoExternalDeviceConnected, isSpeakerOnlyAvailable: $isSpeakerOnlyAvailable, isEarpieceOnlyAvailable: $isEarpieceOnlyAvailable");

    if (isSpeakerOnlyAvailable || isEarpieceOnlyAvailable) {
      callkitLogger.info(
          "[_showAudioDeviceSelector] only one device available not showing");
      return;
    }

    if (onlyEarpieceAndSpeakerAvailable ||
        isVideoCallAndNoExternalDeviceConnected) {
      //Toggle between the two available devices dynamically
      final currentType = controller.selectedDeviceType.value;
      final nextDevice = controller.availableTypes.firstWhere(
            (device) => device.type.value != currentType,
      );
      callkitLogger.info(
          "[_showAudioDeviceSelector] Toggling between two devices. Current: $currentType → Next: ${nextDevice
              .type.value}");
      controller.changeAudioDevice(nextDevice);
    } else {
      controller.isAudioDialogOpen.value = true;
      await showDialog(
        context: context.mounted ? context : Get.context!,
        barrierDismissible: true,
        builder: (_) =>
            Obx(() {
              return Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: controller.availableTypes.map((type) {
                        return ListTile(
                          leading: getAudioDeviceIcon(type.type),
                          title: Text(type.deviceName),
                          trailing: controller.selectedDeviceType.value ==
                              type.type.value
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            controller.isAudioDialogOpen.value = false;
                            controller.changeAudioDevice(type);
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            }),
      );
    }
  }

  /// Get audio device icon
  Icon getAudioDeviceIcon(FlyAudioDeviceType kind) {
    callkitLogger.info(
        "[getAudioDeviceIcon] Getting icon for audio device kind: $kind");
    switch (kind) {
      case FlyAudioDeviceType.bluetooth:
        return const Icon(Icons.bluetooth_connected, color: Colors.black);
      case FlyAudioDeviceType.speaker:
        return const Icon(Icons.volume_up, color: Colors.black);
      case FlyAudioDeviceType.receiver:
        return const Icon(Icons.phone_iphone, color: Colors.black);
      case FlyAudioDeviceType.headset:
        return const Icon(Icons.headset, color: Colors.black);
    }
  }

  Widget _buildTileImage({
    required bool isGroupCall,
    required String participantId,
    required double profileImageSize,
    required Alignment profileImageAlignment,
  }) {
    final bool isOngoing = controller.isOnGoingCallViewEnable.value;
    final bool hasGroupId = controller.groupId.value.isNotEmpty;
    final bool isOneToOne = controller.callerList.length <= 2;

    final EdgeInsets padding = EdgeInsets.only(
      top: profileImageAlignment == Alignment.topCenter ? 10.0 : 0,
    );

    // ---------- ONGOING CALL ----------
    if (isOngoing) {
      return Padding(
        padding: padding,
        child: _buildProfileImageForUser(
          participantId: participantId,
          size: profileImageSize,
          isGroupProfile: false,
        ),
      );
    }

    // ---------- GROUP CALL (OUTGOING VIEW) ----------
    if (hasGroupId) {
      return Padding(
        padding: padding,
        child: _buildProfileImageForUser(
          participantId: controller.groupId.value,
          size: profileImageSize,
          isGroupProfile: isGroupCall,
        ),
      );
    }

    // ---------- ONE-TO-ONE CALL ----------
    if (isOneToOne) {
      return Padding(
        padding: padding,
        child: _buildProfileImageForUser(
          participantId: participantId,
          size: profileImageSize,
          isGroupProfile: isGroupCall,
        ),
      );
    }

    // ---------- ONE-TO-MANY ----------
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.callerList.length > 3 ? 4 : controller.callerList.length,
            (index) {
          if (index == 3) {
            return ProfileTextImage(
              text: "+${controller.callerList.length - 3}",
              radius: 45 / 2,
              bgColor: Colors.white,
              fontColor: Colors.grey,
            );
          }

          final userId = controller.callerList[index].identity;

          return FutureBuilder(
            future: getProfileDetails(
              CallUtils.getJidFromUserId(
                userId: userId,
                isGroup: false,
              ),
            ),
            builder: (ctx, snap) {
              if (snap.hasData && snap.data != null) {
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: buildProfileImage(snap.data!, size: 45),
                );
              }
              return const Offstage();
            },
          );
        },
      ),
    );
  }
}

class _AudioRoutingUIConfig {
  final String icon;
  final bool isActive;

  const _AudioRoutingUIConfig({
    required this.icon,
    required this.isActive,
  });
}