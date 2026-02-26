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
      debugPrint(
          "#CallKitOutGoingCallView Build Called, isGroupCall");
      // return PopScope(
      //   canPop: false,
      //   child: Scaffold(
      return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: ColoredBox(
              color: AppColors.audioCallerBackground,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: controller.toggleControls,
                child: controller.isGroupCall.value
                    ? buildGroupGridItem(context)
                    : oneToOneCallUI(context),
              ),
            ),
          ),
        // ),
        );
      // );
    });
  }

  /// One-to-One Call View
  Widget oneToOneCallUI(BuildContext context) {
    callkitLogger.info("#CallKitOutGoingCallView One-One Call UI Build Called");

    final String remoteTileParticipantId =
        !controller.isOnGoingCallViewEnable.value && controller.callType.toUpperCase() == "VIDEO"
            ? controller.getLocalParticipant()?.identity ?? ""
            : controller.mainCallViewUserId.value;

    final FlyCallParticipant? remoteParticipant =
        controller.callerList.firstWhereOrNull(
            (e) => e.identity == remoteTileParticipantId);
    final String remoteParticipantId = remoteParticipant?.identity ?? controller.getLocalParticipant()?.identity ?? "";

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
                          // key: ValueKey(remoteTileParticipantId),
                          userJID: remoteTileParticipantId,
                          fit: BoxFit.cover,
                    viewBgColor: AppColors.audioCallerBackground,
                    isLocalPreviewView: false,
                    profileImage: getUserProfileImageWithName(
                      isLocalTile: false,
                      participantId: remoteParticipantId,
                      callKind: remoteParticipant?.kind,
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
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                        )
                      ],
                    ),

                    /// Mute Icon
              buildMuteIcon(remoteParticipantId, radius: 34),

              /// Connection Quality Icon
              Visibility(
                visible: controller.callerConnectionQuality.containsKey(remoteParticipantId),
                child: Positioned(
                  right: 38,
                  top: 108,
                  child: getConnectionQualityIcon(
                      controller.callerConnectionQuality[remoteParticipantId] ??
                          FlyConnectionQuality.unknown),
                ),
              ),

              /// Speaking Indicator
              Visibility(
                visible: controller.callerConnectionQuality.containsKey(remoteParticipantId),
                child: Positioned(
                  right: 38,
                  top: 80,
                  child:Obx((){ return buildSpeakingIndicatorIcon(remoteParticipantId);}),
                ),
              ),
                  ],
          )
              : const Offstage();
        }),

        /// Foreground content
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 12),

              /// Call Status
              Obx(() {
                final isOngoing = controller.isOnGoingCallViewEnable.value;

                return Column(
                  children: [
                    if (!isOngoing && controller.currentCallMode.value == "MEET") ...[
                      SizedBox(
                        height: 38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            const SizedBox(width: 48), // balance space

                            Expanded(
                              child: Center(
                                child: Text(
                                  controller.getOneToOneCallRemoteUserName.value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyleConfig
                                      .ongoingCallPageStyle.callerNameTextStyle,
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 48,
                              child: Obx(() {
                                final showInviteButton =
                                    controller.currentCallMode.value == "MEET" &&
                                        controller.callKind != FlyCallKind.sip;

                                return Visibility(
                                  visible: showInviteButton,
                                  child: IconButton(
                                    onPressed: () {
                                      controller.inviteParticipants();
                                    },
                                    icon: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      Center(
                        child: Text(
                          controller.callDuration.value,
                          style: AppStyleConfig
                              .ongoingCallPageStyle.callDurationTextStyle,
                        ),
                      ),
                    ],
                    if (!isOngoing && controller.currentCallMode.value != "MEET") ...[
                      Center(
                        child: Text(
                          controller.currentCallMode.value == "MEET" ? controller.callDuration.value : controller.callStatus.value,
                          style: AppStyleConfig
                              .ongoingCallPageStyle.callStatusTextStyle,
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            controller.getOneToOneCallRemoteUserName(),
                            style: AppStyleConfig
                                .ongoingCallPageStyle.callStatusTextStyle,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                    if (isOngoing) ...[
                      SizedBox(
                        height: 38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            // Invisible widget at the right to balance the invite button
                            const SizedBox(
                              width: 48,
                            ),

                            Expanded(
                              child: Center(
                                child: Text(
                                  controller.getOneToOneCallRemoteUserName.value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyleConfig
                                      .ongoingCallPageStyle.callerNameTextStyle,
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 48,
                              child: Obx(() {
                                final showInviteButton =
                                    controller.isOnGoingCallViewEnable.value &&
                                        controller.callKind != FlyCallKind.sip;

                                return Visibility(
                                  visible: showInviteButton,
                                  child: IconButton(
                                    onPressed: () {
                                      controller.inviteParticipants();
                                    },
                                    icon: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      Obx((){
                        return Center(
                        child: Text(
                          controller.callDuration.value,
                          style: AppStyleConfig
                              .ongoingCallPageStyle.callDurationTextStyle,
                        ),
                      );}),

                      // On Hold overlay widget
                      if (controller.callerList.any((FlyCallParticipant e) =>
                              e.flyCallStatusEvent ==
                              FlyCallStatusEvent.callHold) &&
                          (controller.callerList.every((e) =>
                              e.flyCallStatusEvent !=
                              FlyCallStatusEvent.reconnecting))) ...[
                        const SizedBox(height: 140),
                        Visibility(
                          visible: true,
                          child: Center(
                            child: Text(
                              "On Hold",
                              style: AppStyleConfig
                                  .ongoingCallPageStyle.callStatusTextStyle,
                            ),
                          ),
                        ),
                      ],

                      // Reconnecting overlay widget
                      if (controller.callerList
                              .firstWhereOrNull((e) =>
                                  e.identity ==
                                  controller
                                      .getRemoteParticipantIdForOneToOneCall())
                              ?.isReconnecting ??
                          false) ...[
                        const SizedBox(height: 140),
                        Visibility(
                          visible: true,
                          child: Center(
                            child: Text(
                              'Reconnecting...',
                              style: AppStyleConfig
                                  .ongoingCallPageStyle.callStatusTextStyle,
                            ),
                          ),
                        )
                      ]
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
          final previewWidth = (screenSize.width * 0.32).clamp(100.0, 180.0);
          final previewHeight = previewWidth *
              1.3; // maintain 4:3-ish aspect ratio
          final bottomOffset = controller.showControls.value
              ? screenSize.height * 0.20
              : screenSize.height * 0.06;

          return AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: bottomOffset,
            right: screenSize.width * 0.0015,
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
              icon: callMutedIcon,
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

  /// Grid view for group call participants
  Widget buildGroupGridItem(BuildContext context) {
    return Obx(() {
      final isGroupCall = controller.isGroupOnGoingCallEnabled.value;
      return SafeArea(
        child: Stack(
          children: [
            Column(
              children: [

                /// --- Call Info Header (Top Section) ---
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
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
                                  ? controller.getOneToOneCallRemoteUserName.value
                                  : controller.getOneToOneCallRemoteUserName.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              textAlign: TextAlign.center,
                              style: AppStyleConfig.ongoingCallPageStyle
                                  .callStatusTextStyle,
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
                                isLocalPreviewView: false,
                                key: ValueKey(controller.callerList[index].identity),
                                userJID: controller
                                    .callerList[index].identity,
                                fit: BoxFit.cover,
                                viewBgColor: AppColors.callerTitleBackground,
                                profileImage: getUserProfileImageWithName(
                                  isGroupGrid: true,
                                  isLocalTile: false,
                                  participantId: controller
                                      .callerList[index].identity,
                                  scale: 1.2, callKind: controller
                                      .callerList[index].kind,
                                ),
                              ),

                              Obx(() {
                                final participant = controller.callerList[index];
                                debugPrint(
                                  '[Group UI][AudioMute] '
                                      'identity=${participant.identity}, '
                                      'isAudioMuted=${participant.isAudioMuted}',
                                );
                                return Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (participant.isAudioMuted == true) ...[
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.grey, //AppColors.audioMutedIconBgColor,
                                          child: AppUtils.svgIcon(
                                            icon: callMutedIcon,
                                            colorFilter: const ColorFilter.mode(
                                                Colors.white,
                                                BlendMode.srcIn),
                                          ),
                                        ),
                                    ],
                                      if (participant.isAudioMuted != true) ...[
                                              buildSpeakingIndicatorIcon(
                                                  controller.callerList[index].identity)
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
                                  participant.flyCallStatusEvent,
                                );
                                callkitLogger.info("[buildGroupGridItem] Participant: ${participant.identity}, isSelf: $isSelf, connectionState: $connectionState");
                                if ((!isSelf && connectionState.isNotEmpty) ||( isSelf && connectionState == "Reconnecting" && connectionState.isNotEmpty)) {
                                  return Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        // borderRadius: BorderRadius.circular(10.0),
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
                                  isLocalPreviewView: false,
                                  // key: ValueKey(controller.groupId.value),
                                  userJID: !controller.isOnGoingCallViewEnable.value &&
                                      controller.callType.toUpperCase() == "VIDEO"
                                      ? controller.getLocalParticipant()?.identity ?? "" :controller.groupId.value,
                                  fit: BoxFit.cover,
                                  viewBgColor:
                                      AppColors.audioCallerBackground,
                                  profileImage: getUserProfileImageWithName(
                                    isLocalTile: false,
                                    isGroup: true,
                                    participantId: controller.groupId.value,
                                    scale: 1, callKind: null,
                                  ),
                                ),

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
                                          style: AppStyleConfig
                                              .ongoingCallPageStyle.callStatusTextStyle,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          controller.chatNameForGroupCall.value.isEmpty &&  controller.groupId.value.isEmpty ? controller.getOneToOneCallRemoteUserName.value:"${controller.chatNameForGroupCall.value}\n${controller.groupCallTitle.value}",
                                          textAlign: TextAlign.center,
                                          style: AppStyleConfig
                                              .ongoingCallPageStyle.callerNameTextStyle,
                                        ),
                                        const SizedBox(height: 8),
                                        controller.chatNameForGroupCall.value.isEmpty &&  controller.groupId.value.isEmpty ? Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: List.generate(
                                                  controller.callerList.length > 3
                                                      ? 4
                                                      : controller.callerList.length,
                                                      (index) => (index == 3)
                                                      ? ProfileTextImage(
                                                    text:
                                                    "+${controller.callerList.length - 3}",
                                                    radius: 45 / 2,
                                                    bgColor: Colors.white,
                                                    fontColor: Colors.grey,
                                                  )
                                                      : FutureBuilder(
                                                      future: getProfileDetails(CallUtils.getJidFromUserId(userId:controller.callerList[index].identity,isGroup: false)),
                                                      builder: (ctx, snap) {
                                                        return snap.hasData &&
                                                            snap.data != null
                                                            ? Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .all(2.0),
                                                          child:
                                                          buildProfileImage(
                                                              snap.data!,
                                                              size: 45),
                                                        )
                                                            : const Offstage();
                                                      })),
                                                     ): const Offstage()

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
                padding: const EdgeInsets.only(right: 8.0, top: 12),
                child: Obx(() {
                  final showInviteButton = controller.isOnGoingCallViewEnable.value && controller.callKind != FlyCallKind.sip;
                  return Visibility(
                    visible: showInviteButton,
                    child: IconButton(
                      onPressed: () {
                        controller.inviteParticipants();
                      },
                      icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }

  ///  Local Preview Widget
  Widget _buildLocalPreview({required double width, required double height}) {
    final participantId =
    controller.getLocalParticipant()?.identity ?? "";
    return SizedBox(
      height: 140,
      width: 120,
      child: Padding(
        padding: const EdgeInsets.only(right: 18),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Stack(
              children: [
                MirrorFlyCallView(
                  isLocalPreviewView: false,
                  radius: 15.0,
                  viewBgColor: Colors.black.withAlpha(150),
                  userJID: controller.secondaryCallViewUserId.value,
                  isLocalUser: true,
                  fit: BoxFit.cover,
                  profileImage: getUserProfileImageWithName(
                    isLocalTile: true,
                    participantId: controller.getLocalParticipant()?.identity ?? "",
                    scale: 2,
                    useMaxSize: true, callKind: controller.getLocalParticipant()?.kind,
                  ),
                  onTap: () {
                    controller.videoSwap();
                  },
                ),

                // Reconnecting overlay widget
                Visibility(
                  visible: controller.callerList
                          .firstWhereOrNull((e) => e.isLocalParticipant == true)
                          ?.isReconnecting ??
                      false,
                  child: Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black.withOpacity(0.4), // semi-transparent dark shade
                    ),
                      padding: const EdgeInsets.all(2),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          'Reconnecting',
                          style: AppStyleConfig.ongoingCallPageStyle.callStatusTextStyle.copyWith(fontSize: 12),
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
                  .containsKey(controller.getLocalParticipant()?.identity ?? ""),
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
                        data: const IconThemeData(size: 12, color: Colors.transparent),
                        child: getConnectionQualityIcon(
                            controller.callerConnectionQuality[
                                    controller.getLocalParticipant()?.identity ?? ""] ??
                                FlyConnectionQuality.unknown),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Mute Icon
            Positioned(
              top: 12,
              right: 12,
              child: Obx(() {
                return buildMuteIcon(
                  controller.getLocalParticipant()?.identity ?? "",
                  isLocalParticipant: true,
                );
              }),
            ),

            // Speaking indicator
            Positioned(
              top: 12,
              right: 12,
              child: Obx(() {
                return buildSpeakingIndicatorIcon(
                    participantId);
              }),
            ),
          ],
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

  Widget getUserProfileImageWithName({
    required String participantId,
    bool isGroup = false,
    double scale = 1.0,
    bool useMaxSize = false, required callKind,
    required bool isLocalTile,
    bool isGroupGrid = false,
  }) {

    callkitLogger.info("[getUserProfileImageWithName] Called with participantId: $participantId");

    if (participantId == "") {
      callkitLogger
          .info("[getUserProfileImageWithName] participantId is empty");
      return const Offstage();
    }

    callkitLogger.info("[getUserProfileImageWithName] isGroupCall: $isGroup");

    final String normalizedParticipantId = controller.validId(userId: participantId, isGroup: isGroup);
    callkitLogger.info("[getUserProfileImageWithName] normalizedParticipantId: $normalizedParticipantId");

    final Future<ProfileDetails> profileDetails = isGroup == true
        ? getGroupProfileDetails(normalizedParticipantId)
        : getProfileDetails(normalizedParticipantId);

    return FutureBuilder<ProfileDetails>(
      future: profileDetails,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          callkitLogger.info("[getUserProfileImageWithName] Loading profile for: $normalizedParticipantId");
        } else if (snap.connectionState == ConnectionState.done) {
          if (snap.hasError) {
            callkitLogger.info("[getUserProfileImageWithName] Error loading profile for $normalizedParticipantId → ${snap.error}");
          } else if (!snap.hasData || snap.data == null) {
            callkitLogger.info("[getUserProfileImageWithName]  No data found for participantId: $normalizedParticipantId");
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

          RxBool isLocalView = (participantId == controller.getLocalParticipant()?.identity).obs;
          return Stack(
            children: [

              /// LOCAL VIEW → CENTER
              if (isLocalView.value)
                Center(
                  child: controller.callKind == FlyCallKind.sip
                      ? ProfileTextImage(
                    text: (controller.remoteUserNameMap[participantId]?.trim().length ?? 0) > 3
                        ? controller.remoteUserNameMap[participantId]!.trim().substring(3)
                        : "You",
                    radius:
                    (AppStyleConfig.outgoingCallPageStyle.profileImageSize.width /
                        scale) /
                        2,
                  )
                      : buildProfileImage(
                    snap.data!,
                    size: AppStyleConfig.outgoingCallPageStyle
                        .profileImageSize.width /
                        scale,
                  ),
                ),

              /// REMOTE VIEW → TOP CENTER
              if (!isLocalView.value)
                Positioned(
                  top: isGroupGrid ? 50 : 80,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: controller.callKind == FlyCallKind.sip
                        ? ProfileTextImage(
                      text: (controller.remoteUserNameMap[participantId]?.trim().length ?? 0) > 3
                          ? controller.remoteUserNameMap[participantId]!.trim().replaceFirst(RegExp(r'^sip_'), '').substring(3) : "User",
                      radius:
                      (AppStyleConfig.outgoingCallPageStyle.profileImageSize.width /
                          scale) /
                          2,
                    )
                        : buildProfileImage(
                      snap.data!,
                      size: AppStyleConfig.outgoingCallPageStyle
                          .profileImageSize.width /
                          scale,
                    ),
                  ),
                ),

              /// "You" label
              if (isLocalTile && !controller.isGroupCall.value)
                const Positioned(
                  bottom: 8,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "You",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
        return const Offstage();
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
                  callkitLogger.info("[_buildCallControls] Local participant found enable: $enable");
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
                      "[_buildCallControls] Audio device selector tapped");
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
  Widget _buildAudioRoutingControl({
    required VoidCallback onTap,
    double size = 52,
  }) {

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
  Widget _buildVideoMuteUI({
    required bool isVideoEnabled,
    required VoidCallback onTap,
    double size = 52,
  }) {
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
  Widget _buildCameraSwitchUI({
    required bool isActive,
    required VoidCallback onTap,
    double size = 52,
  }) {
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
  Widget _buildAudioMuteUI({
    required bool isMuted,
    required VoidCallback onTap,
    double size = 52,
  }) {
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

  /// Speaking indicator icon
  Widget buildSpeakingIndicatorIcon(String? participantId) {
    callkitLogger.info("[buildSpeakingIndicatorIcon] Called for participantId: $participantId");

    if (participantId == null || participantId.isEmpty) {
      callkitLogger.info("[buildSpeakingIndicatorIcon] participantId is null or empty");
      return const SizedBox.shrink();
    }

    return AudioLevelAnimation(
      radius: 8,
      audioLevel: controller.getAudioLevelForParticipant(participantId),
      bgColor: const CallUserTileStyle().speakingIndicatorStyle
          .activeBgColor, //AppColors.speakingBg,
      dotsColor: const CallUserTileStyle()
          .speakingIndicatorStyle.activeIconColor,
      useLiveKitAudio: true,
    );
  }

  /// Get connection quality icon
  Icon getConnectionQualityIcon(FlyConnectionQuality quality) {
    switch (quality) {
      case FlyConnectionQuality.unknown:
        callkitLogger.info("[getConnectionQualityIcon] Connection quality is unknown");
        return const Icon(Icons.signal_cellular_connected_no_internet_0_bar, color: Colors.grey, size: 18);

      case FlyConnectionQuality.poor:
        callkitLogger.info("[getConnectionQualityIcon] Connection quality is poor");
        return const Icon(Icons.signal_cellular_alt_2_bar, color: Colors.red, size: 18);

      case FlyConnectionQuality.good:
        callkitLogger.info("[getConnectionQualityIcon] Connection quality is good");
        return const Icon(Icons.signal_cellular_alt, color: Colors.orange, size: 18);

      case FlyConnectionQuality.excellent:
        callkitLogger.info("[getConnectionQualityIcon] Connection quality is excellent");
        // for excellent, returning transparent icon to hide it
        return const Icon(Icons.signal_cellular_alt, size: 0, color: Colors.transparent);

      case FlyConnectionQuality.lost:
        callkitLogger.info("[getConnectionQualityIcon] Connection quality is lost");
        return const Icon(Icons.signal_cellular_connected_no_internet_0_bar,
            color: Colors.red, size: 18);
    }
  }

  ///
  ///
  void _showAudioDeviceSelector(BuildContext context) async {
    await controller.getAvailableAudioOutputDevices();
    callkitLogger.info("[_showAudioDeviceSelector] Available audio devices: ${controller.availableTypes.map((e) => e.toMap()).toList()}");
    if (controller.availableTypes.length > 2) {
      controller.isAudioDialogOpen.value = true;
      await showDialog(
        context: context.mounted ? context : Get.context!,
        barrierDismissible: true,
        builder: (_) => Obx(() {
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
                      trailing: controller.selectedDeviceType.value == type.type.value
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
    } else if (controller.availableTypes.length == 2) {
      //Toggle between the two available devices dynamically
      final currentType = controller.selectedDeviceType.value;
      final nextDevice = controller.availableTypes.firstWhere(
            (device) => device.type.value != currentType,
      );
      callkitLogger.info("[_showAudioDeviceSelector] Toggling between two devices. Current: $currentType → Next: ${nextDevice.type.value}");
      controller.changeAudioDevice(nextDevice);
    } else {
      // Only one device available → nothing to toggle
      callkitLogger.info(
        "[_showAudioDeviceSelector] Only one audio device available. No action taken.",
      );
    }
  }

  /// Get audio device icon
  Icon getAudioDeviceIcon(FlyAudioDeviceType kind) {
    callkitLogger.info("[getAudioDeviceIcon] Getting icon for audio device kind: $kind");
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
}

class _AudioRoutingUIConfig {
  final String icon;
  final bool isActive;

  const _AudioRoutingUIConfig({
    required this.icon,
    required this.isActive,
  });
}