import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/audio_level_animation.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirror_fly_demo/app/call_modules/call_widgets.dart';
import 'package:mirror_fly_demo/app/call_modules/pip_view/pip_view_controller.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/model/call_user_list.dart';
import 'package:mirror_fly_demo/app/stylesheet/stylesheet.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';

class PIPView extends NavViewStateful<PipViewController> {
  const PIPView({Key? key, required this.style,this.pipTag})
      : super(key: key, tag: pipTag);
  final PIPViewStyle style;
  final String? pipTag;

  @override
  PipViewController createController({String? tag}) => Get.put(PipViewController(),tag: tag);

  @override
  Widget build(BuildContext context) {
    // debugPrint("PIPView build : NavUtils : ${NavUtils.width} , ${NavUtils.height}");
    return Scaffold(
        resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context,cons) {
          // debugPrint("PIPView build : cons : ${cons.maxWidth} , ${cons.maxHeight}");
          return InkWell(
            onTap: (){
              controller.showExpand(!controller.showExpand.value);
            },
            child: Stack(
              children: [
                Obx(() {
                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: controller.callList.length <= 2
                        ? controller.callList.length
                        : 2,
                    itemBuilder: (cxt, index) {
                      var item = controller.callList[index];
                      debugPrint("PIPView Obx callList : ${item.toJson()}");
                      return AspectRatio(
                        aspectRatio: Rational(
                           (cons.maxWidth.toInt()), controller.callList.length <2 ? (cons.maxHeight).toInt() : ((cons.maxHeight).toInt()~/2)).aspectRatio,
                        child: MirrorflyPIPItem(
                          item: item,
                          userStyle: style.userTileStyle,
                          controller: controller,
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(
                        height: 0.2,
                        color: Colors.grey,
                      );
                    },
                  );
                }),
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
                Obx((){
                  var count = controller.callList.length - 2;
                  return count.isLowerThan(1) ? const Offstage() : Positioned(
                    right: 8,
                    bottom: 8,
                    child: CircleAvatar(
                      backgroundColor: style.countBgColor,
                      radius: 9,
                      child: Text(
                        "+$count",
                        style: style.countStyle,
                      ),
                    ),
                  );
                })
              ],
            ),
          );
        }
      ),
    );
  }
}

class MirrorflyPIPItem extends StatelessWidget {
  const MirrorflyPIPItem(
      {super.key,
        // required this.width,
        // required this.height,
        required this.item,
        required this.userStyle,
        required this.controller});

  // final double width;
  // final double height;
  final CallUserList item;
  final CallUserTileStyle userStyle;
  final PipViewController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          return (item.userJid?.value).checkNull().isNotEmpty
              ? MirrorFlyView(
                key: UniqueKey(),
                userJid: (item.userJid?.value).checkNull(),
                viewBgColor: userStyle.backgroundColor,
                profileSize: userStyle.profileImageSize,
              ).setBorderRadius(userStyle.borderRadius)
              : Container(
            width: double.infinity,
            height: double.infinity,
            color: userStyle.backgroundColor,
            decoration: BoxDecoration(borderRadius: userStyle.borderRadius),
          );
        }),
        SpeakingIndicatorItem(item: item, style: userStyle, controller: controller),
        MirrorflyUsernameView(item: item, style: userStyle),
        UserCallStatusView(//width: width,height: height,
            item: item, controller: controller, style: userStyle),
      ],
    );
  }
}

class UserCallStatusView extends StatelessWidget {
  const UserCallStatusView({
    super.key,
    // required this.width, required this.height,
    required this.style,
    required this.item,
    required this.controller,
  });

  // final double width;
  // final double height;
  final CallUserList item;
  final PipViewController controller;
  final CallUserTileStyle style;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      debugPrint(
          "getUserJID ${item.userJid} ${item.callStatus} current user ${item.userJid!.value == SessionManagement.getUserJID()}");
      return (getTileCallStatus(item.callStatus?.value,
          item.userJid!.value.checkNull(), controller.isOneToOneCall)
          .isNotEmpty)
          ? Container(
        decoration: BoxDecoration(
          color: Colors.black
              .withOpacity(0.5), // Adjust the color and opacity as needed
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: Text(
              getTileCallStatus(item.callStatus?.value,
                  item.userJid!.value.checkNull(), controller.isOneToOneCall),
              style: style.callStatusTextStyle,
              // style: const TextStyle(color: Colors.white),
            )),
      )
          : const Offstage();
    });
  }
}

class MirrorflyUsernameView extends StatelessWidget {
  const MirrorflyUsernameView({
    super.key,
    required this.item,
    required this.style,
  });

  final CallUserList item;
  final CallUserTileStyle style;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      bottom: 8,
      right: 8,
      child: Obx(() {
        return FutureBuilder<String>(
            future: CallUtils.getNameOfJid(item.userJid!.value.checkNull()),
            builder: (context, snapshot) {
              if (!snapshot.hasError && snapshot.data.checkNull().isNotEmpty) {
                return Text(
                  snapshot.data.checkNull(),
                  style: style.nameTextStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                );
              }
              return const Offstage();
            });
      }),
    );
  }
}

class SpeakingIndicatorItem extends StatelessWidget {
  const SpeakingIndicatorItem({
    super.key,
    required this.item,
    required this.style,
    required this.controller,
  });

  final CallUserList item;
  final CallUserTileStyle style;
  final PipViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Positioned(
        top: 8,
        right: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (item.isAudioMuted.value) ...[
              CircleAvatar(
                radius: 10,
                backgroundColor: style.muteActionStyle
                    .activeBgColor, //AppColors.audioMutedIconBgColor,
                child: AppUtils.svgIcon(
                  icon: callMutedIcon,
                  colorFilter: ColorFilter.mode(
                      style.muteActionStyle.activeIconColor, BlendMode.srcIn),
                ),
              ),
            ],
            if (controller.speakingUsers.isNotEmpty &&
                !item.isAudioMuted.value &&
                !controller.audioLevel(item.userJid!.value).isNegative) ...[
              AudioLevelAnimation(
                radius: 9,
                audioLevel: controller.audioLevel(item.userJid!.value),
                bgColor: style.speakingIndicatorStyle
                    .activeBgColor, //AppColors.speakingBg,
                dotsColor: style.speakingIndicatorStyle.activeIconColor,
              )
            ],
          ],
        ),
      );
    });
  }
}
