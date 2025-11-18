import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../app_style_config.dart';
import '../common/app_localizations.dart';
import '../data/session_management.dart';
import '../data/utils.dart';
import '../model/arguments.dart';
import '../routes/route_settings.dart';
import 'package:permission_handler/permission_handler.dart';

import 'callkit_logger.dart';

class CallKitOutgoingCallController extends GetxController
    with GetTickerProviderStateMixin {

  /// Observables
  var callStatus = "Trying to connect".obs;
  var callDuration = "".obs;
  var callTryStatus = "".obs;

  RxString callType = "".obs; // "audio" or "video"
  RxString groupId = "".obs;
  RxString callMode = "".obs;

  RxBool showControls = true.obs;
  RxBool isVideoEnabled = true.obs;
  RxBool speakerOn = false.obs;
  RxBool isOnGoingCallViewEnable = false.obs;

  // RxList<String?> callerUsersId = <String?>[].obs;

  RxBool selectedDevice = false.obs;

  final RxBool cameraSwitch = false.obs;
  final RxBool isIncoming = false.obs;
  final RxBool isManualDeviceSelected = false.obs;

  RxString cameraPosition = CameraType.front.obs;
  RxBool isRemoteVideoMuted = true.obs;

  /// For group call handling
  RxBool isGroupCall = false.obs;
  RxBool isGroupOnGoingCallEnabled = false.obs;
  RxString chatNameForGroupCall = "".obs;
  RxString groupCallTitle = "".obs;
  RxMap<String, String> remoteUserNameMap = <String, String>{}.obs;

  RxBool isCallModeChangedToOneToMany = false.obs;
  RxString titleAfterCallModeChange = "".obs;

  /// Over all call participant list
  var callerList = <FlyCallParticipant>[].obs;
  RxMap<String, double> callerAudioLevel = <String, double>{}.obs;

  ///
  final RxBool isLocalTracksPublished = false.obs;
  final RxBool isRemoteTracksPublished = false.obs;
  Timer? timer;
  AudioPlayer? _player;
  bool _isPlaying = false;

  @override
  Future<void> onInit() async {
    await _handleInitialCallStatus();
    await getCurrentCallParticipants();

    callkitLogger.info("[MirrorFly][OutgoingCallController] callviewinit");
    if (callType.value.isNotEmpty) {
      _handleWakelock(callType.value);
    }

    ever(callType, (String type) {
      _handleWakelock(type);
    });
    if (NavUtils.arguments != null) {
      await _initCallArguments();
      _handleCallTypeLogic();
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] No call arguments found");
    }

    // callMode()
    await configureCallMode(callMode: callMode.value, chatId: groupId.value);
    callkitLogger.info("[MirrorFly][OutgoingCallController] callview");
    super.onInit();
  }

  Future<void> _initCallArguments() async {
    try {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Initializing call arguments from NavUtils");
      // callerUsersId.value = NavUtils.arguments?["userJid"] as List<String?>;
      callType(NavUtils.arguments?["callType"]);
      groupId(NavUtils.arguments?["chatId"] as String? ?? "");
      callMode(NavUtils.arguments?["callMode"] as String? ?? "");
      isIncoming.value = NavUtils.arguments?["isIncoming"] as bool? ?? false;

      callkitLogger.info(
        "[MirrorFly][OutgoingCallController] "
            "isIncoming: groupId $groupId incoming $isIncoming callType $callType  callMode $callMode ",
      );
    } catch (e) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Error initializing call arguments: $e");
    }
  }

  void _handleCallTypeLogic() {
    if (isIncoming.value) {
      _handleIncomingCall();
    } else if (!isIncoming.value && callType.value == "audio") {
      // _handleOutgoingAudioCall();
    } else if (!isIncoming.value && callType.value == "video") {
      // _handleOutgoingVideoCall();
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Invalid call parameters");
    }
  }

  void _handleIncomingCall() {
    isOnGoingCallView();
    callkitLogger.info("[MirrorFly][IncomingCall] Incoming call view setup completed");
  }

  @override
  void onReady() async {
    initAudioRouting();

    if (isGroupCall.value || isGroupOnGoingCallEnabled.value) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] onReady getRemoteAndLocalUserNameForGroupCall");
      await getRemoteAndLocalUserNameForGroupCall();
      await getChatNameForGroupCall(chatId: groupId.value);
      await getGroupCallTitle();
    } else {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] onReady getRemoteAndLocalUserNameForOneToOneCall");
      await getRemoteAndLocalUserNameForOneToOneCall();
    }

    getLogsOfLocalValues();

    callType.value == "audio" ? isVideoEnabled.value = false : isVideoEnabled.value = true;
    super.onReady();
  }

  ///
  /// Get current participants in the call
  ///
  Future<List<FlyCallParticipant>> getCurrentCallParticipants() async {
    final participants = await MirrorFlyCallKit.getCurrentCallParticipants();

    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] Current call participants: ${participants
            ?.length},"
            " participants: ${participants?.map((p) => p.identity).toList()}");

    if (participants != null && participants.isNotEmpty) {
      callkitLogger.info(
        "[MirrorFly][OutgoingCallController] getCurrentCallParticipants: fetched ${participants
            .length} "
            "participants → ${participants.map((e) => e.identity).toList()}",
      );

      final existingIds = callerList.map((e) => e.identity).toSet();
      callkitLogger.info(
        "[MirrorFly][OutgoingCallController] Existing callerList (${callerList
            .length}): ${existingIds.toList()}",
      );

      for (var p in participants) {
        if (!existingIds.contains(p.identity)) {
          callerList.add(p);
          callkitLogger.info(
            "[MirrorFly][OutgoingCallController] ➕ Added new participant: ${p
                .identity}",
          );
        } else {
          callkitLogger.info(
            "[MirrorFly][OutgoingCallController]️ Skipped duplicate participant: ${p
                .identity}",
          );
        }
      }

      callerList.refresh();
      callkitLogger.info(
        "[MirrorFly][OutgoingCallController] callerList after merge (${callerList
            .length}): ${callerList.map((e) => e.identity).toList()}",
      );
    } else {
      callkitLogger.info(
        "[MirrorFly][OutgoingCallController] getCurrentCallParticipants: No participants fetched (null or empty)",
      );
    }

    return participants ?? []; // Handle null safely
  }

  ///
  /// Verify the call mode
  ///
  Future<void> configureCallMode(
      {required String callMode, required String chatId}) async {
    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] #configureCallMode with callMode: $callMode, chatId: $chatId");

    // Consider as one to one call
    if (chatId.isEmpty) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #configureCallMode with remote participantId for "
              "one to one call");
    }

    // Validate for group call
    final bool yes = callMode == "TO-ONE-TO-MANY" || callMode == "ONE-TO-MANY";
    isGroupCall.value = yes;
    if (yes) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #configureCallMode isGroupCall: true");

      if (chatId.isEmpty && callMode == "ONE-TO-MANY") {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] #configureCallMode with chatId for group call: $chatId");
        getRemoteAndLocalUserNameForGroupCall();
        isCallModeChangedToOneToMany(true);
      }
      getCallTitleForOneToManyCall();
    }

    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] #configureCallMode isGroupCall: ${isGroupCall
            .value}");
  }

  Future<void> getRemoteAndLocalUserNameForOneToOneCall() async {
    if (isGroupCall.value) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #getRemoteAndLocalUserNameForGroupCall Not a group call");
      return;
    }

    for (var user in callerList) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Getting user name for: ${user.identity}, isLocal: ${user.isLocalParticipant}");
      ProfileDetails profile = await getProfileDetails(
          validId(userId: user.identity, isGroup: false));
      String username = (profile.name?.trim().isNotEmpty == true)
          ? profile.name!.trim()
          : (profile.nickName?.trim().isNotEmpty == true)
              ? profile.nickName!.trim()
              : trimAfterAt(profile.jid ?? "");
      remoteUserNameMap[user.identity] =
          user.isLocalParticipant ? "You" : username;
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Remote User Name for ${user.identity}: $username");
    }
    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] Completed fetching user names for group call, "
            "remoteUserNameMap: ${remoteUserNameMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}");
    return;
  }

  ///
  /// Get remote user name for the each id for group call
  ///
  Future<void> getRemoteAndLocalUserNameForGroupCall() async {
    if (!isGroupCall.value) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #getRemoteAndLocalUserNameForGroupCall Not a group call");
      return;
    }
    for (var user in callerList) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Getting user name for: ${user
              .identity}, isLocal: ${user.isLocalParticipant}");
      ProfileDetails profile = await getProfileDetails(
          validId(userId: user.identity, isGroup: false));
      String username =
      (profile.name?.trim().isNotEmpty == true)
          ? profile.name!.trim()
          : (profile.nickName?.trim().isNotEmpty == true)
          ? profile.nickName!.trim()
          : trimAfterAt(profile.jid ?? "");
      remoteUserNameMap[user.identity] =
      user.isLocalParticipant ? "You" : username;
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Remote User Name for ${user
              .identity}: $username");
    }
    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] Completed fetching user names for group call, remoteUserNameMap: ${remoteUserNameMap
            .entries.map((e) => '${e.key}: ${e.value}').join(', ')}");
    return;
  }

  ///
  /// Get remote user name for one-to-one call (remote participant)
  ///
  String getOneToOneCallRemoteUserName() {
    if (isGroupCall.value) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #getOneToOneCallRemoteUserName Not a one-to-one call");
      return "";
    }

    // Find first non-local participant
    try {

      if (remoteUserNameMap.isEmpty) {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] Remote User name map is empty");
        return "";
      }

      final remoteEntry = remoteUserNameMap.entries.firstWhere(
            (entry) => entry.key != getLocalParticipantId(),
      );

      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Remote User -> ID: ${remoteEntry
              .key}, Name: ${remoteEntry.value}");

      return remoteEntry.value;
    } catch (e) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Remote User name error: $e");
      return "";
    }
  }

  String validId({required String userId,required bool isGroup}) {
    if(isGroup){
      return userId.contains("@") ? userId : "$userId@mix.xmpp-uikit-qa.contus.us";
    }else{
      return userId.contains("@") ? userId : "$userId@xmpp-uikit-qa.contus.us";
    }
  }

  ///
  /// Get chat name for group call
  ///
  Future<void> getChatNameForGroupCall({required String chatId}) async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] #getChatNameForGroupCall called with chatId: $chatId");
    if (isGroupCall.value && chatId.isNotEmpty) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #getChatNameForGroupCall with chatId: ${groupId.value}");
      ProfileDetails profile = await getProfileDetails(validId(userId: chatId,isGroup: true));
      String chatName =
      (profile.name?.trim().isNotEmpty == true)
          ? profile.name!.trim()
          : (profile.nickName?.trim().isNotEmpty == true)
          ? profile.nickName!.trim()
          : trimAfterAt(profile.jid ?? "");
      chatNameForGroupCall.value = chatName;
    } else {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #getChatNameForGroupCall Not a group call chatId: ${groupId.value}");
    }
  }

  ///
  /// Get call title for the one-to-many call.
  ///
  Future<void> getCallTitleForOneToManyCall() async {
    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] #getCallTitleForOneToManyCall called");

    if (!isGroupCall.value) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Not a group call");
      return;
    }

    // Filter remote participants:
    // 1. Exclude local user using isSelfId()
    // 2. Exclude any name that equals "you"
    final filteredNames = remoteUserNameMap.entries
        .where((entry) {
          final id = entry.key;
          final name = entry.value.trim();

          // Exclude self
          if (isSelfId(id: id)) return false;

          // Exclude redundant "you"
          if (name.toLowerCase() == "you") return false;

          return true;
        })
        .map((e) => e.value.trim())
        .toList();

    final count = filteredNames.length;

    if (count == 0) {
      titleAfterCallModeChange.value = "You";
      return;
    }

    String title;

    if (count == 1) {
      title = "You and ${filteredNames[0]}";
    } else if (count == 2) {
      title = "You, ${filteredNames[0]} & ${filteredNames[1]}";
    } else {
      final others = count - 1;
      title =
          "You, ${filteredNames[0]} & $others ${others == 1 ? 'other' : 'others'}";
    }

    titleAfterCallModeChange.value = title;

    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] #getCallTitleForOneToManyCall -> $title");
  }

  ///
  /// Get group call title
  ///
  Future<void> getGroupCallTitle() async {
    if (!isGroupCall.value) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #getGroupCallTitle Not a group call");
      return;
    } else {

    }
  }

  ///
  /// Handle the UI based on the current call status
  ///
  Future<void> _handleInitialCallStatus() async {
    callkitLogger.info("[MirrorFly] _handleInitialCallStatus called");
    final FlyCallStatusEvent? currentStatusEvent =
        MirrorFlyCallKit.currentCallStatus?.flyCallStatusEvent;
    callkitLogger.info("[MirrorFly] currentStatusEvent: $currentStatusEvent");
    if (currentStatusEvent == FlyCallStatusEvent.connected) {
      // onConnected();
    } else if (currentStatusEvent == FlyCallStatusEvent.connecting) {
      connecting();
    } else if (currentStatusEvent == FlyCallStatusEvent.ringing) {
      ringing();
    } else if (currentStatusEvent == FlyCallStatusEvent.tryingToConnect) {
      tryingToConnect();
    } else {
      // Let the listener status will trigger from base controller
    }
  }

  ///
  /// Get participant connection state
  ///
  String getParticipantConnectionState(FlyCallStatusEvent status) {
    callkitLogger.info("[MirrorFly][OutgoingCallController] getParticipantConnectionState called with status: $status");
    switch (status) {
      case FlyCallStatusEvent.connected:
      case FlyCallStatusEvent.reconnected:
        return "";
      case FlyCallStatusEvent.connecting:
        return "Connecting";
      case FlyCallStatusEvent.reconnecting:
        return "Reconnecting";
      case FlyCallStatusEvent.disconnected:
        return "Disconnected";
      case FlyCallStatusEvent.calling:
        return "Calling";
      case FlyCallStatusEvent.ringing:
        return "Ringing";
      case FlyCallStatusEvent.tryingToConnect:
        return "Trying to connect";
      case FlyCallStatusEvent.callHold:
        return "On Hold";
      default:
        return "Unknown";
    }
  }

  ///
  /// Get logs for values
  ///
  void getLogsOfLocalValues() {
    callkitLogger.info('''
       [Call Logs]
       callStatus: ${callStatus.value}
       callDuration: ${callDuration.value}
       callTryStatus: ${callTryStatus.value}
       callType: ${callType.value}
       groupId: ${groupId.value}
       callMode: ${callMode.value}
       showControls: ${showControls.value}
       isVideoEnabled: ${isVideoEnabled.value}
       speakerOn: ${speakerOn.value}
       isOnGoingCallViewEnable: ${isOnGoingCallViewEnable.value}
       selectedDevice: ${selectedDevice.value}
       cameraSwitch: ${cameraSwitch.value}
       isIncoming: ${isIncoming.value}
       isManualDeviceSelected: ${isManualDeviceSelected.value}
       cameraPosition: ${cameraPosition.value}
       isRemoteVideoMuted: ${isRemoteVideoMuted.value}
       isGroupCall: ${isGroupCall.value}
       chatNameForGroupCall: ${chatNameForGroupCall.value}
       remoteUserNameMap: ${remoteUserNameMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}
       callerList length: ${callerList.length}
       isLocalTracksPublished: ${isLocalTracksPublished.value}
       isRemoteTracksPublished: ${isRemoteTracksPublished.value}
          ''');
  }

  @override
  void onClose() {
    callkitLogger.info("[MirrorFly][OutgoingCallController] CallKitOutgoingCallController onClose called");
    super.onClose();
  }


  @override
  void dispose(){
    callkitLogger.info("[MirrorFly][OutgoingCallController] CallKitOutgoingCallController dispose called");
    _player?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void initPlayer() {
    _player = AudioPlayer();
  }

  void _handleWakelock(String type) async {
    if (type == "video") {
      await WakelockPlus.enable();
      callkitLogger.info("[MirrorFly][OutgoingCallController] Wakelock ENABLED (video call)");
    } else {
      await WakelockPlus.disable();
      callkitLogger.info("[MirrorFly][OutgoingCallController] Wakelock DISABLED (not video)");
    }
  }


  void toggleControls() {
    showControls.value = !showControls.value;
  }


  void _startTimer({int? time}) {
    if (timer != null) {
      timer?.cancel();
    }
    timer = null;
    const oneSec = Duration(seconds: 1);
    var startTime = time != null
        ? DateTime.fromMillisecondsSinceEpoch(time)
        : DateTime.now();
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        final hrDur = DateTime.now().difference(startTime).inHours;
        final minDur = DateTime.now().difference(startTime).inMinutes;
        final secDur = DateTime.now().difference(startTime).inSeconds % 60;
        final hours = hrDur.remainder(24).toStringAsFixed(0).padLeft(2, '0');
        final minutes = minDur.remainder(60).toStringAsFixed(0).padLeft(2, '0');
        final seconds = secDur.remainder(60).toStringAsFixed(0).padLeft(2, '0');
        var time = '${hours != "00" ? '$hours:' : ''}$minutes:$seconds';
        // print("[MirrorFly][OutgoingCallController] Timer: $time");
        _updateCallDuration(duration: time);
      },
    );
  }

  void _stopTimer() {
    if (timer == null) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Timer is null");
      return;
    }
    timer?.cancel();
    timer = null;
  }

  void ringing({ FlyCallStatusEvent? ringing, List<String>? participantsId}) {
    callStatus("Ringing...");
    updateCallerStatusList(participantsId: participantsId, status: FlyCallStatusEvent.ringing);
  }

  void tryingToConnect() {
    callStatus("Trying to connect...");
  }

  void updateCallerStatusList({
     List<String>? participantsId,
    FlyCallStatusEvent? status,
  }) {
    if(participantsId?.isNotEmpty ?? false){
      for (final id in participantsId ?? []) {
        if (!isSelfId(id: id)) {
          final index = callerList.indexWhere((p) => p.identity == id);

          if (index != -1) {
            callkitLogger.info("[MirrorFly][OutgoingCallController] updateCallerStatusList updating existing participant");
            // Participant exists — update status
            final existing = callerList[index];
            callerList[index] = FlyCallParticipant(
              identity: existing.identity,
              isLocalParticipant: existing.isLocalParticipant,
              flyCallStatusEvent: status ?? existing.flyCallStatusEvent,
              flyCallActionEvent: existing.flyCallActionEvent,
            );
          } else {
            // Participant not found — add new
            callkitLogger.info("[MirrorFly][OutgoingCallController] updateCallerStatusList adding new participant");
            callerList.add(
              FlyCallParticipant(
                identity: id,
                isLocalParticipant: false,
                flyCallStatusEvent: status,
                flyCallActionEvent: null,
              ),
            );
          }
        }else{
          callkitLogger.info("[MirrorFly][OutgoingCallController] updateCallerStatusList: Skipping self id: $id");
        }
      }
      callerList.refresh();
    }else{
      callkitLogger.info("[MirrorFly][OutgoingCallController] updateCallerStatusList: participantsId is empty");
    }

  }

  /// Handle reconnecting state for local and remote user
  void reconnecting({required List<String> participantIds}) {
    callkitLogger.info(
        "[MirrorFly] #CallKitOutGoingController → Reconnecting event for participantIds: $participantIds");

    if (participantIds.isEmpty) {
      callkitLogger.info(
          "[MirrorFly] #CallKitOutGoingController → Reconnecting event with empty participantIds");
      return;
    }
    for (final id in participantIds) {
      callkitLogger.info(
          "[MirrorFly] #CallKitOutGoingController → Reconnecting event for id: $id");

      try {
        final index = callerList.indexWhere((e) => e.identity == id);
        if (!index.isNegative) {
          final target = callerList[index];
          // if (target.isReconnecting == true) {
          //   callkitLogger.info(
          //       "[MirrorFly] → Participant $id is already marked as reconnecting");
          // } else {
            callerList[index] = target.copyWith(isReconnecting: true, flyCallStatus: FlyCallStatusEvent.reconnecting);
            callkitLogger.info("[MirrorFly] → Updated participant $id as reconnecting");
          // }

          if (target.isLocalParticipant) {
            callStatus("Reconnecting...");
            callTryStatus("Reconnecting...");
          }
        } else {
          callkitLogger.info(
              "[MirrorFly] → No participant found in callerList for id: $id");
        }
      } catch (e) {
        callkitLogger.info(
            "[MirrorFly] → Error while updating reconnecting state for $id: $e");
      }
    }
    callerList.refresh();
  }

  /// Handle reconnected state for local and remote user
  void reconnected({required List<String> participantIds}) {
    callkitLogger.info(
        "[MirrorFly] #CallKitOutGoingController → Reconnected event for participantIds: $participantIds");

    if (participantIds.isEmpty) {
      callkitLogger.info(
          "[MirrorFly] #CallKitOutGoingController → Reconnected event with empty participantIds");
      return;
    }

    for (final id in participantIds) {
      callkitLogger.info(
          "[MirrorFly] #CallKitOutGoingController → Reconnected event for id: $id");

      try {
        final index = callerList.indexWhere((e) => e.identity == id);
        if (!index.isNegative) {
          final target = callerList[index];

          if (target.isReconnecting == true) {
            callerList[index] = target.copyWith(isReconnecting: false, flyCallStatus: FlyCallStatusEvent.reconnected);
            callkitLogger.info("[MirrorFly] → Participant $id marked as reconnected");
          } else {
            callkitLogger.info(
                "[MirrorFly] → Participant $id was not in reconnecting state");
          }

          // Local participant UI update
          if (target.isLocalParticipant) {
            callerList[index] = target.copyWith(isReconnecting: false, flyCallStatus: FlyCallStatusEvent.reconnected);
            callStatus("Connected");
            callTryStatus("Connected");
          }
        } else {
          callkitLogger.info(
              "[MirrorFly] → No participant found in callerList for id: $id");
        }
      } catch (e) {
        callkitLogger.info(
            "[MirrorFly] → Error while updating reconnected state for $id: $e");
      }
    }
    callerList.refresh();
  }

  ///
  /// Audio mute status update
  ///
  void isAudioMute({
    required bool isAudioMuted,
    required String? participantId,
  }) {
    final index = callerList.indexWhere((p) => p.identity == participantId);

    callkitLogger.info(
        "[Controller] isAudioMute called for participantId: $participantId, isAudioMuted: $isAudioMuted, index: $index");

    if (index.isNegative) {
      callkitLogger.info("[Controller] isAudioMute: No participant found for id: $participantId");
      return;
    }

    final updated = callerList[index].copyWith(isAudioMuted: isAudioMuted);
    callerList[index] = updated;

    callkitLogger.info("[Controller] isAudioMute: Updated ${updated.identity} mute status to $isAudioMuted");
  }

  void isVideoMute({required bool isVideoMuted,required String? participantId}) {
    callkitLogger.info("[Controller] isVideoMute called for participantId: $participantId, isVideoMuted: $isVideoMuted");
    if(isSelfId(id: participantId)){
      callkitLogger.info("[Controller] Updating local video mute status to $isVideoMuted");
      isVideoEnabled.value = isVideoMuted;
    }else{
      callkitLogger.info("[Controller] Updating remote video mute status to $isVideoMuted");
      isRemoteVideoMuted.value = isVideoMuted;
    }
    callkitLogger.info("[Controller] Updated =>  videoMuted=${isRemoteVideoMuted.value}");
  }

  void audioCallAfterCallSwitch(){
    callkitLogger.info("audioCallAfterCallSwitch change the call type into audio call");
    switchCamera();
    callType.value = "audio";
  }

   bool isSelfId({required String? id}) {
    final String? currentUserId = SessionManagement.getUserJID();
    if (currentUserId == null) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] isSelfId: is null id=$id");
      return true;
    } else {
      //
      final String participantId = "$id@xmpp-uikit-qa.contus.us";
      callkitLogger.info("[MirrorFly][OutgoingCallController] isSelfId $currentUserId $participantId");
      callkitLogger.info("[MirrorFly][OutgoingCallController] isSelfId: ${currentUserId == participantId}");
      return currentUserId == participantId;
    }
  }

  /// Get self id
  String getLocalParticipantId() {
    final String localId = callerList
        .firstWhere((p) => p.isLocalParticipant)
        .identity;
    callkitLogger.info("[MirrorFly][OutgoingCallController] getLocalParticipant: $localId");
    return localId;
  }

  ///
  List<String> getRemoteParticipantsId() {
    final List<String> remoteIds = callerList
        .where((p) => !p.isLocalParticipant)
        .map((p) => p.identity)
        .toList();
    callkitLogger.info("[MirrorFly][OutgoingCallController] getRemoteParticipantsId: $remoteIds");
    return remoteIds;
  }

  ///
  String getRemoteParticipantIdForOneToOneCall() {
    try {
      final String remoteId = callerList
          .where((p) => !p.isLocalParticipant)
          .map((p) => p.identity)
          .first;
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] getRemoteParticipantIdForOneToOneCall: $remoteId");
      return remoteId;
    } catch (e) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] getRemoteParticipantIdForOneToOneCall error: $e");
      return "";
    }
  }

  ///
  void _updateCallDuration({required String duration}) {
    callDuration(duration);
  }

  String trimAfterAt(String input) {
    return input.split('@').first.trim();
  }

  ///
  void callTimeOut({required List<String> participantsId}) async {
    if (!isGroupOnGoingCallEnabled.value && isGroupCall.value){
      toToast("Call timed out");
      // if(NavUtils.canPop){
      //   NavUtils.back();
      // }
      return;
    }
    if(!isGroupCall.value){
      callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, not a group call");
      for(var i in participantsId){
        final target = callerList.firstWhereOrNull((participant) => participant.identity == i);
        if(target != null){
          callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, removing participantId: ${target.identity}");
          callerList.remove(target);
          // if(callerList.length <=1){
          //   callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, ending call as no participants left");
          //   toToast("Call timed out");
          //   if(NavUtils.canPop){
          //     NavUtils.back();
          //   }
          // }
        }
      }
      return;
    }

    participantsId = participantsId
        .map((id) => id.split('@').first.trim())
        .toList();

    callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, group call is ongoing");
    callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, current call participant list: ${callerList.map((e) => e.identity).toList()}");

    if (participantsId.isEmpty) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, no participantsId found");
      return;
    }

    for (final p in participantsId) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, checking participantId: $p");

      final target = callerList.firstWhereOrNull((participant) => participant.identity == p);

      if (target != null) {
        callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, removing participantId: ${target.identity}");
        callerList.remove(target);

        final fullJid = "$p@xmpp-uikit-qa.contus.us";
        final profile = await getProfileDetails(validId(userId: fullJid, isGroup: false));

        callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout,"
            " fetched profile for $fullJid: name=${profile.name}, nickName=${profile.nickName}, jid=${profile.jid}");

        String rawName =
        (profile.name?.trim().isNotEmpty == true)
            ? profile.name!.trim()
            : (profile.nickName?.trim().isNotEmpty == true)
            ? profile.nickName!.trim()
            : trimAfterAt(profile.jid ?? "");

        callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, rawName for $fullJid: $rawName");

        final username = trimAfterAt(rawName);

        callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, showing toast for $username");

        toToast("Call timed out for $username");
        checkParticipantForCallMode();
      } else {
        // callerList.refresh();
        callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, participantId: $p not found in callerList");
      }
    }
  }

  void checkParticipantForCallMode() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] checkParticipantForCallMode called");
    final List<FlyCallParticipant> participants = await getCurrentCallParticipants();
    if (participants.isEmpty) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] checkParticipantForCallMode: No participants found");
      return;
    }
    if (participants.length <= 2 &&
        isGroupCall.value &&
        isGroupOnGoingCallEnabled.value) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] checkParticipantForCallMode: Switching to one-to-one call mode");
      isCallModeChangedToOneToMany.value = false;
      callMode.value = "TO-ONE-TO-ONE";
      isGroupCall.value = false;
      isGroupOnGoingCallEnabled.value = false;
      titleAfterCallModeChange.value = '';
    } else {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] checkParticipantForCallMode: No call mode change needed");
    }
  }

  void rejected({required String userId}) async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] Call rejected by userId: $userId");

    if (isGroupCall.value) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Call rejected, but group call is ongoing, "
              "current remote participant name map: ${remoteUserNameMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}");

      if (!remoteUserNameMap.containsKey(userId)) {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] Call rejected userId: $userId not found in remoteUserNameMap");
        return;
      }

      final String name = remoteUserNameMap[userId] ?? "";
      await Future.delayed(const Duration(milliseconds: 500));
      toToast("$name is busy");
      callerList.removeWhere((e) => e.identity == userId);
      if(callerList.length <=1){
        callkitLogger.info("[MirrorFly][OutgoingCallController] Call rejected, switching to one-to-one call mode");
       NavUtils.back();
      }
      return;
    }

    callkitLogger.info("[MirrorFly][OutgoingCallController] Call rejected, ending call");
    await Future.delayed(const Duration(milliseconds: 500));
    toToast("User Busy");
    NavUtils.back();
  }

  void connecting({List<String>? participantsId , FlyCallStatusEvent? connecting}) {
    callStatus("Connecting...");
    updateCallerStatusList(participantsId: participantsId, status: FlyCallStatusEvent.connecting);
    callkitLogger.info("[MirrorFly] connecting.. called");
  }

  void outGoingCallCalling({ FlyCallStatusEvent? calling, List<String>? participantsId}) {
    callkitLogger.info("[MirrorFly][OutgoingCallController] outgoing calling");
    callStatus("Calling...");
    updateCallerStatusList(participantsId: participantsId, status: FlyCallStatusEvent.calling);
  }

  void onConnected(List<String> participantIds) {
    if (!isGroupCall.value) {

      final bool isUserOnHold = callerList.any((p) =>
      participantIds.contains(p.identity) &&
          p.flyCallStatusEvent == FlyCallStatusEvent.callHold);
      if (isUserOnHold) {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] onConnected: Users on hold found, updating their status to connected");
        updateCallerStatusList(
            participantsId: participantIds,
            status: FlyCallStatusEvent.connected);
        return;
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] onConnected: No users on hold, skipping update");
      }

      callkitLogger.info("[MirrorFly][OutgoingCallController] onConnected for one to one call");
      callStatus("Connected");
      isOnGoingCallView();

      for (var p in participantIds) {
        if (!isSelfId(id: p)) {

          final index = callerList.indexWhere((e) => e.identity == p);
          callkitLogger.info("[MirrorFly][OutgoingCallController] onConnected: Updating participantId: $p at index: $index");

          if (index != -1) {
            final old = callerList[index];
            callerList[index] = old.copyWith(
              flyCallStatus: FlyCallStatusEvent.connected,
            );
          }

          callerList.refresh();
          if (timer == null || !(timer?.isActive ?? false)) {
            _startTimer();
          } else {
            callkitLogger.info(
                "[MirrorFly][OutgoingCallController] Timer is already running");
          }
        } else {
          callkitLogger.info(
              "[MirrorFly][OutgoingCallController] onConnected: Skipping self id: $p");
        }
      }
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] onConnected for group call");

      final bool isUserOnHold = callerList.any((p) =>
      participantIds.contains(p.identity) &&
          p.flyCallStatusEvent == FlyCallStatusEvent.callHold);
      if (isUserOnHold) {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] onConnected: Users on hold found, updating their status to connected");
        updateCallerStatusList(
            participantsId: participantIds,
            status: FlyCallStatusEvent.connected);
        return;
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] onConnected: No users on hold, skipping update");
      }

      callStatus("Connected");
      isOnGoingCallView();
      updateCallerStatusList(participantsId: participantIds,status: FlyCallStatusEvent.connected);

      if (timer == null || !(timer?.isActive ?? false)) {
        _startTimer();
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] Timer is already running");
      }

      if (!isGroupOnGoingCallEnabled.value) {
        callkitLogger.info("[MirrorFly][OutgoingCallController] Group call is now ongoing");
        isGroupOnGoingCallEnabled.value = true;
      }else{
        callkitLogger.info("[MirrorFly][OutgoingCallController] Group call is already ongoing");
      }
    }
  }

  ///
  /// Disconnect call
  ///
  void disconnectCall({required List<String> userIds, required String reason}) {

    if (userIds.isEmpty) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: No userIds provided, assuming the overall call ended.");
      _resetValues();
      _stopTimer();
      closeDialog();
      if (NavUtils.currentRoute == Routes.callKitOutGoingCallView) {
        callStatus("Disconnected");
        reason == "reconnectAttemptsExceeded"
            ? toToast("Reconnection attempt exceeded")
            : toToast("Call Disconnected");
        NavUtils.back();
      }
      return;
    }

    final String userId = userIds.first;

    callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall invoked with userId: $userId, reason: $reason");

    if (isGroupCall.value && isGroupOnGoingCallEnabled.value) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: Group call is ongoing, applying disconnect logic.");

      callerList.removeWhere((e) => e.identity == userId);

      final String name = remoteUserNameMap[userId] ?? "";
      toToast("$name disconnected");

      return;
    }

    callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: for one-one Ending call.");

    _resetValues();
    _stopTimer();
    closeDialog();
    if (NavUtils.currentRoute == Routes.callKitOutGoingCallView) {
      callStatus("Disconnected");
      reason == "reconnectAttemptsExceeded"
          ? toToast("Reconnection attempt exceeded")
          : toToast("Call Disconnected");
      NavUtils.back();
    }
  }

  void isOnGoingCallView() async {
    isOnGoingCallViewEnable.value = true;
  }

  Future<void> handleTimeOutDisconnect() async {
    await MirrorFlyCallKit.disconnectCall();
  }

  void muteAudio() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] muteAudio start");

    MirrorFlyCallKit.toggleMicrophone(result: (result) async {
      callkitLogger.info("[MirrorFly][OutgoingCallController] muteAudio toggleMicrophone result : $result");

      if (result) {
        final bool isMicEnabled =
            await MirrorFlyCallKit.getIsMicrophoneEnabled();
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] muteAudio failure toggleMicrophone isMicEnabled : $isMicEnabled");
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] muteAudio failure toggleMicrophone result : $result");
      }
    });
  }

  void setCameraEnable({required bool enable}) async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable start");
    final FlyCallType? flyCallType =
        await MirrorFlyCallKit.getCurrentCallType();

    if (flyCallType == null) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable: Unable to get current call type.");
      return;
    }

    final bool callStatus = await MirrorFlyCallKit.isCallConnected();

    if (flyCallType == FlyCallType.audio && callStatus) {
      log(
          "[MirrorFly][OutgoingCallController] setCameraEnable: Current call is not a video call, so requesting to switch video call. callStatus- $callStatus");
      requestVideoCallSwitch();
      return;
    }else {
      log("[MirrorFly][OutgoingCallController] setCameraEnable: Current call type is $flyCallType callStatus $callStatus");
    }

    if (flyCallType == FlyCallType.video && !callStatus) {
      log(
          "[MirrorFly][OutgoingCallController] setCameraEnable: Current call is not connected, cannot change camera state. callStatus- $callStatus");
      return;
    }

    callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable: value : $enable");

    MirrorFlyCallKit.setCameraEnable(
        enable: enable,
        result: (result) async {
          if (result) {
            callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable : $result");
            isVideoEnabled.value = enable;
          } else {
            callkitLogger.info(
                "[MirrorFly][OutgoingCallController]  Error setCameraEnable status  result : $result");
          }
        });
  }



  void onCallSwitchRemoteUserDeclined() {
    callkitLogger.info("[MirrorFly][OutgoingCallController] onCallSwitchRemoteUserDeclined");
    toToast("Video call switch declined");
    closeDialog();
  }

  ///
  void onRemoteUserCancelledTheSwitchRequest() {
    callkitLogger.info("[MirrorFly][OutgoingCallController] onRemoteUserCancelledTheSwitchRequest");
    toToast("Video call switch canceled");
    closeDialog();
  }

  ///
  /// Remote user engaged handling
  ///
  void remoteUserIsEngaged({required List<String> participants}) async {

    callkitLogger.info("[MirrorFly][OutgoingCallController] remoteUserIsEngaged with participants: $participants,"
        "isGroupCall: ${isGroupCall.value} & isGroupOnGoingCallEnabled: ${isGroupOnGoingCallEnabled.value}");

    if (callerList.isEmpty) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] remoteUserIsEngaged: No participants found");
      return;
    }

    callkitLogger.info("[MirrorFly][OutgoingCallController] remoteUserIsEngaged: "
        "Checking current call user list, items: ${callerList.map((p) => p.identity).toList()}");

    callkitLogger.info("[MirrorFly][OutgoingCallController] remoteUserIsEngaged isGroupOnGoingCallEnabled: ${isGroupOnGoingCallEnabled.value},"
        " participantsList: ${callerList.map((p) => '${p.identity}: ${p.flyCallStatusEvent}').toList()}");

    if (isGroupCall.value || isGroupOnGoingCallEnabled.value) {
      /// One - Many call user engaged logic
      callkitLogger.info("[MirrorFly][OutgoingCallController] Group call is ongoing, skipping single user engaged logic");

      if (callerList.firstWhere((e) => e.identity == participants.first).flyCallStatusEvent != FlyCallStatusEvent.engaged) {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] remoteUserIsEngaged: The specified participant is not engaged, so removing the user");
        callerList.removeWhere((e) => e.identity == participants.first);
        final String name = remoteUserNameMap[participants.first] ?? participants.first;
        toToast("$name is engaged");

        // Check if all remote participants are engaged
        bool allEngaged = callerList
            .where((p) => !p.isLocalParticipant)
            .every((p) => p.flyCallStatusEvent == FlyCallStatusEvent.engaged);

        if (allEngaged && callerList.length > 1) {
          callkitLogger.info("[MirrorFly][OutgoingCallController] All remote users are engaged → navigating back");
          toToast("All users are engaged");
          await Future.delayed(const Duration(milliseconds: 500));
          if (NavUtils.canPop) {
            NavUtils.back();
          }
          return;
        } else {
          /// Do not navigate back just to show toast and remove the local maintaining user list
          callkitLogger.info("[MirrorFly][OutgoingCallController] Not all users are engaged");
          return;
        }
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] remoteUserIsEngaged: The specified participant is engaged already");
      }
    } else {
      /// One - One call user engaged logic
      callkitLogger.info(
        "[MirrorFly][OutgoingCallController] single user engaged logic,"
            " remoteUserNameMap: ${remoteUserNameMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}",
      );
      toToast("${remoteUserNameMap[participants.first]} is engaged");
      await Future.delayed(const Duration(milliseconds: 500));
      if (NavUtils.canPop) {
        NavUtils.back();
      }
      return;
    }
  }

  void switchCamera() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] switchCamera start");

    MirrorFlyCallKit.switchCameraPosition(result: (result) async {
      callkitLogger.info("[MirrorFly][OutgoingCallController] switchCameraPosition result : $result");

      // After switching, get the updated position
      var pos = await MirrorFlyCallKit.getCurrentCameraPosition();
      if (pos == CameraType.front) {
        cameraPosition.value = pos;
      } else if (pos == CameraType.back) {
        cameraPosition.value = pos;
      }
      callkitLogger.info("[MirrorFly][OutgoingCallController] updated pos : $pos");

      // Update state
    });
  }

  Future<void> initAudioRouting() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] Initializing audio routing...");

    if (callType.value == "audio") {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Call type is audio, setting to earpiece.");
      selectedDevice.value = false;
    } else if (callType.value == "video") {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Call type is video, setting to speaker.");
      selectedDevice.value = true;
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Unknown call type, defaulting to earpiece.");
      selectedDevice.value = false;
    }

    // // Set the selectedDevice.value based on the passed FlyMediaDevice
    // switch (initialDevice.deviceId.toLowerCase()) {
    //   case 'bluetooth':
    //     selectedDevice.value = FlyCallAudioDeviceType.bluetooth;
    //     break;
    //   case 'wired':
    //     selectedDevice.value = FlyCallAudioDeviceType.wired;
    //     break;
    //   case 'speaker':
    //     selectedDevice.value = FlyCallAudioDeviceType.speaker;
    //     break;
    //   case 'earpiece':
    //   case 'receiver':
    //     selectedDevice.value = FlyCallAudioDeviceType.earpiece;
    //     break;
    //   default:
    //     selectedDevice.value = FlyCallAudioDeviceType.earpiece;
    //     break;
    // }
    }

  Future<void> _switchTo() async {
    // determine target device based on current state
    final targetDevice = selectedDevice.value
        ? FlyCallAudioDeviceType.earpiece.value  // if speaker active → switch to earpiece
        : FlyCallAudioDeviceType.speaker.value; // if earpiece active → switch to speaker

    callkitLogger.info("[MirrorFly][OutgoingCallController] Attempting switch to: $targetDevice");

    final result = await MirrorFlyCallKit.changeAudioOutputDevice(
      flyMediaDevice: const FlyMediaDevice("", "", "", ""),
      device: targetDevice,
    );

    if (result) {
      // update state only after success
      selectedDevice.value = !selectedDevice.value;
      callkitLogger.info("[MirrorFly][OutgoingCallController] Switched to: $targetDevice");
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Failed to switch to: $targetDevice");
    }
  }

  Future<void> changeAudioDevice() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] changeAudioDevice -> ");
    await _switchTo();
  }


  // Future<FlyMediaDevice?> _getAudioDevice(String type) async {
  //   final devices = await MirrorFlyCallKit.getAvailableMediaDevices();
  //   return devices.firstWhereOrNull(
  //     (d) =>
  //         d.deviceId.toLowerCase().contains(type.toLowerCase()) &&
  //         d.kind == "audiooutput",
  //   );
  // }

  Future<List<FlyCallAudioDeviceType>> getAvailableTypes() async {
    // final devices = await MirrorFlyCallKit.getAvailableMediaDevices();
    // final audioOutputs = devices.where((d) => d.kind == "audiooutput").toList();

    // final types = <FlyCallAudioDeviceType>[];
    // if (audioOutputs.any((d) => d.deviceId
    //     .toLowerCase()
    //     .contains(FlyCallAudioDeviceType.speaker.value))) {
    //   types.add(FlyCallAudioDeviceType.speaker);
    // }
    // if (audioOutputs.any((d) =>
    //     d.deviceId
    //         .toLowerCase()
    //         .contains(FlyCallAudioDeviceType.earpiece.value) ||
    //     d.deviceId.toLowerCase().contains("receiver"))) {
    //   types.add(FlyCallAudioDeviceType.earpiece);
    // }
    // if (audioOutputs.any((d) =>
    //     d.groupId
    //         ?.toLowerCase()
    //         .contains(FlyCallAudioDeviceType.bluetooth.value) ??
    //     false)) {
    //   types.add(FlyCallAudioDeviceType.bluetooth);
    // }
    // if (audioOutputs.any((d) => d.deviceId
    //     .toLowerCase()
    //     .contains(FlyCallAudioDeviceType.wired.value))) {
    //   types.add(FlyCallAudioDeviceType.wired);
    // }

    return [FlyCallAudioDeviceType.speaker, FlyCallAudioDeviceType.earpiece];
  }

  void localHangup() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController]  disconnectCall invoked...");
    _stopTimer();
    try {
      var result = await MirrorFlyCallKit.localHangup();
      callkitLogger.info("[MirrorFly][OutgoingCallController] localHangup() result: $result");

      if (result == true) {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController]  Call disconnected successfully. Navigating back...");
        NavUtils.back();
      } else {
        NavUtils.back();
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController]  Call disconnect failed. Retrying or handling failure...");
      }
    } catch (e, stack) {
      callkitLogger.info("[MirrorFly][OutgoingCallController]  Exception in disconnectCall: $e");
      print(stack);
    }
  }

  ///
  void onTracksPublished(
      {required bool isSelf, required String participantId}) {
    if (isSelf) {
      if (!isLocalTracksPublished.value) {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] [MirrorFlyCall] Local tracks published for $participantId");
        isLocalTracksPublished(true);
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] [MirrorFlyCall] Ignoring duplicate local publish for $participantId");
      }
    } else {
      if (!isRemoteTracksPublished.value) {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] [MirrorFlyCall] Remote tracks published for $participantId");
        isRemoteTracksPublished(true);
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] [MirrorFlyCall] Ignoring duplicate remote publish for $participantId");
      }
    }
  }

  ///
  void requestVideoCallSwitch() async {
    if(isGroupCall.value){
      callkitLogger.info("[MirrorFly][OutgoingCallController] requestVideoCallSwitch: Call switch  supported in group calls.");
      MirrorFlyCallKit.toggleVideoForGroupCall();
      return;
    }

    final bool callStatus = await MirrorFlyCallKit.isCallConnected();
    final FlyCallType? flyCallType = await MirrorFlyCallKit.getCurrentCallType();

    if (flyCallType == FlyCallType.audio && callStatus) {
      log("[MirrorFly][OutgoingCallController]  makeCallSwitch invoked...");
      _videoCallSwitchRequestConfirmationPopup();
    }else{
      log("[MirrorFly][OutgoingCallController] Current call is not an audio call or call is not connected, cannot switch to video. callStatus- $callStatus, flyCallType- $flyCallType");
    }

  }

  ///
  void cancelVideoCallSwitchRequest() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController]  cancelVideoCallSwitch invoked...");
    await MirrorFlyCallKit.cancelVideoCallSwitchRequest();
    toToast("Video call switch canceled");
    closeDialog();
    // _cancelCallSwitchReqWaiting();
  }

  ///
  void acceptIncomingCallSwitchRequest() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController]  acceptIncomingCallSwitchRequest invoked...");
    closeDialog();
    await MirrorFlyCallKit.acceptIncomingVideoCallSwitchRequest();
  }

  ///
  void declineIncomingCallSwitchRequest() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController]  declineIncomingCallSwitchRequest invoked...");
    await MirrorFlyCallKit.declineIncomingVideoCallSwitchRequest();
    closeDialog();
  }

  ///

  void onVideoCallSwitchAccept() {
    onVideoCallSwitchRequestAccepted();
    processCallSwitchUI();
  }

  void onVideoCallSwitchTimeOut() {
    closeDialog();
    final String remoteId = getRemoteParticipantsId().first ?? "";
    final remoteUserName = remoteUserNameMap[remoteId] ?? "";
    toToast(getTranslated("noResponseFrom").replaceFirst("%d", remoteUserName));
  }

  ///
  void processCallSwitchUI() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] Processing call switch UI changes...");
    final FlyCallType? flyCallType =
        await MirrorFlyCallKit.getCurrentCallType();
    if (flyCallType == null && flyCallType == FlyCallType.none) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Unable to get current call type after switch.");
      return;
    }
    flyCallType == FlyCallType.audio ? callType("audio") : callType("video");
  }

  ///
  void onVideoCallSwitchRequestAccepted() {
    callkitLogger.info("[MirrorFly][OutgoingCallController] Video call switch request accepted.");
    closeDialog();
  }

  ///
  void _videoCallSwitchRequestConfirmationPopup() {
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("videoSwitchMessage"),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: closeDialog,
              child: Text(
                getTranslated("cancel").toUpperCase(),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () async {
                closeDialog();
                await MirrorFlyCallKit.requestVideoCallSwitch();
              },
              child: Text(
                getTranslated("switchCall"),
              ))
        ],
        barrierDismissible: false);
  }

  ///
  void showIncomingCallSwitchRequestDialog() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController][DEBUG] showIncomingCallSwitchRequestDialog called");

    closeDialog();
    try {
      await _player?.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.voiceCommunicationSignalling,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
      await _player?.setVolume(1.0);
      await _player?.setReleaseMode(ReleaseMode.loop);
      await _player?.play(AssetSource('sounds/reconnecting.mp3'));
      await Future.delayed(const Duration(milliseconds: 300));
      final state = _player?.state;
      callkitLogger.info("[MirrorFly][OutgoingCallController] Player state after play(): $state");

      if (state == PlayerState.playing) {
        _isPlaying = true;
        callkitLogger.info("[MirrorFly][OutgoingCallController]  Ringtone is playing!");
      } else {
        callkitLogger.info("[MirrorFly][OutgoingCallController]  Not playing, state=$state");
      }
      callkitLogger.info("[MirrorFly][OutgoingCallController][DEBUG] AudioPlayer started playing");
    } catch (e) {
      callkitLogger.info("[MirrorFly][OutgoingCallController][DEBUG] Failed to play ringtone: $e");
    }

    DialogUtils.showAlert(
      dialogStyle: AppStyleConfig.dialogStyle,
      message: getTranslated("videoSwitchRequestedMessage")
          .replaceFirst("%d", remoteUserNameMap[getRemoteParticipantsId().first] ?? ""),
      actions: [
        TextButton(
            onPressed: () async {
              callkitLogger.info("[MirrorFly][OutgoingCallController][DEBUG] Decline pressed");
              declineIncomingCallSwitchRequest();
            },
            child: Text(getTranslated("declineRequest").toUpperCase())),
        TextButton(
            onPressed: () async {
              callkitLogger.info("[MirrorFly][OutgoingCallController][DEBUG] Accept pressed");
              acceptIncomingCallSwitchRequest();
            },
            child: Text(getTranslated("acceptRequest"))),
      ],
      barrierDismissible: false,
    );
  }

  ///
  void showOutGoingCallSwitchRequestDialog() {
    //
    // _isWaitingCanceled = false;
    // _outgoingSwitchTimer?.cancel();

    //
    closeDialog();
    DialogUtils.showAlert(
      dialogStyle: AppStyleConfig.dialogStyle,
      message: getTranslated("videoSwitchRequestMessage"),
      actions: [
        TextButton(
          style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: cancelVideoCallSwitchRequest,
          child: Text(getTranslated("cancel").toUpperCase()),
        )
      ],
      barrierDismissible: false,
    );

    // _outgoingSwitchTimer = Timer(const Duration(seconds: 20), () async {
    //   print("[MirrorFly][OutgoingCallController][BaseController] 20s wait ended");
    //   if (!_isWaitingCanceled) {
    //     _cancelVideoCallSwitchRequestOnTimerEnd();
    //     toToast(getTranslated("noResponseFrom").replaceFirst("%d", "Test"));
    //     _closeDialog();
    //   } else {
    //     print("[MirrorFly][OutgoingCallController][BaseController] _isWaitingCanceled is true");
    //   }
    // });
  }

  ///
  // void _cancelVideoCallSwitchRequestOnTimerEnd() async {
  //   print("[MirrorFly][OutgoingCallController][BaseController] Canceling video call switch request due to timeout");
  //
  //   _cancelCallSwitchReqWaiting();
  //
  //   print("[MirrorFly][OutgoingCallController] cancelVideoCallSwitchRequestOnTimerEnd invoked...");
  //   await MirrorFlyCallKit.cancelVideoCallSwitchRequest();
  //   _closeDialog();
  // }

  // ///
  // void _cancelCallSwitchReqWaiting() {
  //   _isWaitingCanceled = true;
  //   _outgoingSwitchTimer?.cancel();
  // }

  ///
  void closeDialog() async{
    callkitLogger.info("[MirrorFly][OutgoingCallController] _closeDialog called");

    // Stop the ringtone only if it is currently playing
    if (_isPlaying) {
      await _player?.stop();
      _isPlaying = false;
      callkitLogger.info("[MirrorFly][OutgoingCallController][DEBUG] AudioPlayer stopped (manual tracking)");
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController][DEBUG] AudioPlayer not playing (manual tracking)");
    }


    // Close the dialog if open
    if (DialogUtils.isDialogOpen() && NavUtils.canPop) {
      NavUtils.back();
      callkitLogger.info("[MirrorFly][OutgoingCallController] Dialog closed");
    }
  }



  ///
  void onCallFailed() {
    callkitLogger.info("[MirrorFly][OutgoingCallController] onCallFailed called");
    _resetValues();
    _stopTimer();
    if (NavUtils.currentRoute == Routes.callKitOutGoingCallView) {
      callStatus("Call Failed");
      toToast("Call Failed");
      NavUtils.back();
    }
  }

  /// Invite participants to the ongoing call
  void inviteParticipants() async {
    final String callMode = this.callMode.value;
    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] inviteParticipants called with callMode: $callMode");
    final List<String> pickedContacts =
    await gotoContacts(isGroupInvite: callMode != "oneToOne");
    if (pickedContacts.length > 5) {
      // Temp limit to 5 participants
      toToast("You can invite up to 5 participants only");
      return;
    } else {

      MirrorFlyCallKit.inviteParticipants(inviteUserList: pickedContacts, flyResult: (res) async {
        callkitLogger.info("[MirrorFly][OutgoingCallController] inviteParticipants result: $res");
        if (res.isSuccess) {
          // callerList.value = await getCurrentCallParticipants();
          callkitLogger.info("[MirrorFly][OutgoingCallController] after inviteParticipants callerList: ${callerList.map((e) => e.identity).toList()}");
        }
      });
    }
  }

  /// Navigate to contacts screen
  Future<List<String>> gotoContacts({bool isGroupInvite = false}) async {
    var topicId = Constants.topicId.obs;
    if (!Constants.enableContactSync) {
      final dynamic result = await NavUtils.toNamed(Routes.contacts,
          arguments: ContactListArguments(
            // forGroup: isGroupInvite,
            // groupJid: isGroupInvite ? groupChatId.value : "",
              topicId: topicId.value,
              forMakeCall: true,
              callType: callType.value));
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] gotoContacts contact sync disabled $result");
      return result;
    } else {
      var contactPermissionHandle =
      await AppPermission.checkAndRequestPermissions(
          permissions: [Permission.contacts],
          permissionIcon: contactPermission,
          permissionContent: getTranslated("contactPermissionContent"),
          permissionPermanentlyDeniedContent:
          getTranslated("contactPermissionDeniedContent"));
      if (contactPermissionHandle) {
        final dynamic result = await NavUtils.toNamed(Routes.contacts,
            arguments: ContactListArguments(
              // forGroup: isGroupInvite,
              // groupJid: isGroupInvite ? groupChatId.value : "",
                topicId: topicId.value,
                forMakeCall: true,
                callType: callType.value));
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] gotoContacts contact sync enabled $result");
        return result;
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] gotoContacts permission denied");
        return [];
      }
    }
  }


  ///
  void onParticipantListUpdated() async {
    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] onCallModeChanged called with callMode");
    final preCallUserListCount = callerList.length;
    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] onCallModeChanged preCallUserListCount: $preCallUserListCount");
    await getCurrentCallParticipants();

    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] onCallModeChanged fetched callerList with length: ${callerList.length}");

    if (preCallUserListCount == callerList.length) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] onCallModeChanged: callerList length changed during fetch, aborting call mode change.");
      return;
    }

    await configureCallMode(
        callMode: callerList.length > 2 ? "ONE-TO-MANY" : "ONE-TO-ONE",
        chatId: groupId.value);

    callkitLogger.info("[MirrorFly][OutgoingCallController] onCallModeChanged updated "
        "local callMode: ${callMode.value}, isGroupCall: ${isGroupCall.value} "
        "isGroupOnGoingCallEnabled: ${isGroupOnGoingCallEnabled.value}");

    isGroupOnGoingCallEnabled(!(callerList.length <= 2));
    isCallModeChangedToOneToMany(!(callerList.length <= 2));

    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] onCallModeChanged completed, fetching current call"
        " participants..., with isGroupOnGoingCallEnabled: ${isGroupOnGoingCallEnabled.value}, "
        "isCallModeChangedToOneToMany: ${isCallModeChangedToOneToMany.value}");
    await getRemoteAndLocalUserNameForGroupCall();
    getCallTitleForOneToManyCall();
  }

    // ///
    // void videoSwap(){
    //   callkitLogger.info("[MirrorFly][OutgoingCallController] videoSwap called");
    //   if(callType.value == "video"){
    //     callkitLogger.info("[MirrorFly][OutgoingCallController] videoSwap before: mainCallViewUserId: $mainCallViewUserId, secondaryCallViewUserId: $secondaryCallViewUserId");
    //     final String temp = mainCallViewUserId.value;
    //     mainCallViewUserId.value = secondaryCallViewUserId.value;
    //     secondaryCallViewUserId.value = temp;
    //     callkitLogger.info("[MirrorFly][OutgoingCallController] videoSwap: mainCallViewUserId: $mainCallViewUserId, secondaryCallViewUserId: $secondaryCallViewUserId");
    //   }
    // }

  ///
  /// To update the call status of a participant in the callerList
  ///
  Future<void> updateCurrentCallParticipant({required String id, required FlyCallStatusEvent status}) async {
    final FlyCallParticipant? participant = callerList.firstWhereOrNull((p) => p.identity == id);
    if (participant != null) {
      participant?.copyWith(flyCallStatus: status);
      callerList.refresh();
      callkitLogger.info("[MirrorFly][OutgoingCallController] updateCurrentCallParticipant: Updated participant $id to status $status");
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] updateCurrentCallParticipant: Participant $id not found in callerList");
    }
  }

  ///
  /// Call hold - When the user puts the call on hold
  ///
  void callHold({required List<String> participantsId}) {
    callkitLogger.info("[MirrorFly][OutgoingCallController] callHold called with participantsId: $participantsId");

    if (participantsId.isEmpty) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] callHold: No participantsId provided.");
      return;
    }

    final String userId = participantsId.first;
    updateCurrentCallParticipant(id: userId, status: FlyCallStatusEvent.callHold);
    callkitLogger.info("[MirrorFly][OutgoingCallController] callHold: Updated participant $userId to callHold status.");

    if (callMode.string == "ONE-TO-ONE") {
      callStatus("On Hold");
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] callHold: Group call - not updating overall call status.");
    }
  }

  ///
  /// Call resume - When the user resumes the call from hold
  ///
  void callResume({required List<String> participantsId}) {
    callkitLogger.info("[MirrorFly][OutgoingCallController] callResume called with participantsId: $participantsId");

    if (participantsId.isEmpty) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] callResume: No participantsId provided.");
      return;
    }

    final String userId = participantsId.first;
    updateCurrentCallParticipant(id: userId, status: FlyCallStatusEvent.connected);
    callkitLogger.info("[MirrorFly][OutgoingCallController] callResume: Updated participant $userId to connected status.");

    if (callMode.string == "ONE-TO-ONE") {
      callStatus("");
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] callResume: Group call - not updating overall call status.");
    }
  }

  ///
  /// Method triggered for the audio level change
  /// User speaking detection
  ///
  void onActiveSpeakerChange({required bool isSpeaking, required double audioLevel, required String participantId}) {
    callkitLogger.info("[MirrorFly][OutgoingCallController] onActiveSpeakerChange called for participantId: $participantId, isSpeaking: $isSpeaking, audioLevel: $audioLevel");

    final participant = callerList.firstWhereOrNull((p) => p.identity == participantId);
    if (participant != null) {
      participant.copyWith(isSpeaking: isSpeaking, audioLevel: audioLevel);

      callerAudioLevel[participantId] = isSpeaking ? audioLevel : 0;
      callerAudioLevel.refresh();

      callkitLogger.info("[MirrorFly][OutgoingCallController] onActiveSpeakerChange:"
          "newEntries: $callerAudioLevel Updated participant $participantId with isSpeaking: $isSpeaking, audioLevel: $audioLevel");
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] onActiveSpeakerChange: Participant $participantId not found in callerList");
    }
  }

  int getAudioLevelForParticipant(String participantId) {
    // convert double audio level (0.0 to 1.0) to int percentage (0 to 100)
    if (callerAudioLevel.containsKey(participantId)) {
      double level = callerAudioLevel[participantId] ?? 0.0;
      var value = ((level * 100).clamp(0, 100)).toInt();
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] getAudioLevelForParticipant called for participantId: $participantId, is returning audio level: $value");
      return value;
    } else {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] getAudioLevelForParticipant called for participantId: $participantId, no audio level found, returning 0");
      return 0;
    }
  }

  ///
  void _resetValues() {
    callType("");
    // muted(false);
    isVideoEnabled(false);
    speakerOn(false);
    isOnGoingCallViewEnable(false);
    // callerUsersId(<String?>[]);
    cameraSwitch(false);
    isIncoming(false);
    cameraPosition(CameraType.front);
    isRemoteVideoMuted(false);
    isLocalTracksPublished(false);
    isRemoteTracksPublished(false);
    isManualDeviceSelected(false);
    callTryStatus("");
    groupId("");
    callerList.clear();

    remoteUserNameMap({});
    isGroupCall(false);
    chatNameForGroupCall("");
    isGroupOnGoingCallEnabled(false);
    groupCallTitle("");
    isCallModeChangedToOneToMany(false);
    titleAfterCallModeChange("");
    _isPlaying = false;

    callkitLogger.info("[MirrorFly][OutgoingCallController] _resetValues");
  }
}