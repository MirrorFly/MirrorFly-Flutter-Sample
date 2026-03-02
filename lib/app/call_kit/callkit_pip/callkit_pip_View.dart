
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
      body: GridView.builder(
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
                profileImage: controller.getUserProfileImageWithName(
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
                      /*if (participant.isAudioMuted != true) ...[
                        buildSpeakingIndicatorIcon(
                            controller.callerList[index].identity)
                      ]*/
                    ],
                  ),
                );
              }),

              /// Connection Quality Icon
              /*Obx(() {
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
              }),*/

              /// Name label
             /* Positioned(
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
              ),*/

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
    );
  }
}
