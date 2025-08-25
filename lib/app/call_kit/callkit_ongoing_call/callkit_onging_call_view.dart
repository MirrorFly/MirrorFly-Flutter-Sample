import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../../extensions/extensions.dart';
import 'callkit_ongoing_call_controller.dart';

class CallKitOngoingCallView
    extends NavViewStateful<CallKitOnGoingCallController> {
  const CallKitOngoingCallView({super.key});

  @override
  CallKitOnGoingCallController createController({String? tag}) =>
      Get.put(CallKitOnGoingCallController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: Container(
        color: Colors.black,
        child: SafeArea(
          bottom: Platform.isAndroid,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              fit: StackFit.expand,
              children: [
                /// 🔹 Remote video or placeholder
                Obx(() {
                  return controller.callType.value == "video"
                      ? Container(
                    color: Colors.red,
                       height: 100,
                        width: double.infinity,
                        child: MirrorFlyCallView(
                                            key: UniqueKey(),
                                            participantIdentity: "919000000009", // remote JID
                                          ),
                      )
                      : const Center(
                    child: Icon(Icons.call,
                        size: 80, color: Colors.white),
                  );
                }),

                /// 🔹 Gradient overlay like FlutterFlow
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1D1D35),
                        Colors.transparent,
                        Colors.transparent,
                        Color(0xFF1D1D35),
                      ],
                      stops: [0, 0.2, 0.5, 1],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                /// 🔹 Call info (status + timer)
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Obx(() => Text(
                        controller.callStatus.value,
                        style:
                        const TextStyle(color: Colors.white, fontSize: 18),
                      )),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        controller.callTimer.value,
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 14),
                      )),
                    ],
                  ),
                ),

                /// 🔹 Local camera preview bottom-right
                Positioned(
                  right: 16,
                  bottom: 160,
                  width: 120,
                  height: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Obx(() {
                      return controller.callType.value == "video"
                          ? MirrorFlyCallView(
                        key: UniqueKey(),
                        participantIdentity: "917530066369", // local JID
                      )
                          : const SizedBox();
                    }),
                  ),
                ),

                /// 🔹 Call control buttons
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(() => IconButton(
                        icon: Icon(
                            controller.muted.value
                                ? Icons.mic_off
                                : Icons.mic,
                            color: Colors.white),
                        onPressed: controller.muteAudio,
                      )),
                      Obx(() => IconButton(
                        icon: Icon(
                            controller.videoMuted.value
                                ? Icons.videocam_off
                                : Icons.videocam,
                            color: Colors.white),
                        onPressed: controller.videoMute,
                      )),
                      IconButton(
                        icon: const Icon(Icons.switch_camera, color: Colors.white),
                        onPressed: controller.switchCamera,
                      ),
                      Obx(() => IconButton(
                        icon: Icon(
                            controller.speakerOn.value
                                ? Icons.volume_up
                                : Icons.hearing,
                            color: Colors.white),
                        onPressed: controller.changeSpeaker,
                      )),
                    ],
                  ),
                ),

                /// 🔹 End call button
                Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(18),
                      ),
                      onPressed: controller.disconnectCall,
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ),
                ),

                /// 🔹 Optional: PIP button top-left
                Positioned(
                  left: 10,
                  top: 10,
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white),
                    onPressed: controller.goToPIP,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
