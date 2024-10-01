import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/call_modules/audio_level_animation.dart';
import '../../app/call_modules/call_utils.dart';
import '../../app/call_modules/outgoing_call/call_controller.dart';
import '../../app/common/app_localizations.dart';
import '../../app/common/constants.dart';
import '../../app/common/widgets.dart';
import '../../app/data/session_management.dart';
import '../../app/data/utils.dart';
import '../../app/extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../stylesheet/stylesheet.dart';

Widget buildProfileImage(ProfileDetails item, {double size = 105}) {
  return ImageNetwork(
    url: item.image.toString(),
    width: size,
    height: size,
    clipOval: true,
    errorWidget: item.isGroupProfile.checkNull()
        ? ClipOval(
      child: AppUtils.assetIcon(assetName:
        groupImg,
        height: size,
        width: size,
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
  const SpeakingDots({Key? key, required this.audioLevel, required this.bgColor, this.radius = 14, this.dotsColor = Colors.white}) : super(key: key);
  final double radius;
  final int audioLevel;
  final Color bgColor;
  final Color dotsColor;

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
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.30,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.30,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
    ];
  }

  List<Widget> lowAudioLevel() {
    return [
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.30,
        decoration: BoxDecoration(
            color: widget.dotsColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(
              widget.radius * 0.4,
            )),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.70,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.30,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
    ];
  }

  List<Widget> mediumAudioLevel() {
    return [
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.50,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.90,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.50,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
    ];
  }

  List<Widget> highAudioLevel() {
    return [
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.70,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.90,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.70,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
    ];
  }

  List<Widget> peakAudioLevel() {
    return [
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.90,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.90,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
      SizedBox(
        width: widget.radius * 0.20,
      ),
      Container(
        width: widget.radius * 0.30,
        height: widget.radius * 0.90,
        decoration: BoxDecoration(
            color: widget.dotsColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(widget.radius * 0.4)),
      ),
    ];
  }
}

Widget buildListItem(CallController controller,CallUserTileStyle style) {
  var callListLength = controller.callList.length;
  debugPrint("callListLength --> $callListLength");
  return SizedBox(
    height: 135,
    width: double.infinity,
    child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.callList.length,
        reverse: controller.callList.length <= 2 ? true : false,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          debugPrint(
              "ListBuilder ${controller.callList.length} userJid ${controller.callList[index]
                  .userJid} pinned ${controller.pinnedUserJid.value}");
          return controller.callList[index].userJid!.value != controller.pinnedUserJid.value
              ? Container(
              height: 135,
              width: 100,
              margin: const EdgeInsets.only(left: 10),
              child: Stack(
                children: [
                  MirrorFlyView(
                    key: UniqueKey(),
                    userJid: controller.callList[index].userJid?.value ?? "",
                    viewBgColor: style.backgroundColor,//AppColors.callerTitleBackground,
                    profileSize: style.profileImageSize,
                    onClick: (){
                      //swap View
                      controller.swap(index);
                    },
                  ).setBorderRadius(style.borderRadius),
                  Obx(() {
                    return Positioned(
                          top: 8,
                      right: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (controller.callList[index].isAudioMuted.value) ...[
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: style.muteActionStyle.activeBgColor,//AppColors.audioMutedIconBgColor,
                              child: AppUtils.svgIcon(icon: callMutedIcon,colorFilter: ColorFilter.mode(style.muteActionStyle.activeIconColor, BlendMode.srcIn),),
                            ),
                          ],
                          if (controller.speakingUsers.isNotEmpty &&
                                !controller.callList[index].isAudioMuted.value &&
                                !controller.audioLevel(controller.callList[index].userJid!.value).isNegative) ...[
                                AudioLevelAnimation(
                                  radius: 9,
                                  audioLevel: controller.audioLevel(controller.callList[index].userJid!.value),
                                  bgColor: style.speakingIndicatorStyle.activeBgColor,//AppColors.speakingBg,
                                  dotsColor: style.speakingIndicatorStyle.activeIconColor,
                                )
                         ],
                        ],
                      ),
                    );
                  }),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    right: 8,
                    child: Obx(() {
                      return FutureBuilder<String>(
                          future: CallUtils.getNameOfJid(controller.callList[index].userJid!.value.checkNull()),
                          builder: (context, snapshot) {
                            if (!snapshot.hasError && snapshot.data
                                .checkNull()
                                .isNotEmpty) {
                              return Text(
                                snapshot.data.checkNull(),
                                style: style.nameTextStyle,
                                /*style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),*/
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              );
                            }
                            return const SizedBox.shrink();
                          });
                    }),
                  ),
                  Obx(() {
                    debugPrint(
                        "getUserJID ${controller.callList[index].userJid} ${controller.callList[index]
                            .callStatus} current user ${controller.callList[index].userJid!.value ==
                            SessionManagement.getUserJID()}");
                    return (getTileCallStatus(
                        controller.callList[index].callStatus?.value,
                        controller.callList[index].userJid!.value.checkNull(), controller.isOneToOneCall)
                        .isNotEmpty)
                        ? Container(
                      decoration: BoxDecoration(
                        color:
                        Colors.black.withOpacity(0.5), // Adjust the color and opacity as needed
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      width: 100,
                      height: 135,
                      child: Center(
                          child: Text(
                            getTileCallStatus(controller.callList[index].callStatus?.value,
                                controller.callList[index].userJid!.value.checkNull(), controller.isOneToOneCall),
                            style: style.callStatusTextStyle,
                            // style: const TextStyle(color: Colors.white),
                          )),
                    )
                        : const Offstage();
                  }),
                ],
              ))
              : const Offstage();
        }),
  );
}

Widget buildGridItem(CallController controller,CallUserTileStyle style) {
  return GestureDetector(
    onTap: () {
      if (controller.callType.value == CallType.video) {
        controller.isVisible(!controller.isVisible.value);
      }
    },
    child: GridView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: controller.callList.length > 2 ? 2 : 1, // number of items in each row
          mainAxisSpacing: 4.0, // spacing between rows
          crossAxisSpacing: 2.0, // spacing between columns
          childAspectRatio: controller.callList.length == 2 ? 1.23 : 1.0
      ),
      padding: const EdgeInsets.all(8.0),
      // padding around the grid
      itemCount: controller.callList.length,
      // total number of items
      itemBuilder: (context, index) {
        return Stack(
          children: [
            MirrorFlyView(
              key: UniqueKey(),
              userJid: controller.callList[index].userJid?.value ?? "",
              viewBgColor: style.backgroundColor,//AppColors.callerTitleBackground,
              profileSize: style.profileImageSize,
              onClick: (){
                // if(controller.callType.value==CallType.video) {
                  controller.isVisible(!controller.isVisible.value);
                // }
              }
            ).setBorderRadius(style.borderRadius),
            Obx(() {
              return Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (controller.callList[index].isAudioMuted.value) ...[
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: style.muteActionStyle.activeBgColor,//AppColors.audioMutedIconBgColor,
                        child: AppUtils.svgIcon(icon:callMutedIcon,colorFilter: ColorFilter.mode(style.muteActionStyle.activeIconColor, BlendMode.srcIn),),
                      ),
                    ],
                    if (controller.speakingUsers.isNotEmpty &&
                        !controller.callList[index].isAudioMuted.value &&
                        !controller.audioLevel(controller.callList[index].userJid!.value).isNegative) ...[
                      AudioLevelAnimation(
                        radius: 12,
                        audioLevel: controller.audioLevel(controller.callList[index].userJid!.value),
                        bgColor: style.speakingIndicatorStyle.activeBgColor,//AppColors.speakingBg,
                        dotsColor: style.speakingIndicatorStyle.activeIconColor,
                      ),
                    ],
                  ],
                ),
              );
            }),
            Positioned(
              left: 8,
              bottom: 8,
              right: 8,
              child: Obx(() {
                // debugPrint("name changed ${controller.callList[index].userJid}");
                return FutureBuilder<String>(
                    future: CallUtils.getNameOfJid(controller.callList[index].userJid!.value.checkNull()),
                    builder: (context, snapshot) {
                      if (!snapshot.hasError && snapshot.data.checkNull().isNotEmpty) {
                        return Text(
                          snapshot.data.checkNull(),
                          style: style.nameTextStyle,
                          /*style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),*/
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }
                      return const Offstage();
                    });
              }),
            ),
            Obx(() {
              debugPrint(
                  "getUserJID ${controller.callList[index].userJid} ${controller.callList[index].callStatus} current user ${controller.callList[index].userJid!.value == SessionManagement.getUserJID()}");
              return (getTileCallStatus(controller.callList[index].callStatus?.value, controller.callList[index].userJid!.value.checkNull(),
                          controller.isOneToOneCall)
                      .isNotEmpty)
                  ? Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5), // Adjust the color and opacity as needed
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                            child: Text(
                          getTileCallStatus(controller.callList[index].callStatus?.value, controller.callList[index].userJid!.value.checkNull(),
                              controller.isOneToOneCall),
                              style: style.callStatusTextStyle,
                              // style: const TextStyle(color: Colors.white),
                        )),
                      ),
                    )
                  : const Offstage();
            }),
          ],
        );
      },
    ),
  );
}

String getTileCallStatus(String? callStatus, String userjid, bool isOnetoOneCall) {
  debugPrint("getTileCallStatus $callStatus isOnetoOneCall $isOnetoOneCall");
  switch (callStatus) {
    case CallStatus.connected:
    case CallStatus.callTimeout:
    case CallStatus.disconnected:
    case CallStatus.attended:
    case CallStatus.inviteCallTimeout:
    case CallStatus.onResume:
    case CallStatus.userJoined:
    case CallStatus.userLeft:
    case CallStatus.reconnected:
    case CallStatus.calling10s:
    case CallStatus.callingAfter10s:
      return '';
    case CallStatus.connecting:
      return userjid == SessionManagement.getUserJID() ? "" : "${getTranslated("connectingCall")}…";
    case CallStatus.ringing:
      return userjid == SessionManagement.getUserJID() ? "" : "${getTranslated("ringing")}…";
    case CallStatus.calling:
      return userjid == SessionManagement.getUserJID() ? "" : isOnetoOneCall ? "" : "${getTranslated("calling")}…";
    case CallStatus.onHold:
      return "${getTranslated("callOnHold")}…";
    case CallStatus.reconnecting:
      return "${getTranslated("reconnecting")}…";
    default:
      return '';
  }
}
