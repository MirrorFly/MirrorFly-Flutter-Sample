import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../common/constants.dart';
import '../../common/widgets.dart';
import '../../data/helper.dart';
import '../../data/utils.dart';
import 'package:focus_detector/focus_detector.dart';
import '../../stylesheet/stylesheet.dart';
import 'call_log_controller.dart';

class CallLogView extends GetView<CallLogController> {
  const CallLogView(
      {super.key,
        this.callHistoryItemStyle = const CallHistoryItemStyle(),
        required this.noDataTextStyle,
        this.recentCallsTitleStyle = const TextStyle(
            fontWeight: FontWeight.w600, color: Color(0xff181818), fontSize: 14),
        this.createMeetLinkStyle = const CreateMeetLinkStyle(),
        this.meetBottomSheetStyle = const MeetBottomSheetStyle()});

  final CreateMeetLinkStyle createMeetLinkStyle;
  final TextStyle recentCallsTitleStyle;
  final CallHistoryItemStyle callHistoryItemStyle;
  final MeetBottomSheetStyle meetBottomSheetStyle;
  final TextStyle noDataTextStyle;

  @override
  Widget build(BuildContext context) {
    callkitLogger.info("#CallLogView build called with controller hash: ${controller.hashCode}");
    return FocusDetector(
      onFocusGained: () {
        callkitLogger.info("#CallLogView focus gained, refreshing logs");
        controller.fetchCallLogs();
      },
      child: _buildScaffold(context,)
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      body: Column(
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
                        Text(
                          getTranslated("createNewMeetingSubtitle"),
                          style: createMeetLinkStyle.subTitleTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Obx(() {
            return controller.callLogList.isEmpty
                ? const Offstage()
                : Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getTranslated("recentCalls"),
                style: recentCallsTitleStyle,
              ),
            );
          }),
          Expanded(
            child: Obx(
                  () => controller.callLogList.isEmpty
                  ? emptyCalls(context)
                  : _buildBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.callLogList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.callLogList.isEmpty) {
        return emptyCalls(context);
      }
      return RefreshIndicator(
        onRefresh: controller.refreshCallLogs,
        child: ListView.builder(
          controller: controller.scrollController,
          itemCount: controller.callLogList.length + (controller.isPaginating.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < controller.callLogList.length) {
              final item = controller.callLogList[index];
              return callLogItem(context, item);
            } else {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      );
    });
  }


  Widget callLogItem(BuildContext context, CallLog item) {
    final isOutgoing = item.isCaller == 1;
    final isMissed = item.missedStatus == 1;

    return Obx(() {
      final profile = controller.profiles[item.userId];
      return ListTile(
        leading: profile != null
            ? ImageNetwork(
                url: profile.image ?? "",
                width: 48,
                height: 48,
                clipOval: true,
                errorWidget: ProfileTextImage(
                  text: getName(profile),
                  radius: 24,
                ),
                isGroup: profile.isGroupProfile ?? false,
                blocked: false,
                unknown: false,
              )
            : const CircleAvatar(
                radius: 24,
                child: Icon(Icons.person),
              ),
        title: Text(
          profile != null ? getName(profile) : (item.userId ?? ""),
          style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            callStatusIcon(isOutgoing, isMissed),
            const SizedBox(width: 4),
            Text(
              "${DateTimeUtils.getCallLogDate(microSeconds: item.callTime!)}  ${getChatTime(context, item.callTime)}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(
              item.callType?.toLowerCase() == 'video' ? Icons.videocam : Icons.call,
              size: 18,
              color: Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              item.duration ?? "",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          // Mark as seen if missed
          if (isMissed) {
            controller.markAsSeen([item.callId!]);
          }
        },
        onLongPress: () {
          Get.dialog(
            AlertDialog(
              title: Text(getTranslated("deleteCallLog")),
              content: Text(getTranslated("deleteCallLogContent")),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(getTranslated("cancel")),
                ),
                TextButton(
                  onPressed: () {
                    controller.clearLogs(callIds: [item.callId.toString()]);
                    Get.back();
                  },
                  child: Text(getTranslated("delete")),
                ),
              ],
            ),
          );
        },
      );
    });
  }


  Widget callStatusIcon(bool isOutgoing, bool isMissed) {
    if (isMissed) {
      return const Icon(Icons.call_missed, color: Colors.red, size: 16);
    }
    return Icon(
      isOutgoing ? Icons.call_made : Icons.call_received,
      color: Colors.green,
      size: 16,
    );
  }

  Widget emptyCalls(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppUtils.assetIcon(assetName: noCallImage, width: 150),
          const SizedBox(height: 16),
          Text(getTranslated("noCallLogsFound"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(getTranslated("noCallLogsContent"), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.fetchCallLogs(),
            icon: const Icon(Icons.refresh),
            label: Text(getTranslated("refresh")),
          ),
        ],
      ),
    );

  }
}
