import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../app_style_config.dart';
import '../call_modules/call_widgets.dart';
import '../common/constants.dart';
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
      backgroundColor: AppColors.audioCallerBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🔹 Background: video or placeholder
          // Obx(() => _buildCallMainView()),

          Obx(() {
            return controller.mainCallViewUserId.value.isNotEmpty ? MirrorFlyCallView(
                key: UniqueKey(),
                userJID: controller.mainCallViewUserId.value,viewBgColor: AppColors.audioCallerBackground,
                profileImage: getUserProfileImageWithName(
                    participantId: controller.mainCallViewUserId.value)) : const Offstage();
          }),

          /// 🔹 Gradient overlay
          _buildGradientOverlay(),

          /// 🔹 Foreground content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 40),
                Obx(() =>
                    Center(
                      child: Text(
                        controller.callStatus.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )),
                const SizedBox(height: 10,),
                Obx(() => Center(
                  child: Text(
                    controller.remoteUserName.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )),
                /// Call Status


                const Spacer(),

                /// Local Preview / Profile Image
                Obx(() =>
                controller.isOnGoingCallViewEnable.value
                    ? Container(
                  margin: const EdgeInsets.all(12.0),
                  height: 160,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 4),
                        blurRadius: 8,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  child: MirrorFlyCallView(
                      key: UniqueKey(),
                      userJID: controller.secondaryCallViewUserId.value,
                      viewBgColor: AppColors.callerBackground,
                      profileImage: getUserProfileImageWithName(
                          participantId:
                          controller.secondaryCallViewUserId.value)),
                )
                    : const SizedBox.shrink()),

                /// Call Control Buttons
                Center(child: _buildCallControls(context)),

                /// End Call
                Center(child: _buildEndCallButton()),
              ],
            ),
          ),
          ///  Remote mute status indicator
          Obx(() {
            if (controller.isOnGoingCallViewEnable.value) {
              return Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.only(top: 70, right: 30),
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: controller.isRemoteAudioMuted.value
                        ? Colors.white : Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.isRemoteAudioMuted.value
                        ? Icons.mic_off
                        : Icons.mic,
                    color: controller.isRemoteAudioMuted.value
                        ?Colors.red:Colors.white,
                    size: 20,
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget getUserProfileImageWithName({required String participantId}) {
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
                    2,
              ),
            ],
          );
        }
        return const Offstage();
      },
    );
  }

  ///  Gradient Overlay
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

  ///  Call Control Buttons
  Widget _buildCallControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: Obx(() =>
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCallOption(
                isActive: true,
                icon: _getCurrentAudioIcon(controller.selectedDevice.value),
                onTap: () async {
                  _showAudioDeviceSelector(context, controller);
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
                    controller.setCameraEnable(enable: !(controller.isVideoEnabled.value));
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
                isActive: false,
                icon: Icons.switch_video,
                onTap: controller.requestVideoCallSwitch,
              ),
            ],
          )),
    );
  }

  ///  End Call Button
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
            color: isActive ? Colors.red : Colors.white,
          ),
        ),
      ),
    );
  }
}

void _showAudioDeviceSelector(BuildContext context, CallKitOutgoingCallController controller) async {
  final availableTypes = await controller.getAvailableTypes();

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Center(
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
            children: availableTypes.map((type) {
              return ListTile(
                leading: Icon(
                  type == FlyCallAudioDeviceType.speaker
                      ? Icons.speaker_phone
                      : type == FlyCallAudioDeviceType.earpiece
                      ? Icons.phone_android
                      : type == FlyCallAudioDeviceType.bluetooth
                      ? Icons.bluetooth_audio
                      : Icons.headset,
                ),
                title: Text(type.name.capitalize!),
                trailing: controller.selectedDevice.value == type
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  controller.changeAudioDevice(type);
                  Navigator.of(context).pop(); // close dialog
                },
              );
            }).toList(),
          ),
        ),
      ),
    ),
  );
}

IconData _getCurrentAudioIcon(FlyCallAudioDeviceType? type) {
  switch (type) {
    case FlyCallAudioDeviceType.speaker:
      return Icons.volume_up;
    case FlyCallAudioDeviceType.earpiece:
      return Icons.hearing;
    case FlyCallAudioDeviceType.bluetooth:
      return Icons.bluetooth_audio;
    case FlyCallAudioDeviceType.wired:
      return Icons.headset;
    default:
      return Icons.volume_up;
  }
}


