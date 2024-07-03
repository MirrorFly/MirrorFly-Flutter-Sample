import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';

import '../../app_style_config.dart';
import '../../common/constants.dart';
import '../../common/widgets.dart';
import '../../data/helper.dart';
import '../../data/session_management.dart';
import '../../extensions/extensions.dart';
import '../call_utils.dart';
import '../call_widgets.dart';
import '../ripple_animation_view.dart';
import 'join_call_controller.dart';

class JoinCallPreviewView extends NavViewStateful<JoinCallController> {
  const JoinCallPreviewView({super.key});

  @override
  JoinCallController createController({String? tag}) => Get.put(JoinCallController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: AppStyleConfig.joinCallPreviewPageStyle.backgroundDecoration,
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: FutureBuilder(future:CallUtils.getCallersName(controller.users,controller.users==1),builder: (ctx,snap) {
                    return snap.hasData && snap.data!=null ? Text(
                      snap.data!,
                      style: AppStyleConfig.joinCallPreviewPageStyle.callerNameTextStyle,
                      overflow: TextOverflow.ellipsis,) : const Offstage();
                  })),
              const SizedBox(
                height: 16,
              ),
              Obx(() {
                return controller.users.length == 1 ? RipplesAnimation(
                  onPressed: () {},
                  child: FutureBuilder(future: getProfileDetails(controller.users[0]!), builder: (ctx, snap) {
                    return snap.hasData && snap.data != null ? buildProfileImage(snap.data!,size: AppStyleConfig.joinCallPreviewPageStyle.profileImageSize.width) : const Offstage();
                  }),
                ) : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      controller.users.length > 3 ? 4 : controller.users.length, (index) =>
                  (index == 3) ? Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ProfileTextImage(
                      text: "+${(controller.users.length) - 3}",
                      radius: 45 / 2,
                      bgColor: Colors.white,
                      fontColor: Colors.grey,
                    ),
                  ) : FutureBuilder(future: getProfileDetails(controller.users[index]!), builder: (ctx, snap) {
                    return snap.hasData && snap.data != null ? Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: buildProfileImage(snap.data!, size: 45),
                    ) : const Offstage();
                  })),
                );
              }),
              const Spacer(),
              SizedBox(
                height: 170,
                child: MirrorFlyView(
                  userJid: SessionManagement.getUserJID().checkNull(),
                  viewBgColor: AppColors.callerBackground,
                  hideProfileView: true,
                ),
              ),
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      controller.muted.value
                          ? FloatingActionButton(
                        shape: AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.shape,
                        heroTag: "mute",
                        elevation: 0,
                        backgroundColor: AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeBgColor,//Colors.white,
                        onPressed: () => controller.muteAudio(),
                        child: SvgPicture.asset(
                          muteActive,
                          colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn),
                        ),
                      )
                          : FloatingActionButton(
                        shape: AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.shape,
                        heroTag: "mute",
                        elevation: 0,
                        backgroundColor: AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveBgColor,//Colors.white.withOpacity(0.3),
                        onPressed: () => controller.muteAudio(),
                        child: SvgPicture.asset(
                          muteInactive,
                          colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveIconColor, BlendMode.srcIn),
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
                              ? SvgPicture.asset(cameraSwitchActive,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn),)
                              : SvgPicture.asset(cameraSwitchInactive,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveIconColor, BlendMode.srcIn),),
                        ),
                      ],*/
                      FloatingActionButton(
                        shape: AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.shape,
                        heroTag: "video",
                        elevation: 0,
                        backgroundColor: controller.videoMuted.value ? AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeBgColor : AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveBgColor,
                        onPressed: () => controller.videoMute(),
                        child: controller.videoMuted.value ?
                        SvgPicture.asset(videoInactive,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn),)
                            : SvgPicture.asset(
                          videoActive,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveIconColor, BlendMode.srcIn),),
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
                            ? SvgPicture.asset(speakerInactive,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveIconColor, BlendMode.srcIn),)
                            : controller.audioOutputType.value == AudioDeviceType.speaker
                            ? SvgPicture.asset(speakerActive,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn))
                            : controller.audioOutputType.value == AudioDeviceType.bluetooth
                            ? SvgPicture.asset(speakerBluetooth,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn))
                            : controller.audioOutputType.value == AudioDeviceType.headset
                            ? SvgPicture.asset(speakerHeadset,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn))
                            : SvgPicture.asset(speakerActive,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn)),
                      ),*/
                    ],
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                child: ElevatedButton(
                  style: AppStyleConfig.joinCallPreviewPageStyle.joinCallButtonStyle,
                  onPressed: (){
                    // controller.disconnectOutgoingCall();
                  },
                  child: Text(getTranslated("join_now")),
                )),
            ],
          ),
        ),
      ),
    );
  }
}
