import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/app_localizations.dart';

import 'package:mirrorfly_plugin/mirrorfly_view.dart';

import '../../app_style_config.dart';
import '../../common/constants.dart';
import '../../common/widgets.dart';
import '../../data/helper.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../../extensions/extensions.dart';
import '../../stylesheet/stylesheet.dart';
import '../call_utils.dart';
import '../call_widgets.dart';
import 'join_call_controller.dart';

class JoinCallPreviewView extends NavViewStateful<JoinCallController> {
  const JoinCallPreviewView({super.key});

  @override
  JoinCallController createController({String? tag}) =>
      Get.put(JoinCallController());

  @override void onDispose() {
    controller.disposePreview();
    super.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyleConfig.joinCallPreviewPageStyle
          .backgroundDecoration,
      child: Theme(
        data: ThemeData(
            appBarTheme: AppStyleConfig.joinCallPreviewPageStyle.appBarTheme),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: true,
          ),
          body: SafeArea(
            child: Obx(() {
              return controller.callEnded.isEmpty ? Column(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Obx(() {
                          return FutureBuilder(future: CallUtils.getCallersName(
                              controller.users, false),
                              builder: (ctx, snap) {
                                return Text(
                                  snap.hasData && snap.data != null &&
                                      snap.data!.isNotEmpty
                                      ? snap.data!
                                      : getTranslated("noOneHere"),
                                  style: AppStyleConfig.joinCallPreviewPageStyle
                                      .callerNameTextStyle,
                                  overflow: TextOverflow.ellipsis,);
                              });
                        }),
                      ),
                    ],
                  ),
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          controller.users.length > 3 ? 4 : controller.users
                              .length, (index) =>
                      (index == 3) ? Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: ProfileTextImage(
                          text: "+${(controller.users.length) - 3}",
                          radius: 45 / 2,
                          bgColor: Colors.white,
                          fontColor: const Color(0xff12233E),
                        ),
                      ) : FutureBuilder(future: getProfileDetails(
                          controller.users[index]!), builder: (ctx, snap) {
                        return snap.hasData && snap.data != null ? Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: buildProfileImage(snap.data!, size: 45),
                        ) : const Offstage();
                      })),
                    );
                  }),
                  const Spacer(),
                  Obx(() {
                    return controller.subscribeSuccess.value
                        ? const Offstage()
                        :
                    Text(controller.displayStatus, style: AppStyleConfig
                        .joinCallPreviewPageStyle
                        .callerNameTextStyle,
                      overflow: TextOverflow.ellipsis,);
                  }),
                  const Spacer(),
                  Container(
                    height: 170,
                    width: 150,
                    margin: const EdgeInsets.all(40),
                    child: MirrorFlyView(
                      userJid: SessionManagement.getUserJID().checkNull(),
                      viewBgColor: AppColors.callerBackground,
                    ).setBorderRadius(const BorderRadius.all(Radius.circular(
                        15))),
                  ),
                  Obx(() {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          controller.muted.value
                              ? FloatingActionButton(
                            shape: AppStyleConfig.joinCallPreviewPageStyle
                                .actionButtonsStyle.shape,
                            heroTag: "mute",
                            elevation: 0,
                            backgroundColor: AppStyleConfig
                                .joinCallPreviewPageStyle
                                .actionButtonsStyle.activeBgColor,
                            //Colors.white,
                            onPressed: () => controller.muteAudio(),
                            child: AppUtils.svgIcon(icon:
                            muteActive,
                              colorFilter: ColorFilter.mode(
                                  AppStyleConfig.joinCallPreviewPageStyle
                                      .actionButtonsStyle.activeIconColor,
                                  BlendMode.srcIn),
                            ),
                          )
                              : FloatingActionButton(
                            shape: AppStyleConfig.joinCallPreviewPageStyle
                                .actionButtonsStyle.shape,
                            heroTag: "mute",
                            elevation: 0,
                            backgroundColor: AppStyleConfig
                                .joinCallPreviewPageStyle
                                .actionButtonsStyle.inactiveBgColor,
                            //Colors.white.withOpacity(0.3),
                            onPressed: () => controller.muteAudio(),
                            child: AppUtils.svgIcon(icon:
                            muteInactive,
                              colorFilter: ColorFilter.mode(
                                  AppStyleConfig.joinCallPreviewPageStyle
                                      .actionButtonsStyle.inactiveIconColor,
                                  BlendMode.srcIn),
                            ),
                          ),
                          /*if(controller.callType.value == CallType.video && !controller.videoMuted.value)...[
                          FloatingActionButton(
                            shape: AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.shape,
                            heroTag: "switchCamera",
                            elevation: 0,
                            backgroundColor: controller.cameraSwitch.value ? AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeBgColor : AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveBgColor,
                            // backgroundColor: controller.cameraSwitch.value ? Colors.white : Colors.white.withOpacity(0.3),
                            onPressed: () => controller.switchCamera(),
                            child: controller.cameraSwitch.value
                                ? AppUtils.svgIcon(icon:cameraSwitchActive,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn),)
                                : AppUtils.svgIcon(icon:cameraSwitchInactive,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveIconColor, BlendMode.srcIn),),
                          ),
                        ],*/
                          const SizedBox(width: 15,),
                          FloatingActionButton(
                            shape: AppStyleConfig.joinCallPreviewPageStyle
                                .actionButtonsStyle.shape,
                            heroTag: "video",
                            elevation: 0,
                            backgroundColor: controller.videoMuted.value
                                ? AppStyleConfig.joinCallPreviewPageStyle
                                .actionButtonsStyle.activeBgColor
                                : AppStyleConfig.joinCallPreviewPageStyle
                                .actionButtonsStyle.inactiveBgColor,
                            onPressed: () => controller.videoMute(),
                            child: controller.videoMuted.value ?
                            AppUtils.svgIcon(icon: videoInactive,
                              colorFilter: ColorFilter.mode(
                                  AppStyleConfig.joinCallPreviewPageStyle
                                      .actionButtonsStyle.activeIconColor,
                                  BlendMode.srcIn),)
                                : AppUtils.svgIcon(icon:
                            videoActive, colorFilter: ColorFilter.mode(
                                AppStyleConfig.joinCallPreviewPageStyle
                                    .actionButtonsStyle.inactiveIconColor,
                                BlendMode.srcIn),),
                          ),
                          /*FloatingActionButton(
                          shape: AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.shape,
                          heroTag: "speaker",
                          elevation: 0,
                          backgroundColor:
                          controller.audioOutputType.value == AudioDeviceType.receiver
                              ? AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveBgColor//Colors.white.withOpacity(0.3)
                              : AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeBgColor,//Colors.white,
                          onPressed: () => controller.changeSpeaker(),
                          child: controller.audioOutputType.value == AudioDeviceType.receiver
                              ? AppUtils.svgIcon(icon:speakerInactive,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveIconColor, BlendMode.srcIn),)
                              : controller.audioOutputType.value == AudioDeviceType.speaker
                              ? AppUtils.svgIcon(icon:speakerActive,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn))
                              : controller.audioOutputType.value == AudioDeviceType.bluetooth
                              ? AppUtils.svgIcon(icon:speakerBluetooth,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn))
                              : controller.audioOutputType.value == AudioDeviceType.headset
                              ? AppUtils.svgIcon(icon:speakerHeadset,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn))
                              : AppUtils.svgIcon(icon:speakerActive,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn)),
                        ),*/
                        ],
                      ),
                    );
                  }),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                      child: Obx(() {
                        return ElevatedButton(
                          style: AppStyleConfig.joinCallPreviewPageStyle
                              .joinCallButtonStyle,
                          onPressed: controller.subscribeSuccess.value ? () {
                            controller.joinCall();
                          } : null,
                          child: Text(getTranslated("join_now")),
                        );
                      })),
                ],
              ) :  linkErrorView(callLinkErrorViewStyle: AppStyleConfig.joinCallPreviewPageStyle.callLinkErrorViewStyle,errorText:controller.callEndedMessage,callEndedVisible: !controller.invalidLink);
            }),
          ),
        ),
      ),
    );
  }
}

Widget linkErrorView({CallLinkErrorViewStyle callLinkErrorViewStyle = const CallLinkErrorViewStyle(),String? errorText, bool callEndedVisible = false}) {
  return SizedBox(
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        callLinkErrorViewStyle.logoWidget?? const Offstage(),
        const SizedBox(height: 40,),
        callLinkErrorViewStyle.callIcon?? const Offstage(),
        const SizedBox(height: 20,),
        Visibility(
          visible: callEndedVisible,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Text(getTranslated("callEnded"),
              style: callLinkErrorViewStyle.callEndedTextStyle,),
          ),
        ),
        Text(errorText ?? getTranslated("noOneHere"),
          style: callLinkErrorViewStyle.callEndedMessageTextStyle,),
        const SizedBox(height: 10,),
        ElevatedButton(
          style: callLinkErrorViewStyle.returnToChatButtonStyle,
          onPressed: () {
            NavUtils.back();
          },
          child: Text(
            getTranslated("returnToChat"),
          ),
        ),
      ],
    ),
  );
}
