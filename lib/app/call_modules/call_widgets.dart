import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/outgoing_call/call_controller.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_plugin/model/user_list_model.dart';

Widget buildProfileImage(Profile item) {
  return ImageNetwork(
    url: item.image.toString(),
    width: 105,
    height: 105,
    clipOval: true,
    errorWidget: item.isGroupProfile.checkNull()
        ? ClipOval(
      child: Image.asset(
        groupImg,
        height: 48,
        width: 48,
        fit: BoxFit.cover,
      ),
    )
        : ProfileTextImage(
      text: item.getName(),
      radius: 50,
    ),
    isGroup: item.isGroupProfile.checkNull(),
    blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
    unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),
  );
}

class SpeakingDots extends StatefulWidget {
  const SpeakingDots({Key? key, required this.audioLevel, required this.bgColor}) : super(key: key);
  final int audioLevel;
  final Color bgColor;

  @override
  State<SpeakingDots> createState() => _SpeakingDotsState();
}

class _SpeakingDotsState extends State<SpeakingDots> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: widget.bgColor,
      radius: 13,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: showAudioLevel(widget.audioLevel),
      ),
    );
  }

  List<Widget> showAudioLevel(int audioLevel) {
    switch (audioLevel.getAudioLevel()) {
      case AudioLevel.audioTooLow:
        return tooLowAudioLevel();
      case AudioLevel.audioLow:
        return lowAudioLevel();
      case AudioLevel.audioMedium:
        return mediumAudioLevel();
      case AudioLevel.audioHigh:
        return highAudioLevel();
      case AudioLevel.audioPeak:
        return peakAudioLevel();
      default:
        return tooLowAudioLevel();
    }
  }

  List<Widget> tooLowAudioLevel() {
    return [
      Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
    ];
  }

  List<Widget> lowAudioLevel() {
    return [
      Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 8,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
    ];
  }

  List<Widget> mediumAudioLevel() {
    return [
      Container(
        width: 4,
        height: 6,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 10,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 6,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
    ];
  }

  List<Widget> highAudioLevel() {
    return [
      Container(
        width: 4,
        height: 8,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 12,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 8,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
    ];
  }

  List<Widget> peakAudioLevel() {
    return [
      Container(
        width: 4,
        height: 10,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 12,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 10,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
    ];
  }
}

Widget buildCallItem(CallController controller) {
  return Obx(() {
    return controller.layoutSwitch.value ? SizedBox(
      height: 135,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.callList.length,
          reverse: controller.callList.length <= 2 ? true : false,
          itemBuilder: (context, index) {
            return index != 1 ? Container(
                height: 135,
                width: 100,
                margin: const EdgeInsets.only(left: 10),
                child: Stack(
                  children: [
                    MirrorFlyView(
                      userJid: controller.callList[index].userJid ?? "",
                      viewBgColor: AppColors.callerTitleBackground,
                      profileSize: 50,
                    ).setBorderRadius(const BorderRadius.all(Radius.circular(10))),
                    controller.speakingUsers.isNotEmpty && !controller
                        .audioLevel(controller.callList[0].userJid)
                        .isNegative && !controller.muted.value
                        ? Positioned(
                        top: 8,
                        right: 8,
                        child: SpeakingDots(
                          audioLevel: controller.audioLevel(controller.callList[index].userJid),
                          bgColor: const Color(0xff3abf87),
                        ))
                        : const SizedBox.shrink(),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      right: 8,
                      child: FutureBuilder<String>(
                          future: controller.getNameOfJid(controller.callList[index].userJid.checkNull()),
                          builder: (context, snapshot) {
                            if (!snapshot.hasError && snapshot.data
                                .checkNull()
                                .isNotEmpty) {
                              return Text(
                                snapshot.data.checkNull(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                    )
                  ],
                )) : const SizedBox.shrink();
          }
      ),
    ) : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // number of items in each row
            mainAxisSpacing: 8.0, // spacing between rows
            crossAxisSpacing: 2.0, // spacing between columns
          ),
          padding: const EdgeInsets.all(8.0),
          // padding around the grid
          itemCount: controller.callList.length,
          // total number of items
          itemBuilder: (context, index) {
            return Container(
                height: 160,
                width: 160,
                margin: const EdgeInsets.only(left: 10),
                child: Stack(
                  children: [
                    MirrorFlyView(
                      userJid: controller.callList[index].userJid ?? "",
                      viewBgColor: AppColors.callerTitleBackground,
                      profileSize: 50,
                    ).setBorderRadius(const BorderRadius.all(Radius.circular(10))),
                    controller.speakingUsers.isNotEmpty && !controller
                        .audioLevel(controller.callList[0].userJid)
                        .isNegative && !controller.muted.value
                        ? Positioned(
                        top: 8,
                        right: 8,
                        child: SpeakingDots(
                          audioLevel: controller.audioLevel(controller.callList[index].userJid),
                          bgColor: const Color(0xff3abf87),
                        ))
                        : const SizedBox.shrink(),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      right: 8,
                      child: FutureBuilder<String>(
                          future: controller.getNameOfJid(controller.callList[index].userJid.checkNull()),
                          builder: (context, snapshot) {
                            if (!snapshot.hasError && snapshot.data
                                .checkNull()
                                .isNotEmpty) {
                              return Text(
                                snapshot.data.checkNull(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                    )
                  ],
                ));
          },
        ),
      ],
    );
  });
}
