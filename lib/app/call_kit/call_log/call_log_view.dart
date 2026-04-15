import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart' show CallLog, ProfileDetails, CallType;

import '../../call_modules/call_highlighted_text.dart';
import '../../call_modules/call_utils.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../common/widgets.dart';
import '../../data/helper.dart';
import '../../data/utils.dart';
import '../../modules/dashboard/controllers/dashboard_controller.dart';
import '../../stylesheet/stylesheet.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';


class CallLogView extends StatelessWidget {
  const CallLogView(
      {super.key,
        required this.controller,
        this.callHistoryItemStyle = const CallHistoryItemStyle(),
        required this.noDataTextStyle,
        this.recentCallsTitleStyle = const TextStyle(
            fontWeight: FontWeight.w600, color: Color(0xff181818), fontSize: 14),
        this.createMeetLinkStyle = const CreateMeetLinkStyle(),
        this.meetBottomSheetStyle = const MeetBottomSheetStyle()});

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
          color: Theme.of(context).scaffoldBackgroundColor,
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
                  child: Center(
                    child: Icon(
                      Icons.link,
                      color: createMeetLinkStyle.iconColor,
                      size: 18,
                    ),
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated("createNewMeeting"),
                        style: createMeetLinkStyle.textStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(getTranslated("createNewMeetingSubtitle"),
                          style: createMeetLinkStyle.subTitleTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Obx(() {
          return controller.callKitCallLogList.isEmpty
              ? const Offstage()
              : Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getTranslated("recentCalls"),
                style: recentCallsTitleStyle,
              ));
        }),
        Expanded(
          child: Stack(
            children: [
              Obx(
                    () => controller.callKitCallLogList.isEmpty
                    ? emptyCalls(context)
                    : callLogListView(context, controller.callKitCallLogList),
              )
              // emptyCalls(context)
            ],
          ),
        ),
      ],
    );
  }

  Widget callLogListView(BuildContext context, List<CallLog> callKitCallLogList) {
    if (callKitCallLogList.isEmpty) {
      if (controller.loading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
        );
      } else if (controller.error.value) {
        return const Center(child: Text("Error"));
      }
    }

    return ListView.builder(
      controller: controller.callLogScrollController,
      itemCount: callKitCallLogList.length + 1,
      itemBuilder: (context, index) {

        if (index == callKitCallLogList.length) {
          return Obx(() {
            return controller.loading.value
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            )
                : const SizedBox.shrink();
          });
        }

        final item = callKitCallLogList[index];
        callkitLogger.info(
            "${controller.callKitLogTag} pagination index: $index, logListLength: ${callKitCallLogList.length}, isLoading: ${controller.loading.value}");

        /// ONE TO ONE CALL UI
        if ((item.callMode == "ONE-TO-ONE") &&
            (item.callParticipants != null &&
                item.callParticipants!.length < 2)) {
          return Obx(() => ListTile(
            titleTextStyle: callHistoryItemStyle.titleTextStyle,
            subtitleTextStyle: callHistoryItemStyle.subtitleTextStyle,
            shape: Border(
              bottom: BorderSide(
                color: callHistoryItemStyle.dividerColor,
                width: 0.5,
              ),
            ),

            /// PROFILE IMAGE
            leading: FutureBuilder(
              future: getProfileDetailsFromCallKit(
                id: item.callParticipants?.first ?? "",
                isGroup: false,
              ),
              builder: (context, snap) {
                if (snap.hasData && snap.data != null) {
                  return ImageNetwork(
                    url: snap.data!.image?.checkNull() ?? "",
                    width: callHistoryItemStyle.profileImageSize.width,
                    height: callHistoryItemStyle.profileImageSize.height,
                    clipOval: true,
                    errorWidget: snap.data!.getName().checkNull().isNotEmpty
                        ? ProfileTextImage(
                      text: getName(snap.data!),
                      radius: callHistoryItemStyle.profileImageSize.height / 2,
                    )
                        : const Icon(Icons.person, color: Colors.white),
                    isGroup: false,
                    blocked: false,
                    unknown: false,
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            /// TITLE
            title: FutureBuilder(
              future: getProfileDetailsFromCallKit(
                id: item.callParticipants?.first ?? "",
                isGroup: false,
              ),
              builder: (context, snap) {
                if (snap.hasData && snap.data != null) {
                  return controller.search.text.isNotEmpty
                      ? CallHighlightedText(
                    content: snap.data!.name!,
                    searchString: controller.search.text.trim(),
                  )
                      : Text(
                    snap.data!.name!,
                    style: callHistoryItemStyle.titleTextStyle,
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            /// SUBTITLE
            subtitle: callLogTimeForCallKit(
              "${DateTimeUtils.getCallLogDate(microSeconds: item.callTime!)}  ${getChatTime(context, item.callTime)}",
              item.isCaller == 0,
              item.missedStatus == 1 || item.missedStatus == 2,
              callHistoryItemStyle.subtitleTextStyle,
            ),

            /// TRAILING
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.duration ?? "",
                    style: callHistoryItemStyle.durationTextStyle),
                const SizedBox(width: 8),
                callIcon(
                    item.callType, item, item.callMode, callHistoryItemStyle.iconColor),
              ],
            ),

            selectedTileColor: controller.isLogSelected(index)
                ? callHistoryItemStyle.selectedBgColor
                : callHistoryItemStyle.unselectedBgColor,
            selected: controller.isLogSelected(index),

            onLongPress: () {
              controller.selectedLog(true);
              controller.selectOrRemoveCallKitLogFromList(index);
            },

            onTap: () {
              if (controller.selectedLog.value) {
                controller.selectOrRemoveCallKitLogFromList(index);
              } else {
                final bool isGroupCall =
                    item.chatId != null && item.chatId!.isNotEmpty;

                final String toChatId = isGroupCall
                    ? CallUtils.getGroupJidFromGroupId(item.chatId!)
                    : (item.callParticipants != null &&
                    item.callParticipants!.isNotEmpty)
                    ? CallUtils.getJidFromUserId(
                    userId: item.callParticipants!.first,
                    isGroup: isGroupCall)
                    : "";

                controller.toChatPage(toChatId);
              }
            },
          ));
        }

        /// =========================
        /// GROUP CALL UI
        /// =========================
        return Obx(() => ListTile(
          titleTextStyle: callHistoryItemStyle.titleTextStyle,
          subtitleTextStyle: callHistoryItemStyle.subtitleTextStyle,
          shape: Border(
            bottom: BorderSide(
              color: callHistoryItemStyle.dividerColor,
              width: 0.5,
            ),
          ),

          /// LEADING
          leading: ClipOval(
            child: AppUtils.assetIcon(
              assetName: groupImg,
              width: callHistoryItemStyle.profileImageSize.width,
              height: callHistoryItemStyle.profileImageSize.height,
              fit: BoxFit.cover,
            ),
          ),

          /// TITLE
          title: FutureBuilder(
            future: CallUtils.getCallKitLogUserNames(
                item.callParticipants ?? [], item),
            builder: (context, snap) {
              if (snap.hasData) {
                return controller.search.text.isNotEmpty
                    ? CallHighlightedText(
                  content: snap.data!,
                  searchString: controller.search.text.trim(),
                )
                    : Text(
                  snap.data!,
                  style: callHistoryItemStyle.titleTextStyle,
                );
              }
              return const SizedBox.shrink();
            },
          ),

          /// SUBTITLE
          subtitle: callLogTimeForCallKit(
            "${DateTimeUtils.getCallLogDate(microSeconds: item.callTime!)}  ${getChatTime(context, item.callTime)}",
            item.isCaller == 0,
            item.missedStatus == 1 || item.missedStatus == 2,
            callHistoryItemStyle.subtitleTextStyle,
          ),

          /// TRAILING
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.duration ?? "",
                  style: callHistoryItemStyle.durationTextStyle),
              const SizedBox(width: 8),
              callIcon(item.callType, item, item.callMode,
                  callHistoryItemStyle.iconColor),
            ],
          ),

          selectedTileColor:
          controller.isLogSelected(index) ? Colors.grey[400] : null,
          selected: controller.isLogSelected(index),

          onLongPress: () {
            controller.selectedLog(true);
            controller.selectOrRemoveCallKitLogFromList(index);
          },

          onTap: () {
            if (controller.selectedLog.value) {
              controller.selectOrRemoveCallKitLogFromList(index);
            } else {
              controller.toCallKitCallInfo(item);
            }
          },
        ));
      },
    );
  }

  Widget emptyCalls(BuildContext context) {
    return !controller.callLogSearchLoading.value
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppUtils.assetIcon(
            assetName: noCallImage,
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

  Widget callIcon(String? callType, CallLog item, String? callMode, Color iconColor) {
    return callType!.toLowerCase() == CallType.video
        ? IconButton(
            onPressed: () {
              controller.makeCallKitVideoCall(
                  callersId: item.callParticipants ?? [],
                  chatId: item.chatId ?? "",
                  isOneToOne: item.callMode?.isOneToOneCall == true);
            },
            icon: AppUtils.svgIcon(
              icon: videoCallIcon,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          )
        : IconButton(
            onPressed: () {
              controller.makeCallKitAudioCall(
                  callersId: item.callParticipants ?? [],
                  chatId: item.chatId ?? "",
                  isOneToOne: item.callMode?.isOneToOneCall == true);
        },
        icon: AppUtils.svgIcon(
          icon: audioCallIcon,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ));
  }

  Future<ProfileDetails> getProfileDetailsFromCallKit({required String id, required bool isGroup}) async {
    final String jid = isGroup ? CallUtils.getGroupJidFromGroupId(id) : CallUtils.getJidFromUserId(userId: id, isGroup: false);
    callkitLogger.info("${controller.callKitLogTag} - getProfileDetailsFromCallKit | jid: $jid, isGroup: $isGroup");
    return getProfileDetails(jid);
  }

  Widget callLogTimeForCallKit(
      String time,
      bool isCaller,
      bool isMissedCall,
      TextStyle? textStyle,
      ) {
    Widget iconWidget;

    if (isMissedCall) {
      iconWidget = AppUtils.svgIcon(
        icon: arrowDropDown,
        colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
      );
    } else if (isCaller) {
      iconWidget = AppUtils.svgIcon(
        icon: arrowDownIcon,
        colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
      );
    } else {
      iconWidget = AppUtils.svgIcon(
        icon: arrowUpIcon,
        colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
      );
    }

    return Row(
      children: [
        iconWidget,
        const SizedBox(width: 5),
        Text(
          time,
          style: textStyle,
        ),
      ],
    );
  }
}



extension StringExtension on String {
  bool get isOneToOneCall {
    switch (this) {
      case "ONE-TO-ONE":
        return true;
      default:
        return false;
    }
  }
}
