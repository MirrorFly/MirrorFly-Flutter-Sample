import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/outgoing_call/call_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';

import '../../common/constants.dart';
import '../../common/widgets.dart';

class OnGoingCallView extends GetView<CallController> {
  const OnGoingCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.callerBackground,
      body: SafeArea(
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            controller.isVisible(!controller.isVisible.value);
          },
          child: Stack(
            children: [
              // Obx(() {
              /*return AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  top: controller.isVisible.value ? 0.0 : -72,
                  left: 0.0,
                  right: 0.0,
                  height: 72,
                  child: buildToolbar(),
                );*/

              // }),
              // controller.layoutSwitch.value ?
              Obx(() {
                return controller.callList.length > 1
                    ? SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height,
                  child: Expanded(
                      child: MirrorFlyView(
                          userJid:
                          controller.callList[0].userJid ?? "")
                          .setBorderRadius(const BorderRadius.all(
                          Radius.circular(10)))),
                )
                    : const SizedBox.shrink();
              }),

              Positioned(
                bottom: 5,
                left: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() {
                      return controller.callList.length > 1
                          ? Align(
                        alignment: Alignment.topRight,
                        child: SizedBox(
                          width: 130,
                          height: 180,
                          child: MirrorFlyView(
                            userJid: controller.callList[1].userJid ?? "",
                            viewBgColor: Colors.blueGrey,
                          ).setBorderRadius(
                              const BorderRadius.all(Radius.circular(10))),
                        ),
                      )
                          : const SizedBox.shrink();
                    }),
                    const SizedBox(height: 10,),
                    buildCallOptions(),
                  ],
                ),
              ),

              /* Obx(() {
              return Expanded(
                child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        */ /*controller.remoteUsers.length <= 2
                          ? 1
                          : 2,*/ /*
                        // crossAxisSpacing: 4.0,
                        // mainAxisSpacing: 4.0,
                        // childAspectRatio: 1.3
                      // controller.remoteUsers.length <= 2
                      //     ? 1.3
                      //     : 2 / 3,
                    ),
                    itemCount: controller.callList.length,
                    itemBuilder: (con, index) {
                      // return buildProfileView();
                      var user = controller.callList[index];
                      debugPrint("#Mirrorfly call --> $user");
                      return MirrorFlyView(userJid: user.userJid ?? "").setBorderRadius(
                          const BorderRadius.all(Radius.circular(10)));
                    }),
              );  }),*/

              /*Obx(() {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  left: 0,
                  right: 0,
                  bottom: controller.isVisible.value ? 200 : 0,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      height: 170,
                      child: buildListViewHorizontal(),
                    ),
                  ),
                );
              }),*/
              // Obx(() {
              /*return AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  bottom: controller.isVisible.value ? 0.0 : -200,
                  left: 0.0,
                  right: 0.0,
                  child: buildCallOptions(),
                );*/
              // return
              Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  child: buildToolbar()),
              // }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileView() {
    return Center(
      child: FutureBuilder(
        // future: getProfileDetails(""),
          builder: (cxt, data) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                ProfileTextImage(
                  text: "Saravanakumar",
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Saravanakumar",
                  style: TextStyle(color: Colors.white),
                )
              ],
            );
          }),
    );
  }

  Widget buildToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
          ),
        ),
        Obx(() {
          return Expanded(
            child: Column(
              children: [
                Text(
                  controller.callList.isNotEmpty ? controller.callTitle : "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  controller.callTimer.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          );
        }),
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(addUserCall),
        ),
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(moreMenu),
        )
      ],
    );
  }

  Widget buildCallOptions() {
    return Obx(() {
      return Column(
        children: [
          // InkWell(
          //   onTap: () {
          //     controller.showCallOptions();
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.all(10.0),
          //     child: SvgPicture.asset(
          //       callOptionsUpArrow,
          //       width: 30,
          //     ),
          //   ),
          // ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: "mute",
                elevation: 0,
                backgroundColor: controller.muted.value
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                onPressed: () => controller.muteAudio(),
                child: controller.muted.value
                    ? SvgPicture.asset(
                  muteActive,
                )
                    : SvgPicture.asset(
                  muteInactive,
                ),
              ),
              controller.callType.value == 'video' ? FloatingActionButton(
                  heroTag: "switchCamera",
                  elevation: 0,
                  backgroundColor: controller.cameraSwitch.value
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  onPressed: () => controller.switchCamera(),
                  child: controller.cameraSwitch.value
                      ? SvgPicture.asset(cameraSwitchActive)
                      : SvgPicture.asset(cameraSwitchInactive),
                ) : Container(),
              FloatingActionButton(
                heroTag: "videoMute",
                elevation: 0,
                backgroundColor: controller.videoMuted.value
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                onPressed: () => controller.videoMute(),
                child: controller.videoMuted.value
                    ? SvgPicture.asset(videoInactive)
                    : SvgPicture.asset(videoActive),
              ),
              FloatingActionButton(
                heroTag: "speaker",
                elevation: 0,
                backgroundColor: controller.speakerOff.value
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white,
                onPressed: () => controller.changeSpeaker(),
                child: controller.speakerOff.value
                    ? SvgPicture.asset(speakerInactive)
                    : SvgPicture.asset(speakerActive),
              ),
            ],
          ),
          // Visibility(
          //   visible: controller.isVisible.value,
          //   child:
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    maximumSize: const Size(200, 50),
                    shape: const StadiumBorder(),
                    backgroundColor: AppColors.endButton),
                onPressed: () {
                  controller.declineCall();
                },
                child: SvgPicture.asset(
                  callEndButton,
                )),
          ),
          // )
        ],
      );
    });
  }

  Widget buildListViewHorizontal() {
    return ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (cxt, index) {
          return /*controller.callUsers.first !=
              controller.remoteUsers[index].value
              ? Container(
            height: 200,
            width: 150,
            padding: const EdgeInsets.all(8),
            child: controller.mutedUsers.contains(controller.remoteUsers[index])
                ? */
            Container(
                margin: const EdgeInsets.only(right: 4),
                color: AppColors.audioCallBackground,
                padding: const EdgeInsets.all(4),
                child: buildProfileView());
          /*: MirrorFlyView(
              isLocalUser: controller.remoteUsers[index].value == "local",
              remoteUserJid: controller.remoteUsers[index].value,
            ).setBorderRadius(const BorderRadius.all(Radius.circular(10))),
          )
              : Container();*/
        });
  }
}
