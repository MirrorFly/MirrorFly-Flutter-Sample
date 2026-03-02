
import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_pip/callkit_pip_controller.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../common/constants.dart';
import '../../data/utils.dart';
import '../../extensions/extensions.dart';
import '../callkit_logger.dart';

class CallkitPipView extends NavViewStateful<CallKitPipController> {
  const CallkitPipView({Key? key})
      : super(key: key);


  @override
  CallKitPipController createController({String? tag}) =>
      Get.put(CallKitPipController(), tag: tag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<List<FlyCallParticipant>>(
            future: MirrorFlyCallKit.getCurrentCallParticipants().then((value) => value ?? []),
            builder: (context, snapshot) {

              /// Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              /// Error
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              /// No data
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No participants",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final participants = snapshot.data!;
              return GridView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: participants.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: participants.length > 2 ? 2 : 1,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 2.0,
                  childAspectRatio: participants.length == 2 ? 1.23 : 1.0,
                ),
                itemBuilder: (context, index) {

                  final participant = participants[index];

                  return Stack(
                    children: [

                      /// Video View
                      SizedBox(
                        // height: 60,
                        child: Stack(
                          children: [

                            MirrorFlyCallView(
                              isLocalPreviewView: false,
                              key: ValueKey(participant.identity),
                              userJID: participant.identity,
                              // fit: BoxFit.cover,
                              viewBgColor: AppColors.callerTitleBackground,
                              profileImage: controller.getUserProfileImageWithName(
                                isGroupGrid: false,
                                // isLocalTile: true,
                                participantId: participant.identity,
                                scale: 1.2,
                                callKind: participant.kind,
                              ),
                            ),
                            // controller.getUserProfileImageWithName(
                            //   isGroupGrid: true,
                            //   isLocalTile: true,
                            //   participantId: participant.identity,
                            //   scale: 1.2,
                            //   callKind: participant.kind,
                            // ),
                          ],
                        ),
                      ),

                      /// Audio Mute
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          children: [
                            if (participant.isAudioMuted == true)
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.grey,
                                child: AppUtils.svgIcon(
                                  icon: callMutedIcon,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      /// Call status overlay
                      Builder(
                        builder: (_) {
                          final isSelf =
                          controller.isSelfId(id: participant.identity);

                          final connectionState =
                          controller.getParticipantConnectionState(
                              participant.flyCallStatusEvent);

                          if ((!isSelf && connectionState.isNotEmpty) ||
                              (isSelf &&
                                  connectionState == "Reconnecting")) {

                            return Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
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

                          return const SizedBox();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),

          GestureDetector(onTap: (){
            controller.showExpand(!controller.showExpand.value);
          },
              child: Container(color: Colors.transparent,)),
          Obx((){
            return Visibility(
              visible: !controller.isPIPActive.value && controller.showExpand.value,
              child: Container(
                color: controller.showExpand.value ? Colors.black38 : null,
                child: Center(
                  child: IconButton(
                      iconSize: 32,
                      onPressed: (){
                        controller.expandPIP();
                      },
                      icon: const Icon(
                        Icons.crop_free,
                        color: Colors.white,
                      )),
                ),
              ),
            );
          }),
        ],
      )
    );
  }
}
