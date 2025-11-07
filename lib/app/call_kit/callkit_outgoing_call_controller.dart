import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../app_style_config.dart';
import '../common/app_localizations.dart';
import '../data/session_management.dart';
import '../data/utils.dart';
import '../model/arguments.dart';
import '../routes/route_settings.dart';
import 'package:permission_handler/permission_handler.dart';

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
  RxBool muted = false.obs;
  RxBool isVideoEnabled = true.obs;
  RxBool speakerOn = false.obs;
  RxBool isOnGoingCallViewEnable = false.obs;

  RxList<String?> callerUsersId = <String?>[].obs;

  RxBool selectedDevice = false.obs;

  final RxBool cameraSwitch = false.obs;
  final RxBool isIncoming = false.obs;
  final RxBool isManualDeviceSelected = false.obs;

  RxString cameraPosition = CameraType.front.obs;
  RxBool isRemoteAudioMuted = false.obs;
  RxBool isRemoteVideoMuted = true.obs;

  /// For one to one call
  RxString remoteUserName = "".obs;

  /// For both the calls
  RxString localUserName = "".obs;

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

  ///
  final RxBool isLocalTracksPublished = false.obs;
  final RxBool isRemoteTracksPublished = false.obs;

  RxString localParticipantId = "".obs;
  RxString remoteParticipantId = "".obs; // Temp for now as we do only 1-1 calls

  ///
  RxString mainCallViewUserId = "".obs;
  RxString secondaryCallViewUserId = "".obs;
  Timer? timer;

  ///
  // Timer? _outgoingSwitchTimer;
  // bool _isWaitingCanceled = false;

  RxBool isLocalUserReconnecting = false.obs;
  RxBool isRemoteUserReconnecting = false.obs;

  @override
  Future<void> onInit() async {
    await _handleInitialCallStatus();
    await getCurrentCallParticipants();

    debugPrint("[MirrorFly][OutgoingCallController] callviewinit");

    if (NavUtils.arguments != null) {
      await _initCallArguments();
      _handleCallTypeLogic();
    } else {
      debugPrint("[MirrorFly][OutgoingCallController] No call arguments found");
    }

    await configureCallMode(callMode: callMode.value, chatId: groupId.value);
    debugPrint("[MirrorFly][OutgoingCallController] callview");
    super.onInit();
  }

  Future<void> _initCallArguments() async{
    try {
      debugPrint("[MirrorFly][OutgoingCallController] Initializing call arguments from NavUtils");
      callerUsersId.value = NavUtils.arguments?["userJid"] as List<String?>;
      callType(NavUtils.arguments?["callType"]);
      groupId(NavUtils.arguments?["chatId"] as String? ?? "");
      callMode(NavUtils.arguments?["callMode"] as String? ?? "");
      isIncoming.value = NavUtils.arguments?["isIncoming"] as bool? ?? false;

      debugPrint(
        "[MirrorFly][OutgoingCallController] "
            "isIncoming: groupId $groupId incoming $isIncoming callType $callType callerUsersId $callerUsersId callMode $callMode ",
      );
    } catch(e) {
      debugPrint("[MirrorFly][OutgoingCallController] Error initializing call arguments: $e");
    }
  }

  void _handleCallTypeLogic() {
    if (isIncoming.value) {
      _handleIncomingCall();
    } else if (!isIncoming.value && callType.value == "audio") {
      _handleOutgoingAudioCall();
    } else if (!isIncoming.value && callType.value == "video") {
      _handleOutgoingVideoCall();
    } else {
      debugPrint("[MirrorFly][OutgoingCallController] Invalid call parameters");
    }
  }

  void _handleIncomingCall() {
    isOnGoingCallView();

    final localParticipant =
    callerList.firstWhereOrNull((p) => p.isLocalParticipant == true);
    final remoteParticipant =
    callerList.firstWhereOrNull((p) => p.isLocalParticipant == false);

    if (localParticipant != null) {
      secondaryCallViewUserId.value = localParticipant.identity;
    } else {
      secondaryCallViewUserId.value = SessionManagement.getUserJID().checkNull();
    }

    if (remoteParticipant != null) {
      mainCallViewUserId.value = remoteParticipant.identity;
    } else {
      mainCallViewUserId.value = callerUsersId[0] ?? "";
    }

    debugPrint("[MirrorFly][IncomingCall] main:${mainCallViewUserId.value} "
        "secondary:${secondaryCallViewUserId.value}");
  }

  void _handleOutgoingAudioCall() {
    if (groupId.value.isNotEmpty) {
      mainCallViewUserId.value = groupId.value;
      return;
    }

    if (callerList.isEmpty) {
      debugPrint("[MirrorFly][AudioCall] Caller list empty");
      mainCallViewUserId.value = callerUsersId[0] ?? "";
      return;
    }

    final remoteParticipant =
    callerList.firstWhereOrNull((p) => p.isLocalParticipant == false);

    if (remoteParticipant != null) {
      mainCallViewUserId.value = remoteParticipant.identity;
    } else {
      mainCallViewUserId.value = callerUsersId[0] ?? "";
    }

    debugPrint("[MirrorFly][AudioCall] main:${mainCallViewUserId.value}");
  }

  void _handleOutgoingVideoCall() {
    if (groupId.value.isNotEmpty) {
      mainCallViewUserId.value = groupId.value;
      return;
    }

    if (callerList.isEmpty) {
      debugPrint("[MirrorFly][VideoCall] Caller list empty");
      return;
    }

    final localParticipant =
    callerList.firstWhereOrNull((p) => p.isLocalParticipant == true);
    final remoteParticipant =
    callerList.firstWhereOrNull((p) => p.isLocalParticipant == false);

    if (localParticipant != null && remoteParticipant != null) {
      mainCallViewUserId.value = localParticipant.identity;
      secondaryCallViewUserId.value = remoteParticipant.identity;
    } else {
      mainCallViewUserId.value = SessionManagement.getUserJID().checkNull();
      secondaryCallViewUserId.value = callerUsersId[0] ?? "";
    }

    debugPrint("[MirrorFly][VideoCall] main:${mainCallViewUserId.value} "
        "secondary:${secondaryCallViewUserId.value}");
  }

  @override
  void onReady() async {
    initAudioRouting();

    await getRemoteAndLocalUserNameForGroupCall();

    await getChatNameForGroupCall(chatId: groupId.value);

    await getGroupCallTitle();

    getUserNameForOneToOneCall(
        remoteUserId: remoteParticipantId.value, localUserId: localParticipantId.value);

    getLogsOfLocalValues();
    super.onReady();
  }

  ///
  /// Get current participants in the call
  ///
  Future<List<FlyCallParticipant>> getCurrentCallParticipants() async {
    final participants = await MirrorFlyCallKit.getCurrentCallParticipants();
    debugPrint("[MirrorFly][OutgoingCallController] Current call participants: ${callerList.length}, participants: ${callerList.map((p) => p.identity).toList()}");
    callerList.value = participants ?? [];
    return participants ?? []; // Handle null safely
  }

  ///
  /// Verify the call mode
  ///
  Future<void> configureCallMode({required String callMode, required String chatId}) async {

    debugPrint("[MirrorFly][OutgoingCallController] #configureCallMode with callMode: $callMode, chatId: $chatId");

    // Consider as one to one call
    if (chatId.isEmpty) {
      debugPrint(
          "[MirrorFly][OutgoingCallController] #configureCallMode with remote participantId for "
              "one to one call, callerUsersId: ${callerUsersId.map((e) => e).toList()}");
      remoteParticipantId.value = callerUsersId.first ?? '';
    }

    // Validate for group call
    final bool yes = callMode == "TO-ONE-TO-MANY" || callMode == "ONE-TO-MANY" && chatId != "";
    isGroupCall.value = yes;

    debugPrint(
        "[MirrorFly][OutgoingCallController] #configureCallMode isGroupCall: ${isGroupCall.value}");

    // For both
    localParticipantId.value = SessionManagement.getUserJID() ?? '';

    debugPrint(
        "[MirrorFly][OutgoingCallController] #configureCallMode localParticipantId: ${localParticipantId.value}, remoteParticipantId: ${remoteParticipantId.value}");
  }

  ///
  /// Get remote user name for the each id for group call
  ///
  Future<void> getRemoteAndLocalUserNameForGroupCall() async {
    if (!isGroupCall.value) {
      debugPrint(
          "[MirrorFly][OutgoingCallController] #getRemoteAndLocalUserNameForGroupCall Not a group call");
      return;
    }
    for (var user in callerList) {
      debugPrint("[MirrorFly][OutgoingCallController] Getting user name for: ${user.identity}, isLocal: ${user.isLocalParticipant}");
        ProfileDetails profile = await getProfileDetails(validId(userId: user.identity,isGroup: false));
        String username = profile.name ?? profile.nickName ?? "Unknown";
        remoteUserNameMap[user.identity] = user.isLocalParticipant ? "You" : username;
        debugPrint(
            "[MirrorFly][OutgoingCallController] Remote User Name for ${user.identity}: $username");
    }
    debugPrint("[MirrorFly][OutgoingCallController] Completed fetching user names for group call, remoteUserNameMap: ${remoteUserNameMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}");
    return;
  }

  String validId({required String userId,required bool isGroup}) {
    if(isGroup){
      return userId.contains("@") ? userId : "$userId@mix.xmpp-uikit-qa.contus.us";
    }else{
      return userId.contains("@") ? userId : "$userId@xmpp-uikit-qa.contus.us";
    }
  }


  ///
  /// Get user name of remote user for one to one call
  ///
  Future<void> getUserNameForOneToOneCall(
      {required String remoteUserId, required String localUserId}) async {
    if (!isGroupCall.value) {
      debugPrint(
          "[MirrorFly][OutgoingCallController] #getUserNameForOneToOneCall User Name for remote: $remoteUserId");
      ProfileDetails remoteProfile = await getProfileDetails(remoteUserId);
      String remoteProfileName =
          remoteProfile.name ?? remoteProfile.nickName ?? "Unknown";
      remoteUserName.value = remoteProfileName;
      debugPrint(
          "[MirrorFly][OutgoingCallController] #getUserNameForOneToOneCall User Name for local: $localUserId");
      ProfileDetails localProfile = await getProfileDetails(localUserId);
      String localProfileName =
          localProfile.name ?? localProfile.nickName ?? "Unknown";
      localUserName.value = localProfileName;
    } else {
      debugPrint(
          "[MirrorFly][OutgoingCallController] #getUserNameForOneToOneCall  a one to one call");
    }
  }

  ///
  /// Get chat name for group call
  ///
  Future<void> getChatNameForGroupCall({required String chatId}) async {
    debugPrint("[MirrorFly][OutgoingCallController] #getChatNameForGroupCall called with chatId: $chatId");
    if (isGroupCall.value && chatId.isNotEmpty) {
      debugPrint(
          "[MirrorFly][OutgoingCallController] #getChatNameForGroupCall with chatId: ${groupId.value}");
      ProfileDetails profile = await getProfileDetails(validId(userId: chatId,isGroup: true));
      String chatName = profile.name ?? profile.nickName ?? "Unknown Group";
      chatNameForGroupCall.value = chatName;
    } else {
      debugPrint(
          "[MirrorFly][OutgoingCallController] #getChatNameForGroupCall Not a group call chatId: ${groupId.value}");
    }
  }

  ///
  /// Get call title for the one-to-many call.
  ///
  Future<void> getCallTitleForOneToManyCall() async {
    debugPrint("[MirrorFly][OutgoingCallController] #getCallTitleForOneToManyCall called");

    if (!isGroupCall.value) {
      debugPrint("[MirrorFly][OutgoingCallController] Not a group call");
      return;
    }

    final filteredNames = remoteUserNameMap.values
        .where((name) => name.trim().toLowerCase() != "you")
        .toList();

    final int participantCount = filteredNames.length;

    if (participantCount == 0) {
      titleAfterCallModeChange.value = "You";
      return;
    }

    String title;

    if (participantCount == 1) {
      title = "You and ${filteredNames.first}";
    } else if (participantCount == 2) {
      title = "You, ${filteredNames[0]} & ${filteredNames[1]}";
    } else {
      title = "You, ${filteredNames.first} & ${participantCount - 1} others";
    }

    titleAfterCallModeChange.value = title;

    debugPrint(
        "[MirrorFly][OutgoingCallController] #getCallTitleForOneToManyCall -> $title");
  }

  ///
  /// Get group call title
  ///
  Future<void> getGroupCallTitle() async {
    if (!isGroupCall.value) {
      debugPrint(
          "[MirrorFly][OutgoingCallController] #getGroupCallTitle Not a group call");
      return;
    } else {

    }
  }

  ///
  /// Handle the UI based on the current call status
  ///
  Future<void> _handleInitialCallStatus() async {
    debugPrint("[MirrorFly] _handleInitialCallStatus called");
    final FlyCallStatusEvent? currentStatusEvent =
        MirrorFlyCallKit.currentCallStatus?.flyCallStatusEvent;
    debugPrint("[MirrorFly] currentStatusEvent: $currentStatusEvent");
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
  /// Handle group call connected state
  ///
  void onGroupCallJoinSync(
      {required Map<String, FlyCallStatusEvent> joinSyncStatus}) async {
    if (!isGroupCall.value) {
      debugPrint(
          "[MirrorFly][OutgoingCallController] onGroupCallConnected called for non-group call");
      return;
    }

    debugPrint(
        "[MirrorFly][OutgoingCallController] onGroupCallConnected called with joinSyncStatus: ${joinSyncStatus.entries.map((e) => '${e.key}: ${e.value}').join(', ')}");

    // // Refresh the participants list
    // // await getCurrentCallParticipants();
    //
    // debugPrint("[MirrorFly][OutgoingCallController] onGroupCallConnected checking connected participants");
    //
    // final List<FlyCallParticipant> onlyRemote =
    // callerList.where((e) => !e.isLocalParticipant).toList();
    //
    // if (onlyRemote.any((p) => p.flyCallStatusEvent == FlyCallStatusEvent.connected)) {
    //   isGroupOnGoingCallEnabled.value = true;
    //   callStatus("Connected");
    //   if (timer == null || !(timer?.isActive ?? false)) {
    //     debugPrint("[MirrorFly][OutgoingCallController] onGroupCallConnected starting timer");
    //     _startTimer();
    //   } else {
    //     debugPrint("[MirrorFly][OutgoingCallController] onGroupCallConnected Timer is already running");
    //   }
    // }
  }

  ///
  /// Get participant connection state
  ///
  String getParticipantConnectionState(FlyCallStatusEvent status) {
    debugPrint("[MirrorFly][OutgoingCallController] getParticipantConnectionState called with status: $status");
    switch (status) {
      case FlyCallStatusEvent.connected:
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
      default:
        return "Unknown";
    }
  }

  ///
  /// Get logs for values
  ///
  void getLogsOfLocalValues() {
    debugPrint('''
       [Call Logs]
       callStatus: ${callStatus.value}
       callDuration: ${callDuration.value}
       callTryStatus: ${callTryStatus.value}
       callType: ${callType.value}
       groupId: ${groupId.value}
       callMode: ${callMode.value}
       showControls: ${showControls.value}
       muted: ${muted.value}
       isVideoEnabled: ${isVideoEnabled.value}
       speakerOn: ${speakerOn.value}
       isOnGoingCallViewEnable: ${isOnGoingCallViewEnable.value}
       callerUsersId: ${callerUsersId.join(', ')}
       selectedDevice: ${selectedDevice.value}
       cameraSwitch: ${cameraSwitch.value}
       isIncoming: ${isIncoming.value}
       isManualDeviceSelected: ${isManualDeviceSelected.value}
       cameraPosition: ${cameraPosition.value}
       isRemoteAudioMuted: ${isRemoteAudioMuted.value}
       isRemoteVideoMuted: ${isRemoteVideoMuted.value}
       remoteUserName: ${remoteUserName.value}
       localUserName: ${localUserName.value}
       isGroupCall: ${isGroupCall.value}
       chatNameForGroupCall: ${chatNameForGroupCall.value}
       remoteUserNameMap: ${remoteUserNameMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}
       callerList length: ${callerList.length}
       isLocalTracksPublished: ${isLocalTracksPublished.value}
       isRemoteTracksPublished: ${isRemoteTracksPublished.value}
       localParticipantId: ${localParticipantId.value}
       remoteParticipantId: ${remoteParticipantId.value}
       mainCallViewUserId: ${mainCallViewUserId.value}
       secondaryCallViewUserId: ${secondaryCallViewUserId.value}
          ''');
  }

  @override
  void onClose() {
    debugPrint("[MirrorFly][OutgoingCallController] CallKitOutgoingCallController onClose called");
    super.onClose();
  }


  @override
  void dispose(){
    debugPrint("[MirrorFly][OutgoingCallController] CallKitOutgoingCallController dispose called");
    super.dispose();

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
      debugPrint("[MirrorFly][OutgoingCallController] Timer is null");
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
    if(participantsId!.isNotEmpty){
      for (final id in participantsId) {
        if (!isSelfId(id: id)) {
          final index = callerList.indexWhere((p) => p.identity == id);

          if (index != -1) {
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
            callerList.add(
              FlyCallParticipant(
                identity: id,
                isLocalParticipant: false, // or determine based on logic
                flyCallStatusEvent: status,
                flyCallActionEvent: null,
              ),
            );
          }
        }else{
          debugPrint("[MirrorFly][OutgoingCallController] updateCallerStatusList: Skipping self id: $id");
        }
      }
      callerList.refresh();
    }else{
      debugPrint("[MirrorFly][OutgoingCallController] updateCallerStatusList: participantsId is empty");
    }

  }


  /// Handle reconnecting state for local and remote user
  void reconnecting({required List<String> participantId}) {
    for (final id in participantId) {
      debugPrint("[MirrorFly] #CallKitOutGoingController Reconnecting event for id: $id");
      final isLocal = isSelfId(id: id);

      if (isLocal && isLocalUserReconnecting.value) {
        debugPrint("[MirrorFly] #CallKitOutGoingController Local user already reconnecting of id: $id");
        return;
      }

      if (!isLocal && isRemoteUserReconnecting.value) {
        debugPrint("[MirrorFly] #CallKitOutGoingController Remote user already reconnecting of id: $id");
        return;
      }

      if (isLocal) {
        isLocalUserReconnecting.value = true;
        callStatus("Reconnecting...");
      } else {
        isRemoteUserReconnecting.value = true;
      }

      callTryStatus("Reconnecting...");
      break;
    }
  }

  void reconnected({required List<String> participantIds}) {
    debugPrint("[MirrorFly] #CallKitOutGoingController Reconnected event for participantId: $participantIds");

    if (participantIds.isEmpty) {
      debugPrint("[MirrorFly] #CallKitOutGoingController Reconnected event with empty participantId");
      return;
    }

    for (final id in participantIds) {
      debugPrint("[MirrorFly] #CallKitOutGoingController Reconnected event for id: $id");
      final isLocal = isSelfId(id: id);

      if (isLocal && isLocalUserReconnecting.value) {
        debugPrint("[MirrorFly] #CallKitOutGoingController Local user reconnected of id: $id");
        isLocalUserReconnecting.value = false;
        callStatus("Connected");
      } else {
        debugPrint("[MirrorFly] #CallKitOutGoingController Local user is not in reconnecting state");
      }

      if (!isLocal && isRemoteUserReconnecting.value) {
        debugPrint("[MirrorFly] #CallKitOutGoingController Remote user reconnected of id: $id");
        isRemoteUserReconnecting.value = false;
      }else {
        debugPrint("[MirrorFly] #CallKitOutGoingController Remote user is not in reconnecting state");
      }
    }
  }

  void isAudioMute({required bool isAudioMuted,required String? participantId}) {
    if(isSelfId(id: participantId)){
      muted.value = isAudioMuted;
    }else{
      isRemoteAudioMuted.value = isAudioMuted;
    }

    debugPrint("[Controller] Updated => audioMuted=${isRemoteAudioMuted.value}");
  }

  void isVideoMute({required bool isVideoMuted,required String? participantId}) {
    if(isSelfId(id: participantId)){
      isVideoEnabled.value = isVideoMuted;
    }else{
      isRemoteVideoMuted.value = isVideoMuted;
    }
    debugPrint("[Controller] Updated =>  videoMuted=${isRemoteVideoMuted.value}");
  }

  void audioCallAfterCallSwitch(){
    debugPrint("audioCallAfterCallSwitch change the call type into audio call");
    callType.value = "audio";
  }

   bool isSelfId({required String? id}) {
    final String? currentUserId = SessionManagement.getUserJID();
    if (currentUserId == null) {
      debugPrint("[MirrorFly][OutgoingCallController] isSelfId: is null id=$id");
      return true;
    } else {
      //
      final String participantId = "$id@xmpp-uikit-qa.contus.us";
      debugPrint("[MirrorFly][OutgoingCallController] isSelfId $currentUserId $participantId");
      debugPrint("[MirrorFly][OutgoingCallController] isSelfId: ${currentUserId == participantId}");
      return currentUserId == participantId;
    }
  }

  ///
  void _updateCallDuration({required String duration}) {
    callDuration(duration);
  }

  ///
  void callTimeOut({required List<String> participantsId}) async {
    if (!isGroupOnGoingCallEnabled.value) return;

    participantsId = participantsId
        .map((id) => id.split('@').first.trim())
        .toList();

    debugPrint("[MirrorFly][OutgoingCallController] Call Timeout, group call is ongoing");
    debugPrint("[MirrorFly][OutgoingCallController] Call Timeout, current call participant list: ${callerList.map((e) => e.identity).toList()}");

    if (participantsId.isEmpty) {
      debugPrint("[MirrorFly][OutgoingCallController] Call Timeout, no participantsId found");
      return;
    }

    for (final p in participantsId) {
      debugPrint("[MirrorFly][OutgoingCallController] Call Timeout, checking participantId: $p");

      final target = callerList.firstWhereOrNull((participant) => participant.identity == p);

      if (target != null) {
        debugPrint("[MirrorFly][OutgoingCallController] Call Timeout, removing participantId: ${target.identity}");
        callerList.remove(target);

        final fullJid = "$p@xmpp-uikit-qa.contus.us";
        final profile = await getProfileDetails(validId(userId: fullJid, isGroup: false));
        final username = profile.name ?? profile.nickName ?? "Unknown";
        toToast("Call timed out for $username");
        checkParticipantForCallMode();
      } else {
        debugPrint("[MirrorFly][OutgoingCallController] Call Timeout, participantId: $p not found in callerList");
      }
    }
  }

  void checkParticipantForCallMode() async {
    debugPrint("[MirrorFly][OutgoingCallController] checkParticipantForCallMode called");
    final List<FlyCallParticipant> participants = await getCurrentCallParticipants();
    if (participants.isEmpty) {
      debugPrint(
          "[MirrorFly][OutgoingCallController] checkParticipantForCallMode: No participants found");
      return;
    }
    if (participants.length <= 2 &&
        isGroupCall.value &&
        isGroupOnGoingCallEnabled.value) {
      debugPrint(
          "[MirrorFly][OutgoingCallController] checkParticipantForCallMode: Switching to one-to-one call mode");
      isCallModeChangedToOneToMany.value = false;
      callMode.value = "TO-ONE-TO-ONE";
      isGroupCall.value = false;
      isGroupOnGoingCallEnabled.value = false;
      titleAfterCallModeChange.value = '';
    } else {
      debugPrint(
          "[MirrorFly][OutgoingCallController] checkParticipantForCallMode: No call mode change needed");
    }
  }

  void rejected({required String userId}) {
    debugPrint("[MirrorFly][OutgoingCallController] Call rejected by userId: $userId");

    if (isGroupCall.value && isGroupOnGoingCallEnabled.value) {
      debugPrint(
          "[MirrorFly][OutgoingCallController] Call rejected, but group call is ongoing, "
              "current remote participant name map: ${remoteUserNameMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}");
      final String name = remoteUserNameMap[userId] ?? "Unknown";
      toToast("$name is busy");
      return;
    }

    debugPrint("[MirrorFly][OutgoingCallController] Call rejected, ending call");
    toToast("User Busy");
    NavUtils.back();
  }

  void connecting() {
    callStatus("Connecting...");
    debugPrint("[MirrorFly] connecting.. called");
  }

  void outGoingCallCalling() {
    debugPrint("[MirrorFly][OutgoingCallController] outgoing calling");
    callStatus("Calling...");
  }

  void onConnected(List<String> participantIds) {
    if (!isGroupCall.value) {
      debugPrint("[MirrorFly][OutgoingCallController] onConnected for one to one call");
      callStatus("Connected");
      isOnGoingCallView();

      for (var p in participantIds) {
        if (!isSelfId(id: p)) {
          callerList
              .firstWhereOrNull((e) => e.identity == p)
              ?.flyCallStatusEvent = FlyCallStatusEvent.connected;
          callerList.refresh();
          if (timer == null || !(timer?.isActive ?? false)) {
            _startTimer();
          } else {
            debugPrint(
                "[MirrorFly][OutgoingCallController] Timer is already running");
          }
        } else {
          debugPrint(
              "[MirrorFly][OutgoingCallController] onConnected: Skipping self id: $p");
        }
      }
    } else {
      debugPrint("[MirrorFly][OutgoingCallController] onConnected for group call");
      callStatus("Connected");
      isOnGoingCallView();
      updateUserId();

      for(var p in participantIds) {
        debugPrint(
            "[MirrorFly][OutgoingCallController] onConnected updating participantId: $p");

        callerList
            .firstWhereOrNull((e) => e.identity == p)
            ?.flyCallStatusEvent = FlyCallStatusEvent.connected;
        callerList.refresh();
      }

      if (timer == null || !(timer?.isActive ?? false)) {
        _startTimer();
      } else {
        debugPrint(
            "[MirrorFly][OutgoingCallController] Timer is already running");
      }

      if (!isGroupOnGoingCallEnabled.value) {
        isGroupOnGoingCallEnabled.value = true;
      }

      secondaryCallViewUserId.value =
          SessionManagement.getUserJID().checkNull();
      mainCallViewUserId.value = callerUsersId[0] ?? "";
    }
  }

  void disconnectCall({required String reason}) {
    debugPrint("[MirrorFly][OutgoingCallController] disconnectCall invoked with reason: $reason");
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
    debugPrint("[MirrorFly][OutgoingCallController] muteAudio start");

    MirrorFlyCallKit.toggleMicrophone(result: (result) async {
      debugPrint("[MirrorFly][OutgoingCallController] muteAudio toggleMicrophone result : $result");

      if (result) {
        final bool isMicEnabled =
            await MirrorFlyCallKit.getIsMicrophoneEnabled();
        debugPrint(
            "[MirrorFly][OutgoingCallController] muteAudio failure toggleMicrophone isMicEnabled : $isMicEnabled");
      } else {
        debugPrint(
            "[MirrorFly][OutgoingCallController] muteAudio failure toggleMicrophone result : $result");
      }
    });
  }

  void setCameraEnable({required bool enable}) async {
    debugPrint("[MirrorFly][OutgoingCallController] setCameraEnable start");
    final FlyCallType? flyCallType =
        await MirrorFlyCallKit.getCurrentCallType();

    if (flyCallType == null) {
      debugPrint("[MirrorFly][OutgoingCallController] setCameraEnable: Unable to get current call type.");
      return;
    }

    final bool callStatus = MirrorFlyCallKit.isCallConnected();

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

    debugPrint("[MirrorFly][OutgoingCallController] setCameraEnable: value : $enable");

    MirrorFlyCallKit.setCameraEnable(
        enable: enable,
        result: (result) async {
          if (result) {
            debugPrint("[MirrorFly][OutgoingCallController] setCameraEnable : $result");
            isVideoEnabled.value = enable;
          } else {
            debugPrint(
                "[MirrorFly][OutgoingCallController]  Error setCameraEnable status  result : $result");
          }
        });
  }



  void onCallSwitchRemoteUserDeclined() {
    debugPrint("[MirrorFly][OutgoingCallController] onCallSwitchRemoteUserDeclined");
    toToast("Video call switch declined");
    closeDialog();
  }

  ///
  void onRemoteUserCancelledTheSwitchRequest() {
    debugPrint("[MirrorFly][OutgoingCallController] onRemoteUserCancelledTheSwitchRequest");
    toToast("Video call switch canceled");
    closeDialog();
  }

  void remoteUserIsEngaged() async {
    debugPrint("[MirrorFly][OutgoingCallController] remoteUserIsEngaged");

    List<FlyCallParticipant>? participantsList =
    await MirrorFlyCallKit.getCurrentCallParticipants();
    debugPrint("isGroupOnGoingCallEnabled: ${isGroupOnGoingCallEnabled.value}, participantsList: ${participantsList?.map((p) => '${p.identity}: ${p.flyCallStatusEvent}').toList()}");

    if (isGroupCall.value || isGroupOnGoingCallEnabled.value) {
      // Check if all remote participants are engaged
      bool allEngaged = participantsList
          !.where((p) => !p.isLocalParticipant)
          .every((p) => p.flyCallStatusEvent == FlyCallStatusEvent.engaged);

      if (allEngaged) {
        debugPrint("[MirrorFly][OutgoingCallController] All remote users are engaged → navigating back");
        toToast("All users are engaged");
        await Future.delayed(const Duration(milliseconds: 500));
        if (NavUtils.canPop) {
          NavUtils.back();
        }
        return;
      } else {
        debugPrint("[MirrorFly][OutgoingCallController] Not all users are engaged");
        toToast("${remoteUserNameMap.value} is engaged");
        return;
      }
    }
    if(!isGroupCall.value && !isGroupOnGoingCallEnabled.value){
      debugPrint("[MirrorFly][OutgoingCallController] Group call is ongoing, skipping single user engaged logic");
      // Single call logic (non-group)
      toToast("${remoteUserNameMap.value} is engaged");
      await Future.delayed(const Duration(milliseconds: 500));
      if (NavUtils.canPop) {
        NavUtils.back();
      }
      return;
    }


  }


  void switchCamera() async {
    debugPrint("[MirrorFly][OutgoingCallController] switchCamera start");

    MirrorFlyCallKit.switchCameraPosition(result: (result) async {
      debugPrint("[MirrorFly][OutgoingCallController] switchCameraPosition result : $result");

      // After switching, get the updated position
      var pos = await MirrorFlyCallKit.getCurrentCameraPosition();
      if (pos == CameraType.front) {
        cameraPosition.value = pos;
      } else if (pos == CameraType.back) {
        cameraPosition.value = pos;
      }
      debugPrint("[MirrorFly][OutgoingCallController] updated pos : $pos");

      // Update state
    });
  }

  Future<void> initAudioRouting() async {
    debugPrint("[MirrorFly][OutgoingCallController] Initializing audio routing...");

    if (callType.value == "audio") {
      debugPrint("[MirrorFly][OutgoingCallController] Call type is audio, setting to earpiece.");
      selectedDevice.value = false;
    } else if (callType.value == "video") {
      debugPrint("[MirrorFly][OutgoingCallController] Call type is video, setting to speaker.");
      selectedDevice.value = true;
    } else {
      debugPrint("[MirrorFly][OutgoingCallController] Unknown call type, defaulting to earpiece.");
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

    debugPrint("[MirrorFly][OutgoingCallController] Attempting switch to: $targetDevice");

    final result = await MirrorFlyCallKit.changeAudioOutputDevice(
      flyMediaDevice: const FlyMediaDevice("", "", "", ""),
      device: targetDevice,
    );

    if (result) {
      // update state only after success
      selectedDevice.value = !selectedDevice.value;
      debugPrint("[MirrorFly][OutgoingCallController] Switched to: $targetDevice");
    } else {
      debugPrint("[MirrorFly][OutgoingCallController] Failed to switch to: $targetDevice");
    }
  }

  Future<void> changeAudioDevice() async {
    debugPrint("[MirrorFly][OutgoingCallController] changeAudioDevice -> ");
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
    debugPrint("[MirrorFly][OutgoingCallController]  disconnectCall invoked...");
    _stopTimer();
    try {
      var result = await MirrorFlyCallKit.localHangup();
      debugPrint("[MirrorFly][OutgoingCallController] localHangup() result: $result");

      if (result == true) {
        debugPrint(
            "[MirrorFly][OutgoingCallController]  Call disconnected successfully. Navigating back...");
        NavUtils.back();
      } else {
        NavUtils.back();
        debugPrint(
            "[MirrorFly][OutgoingCallController]  Call disconnect failed. Retrying or handling failure...");
      }
    } catch (e, stack) {
      debugPrint("[MirrorFly][OutgoingCallController]  Exception in disconnectCall: $e");
      print(stack);
    }
  }

  ///
  void onTracksPublished(
      {required bool isSelf, required String participantId}) {
    if (isSelf) {
      if (!isLocalTracksPublished.value) {
        debugPrint(
            "[MirrorFly][OutgoingCallController] [MirrorFlyCall] Local tracks published for $participantId");
        isLocalTracksPublished(true);
        localParticipantId(participantId);
      } else {
        debugPrint(
            "[MirrorFly][OutgoingCallController] [MirrorFlyCall] Ignoring duplicate local publish for $participantId");
      }
    } else {
      if (!isRemoteTracksPublished.value) {
        debugPrint(
            "[MirrorFly][OutgoingCallController] [MirrorFlyCall] Remote tracks published for $participantId");
        isRemoteTracksPublished(true);
        remoteParticipantId(participantId);
      } else {
        debugPrint(
            "[MirrorFly][OutgoingCallController] [MirrorFlyCall] Ignoring duplicate remote publish for $participantId");
      }
    }
  }

  void updateUserId() {
    debugPrint(
        "[MirrorFly][OutgoingCallController] [MirrorFlyCall] updateUserId called with isIncoming: $isIncoming, callerUsersId: $callerUsersId");
    if (isIncoming.value) {
      mainCallViewUserId(callerUsersId.first);
      if (callerUsersId.length > 1) {
        secondaryCallViewUserId(callerUsersId.last);
      }
    } else {
      final localParticipant =
      callerList.firstWhereOrNull((p) => p.isLocalParticipant == true);
      final remoteParticipant =
      callerList.firstWhereOrNull((p) => p.isLocalParticipant == false);
      if(localParticipant != null && remoteParticipant != null){
        mainCallViewUserId.value = remoteParticipant.identity;
        secondaryCallViewUserId.value = localParticipant.identity;
        debugPrint("[MirrorFly][OutgoingCallController] [MirrorFlyCall] mainCallViewUserId: $mainCallViewUserId, secondaryCallViewUserId: $secondaryCallViewUserId");
      }else{
        mainCallViewUserId(callerUsersId.first);
        secondaryCallViewUserId(SessionManagement.getUserJID());
      }
    }
    debugPrint(
        "[MirrorFly][OutgoingCallController] [MirrorFlyCall] mainCallViewUserId: $mainCallViewUserId, secondaryCallViewUserId: $secondaryCallViewUserId");
  }

  ///
  void requestVideoCallSwitch() async {

    final bool callStatus = MirrorFlyCallKit.isCallConnected();
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
    debugPrint("[MirrorFly][OutgoingCallController]  cancelVideoCallSwitch invoked...");
    await MirrorFlyCallKit.cancelVideoCallSwitchRequest();
    toToast("Video call switch canceled");
    closeDialog();
    // _cancelCallSwitchReqWaiting();
  }

  ///
  void acceptIncomingCallSwitchRequest() async {
    debugPrint("[MirrorFly][OutgoingCallController]  acceptIncomingCallSwitchRequest invoked...");
    closeDialog();
    await MirrorFlyCallKit.acceptIncomingVideoCallSwitchRequest();
  }

  ///
  void declineIncomingCallSwitchRequest() async {
    debugPrint("[MirrorFly][OutgoingCallController]  declineIncomingCallSwitchRequest invoked...");
    await MirrorFlyCallKit.declineIncomingVideoCallSwitchRequest();
    closeDialog();
  }

  ///

  void onVideoCallSwitchAccept() {
    closeDialog();
    onVideoCallSwitchRequestAccepted();
    processCallSwitchUI();
  }

  void onVideoCallSwitchTimeOut() {
    closeDialog();
    toToast(getTranslated("noResponseFrom")
        .replaceFirst("%d", remoteUserName.value));
  }

  ///
  void processCallSwitchUI() async {
    debugPrint("[MirrorFly][OutgoingCallController] Processing call switch UI changes...");
    final FlyCallType? flyCallType =
        await MirrorFlyCallKit.getCurrentCallType();
    if (flyCallType == null && flyCallType == FlyCallType.none) {
      debugPrint("[MirrorFly][OutgoingCallController] Unable to get current call type after switch.");
      return;
    }
    flyCallType == FlyCallType.audio ? callType("audio") : callType("video");
  }

  ///
  void onVideoCallSwitchRequestAccepted() {
    debugPrint("[MirrorFly][OutgoingCallController] Video call switch request accepted.");
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
  void showIncomingCallSwitchRequestDialog() {
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("videoSwitchRequestedMessage")
            .replaceFirst("%d", remoteUserName.value),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: declineIncomingCallSwitchRequest,
              child: Text(
                getTranslated("declineRequest").toUpperCase(),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: acceptIncomingCallSwitchRequest,
              child: Text(
                getTranslated("acceptRequest"),
              ))
        ],
        barrierDismissible: false);
  }

  ///
  void showOutGoingCallSwitchRequestDialog() {
    //
    // _isWaitingCanceled = false;
    // _outgoingSwitchTimer?.cancel();

    //
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
  void closeDialog() {
    debugPrint("[MirrorFly][OutgoingCallController] _closeDialog called");
    if (DialogUtils.isDialogOpen() && NavUtils.canPop) {
      NavUtils.back();
    }
  }

  ///
  void onCallFailed() {
    debugPrint("[MirrorFly][OutgoingCallController] onCallFailed called");
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
    debugPrint(
        "[MirrorFly][OutgoingCallController] inviteParticipants called with callMode: $callMode");
    final List<String> pickedContacts =
    await gotoContacts(isGroupInvite: callMode != "oneToOne");
    if (pickedContacts.length > 5) {
      // Temp limit to 5 participants
      toToast("You can invite up to 5 participants only");
      return;
    } else {

      MirrorFlyCallKit.inviteParticipants(inviteUserList: pickedContacts, flyResult: (res) {
        debugPrint("[MirrorFly][OutgoingCallController] inviteParticipants result: $res");
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
      debugPrint(
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
        debugPrint(
            "[MirrorFly][OutgoingCallController] gotoContacts contact sync enabled $result");
        return result;
      } else {
        debugPrint(
            "[MirrorFly][OutgoingCallController] gotoContacts permission denied");
        return [];
      }
    }
  }


  ///
  ///
  ///
  void onCallModeChanged(FlyCallModeChanged? callMode) async {
    debugPrint(
        "[MirrorFly][OutgoingCallController] onCallModeChanged called with callMode: ${callMode?.mode.toString()}");
    if (callMode == null) {
      debugPrint(
          "[MirrorFly][OutgoingCallController] onCallModeChanged: callMode is null");
      return;
    }

    final Map<String, dynamic> mode = callMode.toJson();
    debugPrint(
        "[MirrorFly][OutgoingCallController] onCallModeChanged mode: $mode");

    final String modeRaw = mode['mode'] ?? '';
    final bool isOneToOne = (mode['mode'] ?? '') == "ONE-TO-ONE";

    debugPrint(
        "[MirrorFly][OutgoingCallController] onCallModeChanged modeRaw: $modeRaw, isOneToOne: $isOneToOne");
    await configureCallMode(callMode: modeRaw, chatId: groupId.value);

    debugPrint(
        "[MirrorFly][OutgoingCallController] onCallModeChanged updated "
            "local callMode: ${this.callMode.value}, isGroupCall: ${isGroupCall.value} "
            "isGroupOnGoingCallEnabled: ${isGroupOnGoingCallEnabled.value}");

    isGroupOnGoingCallEnabled(!isOneToOne);
    isCallModeChangedToOneToMany(!isOneToOne);

    debugPrint(
        "[MirrorFly][OutgoingCallController] onCallModeChanged completed, fetching current call"
            " participants..., with isGroupOnGoingCallEnabled: ${isGroupOnGoingCallEnabled.value}, "
            "isCallModeChangedToOneToMany: ${isCallModeChangedToOneToMany.value}");
    await getCurrentCallParticipants();
    await getRemoteAndLocalUserNameForGroupCall();
    getCallTitleForOneToManyCall();
  }

  ///
  /// To update the call status of a participant in the callerList
  ///
  Future<void> updateCurrentCallParticipant({required String id, required FlyCallStatusEvent status}) async {
    final participant = callerList.firstWhereOrNull((p) => p.identity == id);
    if (participant != null) {
      participant.flyCallStatusEvent = status;
      callerList.refresh();
      debugPrint("[MirrorFly][OutgoingCallController] updateCurrentCallParticipant: Updated participant $id to status $status");
    } else {
      debugPrint("[MirrorFly][OutgoingCallController] updateCurrentCallParticipant: Participant $id not found in callerList");
    }
  }

  ///
  void _resetValues() {
    callType("");
    muted(false);
    isVideoEnabled(false);
    speakerOn(false);
    isOnGoingCallViewEnable(false);
    callerUsersId(<String?>[]);
    cameraSwitch(false);
    isIncoming(false);
    cameraPosition(CameraType.front);
    isRemoteAudioMuted(false);
    isRemoteVideoMuted(false);
    localUserName("");
    isLocalTracksPublished(false);
    isRemoteTracksPublished(false);
    localParticipantId("");
    remoteParticipantId("");
    mainCallViewUserId("");
    secondaryCallViewUserId("");
    isManualDeviceSelected(false);
    callTryStatus("");
    groupId("");
    callerList.clear();

    remoteUserNameMap({});
    remoteUserName("");
    localUserName("");
    isGroupCall(false);
    chatNameForGroupCall("");
    isGroupOnGoingCallEnabled(false);
    groupCallTitle("");
    isCallModeChangedToOneToMany(false);
    titleAfterCallModeChange("");

    debugPrint("[MirrorFly][OutgoingCallController] _resetValues");
  }
}