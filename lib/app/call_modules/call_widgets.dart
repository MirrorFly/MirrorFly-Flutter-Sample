import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirror_fly_demo/app/call_modules/outgoing_call/call_controller.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_plugin/model/user_list_model.dart';

Widget buildProfileImage(Profile item, {double size = 105}) {
  return ImageNetwork(
    url: item.image.toString(),
    width: size,
    height: size,
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
      radius: size / 2,
    ),
    isGroup: item.isGroupProfile.checkNull(),
    blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
    unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),
  );
}

class SpeakingDots extends StatefulWidget {
  const SpeakingDots({Key? key, required this.audioLevel, required this.bgColor, this.radius = 14}) : super(key: key);
  final double radius;
  final int audioLevel;
  final Color bgColor;

  @override
  State<SpeakingDots> createState() => _SpeakingDotsState();
}

class _SpeakingDotsState extends State<SpeakingDots> {
  @override
  Widget build(BuildContext context) {
    // debugPrint("widget.width * 0.4 ${14 * 0.90}");
    return CircleAvatar(
      backgroundColor: widget.bgColor,
      radius: widget.radius,
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
        width: widget.radius * 0.30,
        height: widget.radius * 0.30,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.30,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.30,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
    ];
  }

  List<Widget> lowAudioLevel() {
    return [
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.30,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4,)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.70,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.30,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
    ];
  }

  List<Widget> mediumAudioLevel() {
    return [
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.50,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.90,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.50,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
    ];
  }

  List<Widget> highAudioLevel() {
    return [
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.70,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.90,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.70,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
    ];
  }

  List<Widget> peakAudioLevel() {
    return [
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.90,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.90,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.90,
        decoration:
        BoxDecoration(
            color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
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
            return controller.callList[index].userJid!=controller.pinnedUserJid.value ? Container(
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
                    Obx(() {
                      return Positioned(
                        top: 0,
                        right: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              child: CircleAvatar(
                                backgroundColor: AppColors.audioMutedIconBgColor,
                                child: SvgPicture.asset(unpinUser),
                              ),
                            ),
                            if(controller.callList[index].isAudioMuted.value)...[
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: SizedBox(
                                  width: 20,
                                  child: CircleAvatar(
                                    backgroundColor: AppColors.audioMutedIconBgColor,
                                    child: SvgPicture.asset(callMutedIcon),
                                  ),
                                ),
                              ),
                            ],
                            if(controller.speakingUsers.isNotEmpty && !controller
                                .audioLevel(controller.callList[index].userJid)
                                .isNegative && !controller.muted.value)...[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 4.0),
                                child: SpeakingDots(
                                  radius: 9,
                                  audioLevel: controller.audioLevel(controller.callList[index].userJid),
                                  bgColor: AppColors.speakingBg,
                                ),
                              )
                            ],
                          ],),
                      );
                    }),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      right: 8,
                      child: FutureBuilder<String>(
                          future: CallUtils.getNameOfJid(controller.callList[index].userJid.checkNull()),
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
                    ),
                    /*Obx(() {
                      return (controller.callList[index].callStatus==CallStatus.ringing) ?
                      Container(color: AppColors.transBlack75, child: Center(
                        child: Text(controller.callList[index].callStatus.toString(), style: const TextStyle(color: Colors.white),),),) : const SizedBox.shrink();
                    })*/
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
                      profileSize: 60,
                    ).setBorderRadius(const BorderRadius.all(Radius.circular(10))),
                    Obx(() {
                      return Positioned(
                        top: 0,
                        right: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              child: CircleAvatar(
                                backgroundColor: AppColors.audioMutedIconBgColor,
                                child: SvgPicture.asset(unpinUser),
                              ),
                            ),
                            if(controller.callList[index].isAudioMuted.value)...[
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: SizedBox(
                                  width: 20,
                                  child: CircleAvatar(
                                    backgroundColor: AppColors.audioMutedIconBgColor,
                                    child: SvgPicture.asset(callMutedIcon),
                                  ),
                                ),
                              ),
                            ],
                            if(controller.speakingUsers.isNotEmpty && !controller
                                .audioLevel(controller.callList[index].userJid)
                                .isNegative && !controller.muted.value)...[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 4.0),
                                child: SpeakingDots(
                                  radius: 9,
                                  audioLevel: controller.audioLevel(controller.callList[index].userJid),
                                  bgColor: AppColors.speakingBg,
                                ),
                              )
                            ],
                          ],),
                      );
                    }),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      right: 8,
                      child: FutureBuilder<String>(
                          future: CallUtils.getNameOfJid(controller.callList[index].userJid.checkNull()),
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
                    ),
                    /*Obx(() {
                      return (controller.callList[index].callStatus==CallStatus.ringing) ?
                        Container(color: AppColors.transBlack75, child: Center(
                        child: Text(controller.callList[index].callStatus.toString(),style: const TextStyle(color: Colors.white)),),) : const SizedBox.shrink();
                    })*/
                  ],
                ));
          },
        ),
      ],
    );
  });
}
