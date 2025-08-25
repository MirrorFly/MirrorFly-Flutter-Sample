import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';
import '../app_style_config.dart';
import '../call_modules/call_widgets.dart';
import '../call_modules/ripple_animation_view.dart';
import '../data/helper.dart';
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
          /// 🔹 Background (network image or MirrorFly video view)
          Obx(() {
            if (controller.callType.value == "video") {
              return const MirrorFlyCallView(
                participantIdentity: "917530066369",
              );
            } else {
              return RipplesAnimation(onPressed: () {  }, child: FutureBuilder(
                  future: getProfileDetails(
                      controller.users[0]!),
                  builder: (ctx, snap) {
                    return snap.hasData &&
                        snap.data != null
                        ? buildProfileImage(snap.data!,
                        size: AppStyleConfig
                            .outgoingCallPageStyle
                            .profileImageSize
                            .width)
                        : const Offstage();
                  }),);
            }
          }),

          /// 🔹 Gradient overlay
          Container(
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
          ),

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
                      fontWeight: FontWeight.w500),
                )),

                const Spacer(),

                /// Mini Self Preview (like WhatsApp)
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Container(
                //     margin: const EdgeInsets.all(16.0),
                //     height: 120,
                //     width: 96,
                //     decoration: const BoxDecoration(
                //       borderRadius: BorderRadius.all(Radius.circular(16.0)),
                //       boxShadow: [
                //         BoxShadow(
                //           offset: Offset(0, 8),
                //           blurRadius: 20,
                //           color: Colors.black38,
                //         ),
                //       ],
                //       image: DecorationImage(
                //         fit: BoxFit.cover,
                //         image: NetworkImage(
                //             "https://i.postimg.cc/0Q0n66Ff/call-bg.png"),
                //       ),
                //     ),
                //   ),
                // ),

                /// Control Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 16.0),
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
                          controller.muted.value
                              ? Icons.mic_off
                              : Icons.mic,
                          color: Colors.white,
                        )),
                        onTap: controller.muteAudio,
                      ),
                      _buildCallOption(
                        icon: Obx(() => Icon(
                          controller.videoMuted.value
                              ? Icons.videocam_off
                              : Icons.videocam,
                          color: Colors.white,
                        )),
                        onTap: controller.videoMute,
                      ),
                      _buildCallOption(
                        icon: const Icon(Icons.switch_camera,
                            color: Colors.white),
                        onTap: controller.switchCamera,
                      ),
                    ],
                  ),
                ),

                /// End Call Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: InkWell(
                    onTap: controller.disconnectCall,
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
                      child: const Icon(Icons.call_end,
                          color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallOption({required Widget icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        width: 56,
        decoration: const BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      ),
    );
  }
}
