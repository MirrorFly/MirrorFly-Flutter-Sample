import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../app_style_config.dart';
import '../call_modules/call_widgets.dart';
import '../call_modules/ripple_animation_view.dart';
import '../data/helper.dart';
import '../data/session_management.dart';
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
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🔹 Background: video or placeholder
          Obx(() => _buildCallBackground()),

          /// 🔹 Gradient overlay
          _buildGradientOverlay(),

          /// 🔹 Foreground content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                /// Call Status
                Obx(() => Text(
                  controller.callStatus.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                )),

                const Spacer(),

                /// Local Preview / Profile Image
                Obx(() => controller.isOnGoingCallViewEnable.value
                    ? _buildLocalPreviewOrProfile()
                    : const SizedBox.shrink()),

                /// Call Control Buttons
                _buildCallControls(),

                /// End Call
                _buildEndCallButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================================
  /// 🔹 Call Background (Video or Loading)
  Widget _buildCallBackground() {
    final isVideoCall = controller.callType.value.toUpperCase() != "AUDIO";

    if (!isVideoCall) {
      return _getAudioCallView();
    }

      return _getVideoCallView("919000000008@xmpp-uikit-qa.contus.us", "Large");
    // }

    // Waiting for tracks
    return _loadingVideoContainer();
  }

  /// 🔹 Local Preview (Video / Profile Pic for audio)
  Widget _buildLocalPreviewOrProfile() {
    final isVideoCall = controller.callType.value.toUpperCase() != "AUDIO";

    if (isVideoCall) {
      if (controller.isLocalTracksPublished.value &&
          controller.isRemoteTracksPublished.value) {
        return _buildVideoPreview(controller.localParticipantId.value);
      }
      return const Offstage();
    }

    // Audio call -> show profile image
    return Align(
      alignment: Alignment.bottomRight,
      child: FutureBuilder(
        future: getProfileDetails(SessionManagement.getUserJID().checkNull()),
        builder: (ctx, snap) {
          if (snap.hasData && snap.data != null) {
            return buildProfileImage(
              snap.data!,
              size: AppStyleConfig.outgoingCallPageStyle.profileImageSize.width,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// 🔹 Video Call View
  Widget _getVideoCallView(String participantId, String from) {
    print("[MirrorFly] [MirrorFlyCall] Getting video view from: $from ,for participant: $participantId");

    // if (participantId == controller.localParticipantId.value) {
    //   // Local participant
    //   print("[MirrorFly] [MirrorFlyCall] Returning LOCAL video view for $participantId");
      return MirrorFlyCallView(key: UniqueKey(),participantIdentity: participantId);
    // } else {
    //   // Remote participant
    //   print("[MirrorFly] [MirrorFlyCall] Returning REMOTE video view for $participantId");
    //   return MirrorFlyCallView(participantIdentity: participantId);
    // }
  }

  /// 🔹 Local Video Preview
  Widget _buildVideoPreview(String participantId) {
    print("[MirrorFly] [MirrorFlyCall] Building local video preview for participant: $participantId");
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        height: 120,
        width: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 8),
              blurRadius: 20,
              color: Colors.black38,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: _getVideoCallView("919000000009@xmpp-uikit-qa.contus.us", "Small"),
        ),
      ),
    );
  }

  /// 🔹 Audio Call View
  Widget _getAudioCallView() {
    return RipplesAnimation(
      onPressed: () {},
      child: FutureBuilder(
        future: getProfileDetails(
          controller.isOnGoingCallViewEnable.value
              ? controller.callerUsersId[0]!
              : SessionManagement.getUserJID().checkNull(),
        ),
        builder: (ctx, snap) {
          if (snap.hasData && snap.data != null) {
            return buildProfileImage(
              snap.data!,
              size: AppStyleConfig.outgoingCallPageStyle.profileImageSize.width,
            );
          }
          return const Offstage();
        },
      ),
    );
  }

  /// 🔹 Gradient Overlay
  Widget _buildGradientOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1D1D35),
            Colors.transparent,
            Colors.transparent,
            Color(0xFF1D1D35),
          ],
          stops: [0, 0.2, 0.6, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  /// 🔹 Loading Container (Video Connecting)
  Widget _loadingVideoContainer() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text(
              "Connecting...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Call Control Buttons
  Widget _buildCallControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCallOption(
            icon: Obx(() => Icon(
              controller.speakerOn.value
                  ? Icons.volume_up
                  : Icons.hearing,
              color: Colors.white,
            )),
            onTap: controller.changeSpeaker,
          ),
          _buildCallOption(
            icon: Obx(() => Icon(
              controller.muted.value ? Icons.mic_off : Icons.mic,
              color: Colors.white,
            )),
            onTap: controller.muteAudio,
          ),
          Obx(() => controller.callType.value == CallType.video
              ? _buildCallOption(
            icon: Icon(
              controller.videoMuted.value
                  ? Icons.videocam_off
                  : Icons.videocam,
              color: Colors.white,
            ),
            onTap: controller.videoMute,
          )
              : const SizedBox.shrink()),
          _buildCallOption(
            icon: const Icon(Icons.switch_camera, color: Colors.white),
            onTap: controller.switchCamera,
          ),
        ],
      ),
    );
  }

  /// 🔹 End Call Button
  Widget _buildEndCallButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: InkWell(
        onTap: controller.localHangup,
        child: Container(
          height: 72,
          width: 72,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 8),
                blurRadius: 20,
                color: Colors.black45,
              )
            ],
          ),
          child: const Icon(Icons.call_end, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  /// 🔹 Call Option Button
  Widget _buildCallOption({required Widget icon, required VoidCallback onTap}) {
    return Obx(() => Visibility(
      visible: controller.isIconEnable.value,
      child: InkWell(
        onTap: controller.isIconEnable.value ? onTap : null,
        child: Container(
          height: 56,
          width: 56,
          decoration: const BoxDecoration(
            color: Colors.white10,
            shape: BoxShape.circle,
          ),
          child: Center(child: icon),
        ),
      ),
    ));
  }
}
