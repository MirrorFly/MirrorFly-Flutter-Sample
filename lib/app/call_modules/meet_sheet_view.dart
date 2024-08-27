import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../common/app_localizations.dart';
import '../common/constants.dart';
import '../data/utils.dart';
import '../extensions/extensions.dart';
import '../routes/route_settings.dart';
import '../stylesheet/stylesheet.dart';

class MeetSheetView extends NavViewStateful<MeetLinkController> {
  const MeetSheetView(
      {super.key, required this.title, required this.description, this.meetBottomSheetStyle = const MeetBottomSheetStyle()});

  final MeetBottomSheetStyle meetBottomSheetStyle;
  final showSchedule = false;
  final String title;
  final String description;

  @override
  createController({String? tag}) => Get.put(MeetLinkController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 5,),
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xffC5C5C7),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
            ),
          ),
          const SizedBox(height: 10,),
          Text(title,
            style: meetBottomSheetStyle.titleStyle,),
          const SizedBox(height: 10,),
          Text(description,
            style: meetBottomSheetStyle.subTitleTextStyle,),
          const SizedBox(height: 15,),
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: meetBottomSheetStyle.meetLinkDecoration,
            child: Row(
              children: [
                Obx(() {
                  return Expanded(child: Text(
                      controller.meetLink.value.isNotEmpty ? controller.meetLink
                          .value : getTranslated("loading"), maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: meetBottomSheetStyle.meetLinkTextStyle));
                }),
                IconButton(
                  visualDensity: const VisualDensity(
                      horizontal: -4, vertical: -4),
                  onPressed: () {
                    if (controller.meetLink.value.isEmpty) return;
                    Clipboard.setData(
                        ClipboardData(text: controller.meetLink.value));
                    toToast(getTranslated("linkCopied"));
                  },
                  icon: AppUtils.svgIcon(icon:
                      copyIcon,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                          meetBottomSheetStyle.copyIconColor, BlendMode.srcIn)
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15,),
          SizedBox(
              width: double.infinity,
              child: Obx(() {
                return ElevatedButton(onPressed: controller.meetLink.value.isEmpty ? null : () {
                  controller.joinCall();
                },
                    style: meetBottomSheetStyle.joinMeetingButtonStyle,
                    child: Text(getTranslated("joinMeeting")));
              })),
          const SizedBox(height: 10,),
          if(showSchedule)...[
            Divider(thickness: 1, color: Colors.black.withOpacity(0.1),),
            const SizedBox(height: 10,),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(child: Text(getTranslated("scheduleMeeting"),
                    style: meetBottomSheetStyle.scheduleMeetToggleStyle
                        .textStyle,)),
                  FlutterSwitch(
                    width: 40.0,
                    height: 20.0,
                    valueFontSize: 12.0,
                    toggleSize: 12.0,
                    activeColor: meetBottomSheetStyle.scheduleMeetToggleStyle
                        .toggleStyle.activeColor,
                    //Colors.white,
                    activeToggleColor: meetBottomSheetStyle
                        .scheduleMeetToggleStyle.toggleStyle.activeToggleColor,
                    //Colors.blue,
                    inactiveToggleColor: meetBottomSheetStyle
                        .scheduleMeetToggleStyle.toggleStyle
                        .inactiveToggleColor,
                    //Colors.grey,
                    inactiveColor: meetBottomSheetStyle.scheduleMeetToggleStyle
                        .toggleStyle.inactiveColor,
                    //Colors.white,
                    switchBorder: Border.all(
                        color: controller.turnOnSchedule ? meetBottomSheetStyle
                            .scheduleMeetToggleStyle.toggleStyle
                            .activeToggleColor : meetBottomSheetStyle
                            .scheduleMeetToggleStyle.toggleStyle
                            .inactiveToggleColor,
                        width: 1),
                    value: controller.turnOnSchedule,
                    onToggle: (value) {

                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
          ]
        ],
      ),
    );
  }
}

class MeetLinkController extends GetxController {

  var meetLink = "".obs;

  var turnOnSchedule = false;

  @override
  void onInit() {
    createMeetLink();
    super.onInit();
  }

  void createMeetLink() {
    Mirrorfly.createMeetLink(flyCallback: (FlyResponse response) {
      if (response.isSuccess) {
        var meetLink = response.data;
        if (meetLink.isNotEmpty) {
          this.meetLink(Constants.webChatLogin + meetLink);
          // showMeetBottomSheet(Constants.webChatLogin + meetLink, meetBottomSheetStyle);
        }
      } else {
        if(NavUtils.isOverlayOpen) {
          toToast(response.message.checkNull());
          NavUtils.back();
        }
      }
    });
  }

  Future<void> joinCall() async {
    if (await AppUtils.isNetConnected()) {
      if (meetLink.isNotEmpty) {
        NavUtils.offNamed(Routes.joinCallPreview, arguments: {
          "callLinkId": meetLink.replaceAll(
              Constants.webChatLogin, "")
        });
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }
}
