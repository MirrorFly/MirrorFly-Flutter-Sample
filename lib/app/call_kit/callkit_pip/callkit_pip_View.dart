import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_pip/callkit_pip_controller.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../../common/constants.dart';
import '../../extensions/extensions.dart';

class CallkitPipView extends NavViewStateful<CallKitPipController> {
  const CallkitPipView({Key? key}) : super(key: key);

  @override
  CallKitPipController createController({String? tag}) =>
      Get.put(CallKitPipController(), tag: tag);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Obx(() {
              return _buildDynamicLayout(controller.callerList, controller.callerList.length);
            }),

          /// Tap overlay
          GestureDetector(
            onTap: () {
              controller.showExpand(!controller.showExpand.value);
            },
            child: Container(color: Colors.transparent),
          ),

          /// Expand Button
          Obx(() {
            return Visibility(
              visible:
              !controller.isPIPActive.value && controller.showExpand.value,
              child: Container(
                color: controller.showExpand.value ? Colors.black38 : null,
                child: Center(
                  child: IconButton(
                    iconSize: 32,
                    onPressed: controller.expandPIP,
                    icon: const Icon(
                      Icons.crop_free,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),


          /// Close Button (Top Right)
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                controller.closePip();
              },
              child: Container(
                height: 26,
                width: 26,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        ],
        ),   // Stack
      ),     // ClipRect
    );
  }

  Widget _buildDynamicLayout(List<FlyCallParticipant> participants, int total) {
    /// 1 USER
    if (total == 1) {
      return _buildTile(participants[0]);
    }

    /// 2 USERS (vertical)
    if (total == 2) {
      return Column(
        children: [
          Expanded(child: _buildTile(participants[0])),
          const SizedBox(height: 4),
          Expanded(child: _buildTile(participants[1])),
        ],
      );
    }

    /// 3 USERS (2 top + 1 full bottom)
    if (total == 3) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildTile(participants[0])),
                const SizedBox(width: 4),
                Expanded(child: _buildTile(participants[1])),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _buildTile(participants[2]),
          ),
        ],
      );
    }

    /// 4 USERS (2x2 grid)
    if (total == 4) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildTile(participants[0])),
                const SizedBox(width: 4),
                Expanded(child: _buildTile(participants[1])),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildTile(participants[2])),
                const SizedBox(width: 4),
                Expanded(child: _buildTile(participants[3])),
              ],
            ),
          ),
        ],
      );
    }

    /// MORE THAN 4 USERS (2x2 with +X more)
    final remaining = total - 3;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildTile(participants[0])),
              const SizedBox(width: 4),
              Expanded(child: _buildTile(participants[1])),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildTile(participants[2])),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "+$remaining more",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTile(FlyCallParticipant participant) {
    return MirrorFlyCallView(
      isLocalPreviewView: false,
      key: ValueKey(participant.identity),
      userJID: participant.identity,
      fit: BoxFit.cover,
      viewBgColor: AppColors.callerTitleBackground,
      profileImage: controller.getUserProfileImageWithName(
        isGroup: controller.callMode.string == 'ONE-TO-ONE' || controller.isOnGoingCallViewEnable.value ? false : true,
        participantId: participant.identity,
      ),
    );
  }
}
