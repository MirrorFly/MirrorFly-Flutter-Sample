import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_plugin/model/call_log_model.dart';

import '../../../call_modules/call_highlighted_text.dart';
import '../../../call_modules/call_utils.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../stylesheet/stylesheet.dart';
import '../widgets.dart';

class CallHistoryView extends StatelessWidget {
  const CallHistoryView(
      {super.key, required this.controller, this.callHistoryItemStyle = const CallHistoryItemStyle(), required this.noDataTextStyle, this.recentCallsTitleStyle = const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xff181818),
          fontSize: 14), this.createMeetLinkStyle = const CreateMeetLinkStyle(), this.meetBottomSheetStyle = const MeetBottomSheetStyle()});

  final DashboardController controller;
  final CreateMeetLinkStyle createMeetLinkStyle;
  final TextStyle recentCallsTitleStyle;
  final CallHistoryItemStyle callHistoryItemStyle;
  final MeetBottomSheetStyle meetBottomSheetStyle;
  final TextStyle noDataTextStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Theme
              .of(context)
              .scaffoldBackgroundColor,
          child: InkWell(
            onTap: () {
              controller.showMeetBottomSheet(meetBottomSheetStyle);
            },
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.all(10.0),
                  decoration: createMeetLinkStyle.iconDecoration,
                  child: Center(child: Icon(
                    Icons.link, color: createMeetLinkStyle.iconColor,
                    size: 18,),),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(getTranslated("createNewMeeting"),
                      style: createMeetLinkStyle.textStyle,),
                    Text(getTranslated("createNewMeetingSubtitle"),
                      style: createMeetLinkStyle.subTitleTextStyle,)
                  ],
                )
              ],
            ),
          ),
        ),
        Obx(() {
          return controller.callLogList.isEmpty ? const Offstage() : Container(
              color: Theme
                  .of(context)
                  .scaffoldBackgroundColor,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getTranslated("recentCalls"), style: recentCallsTitleStyle,)
          );
        }),
        Expanded(
          child: Stack(
            children: [
              Obx(
                    () =>
                controller.callLogList.isEmpty
                    ? emptyCalls(context)
                    : callLogListView(context, controller.callLogList),
              )
              // emptyCalls(context)
            ],
          ),
        ),
      ],
    );
  }

  Widget callLogListView(BuildContext context, List<CallLogData> callLogList) {
    if (callLogList.isEmpty) {
      if (controller.loading.value) {
        return const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ));
      } else if (controller.error.value) {
        return const Center(child: Text("Error"));
      }
    }
    return ListView.builder(
        controller: controller.callLogScrollController,
        itemCount: callLogList.length,
        itemBuilder: (context, index) {
          var item = callLogList[index];
          if (index == callLogList.length) {
            if (controller.error.value) {
              return const Center(child: Text("Error"));
            } else {
              return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ));
            }
          }
          return item.callMode == CallMode.oneToOne &&
              (item.userList == null || item.userList!.length < 2)
              ? Obx(() =>
              ListTile(
                titleTextStyle: callHistoryItemStyle.titleTextStyle,
                subtitleTextStyle: callHistoryItemStyle.subtitleTextStyle,
                shape: Border(bottom: BorderSide(
                    color: callHistoryItemStyle.dividerColor, width: 0.5)),
                leading: FutureBuilder(
                    future: getProfileDetails(
                        item.callState == 1 ? item.toUser! : item.fromUser!),
                    builder: (context, snap) {
                      return snap.hasData && snap.data != null
                          ? ImageNetwork(
                        url: snap.data!.image!,
                        width: callHistoryItemStyle.profileImageSize.width,
                        height: callHistoryItemStyle.profileImageSize.height,
                        clipOval: true,
                        errorWidget: snap.data!.getName() //item.nickName
                            .checkNull()
                            .isNotEmpty
                            ? ProfileTextImage(text: getName(snap.data!),
                          radius: callHistoryItemStyle.profileImageSize.height /
                              2,)
                            : const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        isGroup: false,
                        blocked: false,
                        unknown: false,
                      )
                          : const Offstage();
                    }),
                title: FutureBuilder(
                    future: getProfileDetails(
                        item.callState == 1 ? item.toUser! : item.fromUser!),
                    builder: (context, snap) {
                      return snap.hasData && snap.data != null &&
                          controller.search.text.isNotEmpty
                          ? CallHighlightedText(content: snap.data!.name!,
                          searchString: controller.search.text.trim())
                          : snap.hasData && snap.data != null &&
                          controller.search.text.isEmpty
                          ? Text(
                        snap.data!.name!,
                        style: callHistoryItemStyle.titleTextStyle,
                        // style: const TextStyle(color: Colors.black),
                      )
                          : const Offstage();
                    }),
                subtitle: SizedBox(
                  child: callLogTime(
                      "${DateTimeUtils.getCallLogDate(
                          microSeconds: item.callTime!)}  ${getChatTime(
                          context, item.callTime)}", item.callState,
                      callHistoryItemStyle.subtitleTextStyle),
                ),
                trailing: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        getCallLogDuration(item.startTime!, item.endTime!),
                        style: callHistoryItemStyle.durationTextStyle,
                        // style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      callIcon(item.callType, item, item.callMode, [],
                          callHistoryItemStyle.iconColor),
                    ],
                  ),
                ),
                selectedTileColor: controller.isLogSelected(index)
                    ? callHistoryItemStyle.selectedBgColor
                    : callHistoryItemStyle.unselectedBgColor,
                selected: controller.isLogSelected(index),
                onLongPress: () {
                  controller.selectedLog(true);
                  controller.selectOrRemoveCallLogFromList(index);
                },
                onTap: () {
                  if (controller.selectedLog.value) {
                    controller.selectOrRemoveCallLogFromList(index);
                  } else {
                    controller.toChatPage(
                        item.callState == CallState.outgoingCall
                            ? item.toUser!
                            : item.fromUser!);
                  }
                },
              ))
              : Obx(() =>
              ListTile(
                titleTextStyle: callHistoryItemStyle.titleTextStyle,
                subtitleTextStyle: callHistoryItemStyle.subtitleTextStyle,
                shape: Border(bottom: BorderSide(
                    color: callHistoryItemStyle.dividerColor, width: 0.5)),
                leading: item.groupId
                    .checkNull()
                    .isEmpty
                    ? ClipOval(
                  child: AppUtils.assetIcon(assetName:
                    groupImg,
                    width: callHistoryItemStyle.profileImageSize.width,
                    height: callHistoryItemStyle.profileImageSize.height,
                    fit: BoxFit.cover,
                  ),
                )
                    : FutureBuilder(
                    future: getProfileDetails(item.groupId!),
                    builder: (context, snap) {
                      return snap.hasData && snap.data != null
                          ? ImageNetwork(
                        url: snap.data!.image!,
                        width: callHistoryItemStyle.profileImageSize.width,
                        height: callHistoryItemStyle.profileImageSize.height,
                        clipOval: true,
                        errorWidget: ClipOval(
                          child: AppUtils.assetIcon(assetName:
                            groupImg,
                            width: callHistoryItemStyle.profileImageSize.width,
                            height: callHistoryItemStyle.profileImageSize
                                .height,
                            fit: BoxFit.cover,
                          ),
                        ),
                        isGroup: false,
                        blocked: false,
                        unknown: false,
                      )
                          : ClipOval(
                        child: AppUtils.assetIcon(assetName:
                          groupImg,
                          width: callHistoryItemStyle.profileImageSize.width,
                          height: callHistoryItemStyle.profileImageSize.height,
                          fit: BoxFit.cover,
                        ),
                      );
                    }),
                title: item.groupId
                    .checkNull()
                    .isEmpty
                    ? FutureBuilder(
                    future: CallUtils.getCallLogUserNames(item.userList!, item),
                    builder: (context, snap) {
                      if (snap.hasData) {
                        return controller.search.text.isNotEmpty
                            ? CallHighlightedText(content: snap.data!,
                            searchString: controller.search.text.trim())
                            : Text(
                          snap.data!,
                          style: callHistoryItemStyle.titleTextStyle,
                          // style: const TextStyle(color: Colors.black),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    })
                    : FutureBuilder(
                    future: getProfileDetails(item.groupId!),
                    builder: (context, snap) {
                      if (snap.hasData) {
                        return controller.search.text.isNotEmpty
                            ? CallHighlightedText(content: snap.data!.name!,
                            searchString: controller.search.text.trim())
                            : Text(
                          snap.data!.name!,
                          style: callHistoryItemStyle.titleTextStyle,
                          // style: const TextStyle(color: Colors.black),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                subtitle: SizedBox(
                  child: callLogTime(
                      "${DateTimeUtils.getCallLogDate(
                          microSeconds: item.callTime!)}  ${getChatTime(
                          context, item.callTime)}", item.callState,
                      callHistoryItemStyle.subtitleTextStyle),
                ),
                trailing: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        getCallLogDuration(item.startTime!, item.endTime!),
                        style: callHistoryItemStyle.durationTextStyle,
                        // style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      callIcon(
                          item.callType, item, item.callMode, item.userList,
                          callHistoryItemStyle.iconColor),
                    ],
                  ),
                ),
                selectedTileColor: controller.isLogSelected(index) ? Colors
                    .grey[400] : null,
                selected: controller.isLogSelected(index),
                onLongPress: () {
                  controller.selectedLog(true);
                  controller.selectOrRemoveCallLogFromList(index);
                },
                onTap: () {
                  if (controller.selectedLog.value) {
                    controller.selectOrRemoveCallLogFromList(index);
                  } else {
                    controller.toCallInfo(item);
                  }
                },
              ));
        });
  }

  Widget emptyCalls(BuildContext context) {
    return !controller.callLogSearchLoading.value
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppUtils.assetIcon(assetName:
            noCallImage,
            width: 150,
          ),
          Text(
            getTranslated("noCallLogsFound"),
            textAlign: TextAlign.center,
            style: noDataTextStyle,
            // style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            getTranslated("noCallLogsContent"),
            textAlign: TextAlign.center,
            style: noDataTextStyle.copyWith(fontWeight: FontWeight.w300),
            // style: const TextStyle(color: callsSubText),
          ),
        ],
      ),
    )
        : const Center(child: CircularProgressIndicator());
  }

  Widget callIcon(String? callType, CallLogData item, String? callMode,
      List<String>? userList, Color iconColor) {
    List<String>? localUserList = [];
    if (item.callState == CallState.missedCall ||
        item.callState == CallState.incomingCall) {
      localUserList.addAll(item.userList!);
      if (!item.userList!.contains(item.fromUser)) {
        localUserList.add(item.fromUser!);
      }
    } else {
      localUserList.addAll(item.userList!);
    }
    return callType!.toLowerCase() == CallType.video
        ? IconButton(
      onPressed: () {
        callMode == CallMode.oneToOne
            ? controller.makeVideoCall(item.callState == CallState.missedCall
            ? item.fromUser
            : item.callState == CallState.incomingCall
            ? item.fromUser
            : item.toUser)
            : controller.makeCall(localUserList, callType, item);
      },
      icon: AppUtils.svgIcon(icon:
        videoCallIcon,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    )
        : IconButton(
        onPressed: () {
          callMode == CallMode.oneToOne
              ? controller.makeVoiceCall(item.callState == CallState.missedCall
              ? item.fromUser
              : item.callState == CallState.incomingCall
              ? item.fromUser
              : item.toUser)
              : controller.makeCall(localUserList, callType, item);
        },
        icon: AppUtils.svgIcon(icon:
          audioCallIcon,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ));
  }
}
