import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.blueGrey],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🔹 Call Status
              Obx(() => Text(
                controller.callStatus.value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              )),
              const SizedBox(height: 12),

              /// 🔹 MirrorFlyView for video calls
              Obx(() {
                return controller.callType.value == "video"
                    ? const Expanded(
                  child: MirrorFlyCallView(
                     participantIdentity: '917530066369',
                  ),
                )
                    : const Icon(Icons.phone_in_talk,
                    color: Colors.white, size: 80);
              }),

              const SizedBox(height: 24),

              /// 🔹 Control Buttons
              Row(
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

              const SizedBox(height: 24),

              /// 🔹 End Call Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, shape: const CircleBorder()),
                onPressed: controller.disconnectCall,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(Icons.call_end, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
