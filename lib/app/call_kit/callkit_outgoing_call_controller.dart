import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:flutter_in_app_pip/pip_params.dart';
import 'package:flutter_in_app_pip/pip_view_corner.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
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

import 'callkit_event_buffer.dart';
import 'callkit_logger.dart';
import 'callkit_pip/callkit_pip_View.dart';

class CallKitOutgoingCallController extends GetxController
    with GetTickerProviderStateMixin {

  /// Observables
  var callStatus = "Trying to connect".obs;
  var callDuration = "".obs;
  var callTryStatus = "".obs;

  RxString callType = "".obs; // "audio" or "video"
  RxString groupId = "".obs;
  RxString callMode = "".obs;
  RxString currentCallMode = "".obs;

  RxBool showControls = true.obs;
  RxBool isVideoEnabled = false.obs;
  RxBool isAudioMuted = false.obs;
  RxBool speakerOn = false.obs;
  RxBool isOnGoingCallViewEnable = false.obs;

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
  RxMap<String, FlyConnectionQuality?> callerConnectionQuality = <String, FlyConnectionQuality?>{}.obs;

  ///
  final RxBool isLocalTracksPublished = false.obs;
  final RxBool isRemoteTracksPublished = false.obs;
  Timer? timer;
  AudioPlayer? _player;
  bool _isPlaying = false;

  ///
  var callAgainUserList = <String>[].obs;

  ///
  RxString mainCallViewUserId = "".obs;
  RxString secondaryCallViewUserId = "".obs;

  final String audioRoutingTag = "[AUDIO_ROUTING]";
  // RxString selectedAudioDeviceId = "".obs;
  // final selectedAudioDevice = Rxn<FlyAudioDevice>();

  RxString selectedDeviceType = "".obs;

  final int _maxCallInvitedParticipant = Constants.maxCallUsersLimitForMirrorFlyCallKit;

  FlyCallKind callKind = FlyCallKind.standard;

  final RxBool isAudioDialogOpen = false.obs;
  var availableTypes = <FlyAudioDevice>[].obs;
  RxString getOneToOneCallRemoteUserName = "".obs;

  RxBool isMeet = false.obs;


  @override
  Future<void> onInit() async {
    CallKitEventBuffer.flushTo(this);
    callKind = await MirrorFlyCallKit.getCallKind();
    await _handleInitialCallStatus();
    await getCurrentCallParticipants();
    await initCallViewIds();
    initPlayer();

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
    onParticipantListUpdated();
    callkitLogger.info("[MirrorFly][OutgoingCallController] callview");

    if (isIncoming.value) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] onConnected: Initial audio route set for incoming call");
      await setInitialAudioRouteDevice();
    }

    // await _getOneToOneCallRemoteUserName();
    _listenToSDKCallTimer();
    super.onInit();
  }

  void _listenToSDKCallTimer() {
    MirrorFlyCallKit.flyCallTimer.listen((timer) {
      callDuration(timer);
    });
  }

  Future<void> _initCallArguments() async {
    try {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Initializing call arguments from NavUtils");
      callType(NavUtils.arguments?["callType"]);
      groupId(NavUtils.arguments?["chatId"] as String? ?? "");
      callMode(NavUtils.arguments?["callMode"] as String? ?? "");
      isIncoming.value = NavUtils.arguments?["isIncoming"] as bool? ?? false;
      currentCallMode(MirrorFlyCallKit.getCurrentCallMode());
      if(currentCallMode.value == "MEET"){
        isMeet.value = true;
        if (callerList.length >= 2) {
          callkitLogger.info("[MirrorFly][OutgoingCallController] join via meet link local and remote participant present");
          isOnGoingCallView();
        } else {
          callkitLogger.info("[MirrorFly][OutgoingCallController] join via meet link local participant only present ");
          callStatus("");
          // _startTimer();
        }
        bool isAudioMute = MirrorFlyCallKit.getAudioMuteStatus(userJid: CallUtils.getIdFromJidList(SessionManagement.getUserJID() ?? ""));
        bool isVideoMuted = MirrorFlyCallKit.getVideoMuteStatus(userJid: CallUtils.getIdFromJidList(SessionManagement.getUserJID() ?? ""));
        callkitLogger.info("[MirrorFly][OutgoingCallController] Current call mode is MEET, enabling ongoing call view and fetching video mute status $isVideoMuted and audio mute status $isAudioMute");
        if(!isVideoMuted){
          isVideoEnabled.value = true;
        } else {
          isVideoEnabled.value = false;
        }
        if (isAudioMute){
          isAudioMuted.value = true;
        } else {
          isAudioMuted.value = false;
        }
      }

      callkitLogger.info(
        "[MirrorFly][OutgoingCallController] "
            "isIncoming: groupId $groupId incoming $isIncoming callType $callType  callMode $callMode isMeet $isMeet",
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
    // callDuration("Connecting..");
    // isOnGoingCallView();
    callkitLogger.info("[MirrorFly][IncomingCall] Incoming call view setup completed");
  }

  Future<void> initCallViewIds() async{
    final localId = getLocalParticipant()?.identity ?? "";
    final remoteId = getRemoteParticipants().firstOrNull?.identity ?? "";

    mainCallViewUserId.value = remoteId;     // show remote as main view
    secondaryCallViewUserId.value = localId; // local goes to small preview
  }


  @override
  void onReady() async {
    // if (isGroupCall.value || isGroupOnGoingCallEnabled.value) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] onReady getRemoteAndLocalUserNameForGroupCall, isGroupCall :${isGroupCall.value}");

      if (groupId.value.isNotEmpty) {
        callkitLogger.info("[MirrorFly][OutgoingCallController] onReady groupId is not empty, calling getChatNameForGroupCall");
        await getChatNameForGroupCall(chatId: groupId.value);
      } else {
        await getCallMembersName();
        callkitLogger.info("[MirrorFly][OutgoingCallController] onReady groupId is empty, skipping getChatNameForGroupCall");
      }

    // } else {
    //   callkitLogger.info("[MirrorFly][OutgoingCallController] onReady getRemoteAndLocalUserNameForOneToOneCall");
    //   await getRemoteAndLocalUserNameForOneToOneCall();
    // }

    // getLogsOfLocalValues();

      if(currentCallMode.value != "MEET"){
        callType.value == "audio" ? isVideoEnabled.value = false : isVideoEnabled.value = true;
      }

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
            " participants: ${participants?.map((p) => p.identity).toList()} isAudioMuted: ${participants?.map((p) => p.isAudioMuted).toList()}",);

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

      for (var flyCallParticipant in participants) {
        if (!existingIds.contains(flyCallParticipant.identity)) {
          callerList.add(flyCallParticipant);
          callkitLogger.info(
            "[MirrorFly][OutgoingCallController] ➕ Added new participant: ${flyCallParticipant
                .identity}",
          );
        } else {
          final index = callerList.indexWhere((p) => p.identity == flyCallParticipant.identity);
          final updated = callerList[index].copyWith(isAudioMuted: flyCallParticipant.isAudioMuted);
          callerList.value = List.from(callerList)..[index] = updated;
          callkitLogger.info(
            "[MirrorFly][OutgoingCallController]️ Skipped duplicate participant: ${flyCallParticipant
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
    await getCallMembersName();

    // Validate for group call
    final bool yes = callMode == "TO-ONE-TO-MANY" || callMode == "ONE-TO-MANY";
    isGroupCall.value = yes;
    if (yes) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #configureCallMode isGroupCall: true");

      if (chatId.isEmpty && callMode == "ONE-TO-MANY") {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] #configureCallMode with chatId for group call: $chatId");
        getCallMembersName();
        isCallModeChangedToOneToMany(true);
      }
      getCallTitleForOneToManyCall();
    } else if(callerList.length > 2 && isIncoming.value){
      callkitLogger.info("[MirrorFly][OutgoingCallController] callerList.length value  ${callerList.length} isIncoming.value ${isIncoming.value}");
      isGroupCall.value = true;
      isCallModeChangedToOneToMany(true);
      getCallTitleForOneToManyCall();
    }
    callkitLogger.info("[MirrorFly][OutgoingCallController] callerList.length ${callerList.length}");

    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] #configureCallMode isGroupCall: ${isGroupCall
            .value}");
  }

  Future<void> getCallMembersName() async {
    // if (!isGroupCall.value) {
    //   callkitLogger.info(
    //       "[MirrorFly][OutgoingCallController] #getRemoteAndLocalUserNameForGroupCall Not a group call");
    //   return;
    // }

    if(callKind == FlyCallKind.sip){
      callkitLogger.info("[MirrorFly][OutgoingCallController] #getRemoteAndLocalUserNameForOneToOneCall SIP call - using identity as name");
      for(var user in callerList){
          remoteUserNameMap[user.identity] =
          user.isLocalParticipant ? "You" : user.identity;
          callkitLogger.info("[MirrorFly][OutgoingCallController] #getRemoteAndLocalUserNameForGroupCall Remote User Name for sip call ${user.identity}: ${remoteUserNameMap[user.identity]}");
      }
      return;
    }

    for (var user in callerList) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #getRemoteAndLocalUserNameForGroupCall Getting user name for: ${user.identity}, isLocal: ${user.isLocalParticipant}");
      ProfileDetails profile = await getProfileDetails(
          validId(userId: user.identity, isGroup: false),
          isFromCallKit: true);
      String username = (profile.name?.trim().isNotEmpty == true)
          ? profile.name!.trim()
          : (profile.nickName?.trim().isNotEmpty == true)
              ? profile.nickName!.trim()
              : trimAfterAt(profile.jid ?? "");
      remoteUserNameMap[user.identity] =
          user.isLocalParticipant ? "You" : username;
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #getRemoteAndLocalUserNameForGroupCall Remote User Name for ${user.identity}: $username");
    }
    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] #getRemoteAndLocalUserNameForGroupCall Completed fetching user names for group call, "
            "remoteUserNameMap: ${remoteUserNameMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}");
    return;
  }

  ///
  /// Get remote user name for one-to-one call (remote participant)
  ///
  Future<void> _getCallRemoteUserName() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] #_getOneToOneCallRemoteUserName called for groupId: ${groupId.value}");

    List<String> participantId = [];
    var showLocalUserName = false;
    final bool showRemoteUserNameOnlyOnOutGoingCall = !isOnGoingCallViewEnable.value; //show only remote user name
    final bool onGoingCallEnabledAddLocalUser = isOnGoingCallViewEnable.value; // add local user name to name list
    final bool localUserAloneConnectedInMeetCall = callMode.value == "MEET" && callerList.length == 1;
    final bool isGroupComesOneToOneCall = groupId.value != "" && callerList.length == 2;

    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] #_getCallRemoteUserName, "
            "showRemoteUserNameOnlyOnOutGoingCall: $showRemoteUserNameOnlyOnOutGoingCall"
            "onGoingCallEnabledAddLocalUser: $onGoingCallEnabledAddLocalUser"
            "localUserAloneConnectedInMeetCall: $localUserAloneConnectedInMeetCall"
            "isGroupComesOneToOneCall: $isGroupComesOneToOneCall "
            "participantId: ${participantId.map((e) => e)}");

    try {
      final List<FlyCallParticipant> remoteParticipants = List.from(callerList);
      if (localUserAloneConnectedInMeetCall) {
        callkitLogger.info("localUserAloneConnectedInMeetCall block");
        participantId = remoteParticipants.map((e) => e.identity).toList();
        showLocalUserName = true;
      } else if (showRemoteUserNameOnlyOnOutGoingCall) {
        callkitLogger.info("showRemoteUserNameOnlyOnOutGoingCall block");
        if (!isMeet.value) {
          remoteParticipants.removeWhere((e) => e.isLocalParticipant);
        }
        participantId = remoteParticipants.map((e) => e.identity).toList();
      } else if (onGoingCallEnabledAddLocalUser) {
        callkitLogger.info("onGoingCallEnabledAddLocalUser block");
        if(callerList.length != 2) {
          callkitLogger.info("onGoingCallEnabledAddLocalUser block not to remove local participant");
          participantId = remoteParticipants.map((e) => e.identity).toList();
        } else {
          callkitLogger.info("onGoingCallEnabledAddLocalUser block to remove local participant");
          remoteParticipants.removeWhere((e) => e.isLocalParticipant);
          participantId = remoteParticipants.map((e) => e.identity).toList();
        }
      } else {
        callkitLogger.info("ERROR ====>> #_getOneToOneCallRemoteUserName else block");
      }

      await MirrorFlyCallKit.getCallMembersDisplayNames(
          chatId: isGroupComesOneToOneCall ? "" : groupId.value,
          participantId: participantId,
          showLocalUserName: showLocalUserName).then((value) {
        callkitLogger.info("[MirrorFly][OutgoingCallController] #_getOneToOneCallRemoteUserName fetched display names: $value");
        getOneToOneCallRemoteUserName.value = value;
      });
    } catch (e) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Remote User name error: $e");
      getOneToOneCallRemoteUserName.value = "MF Call";
    }
  }

  String validId({required String userId,required bool isGroup}) {
    if(isGroup){
      callkitLogger.info("[MirrorFly][OutgoingCallController] validId for group called with userId: $userId isGroup: $isGroup, containing @: ${userId.contains("@")}");
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
    // if (isGroupCall.value && chatId.isNotEmpty) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #getChatNameForGroupCall with chatId: ${groupId.value}");
      ProfileDetails profile = await getProfileDetails(validId(userId: chatId,isGroup: true), isFromCallKit: true);
      String chatName =
      (profile.name?.trim().isNotEmpty == true)
          ? profile.name!.trim()
          : (profile.nickName?.trim().isNotEmpty == true)
          ? profile.nickName!.trim()
          : trimAfterAt(profile.jid ?? "");
      chatNameForGroupCall.value = chatName;
    // } else {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] #getChatNameForGroupCall Chat name for groupId: ${groupId.value} is ${chatNameForGroupCall.value}");
    // } else {
    //   callkitLogger.info(
    //       "[MirrorFly][OutgoingCallController] #getChatNameForGroupCall Not a group call chatId: ${groupId.value}");
    // }
  }

  ///
  /// Get call title for the one-to-many call.
  ///
  String getCallTitleForOneToManyCall()  {
    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] #getCallTitleForOneToManyCall called");

    if (!isGroupCall.value) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Not a group call");
      return "";
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
      return "";
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
    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] #getCallTitleForOneToManyCall -> $title");

   titleAfterCallModeChange.value = title;
   return title;


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
  String getParticipantConnectionState(FlyCallStatusEvent? status) {
    callkitLogger.info("[MirrorFly][OutgoingCallController] getParticipantConnectionState called with status: $status");
    switch (status) {
      case FlyCallStatusEvent.connecting:
        return "Connecting";
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
      case FlyCallStatusEvent.reconnecting:
        return "Reconnecting";
      default:
        return "";
    }
  }

  ///
  /// Get logs for values
  ///
  void getLogsOfLocalValues() {
    callkitLogger.info('''
       [Call Logs]
       callStatus: ${callStatus.value}
       callTryStatus: ${callTryStatus.value}
       callType: ${callType.value}
       groupId: ${groupId.value}
       callMode: ${callMode.value}
       showControls: ${showControls.value}
       isVideoEnabled: ${isVideoEnabled.value}
       speakerOn: ${speakerOn.value}
       isOnGoingCallViewEnable: ${isOnGoingCallViewEnable.value}
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
    callkitLogger.info("[MirrorFly][OutgoingCallController] audio player initialize success");
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


  // void _startTimer({int? time}) {
  //   if (timer != null) {
  //     timer?.cancel();
  //   }
  //   timer = null;
  //   const oneSec = Duration(seconds: 1);
  //   var startTime = time != null
  //       ? DateTime.fromMillisecondsSinceEpoch(time)
  //       : DateTime.now();
  //   timer = Timer.periodic(
  //     oneSec,
  //     (Timer timer) {
  //       final hrDur = DateTime.now().difference(startTime).inHours;
  //       final minDur = DateTime.now().difference(startTime).inMinutes;
  //       final secDur = DateTime.now().difference(startTime).inSeconds % 60;
  //       final hours = hrDur.remainder(24).toStringAsFixed(0).padLeft(2, '0');
  //       final minutes = minDur.remainder(60).toStringAsFixed(0).padLeft(2, '0');
  //       final seconds = secDur.remainder(60).toStringAsFixed(0).padLeft(2, '0');
  //       var time = '${hours != "00" ? '$hours:' : ''}$minutes:$seconds';
  //       // print("[MirrorFly][OutgoingCallController] Timer: $time");
  //       _updateCallDuration(duration: time);
  //     },
  //   );
  // }

  // void _stopTimer() {
  //   if (timer == null) {
  //     callkitLogger.info("[MirrorFly][OutgoingCallController] Timer is null");
  //     return;
  //   }
  //   timer?.cancel();
  //   timer = null;
  // }

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
  }) async{
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
      await moveLocalParticipantToLast();
      callerList.refresh();
    }else{
      callkitLogger.info("[MirrorFly][OutgoingCallController] updateCallerStatusList: participantsId is empty");
    }

  }

  Future<void> moveLocalParticipantToLast() async{
    final int index =
    callerList.indexWhere((e) => e.isLocalParticipant == true);

    // Not found → do nothing
    if (index == -1) return;

    final localUser = callerList.removeAt(index);
    callkitLogger.info("[MirrorFly][OutgoingCallController] moveLocalParticipantToLast local value position updated");
    callerList.add(localUser);
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
          callerList[index] = target.copyWith(
              isReconnecting: true,
              flyCallStatus: FlyCallStatusEvent.reconnecting);
          callkitLogger
              .info("[MirrorFly] → Updated participant $id as reconnecting");
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
    callerList.value = List.from(callerList)..[index] = updated;
    // callerList.refresh();

    if (participantId == getLocalParticipant()?.identity) {
      callkitLogger.info("[Controller] isAudioMute: Updating local audio mute status to $isAudioMuted");
      this.isAudioMuted(isAudioMuted);
    } else {
      callkitLogger.info("[Controller] isAudioMute: Received for Remote participantId: $participantId");
    }

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
    // switchCamera();
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

/*  /// Get self id
  String getLocalParticipantId() {
    final String localId = callerList
        .firstWhereOrNull((p) => p.isLocalParticipant)
        ?.identity ?? "";
    callkitLogger.info("[MirrorFly][OutgoingCallController] getLocalParticipantID: $localId");
    return localId;
  }*/

  /// Get Local participant
  FlyCallParticipant? getLocalParticipant() {
    final FlyCallParticipant? localParticipant = callerList
        .firstWhereOrNull((p) => p.isLocalParticipant);
    callkitLogger.info("[MirrorFly][OutgoingCallController] getLocalParticipant: $localParticipant");
    return localParticipant;
  }

  ///
  List<FlyCallParticipant> getRemoteParticipants() {
    callkitLogger.info("[MirrorFly][OutgoingCallController] getRemoteParticipantsId called with callerList length: ${callerList.length}");
    try {
      final List<FlyCallParticipant> remoteParticipants = callerList
          .where((p) => !p.isLocalParticipant)
          .toList();
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] getRemoteParticipantsId: $remoteParticipants");
      return remoteParticipants;
    } catch (e) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] getRemoteParticipantsId error: $e");
      return [];
    }
  }

  ///
  String getRemoteParticipantIdForOneToOneCall() {
    try {
      final String remoteId = callerList
          .where((p) => !p.isLocalParticipant)
          .map((p) => p.identity)
          .firstOrNull ?? "";
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
    // callDuration(duration);
  }

  String trimAfterAt(String input) {
    return input.split('@').firstOrNull?.trim() ?? "";
  }

  ///
  void callTimeOut({required List<String> participantsId, required bool isCallFailed, String reason = ''}) async {

    for (final id in participantsId) {
      if (!callAgainUserList.contains(id)) {
        callAgainUserList.add(id);
      }
    }
    for (var id in participantsId) {
      final target = callerList.firstWhereOrNull((p) => p.identity == id);
      if (target != null) {
        callkitLogger.info("[MirrorFly][OutgoingCallController] Timeout, removing participantId: ${target.identity}");
        callerList.remove(target);
      }
    }

    bool shouldNavigate = false;

    if (!isGroupOnGoingCallEnabled.value && isGroupCall.value) {
      shouldNavigate = callerList.length <= 1;
    } else if (!isGroupCall.value) {
      shouldNavigate = true;
    }else if(callerList.length <= 1){
      shouldNavigate = true;
    }
    callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, shouldNavigate: $shouldNavigate callerList length: ${callerList.length}");

    if (shouldNavigate) {
      if(isAudioDialogOpen.value){
        Get.back();
        isAudioDialogOpen.value = false;
      }
      _navigateToTimeout(isCallFailed: isCallFailed, reason: reason);
       return;
    }


    participantsId = participantsId
        .map((id) => id.split('@').firstOrNull?.trim() ?? "")
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

        final profile = await getProfileDetails(validId(userId: p, isGroup: false), isFromCallKit: true);

        callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout,"
            " fetched profile for $p: name=${profile.name}, nickName=${profile.nickName}, jid=${profile.jid}");

        String rawName =
        (profile.name?.trim().isNotEmpty == true)
            ? profile.name!.trim()
            : (profile.nickName?.trim().isNotEmpty == true)
            ? profile.nickName!.trim()
            : trimAfterAt(profile.jid ?? "");

        callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, rawName for $p: $rawName");

        final username = trimAfterAt(rawName);

        callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, showing toast for $username");

        toToast("Call timed out for $username");
        checkParticipantForCallMode();
        await _getCallRemoteUserName();
      } else {
        checkParticipantForCallMode();
        await _getCallRemoteUserName();
        // callerList.refresh();
        callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, participantId: $p not found in callerList");
      }
    }
  }

  void _navigateToTimeout({required bool isCallFailed, required String reason}) {
    final String message = isCallFailed ? "Call Failed. Reason: $reason" : "Call timed out";
    callkitLogger.info("[MirrorFly][OutgoingCallController] Navigating to timeout view with message: $message");

    toToast(message);

    final String type       = callType.value;
    final String calleeName = isGroupCall.value
        ? chatNameForGroupCall.value
        : getOneToOneCallRemoteUserName();

    final List<dynamic> callUserList = callAgainUserList.toList();
    final String callsMode = callMode.value;
    final String chatId    = groupId.value;

    callkitLogger.info(
      "[MirrorFly][OutgoingCallController] Timeout → navigating to CallKitTimeOutView "
          "type:$type, calleeName:$calleeName, userList:$callUserList, callMode:$callsMode, chatId:$chatId, callKind:$callKind",
    );

    NavUtils.offNamed(Routes.callKitTimeOutView, arguments: {
      "callType": type,
      "userJid": callUserList,
      "calleeName": calleeName,
      "callMode": callsMode,
      "groupId": chatId,
      "callKind": callKind,
    });
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
      callerList.removeWhere((e) => e.identity == userId);
      callerList.refresh();
      if(callerList.length <=1){
        callkitLogger.info("[MirrorFly][OutgoingCallController] Call rejected, switching to one-to-one call mode");
       NavUtils.back();
      }
      await Future.delayed(const Duration(milliseconds: 500));
      toToast("$name is busy");
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

  void onConnected(List<String> participantIds) async {

    if (!isIncoming.value) {
      await setInitialAudioRouteDevice();
      callkitLogger.info("[MirrorFly][OutgoingCallController] onConnected: Initial audio route set for outgoing call");
    }

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
          } else {
            callkitLogger.info("[MirrorFly][OutgoingCallController] onConnected: ParticipantId: $p not found in callerList, adding new entry");
            updateCallerStatusList(participantsId: participantIds,status: FlyCallStatusEvent.connected);
          }

          callerList.refresh();
          if (timer == null || !(timer?.isActive ?? false)) {
            // _startTimer();
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
        // _startTimer();
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
    onParticipantListUpdated();
    await _getCallRemoteUserName();
  }

  ///
  /// Disconnect call
  ///
  void disconnectCall({required List<String> userIds, required String reason}) {

    if (userIds.isEmpty) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: No userIds provided, assuming the overall call ended.");
      _resetValues();
      // _stopTimer();
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

    final String userId = userIds.firstOrNull ?? "";

    callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall invoked with userId: $userId, reason: $reason");

    if (isGroupCall.value && isGroupOnGoingCallEnabled.value) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: Group call is ongoing, applying disconnect logic.");

      callerList.removeWhere((e) => e.identity == userId);
      final String name = remoteUserNameMap[userId] ?? "";
      remoteUserNameMap.remove(userId);
      toToast("$name disconnected");
      callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: Removed userId: $userId from callerList.callerList.length=${callerList.length}");
       _getCallRemoteUserName();

      final bool isLocalHangup = isSelfId(id: userId);
      if (isLocalHangup) {
        callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: Local user hung up, checking remaining participants.");
        if(isAudioDialogOpen.value){
          Get.back();
          isAudioDialogOpen.value = false;
        }
        if(NavUtils.previousRoute == Routes.callKitParticipantView){
          NavUtils.back();
          NavUtils.back();
          return;
        }
        if (NavUtils.currentRoute == Routes.callKitOutGoingCallView) {
          NavUtils.back();
        }
        if(NavUtils.currentRoute == Routes.contacts){
          NavUtils.back();
          NavUtils.back();
          return;
        }
        return;
      }

      if(callerList.length <=1 && !isMeet.value) {
        callkitLogger.info("[MirrorFly][OutgoingCallController] Call disconnectCall");
        if(isAudioDialogOpen.value){
          Get.back();
          isAudioDialogOpen.value = false;
        }
        if(NavUtils.previousRoute == Routes.callKitParticipantView){
          NavUtils.back();
          NavUtils.back();
          return;
        }
        if(NavUtils.currentRoute == Routes.callKitParticipantView){
          NavUtils.back();
          NavUtils.back();
          return;
        }
        if (NavUtils.currentRoute == Routes.callKitOutGoingCallView) {
          NavUtils.back();
        }
      } else if (callerList.any((e) =>
      e.isLocalParticipant == false &&
          e.flyCallStatusEvent != FlyCallStatusEvent.connected)) {
        /// No user is connect so set the value isGroupOnGoingCallEnabled is false
        if(callerList.length <= 2){
          // _stopTimer();
          final remoteParticipant = callerList.firstWhere((e) => e.isLocalParticipant != true);
          callkitLogger.info("[MirrorFly][OutgoingCallController] callerList value  ${remoteParticipant.identity} ${remoteParticipant.flyCallStatusEvent}");
          // callDuration.value = getParticipantConnectionState(remoteParticipant.flyCallStatusEvent);
        }
      } else {
        if(callerList.length <=1 && isMeet.value) {
          isOnGoingCallViewEnable.value = false;
        }
        callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: Call is still ongoing with other participants.");
      }
      return;
    }
    final bool isLocalHangup = isSelfId(id: userId);

    if(isMeet.value && !isLocalHangup) {
      callerList.removeWhere((e) => e.identity == userId);
      final String name = remoteUserNameMap[userId] ?? "";
      remoteUserNameMap.remove(userId);
      toToast("$name disconnected");
      callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: Removed userId: $userId from callerList.callerList.length=${callerList.length}");
      _getCallRemoteUserName();
      isOnGoingCallViewEnable.value = false;
      return;
    }

    callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: for one-one Ending call. ${callerList.length} participants in the call.");

    _resetValues();
    // _stopTimer();
    closeDialog();
    if(isAudioDialogOpen.value){
      callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: Closing audio dialog.");
      Get.back();
      isAudioDialogOpen.value = false;
    }
    if(NavUtils.previousRoute == Routes.callKitParticipantView){
      NavUtils.back();
      NavUtils.back();
      return;
    }
    if(NavUtils.currentRoute == Routes.callKitParticipantView){
      NavUtils.back();
      NavUtils.back();
      return;
    }
    if (NavUtils.currentRoute == Routes.callKitOutGoingCallView) {
      callStatus("Disconnected");
      reason == "reconnectAttemptsExceeded"
          ? toToast("Reconnection attempt exceeded")
          : toToast("Call Disconnected");
      NavUtils.back();
    }
    if(NavUtils.currentRoute == Routes.contacts){
      NavUtils.back();
      NavUtils.back();
      return;
    }
  }

  void isOnGoingCallView() async {
    isOnGoingCallViewEnable.value = true;
  }

  void setMicroPhoneEnabled({required bool enabled}) async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] muteAudio start with mute : $enabled");
    MirrorFlyCallKit.setMicrophoneMuted(
      mute: enabled,
      result: ({
        required bool success,
        bool? isMuted,
        required String message
      }) {
        callkitLogger.info("[MirrorFly][OutgoingCallController] Mute ON result → success=$success, isMuted=$isMuted, message=$message");
        if (success && isMuted != null) {
          callkitLogger.info("[MirrorFly][OutgoingCallController] muteAudio : $isMuted, and setting isAudioEnabled to ${!isMuted}");
          isAudioMuted.value = isMuted;
        } else {
          callkitLogger.info("[MirrorFly][OutgoingCallController]  Error muteAudio status  result → success=$success, message=$message");
        }
      },
    );
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
      callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable: Current call is not a video call, so requesting to switch video call. callStatus- $callStatus");
      requestVideoCallSwitch();
      return;
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable: Current call type is $flyCallType callStatus $callStatus");
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

      if (callerList.firstWhereOrNull((e) => e.identity == participants.first)?.flyCallStatusEvent != FlyCallStatusEvent.engaged) {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] remoteUserIsEngaged: The specified participant is not engaged, so removing the user");
        callerList.removeWhere((e) => e.identity == participants.firstOrNull);
        final String name = remoteUserNameMap[participants.firstOrNull] ?? participants.firstOrNull ?? "";
        toToast(
            getTranslated("usernameIsBusy").replaceFirst("%d", name));
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
      toToast(
          getTranslated("usernameIsBusy").replaceFirst("%d", remoteUserNameMap[participants.firstOrNull] ?? ""));
      await Future.delayed(const Duration(milliseconds: 500));
      if (NavUtils.canPop && NavUtils.currentRoute == Routes.callKitOutGoingCallView) {
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

  void localHangup() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController]  disconnectCall invoked...");
    // _stopTimer();
    try {
      var result = await MirrorFlyCallKit.localHangup();
      callkitLogger.info("[MirrorFly][OutgoingCallController] localHangup() result: $result");

      /// While the local hangup we get the disconnect emit from the plugin
      /// from there we get onDisconnect call and navigate back

      // if (result == true) {
      //   callkitLogger.info(
      //       "[MirrorFly][OutgoingCallController]  Call disconnected successfully. Navigating back...");
      //   NavUtils.back();
      // } else {
      //   NavUtils.back();
      //   callkitLogger.info(
      //       "[MirrorFly][OutgoingCallController]  Call disconnect failed. Retrying or handling failure...");
      // }
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
    final bool toggleVideoEnabledStatus = !isVideoEnabled.value;

    if(isGroupCall.value){
      callkitLogger.info("[MirrorFly][OutgoingCallController] requestVideoCallSwitch: Call switch  supported in group calls.");
      await MirrorFlyCallKit.toggleVideoForGroupCall();
      isVideoEnabled.value = toggleVideoEnabledStatus;
      return;
    }

    final bool callStatus = await MirrorFlyCallKit.isCallConnected();
    final FlyCallType? flyCallType = await MirrorFlyCallKit.getCurrentCallType();
    callkitLogger.info("MirrorFlyCallKit.getVideoMuteStatus(userJid: getRemoteParticipantIdForOneToOneCall()) called ${MirrorFlyCallKit.getVideoMuteStatus(userJid: getRemoteParticipantIdForOneToOneCall())}");

    if (flyCallType == FlyCallType.audio && callStatus) {
      callkitLogger.info("[MirrorFly][OutgoingCallController]  makeCallSwitch invoked...");
      if(await MirrorFlyCallKit.validateSwitchRequest()) {
        _videoCallSwitchRequestConfirmationPopup();
      } else {
        MirrorFlyCallKit.setCameraEnable(
            enable: toggleVideoEnabledStatus,
            result: (result) async {
              if (result) {
                callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable : $result");
                isVideoEnabled.value = toggleVideoEnabledStatus;
              } else {
                callkitLogger.info(
                    "[MirrorFly][OutgoingCallController]  Error setCameraEnable status  result : $result");
              }
            });
      }
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Current call is not an audio call or call is not connected, cannot switch to video. callStatus- $callStatus, flyCallType- $flyCallType");
    }
  }

  ///
  void cancelVideoCallSwitchRequest() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController]  cancelVideoCallSwitch invoked...");
    await MirrorFlyCallKit.cancelVideoCallSwitchRequest();
    toToast("Video call switch canceled");
    // closeDialog();
    // _cancelCallSwitchReqWaiting();
  }

  ///
  void acceptIncomingCallSwitchRequest() async{
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
    final String remoteId = getRemoteParticipants().firstOrNull?.identity ?? "";
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
    if(flyCallType == FlyCallType.video){
      isVideoEnabled.value = true;
    }
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
                if(await AppUtils.isNetConnected()) {
                  if(await AppPermission.askVideoCallPermissions()) {
                    await MirrorFlyCallKit.requestVideoCallSwitch();
                  }else{
                    toToast("Permission is not granted");
                  }

                }else{
                  toToast(getTranslated("noInternetConnection"));
                }
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
          .replaceFirst("%d", remoteUserNameMap[getRemoteParticipants().firstOrNull?.identity] ?? ""),
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
  void onCallFailed({required List<String>? participantsId, String reason = ''}) async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] onCallFailed called");

    if (participantsId == null || participantsId.isEmpty) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] onCallFailed: No participantsId provided");
      return;
    }

    // final FlyCallDirection flyCallDirection = await MirrorFlyCallKit.getCallDirection();
    // callkitLogger.info("[MirrorFly][OutgoingCallController] onCallFailed: Call direction is $flyCallDirection");
    //
    // if (flyCallDirection == FlyCallDirection.incoming || flyCallDirection == FlyCallDirection.none) {
    //   callkitLogger.info("[MirrorFly][OutgoingCallController] onCallFailed: Incoming call, skipping timeout handling");
    //   toToast("Call failed");
    //   await NavUtils.back();
    //
    //   _resetValues();
    //   _stopTimer();
    //   closeDialog();
    //
    //   return;
    // } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] onCallFailed: Outgoing call, processing timeout handling");

      _resetValues();
      // _stopTimer();
      closeDialog();

    toToast("Call Disconnected");
    if(NavUtils.previousRoute == Routes.callKitParticipantView){
      NavUtils.back();
      NavUtils.back();
      return;
    }
    if(NavUtils.currentRoute == Routes.callKitParticipantView){
      NavUtils.back();
      NavUtils.back();
      return;
    }
    if (NavUtils.currentRoute == Routes.callKitOutGoingCallView) {
      NavUtils.back();
    }
      // callTimeOut(participantsId: participantsId, isCallFailed: true, reason: reason);
    // }
  }

  /// Invite participants to the ongoing call
  void inviteParticipants() async {
    final bool isConnected = await AppUtils.isNetConnected();
    if (!isConnected) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] inviteParticipants: No internet connection");
      toToast(getTranslated("noInternetConnection"));
      return;
    }

    NavUtils.toNamed(Routes.callKitParticipantView, arguments: {"joinViaLink": false,"meet":isMeet.value});
  }

  /// Navigate to contacts screen
  Future<List<String>> gotoContacts({bool isGroupInvite = false, String? groupChatId}) async {
    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] gotoContacts called with isGroupInvite: $isGroupInvite, groupChatId: $groupChatId");
    if (isGroupInvite && groupChatId != null) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] gotoContacts for group invite with groupChatId: $groupChatId");
      final dynamic result = await NavUtils.toNamed(Routes.groupParticipants, arguments: {
        "groupId": groupChatId,
        "isFromLiveKitCalls": true,
        "participantsListInCall": callerList.map((e) => e.identity).toList(),
      });
      callkitLogger.info("[MirrorFly][OutgoingCallController] gotoContacts group invite result: $result");
      return result;
    } else {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] gotoContacts for one-to-one call invite");
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

    if (preCallUserListCount > 2) {
      final (bool isIncomingSwitchAvailable, bool isOutgoingSwitchAvailable) result = await MirrorFlyCallKit.getIsSwitchCallRequestOngoing();
      final isDialogOpen = DialogUtils.isDialogOpen() && NavUtils.canPop;

      callkitLogger.info("[MirrorFly][OutgoingCallController] onCallModeChanged"
          " isIncomingSwitchAvailable: ${result.$1},"
          " isOutgoingSwitchAvailable: ${result.$2}"
          " isDialogOpen: $isDialogOpen");

      if (result.$2 && isDialogOpen) {
        // Switch is in progress
        cancelVideoCallSwitchRequest();
        callkitLogger.info("[MirrorFly][OutgoingCallController] onCallModeChanged closed"
            " outgoing call switch dialog due to call mode change");
      } else if (isDialogOpen) {
        // dialog only opened not yet switch started
        NavUtils.back();
        callkitLogger.info("[MirrorFly][OutgoingCallController] Dialog closed");
      } else {
        callkitLogger.info("[MirrorFly][OutgoingCallController] No dialog to close");
      }
    }

    await configureCallMode(
        callMode: callerList.length > 2 ? "ONE-TO-MANY" : "ONE-TO-ONE",
        chatId: groupId.value);

    callkitLogger.info("[MirrorFly][OutgoingCallController] onCallModeChanged updated "
        "local callMode: ${callMode.value}, isGroupCall: ${isGroupCall.value} "
        "isGroupOnGoingCallEnabled: ${isGroupOnGoingCallEnabled.value}");

    if(!isGroupCall.value){
      isGroupOnGoingCallEnabled(!(callerList.length <= 2));
      isCallModeChangedToOneToMany(!(callerList.length <= 2));
    }
    if(isOnGoingCallViewEnable.value){
      isGroupOnGoingCallEnabled(!(callerList.length <= 2));
    }


    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] onCallModeChanged completed, fetching current call"
            " participants..., with isGroupOnGoingCallEnabled: ${isGroupOnGoingCallEnabled.value}, "
            "isCallModeChangedToOneToMany: ${isCallModeChangedToOneToMany.value}");
    await getCallMembersName();
    getCallTitleForOneToManyCall();
    await initCallViewIds();
    await moveLocalParticipantToLast();
    await _getCallRemoteUserName();
  }
    // ///
  void videoSwap() {
    callkitLogger.info("[MirrorFly][OutgoingCallController] videoSwap called");

    if (callType.value == "video") {
      callkitLogger.info(
          "[MirrorFly] before swap → main: ${mainCallViewUserId.value}, pip: ${secondaryCallViewUserId.value}");

      final temp = mainCallViewUserId.value;
      mainCallViewUserId.value = secondaryCallViewUserId.value;
      secondaryCallViewUserId.value = temp;

      callkitLogger.info(
          "[MirrorFly] after swap → main: ${mainCallViewUserId.value}, pip: ${secondaryCallViewUserId.value}");
    }
  }


  ///
  /// To update the call status of a participant in the callerList
  ///
  Future<void> updateCurrentCallParticipant({required String id, required FlyCallStatusEvent status}) async {
    final FlyCallParticipant? participant = callerList.firstWhereOrNull((p) => p.identity == id);

    final int index = callerList.indexWhere((p) => p.identity == id);

    if (participant != null) {
      participant.copyWith(flyCallStatus: status);
      // participant.copyWith(flyCallStatus: status);
      final prevCallList = callerList[index];
      callerList[index] = prevCallList.copyWith(flyCallStatus: status);
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

    final String userId = participantsId.firstOrNull ?? "";
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

    final String userId = participantsId.firstOrNull ?? "";
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
  /// When the connection quality is updated for a participant
  ///
  void onConnectionQualityUpdated({FlyConnectionQuality? quality, String? participantId}) {
    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] onConnectionQualityUpdated called for participantId: $participantId, quality: $quality");

    if (participantId == null && quality == null) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] onConnectionQualityUpdated: participantId and quality is null, aborting.");
      return;
    }

    try {
      final participant = callerList.firstWhereOrNull((p) => p.identity == participantId);
      if (participant != null) {
        participant.copyWith(connectionQuality: quality);
        // callerList.refresh();
        callerConnectionQuality[participantId!] = quality!;
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] onConnectionQualityUpdated: Updated participant $participantId with connectionQuality: "
                "$quality, callerConnectionQuality: $callerConnectionQuality");
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] onConnectionQualityUpdated: Participant $participantId not found in callerList");
      }
    } catch (e) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] onConnectionQualityUpdated: Exception occurred - $e");
    }
  }

  ///
  void _resetValues() {
    callType("");
    // muted(false);
    isVideoEnabled(false);
    speakerOn(false);
    isOnGoingCallViewEnable(false);
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
    callAgainUserList.clear();
    remoteUserNameMap({});
    isGroupCall(false);
    chatNameForGroupCall("");
    isGroupOnGoingCallEnabled(false);
    groupCallTitle("");
    isCallModeChangedToOneToMany(false);
    titleAfterCallModeChange("");
    _isPlaying = false;
    mainCallViewUserId.value = "";
    secondaryCallViewUserId.value = "";
    currentCallMode.value = "";
    isMeet.value = false;

    callkitLogger.info("[MirrorFly][OutgoingCallController] _resetValues");
  }

  /// -------------------------------------------------------------------
  /// AUDIO ROUTING
  /// -------------------------------------------------------------------

  /// Set the initial audio route device when the call screen is opened
  Future<void> setInitialAudioRouteDevice() async {
    final FlyAudioDevice? initialDevice = await MirrorFlyCallKit.getCurrentAudioRoute();
    callkitLogger.info("$audioRoutingTag Initial audio device found: ${initialDevice?.toMap()}");

    if (initialDevice != null) {
      selectedDeviceType.value = initialDevice.type.value;
      // selectedAudioDevice.value = initialDevice;
      callkitLogger.info("$audioRoutingTag updated selectedAudioDevice: ${selectedDeviceType.value}");
    } else {
      callkitLogger.info("$audioRoutingTag No initial audio device found");
    }
  }

  /// Get the available audio output devices
  Future<void> getAvailableAudioOutputDevices() async {
    callkitLogger.info("$audioRoutingTag [MirrorFly][OutgoingCallController] getAvailableAudioOutputDevices called");
    availableTypes.value = await MirrorFlyCallKit.getAvailableAudioRoutes();
    callkitLogger.info("$audioRoutingTag [MirrorFly][OutgoingCallController] getAvailableAudioOutputDevices"
        " result ${availableTypes.map((e) => "name: ${e.deviceName} type: ${e.type} id: ${e.id}")}");
  }

  /// Change the audio output device
  Future<void> changeAudioDevice(FlyAudioDevice flyAudioDevice) async {
    callkitLogger.info(
        "$audioRoutingTag [MirrorFly][OutgoingCallController] changeAudioDevice called with flyAudioDevice: $flyAudioDevice");
    MirrorFlyCallKit.changeAudioRoute(flyAudioDevice: flyAudioDevice);
  }

  void onAudioRouteChanged(FlyAudioDevice flyAudioDevice) async {
    callkitLogger.info("$audioRoutingTag [MirrorFly][OutgoingCallController] onAudioRouteChanged called with flyAudioDevice: $flyAudioDevice");
    await getAvailableAudioOutputDevices();

    selectedDeviceType.value = flyAudioDevice.type.value;
    // selectedAudioDevice.value = flyAudioDevice;
    // selectedAudioDeviceId.value = flyAudioDevice.id;
  }

  void goToPIP() {
    if(NavUtils.canPop) {
      NavUtils.back();
    } else {
      NavUtils.offNamed(NavUtils.defaultRouteName);
    }
    startPIP();
  }

  void startPIP(){
    PictureInPicture.startPiP(pipWidget: const CallkitPipView());
    PictureInPicture.updatePiPParams(
      pipParams: PiPParams(
        pipWindowWidth: AppUtils.getSizeFromAspectRatio(NavUtils.width, NavUtils.height).width * 0.9,
        pipWindowHeight: AppUtils.getSizeFromAspectRatio(NavUtils.width, NavUtils.height).height * 0.6,
        bottomSpace: 20,
        leftSpace: 20,
        rightSpace: 20,
        topSpace: 20,
        movable: true,
        resizable: true,
        initialCorner: PIPViewCorner.bottomRight,
      ),
    );
  }
}