import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/chat_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../common/app_localizations.dart';
import '../common/constants.dart';
import '../data/session_management.dart';
import '../data/utils.dart';
import '../extensions/extensions.dart';
import '../modules/chat/controllers/schedule_calender.dart';
import '../routes/route_settings.dart';
import '../stylesheet/stylesheet.dart';

class MeetSheetView extends NavViewStateful<MeetLinkController> {
  const MeetSheetView(
      {super.key,
      required this.title,
      required this.description,
      this.meetBottomSheetStyle = const MeetBottomSheetStyle()});

  final MeetBottomSheetStyle meetBottomSheetStyle;
  final String title;
  final String description;

  @override
  createController({String? tag}) => Get.put(MeetLinkController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 30),
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 5,
            ),
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
            const SizedBox(
              height: 10,
            ),
            if (!controller.turnOnSchedule.value) ...[
              Text(
                title,
                style: meetBottomSheetStyle.titleStyle,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                description,
                style: meetBottomSheetStyle.subTitleTextStyle,
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: meetBottomSheetStyle.meetLinkDecoration,
                child: Row(
                  children: [
                    Obx(() {
                      return Expanded(
                          child: Text(
                              controller.meetLink.value.isNotEmpty
                                  ? controller.meetLink.value
                                  : getTranslated("loading"),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: meetBottomSheetStyle.meetLinkTextStyle));
                    }),
                    IconButton(
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                      onPressed: () {
                        if (controller.meetLink.value.isEmpty) return;
                        Clipboard.setData(
                            ClipboardData(text: controller.meetLink.value));
                        toToast(getTranslated("linkCopied"));
                      },
                      icon: AppUtils.svgIcon(
                          icon: copyIcon,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                              meetBottomSheetStyle.copyIconColor,
                              BlendMode.srcIn)),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    return ElevatedButton(
                        onPressed: controller.meetLink.value.isEmpty
                            ? null
                            : () {
                                controller.joinCall();
                              },
                        style: meetBottomSheetStyle.joinMeetingButtonStyle,
                        child: Text(getTranslated("joinMeeting")));
                  })),
              const SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1,
                color: Colors.black.withOpacity(0.1),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    getTranslated("scheduleMeeting"),
                    style:
                        meetBottomSheetStyle.scheduleMeetToggleStyle.textStyle,
                  )),
                  Obx(() {
                    return FlutterSwitch(
                      width: 40.0,
                      height: 20.0,
                      valueFontSize: 12.0,
                      toggleSize: 12.0,
                      activeColor: meetBottomSheetStyle
                          .scheduleMeetToggleStyle.toggleStyle.activeColor,
                      //Colors.white,
                      activeToggleColor: meetBottomSheetStyle
                          .scheduleMeetToggleStyle
                          .toggleStyle
                          .activeToggleColor,
                      //Colors.blue,
                      inactiveToggleColor: meetBottomSheetStyle
                          .scheduleMeetToggleStyle
                          .toggleStyle
                          .inactiveToggleColor,
                      //Colors.grey,
                      inactiveColor: meetBottomSheetStyle
                          .scheduleMeetToggleStyle.toggleStyle.inactiveColor,
                      //Colors.white,
                      switchBorder: Border.all(
                          color: controller.turnOnSchedule.value
                              ? meetBottomSheetStyle.scheduleMeetToggleStyle
                                  .toggleStyle.activeToggleColor
                              : meetBottomSheetStyle.scheduleMeetToggleStyle
                                  .toggleStyle.inactiveToggleColor,
                          width: 1),
                      value: controller.turnOnSchedule.value,
                      onToggle: controller.meetLink.value.isEmpty
                          ? (v){}: (value) async {
                        controller.scheduleToggle(value);
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            if(controller.turnOnSchedule.value)...[
            GestureDetector(
              onTap: ()async{
                await controller.dateTimePicker(context);
              },
              child: Container(
                height: 40,
                padding:const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.checkBoxBorder),
                    borderRadius:const BorderRadius.all(Radius.circular(10))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(DateFormat("dd/MM/yyyy").format(controller.scheduleTime.value),
                        style: meetBottomSheetStyle.subTitleTextStyle
                            .copyWith(color: AppColors.callerTitleBackground)),
                   const VerticalDivider(color: AppColors.checkBoxBorder),
                    Text(DateFormat("hh:mm a").format(controller.scheduleTime.value),
                        style: meetBottomSheetStyle.subTitleTextStyle
                            .copyWith(color: AppColors.callerTitleBackground)),
                    const Spacer(),
                    const Icon(
                          Icons.calendar_month_outlined,
                          color: Color(0Xff656565),
                        )
                  ],
                ),
              ),
            ),
            const SizedBox( height: 20),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                      onPressed: () {
                        if(controller.scheduleTime.value.isBefore(DateTime.now().subtract(const Duration(minutes: 1)))){
                          toToast(getTranslated("dateError"));
                        }else{
                          if (Get.isRegistered<ChatController>(tag:SessionManagement.getCurrentChatJID())) {
                            Get.find<ChatController>(tag: SessionManagement.getCurrentChatJID()).sendMeetMessage(link: controller.meetId.value, scheduledDateTime: controller.scheduleTime.value.millisecondsSinceEpoch);
                          }
                        }
                      },
                      style: meetBottomSheetStyle.joinMeetingButtonStyle,
                      child: Text(getTranslated("scheduleMeeting")))
                ),
            const SizedBox(
              height: 20
            ),
        ]
          ],
        );
      }),
    ));
  }
}

class MeetLinkController extends GetxController {
  var meetLink = "".obs;
  Rx<String> meetId="".obs;
  var turnOnSchedule = false.obs;

  Rx<DateTime> scheduleTime = DateTime.now().obs;

  @override
  void onInit() {
    createMeetLink();
    super.onInit();
  }

  void createMeetLink() {
    Mirrorfly.createMeetLink(flyCallback: (FlyResponse response) {
      if (response.isSuccess) {
        meetId(response.data);
        if (meetId.value.isNotEmpty) {
          meetLink(Constants.webChatLogin + meetId.value);
          // showMeetBottomSheet(Constants.webChatLogin + meetLink, meetBottomSheetStyle);
        }
      } else {
        if (NavUtils.isOverlayOpen) {
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
          "callLinkId": meetLink.replaceAll(Constants.webChatLogin, "")
        });
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  Future<void> dateTimePicker(BuildContext context)async{
    TimeOfDay? timeValue;

    DateTime? dateValue = await showDatePicker(
      context: context,
      currentDate: scheduleTime.value,
      initialDate:scheduleTime.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (dateValue != null && context.mounted) {
      timeValue = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour:scheduleTime.value.hour, minute:scheduleTime.value.minute),
      );
    }

    if (dateValue != null && timeValue != null) {
      DateTime finalDateTime = DateTime(
        dateValue.year,
        dateValue.month,
        dateValue.day,
        timeValue.hour,
        timeValue.minute,
      );

      scheduleTime(finalDateTime);
    }

  }

  Future<void> scheduleToggle(bool value) async {
    await ScheduleCalender().requestCalendarPermission();
    turnOnSchedule(value);
  }
}
