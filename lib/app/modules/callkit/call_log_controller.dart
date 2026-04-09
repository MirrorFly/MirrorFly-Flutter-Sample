import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../common/main_controller.dart';

class CallLogController extends GetxController {
  var callLogList = <CallLog>[].obs;
  var unreadMissedCallCount = 0.obs;
  var isLoading = true.obs;
  var isPaginating = false.obs;
  var pageNumber = 0;
  var totalPages = 1;
  var pageSize = 20;

  ScrollController scrollController = ScrollController();
  final String _tag = "#CallLogController";

  @override
  void onInit() {
    super.onInit();
    callkitLogger.info("$_tag onInit called for instance: $hashCode");
    initStreams();
    fetchCallLogs();
    // fetchMissedCallCount();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    callkitLogger.info("$_tag onClose called for instance: $hashCode");
    scrollController.dispose();
    super.onClose();
  }


  void initStreams() {
    MirrorFlyCallKit.flyCallLogUpdate.listen((logs) {
      if (logs != null) {
        callkitLogger.info("$_tag Call Log Stream Updated: ${logs.length} logs");
        // refreshCallLogs();
        // Alternatively, we could merge the logs if we want to be more efficient
        // For now, refreshing the latest makes sense for real-time consistency
        refreshCallLogs();
      }
    });

    MirrorFlyCallKit.flyUnreadMissedCallCountUpdate.listen((count) {
      callkitLogger.info("$_tag Missed Call Count Stream Updated: $count");
      unreadMissedCallCount.value = count;
      if (Get.isRegistered<MainController>()) {
        Get.find<MainController>().unreadCallCount.value = count;
      }
    });

  }

  Future<void> fetchCallLogs({bool isPagination = false}) async {
    if (isPagination) {
      if (isPaginating.value || pageNumber >= totalPages) return;
      isPaginating.value = true;
    } else {
      isLoading.value = true;
      pageNumber = 0;
      totalPages = 1; // Reset until we know better
    }

    try {
      callkitLogger.info("$_tag Fetching Call Logs: page=$pageNumber, size=$pageSize");
      final FlyCallLogRpcResponseModel response = await MirrorFlyCallKit.getCallLogs(page: pageNumber, size: pageSize);
      callkitLogger.info("$_tag Fetch Call Logs response: isSuccess=${response.isSuccess}, data=${response.data != null}, message=${response.message}");
      if (response.data != null) {
        if (!response.isSuccess) {
          callkitLogger.info("$_tag Note: isSuccess is false but data is present. Proceeding anyway.");
        }
        final logs = response.data!.callLogs ?? [];

        callkitLogger.info("$_tag Received ${logs.length} logs from SDK. Total available: ${response.data!.total}");
        if (logs.isNotEmpty) {
          final firstThreeIds = logs.take(3).map((l) => l.callId).toList();
          callkitLogger.info("$_tag First 3 Call IDs: $firstThreeIds");
        }
        if (isPagination) {
          callLogList.addAll(logs);
        } else {
          callLogList.assignAll(logs);
        }

        callkitLogger.info("$_tag callLogList size now: ${callLogList.length}");
        
        // Update total pages if total count is available
        if (response.data!.total != null) {
          totalPages = (response.data!.total! / pageSize).ceil();
        } else {
          // Fallback: if we got less than pageSize, we reached the end
          if (logs.length < pageSize) {
            totalPages = pageNumber + 1;
          } else {
            totalPages = pageNumber + 2; // Allow next page
          }
        }
        pageNumber++;
      } else {
        callkitLogger.info("$_tag Failed to fetch call logs: ${response.message}");
      }
    } catch (e) {
      callkitLogger.error("$_tag Error fetching call logs: $e");
    } finally {
      isLoading.value = false;
      isPaginating.value = false;
    }
  }

  Future<void> refreshCallLogs() async {
    try {
      callkitLogger.info("$_tag Refreshing Latest Call Logs");
      final response = await MirrorFlyCallKit.getLatestCallLogs();
      callkitLogger.info("$_tag Refresh Call Logs response: isSuccess=${response.isSuccess}, data=${response.data != null}, message=${response.message}");
      if (response.data != null) {
        if (!response.isSuccess) {
          callkitLogger.info("$_tag Note: isSuccess is false but data is present in refresh. Proceeding anyway.");
        }
        final logs = response.data!.callLogs ?? [];

        callkitLogger.info("$_tag Received ${logs.length} logs during refresh");
        callLogList.assignAll(logs);
        callkitLogger.info("$_tag callLogList size now: ${callLogList.length}");
        pageNumber = 1; // We just got the first page
        // Reset pagination state
        if (logs.length < pageSize) {
          totalPages = 1;
        } else {
          totalPages = 2; // Allow next page
        }
      }
    } catch (e) {
      callkitLogger.info("$_tag Error refreshing latest call logs: $e");
    }
  }

  Future<void> fetchMissedCallCount() async {
    try {
      final count = await MirrorFlyCallKit.getUnreadMissedCallCount();
      unreadMissedCallCount.value = count;
      if (Get.isRegistered<MainController>()) {
        Get.find<MainController>().unreadCallCount.value = count;
      }
    } catch (e) {
      callkitLogger.error("$_tag Error fetching missed call count: $e");
    }
  }


  Future<void> markAsSeen(List<int> callIds) async {
    try {
      final success = await MirrorFlyCallKit.markMissedCallAsSeen(callIds: callIds);
      if (success) {
        callkitLogger.info("$_tag Marked as seen: $callIds");
        // Missed call count should update via stream
      }
    } catch (e) {
      callkitLogger.error("$_tag Error marking as seen: $e");
    }
  }

  Future<void> clearLogs({List<String>? callIds, bool clearAll = false}) async {
    try {
      final success = await MirrorFlyCallKit.clearCallLogs(
        callIds: callIds ?? [],
        clearAll: clearAll,
      );
      if (success) {
        if (clearAll) {
          callLogList.clear();
        } else if (callIds != null) {
          callLogList.removeWhere((log) => callIds.contains(log.callId.toString()));
        }
      }
    } catch (e) {
      callkitLogger.error("$_tag Error clearing logs: $e");
    }
  }

  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (!isPaginating.value && pageNumber < totalPages) {
        fetchCallLogs(isPagination: true);
      }
    }
  }
}

