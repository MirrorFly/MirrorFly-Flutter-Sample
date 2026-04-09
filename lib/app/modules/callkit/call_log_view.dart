import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../common/widgets.dart';
import '../../data/helper.dart';
import '../../data/utils.dart';
import 'package:focus_detector/focus_detector.dart';
import 'call_log_controller.dart';

class CallLogView extends GetView<CallLogController> {
  final bool showAppBar;
  const CallLogView({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    callkitLogger.info("#CallLogView build called with controller hash: ${controller.hashCode}");
    return FocusDetector(
      onFocusGained: () {
        callkitLogger.info("#CallLogView focus gained, refreshing logs");
        controller.fetchCallLogs();
      },
      child: showAppBar ? _buildScaffold(context) : _buildBody(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("calls")),
        actions: [
          Obx(() => controller.unreadMissedCallCount.value > 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Badge(
                      label: Text(controller.unreadMissedCallCount.value.toString()),
                      child: const Icon(Icons.notifications),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') {
                controller.clearLogs(clearAll: true);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_all',
                child: Text(getTranslated("clearCallLog")),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(context),
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
    callkitLogger.info("Building call log item: ${item.userId}, isOutgoing: $isOutgoing, isMissed: $isMissed");

    return ListTile(
      leading: FutureBuilder<ProfileDetails>(
        future: getProfileDetails(CallUtils.getJidFromUserId(userId: item.userId ?? "", isGroup: false)),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ImageNetwork(
              url: snapshot.data?.image ?? "",
              width: 48,
              height: 48,
              clipOval: true,
              errorWidget: ProfileTextImage(
                text: getName(snapshot.data!),
                radius: 24,
              ),
              isGroup: snapshot.data!.isGroupProfile ?? false,
              blocked: false,
              unknown: false,
            );
          }
          return const CircleAvatar(child: Icon(Icons.person));
        },
      ),
      title: FutureBuilder<ProfileDetails>(
        future: getProfileDetails(CallUtils.getJidFromUserId(userId: item.userId ?? "", isGroup: false)),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Text(
              getName(snapshot.data!),
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          }
          return Text(CallUtils.getJidFromUserId(userId: item.userId ?? "", isGroup: false));
        },
      ),
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
