import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../../data/session_management.dart';
import '../../extensions/extensions.dart';
import 'callkit_ongoing_call_controller.dart';

class CallKitOnGoingCallView
    extends NavViewStateful<CallKitOnGoingCallController> {
  const CallKitOnGoingCallView({super.key});

  @override
  CallKitOnGoingCallController createController({String? tag}) =>
      Get.put(CallKitOnGoingCallController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Container(
        color: Colors.black,
        child: SafeArea(
          bottom: Platform.isAndroid,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              fit: StackFit.expand,
              children: [
                /// 🔹 Remote Video fills screen
                Obx(() {
                  return controller.callType.value == "video"
                      ? MirrorFlyCallView(
                    key: UniqueKey(),
                    participantIdentity: "919000000009", // remote JID
                  )
                      : const Center(
                    child: Icon(Icons.call,
                        size: 80, color: Colors.white),
                  );
                }),

                /// 🔹 Local Video (small preview bottom-right)
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
                        participantIdentity:
                        "917530066369",
                      )
                          : const SizedBox();
                    }),
                  ),
                ),

                /// 🔹 Call Info (Name + Timer)
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Obx(() => Text(
                        controller.callStatus.value,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18),
                      )),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        controller.callTimer.value,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14),
                      )),
                    ],
                  ),
                ),

                /// 🔹 Call Controls
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
                        icon: const Icon(Icons.switch_camera,
                            color: Colors.white),
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

                /// 🔹 End Call Button
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

                /// 🔹 PIP Button
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
