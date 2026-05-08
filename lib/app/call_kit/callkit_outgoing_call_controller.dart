import 'dart:async';
import 'dart:io';

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

import 'callkit_call_state_service.dart';
import 'callkit_event_buffer.dart';
import 'callkit_logger.dart';
import 'callkit_pip/callkit_pip_View.dart';

class CallKitOutgoingCallController extends GetxController
    with GetTickerProviderStateMixin {

  /// Observables
  var callStatus = "".obs;
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
  RxBool isSwapped = false.obs;

  final RxBool cameraSwitch = false.obs;
  final RxBool isIncoming = false.obs;
  final RxBool isManualDeviceSelected = false.obs;
  RxBool isLocalUserOnHold = false.obs;

  RxString cameraPosition = CameraType.front.obs;

  /// For group call handling
  // RxBool isGroupCall = false.obs;
  // RxBool isGroupOnGoingCallEnabled = false.obs;
  // RxString chatNameForGroupCall = "".obs;
  // RxString groupCallTitle = "".obs;
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
  RxString callerNames = "".obs;

  RxBool isMeet = false.obs;
  StreamSubscription<String>? callTimerStream;

  /// Convenience accessor for the running CallStateService.
  /// The service is always started before this controller is created.
  CallStateService get _svc => CallStateService.instance;

  // Workers for service event subscriptions — stored so we can manually
  // dispose them in onClose() for guaranteed cleanup.
  Worker? _statusWorker;
  Worker? _actionWorker;


  @override
  Future<void> onInit() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] onInit called");

    // Ensure the service is running — for incoming calls BaseController starts
    // it before navigation, but for outgoing calls (and edge cases) we start
    // it here as well. CallStateService.start() is idempotent.
    await CallStateService.start();

    // Flush any events that arrived before the service was registered.
    CallKitEventBuffer.flushToService(_svc);

    // ── Subscribe to service events and call controller methods ──────────────
    // When BaseController dispatches an SDK event to CallStateService, it sets
    // lastStatusEvent / lastActionEvent. We ever() those here and call the
    // exact same methods this controller has always had — no behaviour change.

    _statusWorker = ever(_svc.lastStatusEvent, (FlyCallStatus? status) {
      if (status == null) return;
      final event = status.flyCallStatusEvent;
      final ids = status.participantsIds;
      callkitLogger.info('[MirrorFly][OutgoingCallController] lastStatusEvent $event, ids: $ids');
      switch (event) {
        case FlyCallStatusEvent.connecting:
          connecting();
          break;
        case FlyCallStatusEvent.connected:
          onConnected(ids);
          break;
        case FlyCallStatusEvent.ringing:
          ringing(participantsId: ids);
          break;
        case FlyCallStatusEvent.tryingToConnect:
          tryingToConnect();
          break;
        case FlyCallStatusEvent.calling:
          outGoingCallCalling(participantsId: ids);
          break;
        case FlyCallStatusEvent.reconnecting:
          reconnecting(participantIds: ids);
          break;
        case FlyCallStatusEvent.reconnected:
          reconnected(participantIds: ids);
          break;
        case FlyCallStatusEvent.disconnected:
          disconnectCall(userIds: ids, reason: status.reason ?? '');
          break;
        case FlyCallStatusEvent.callHold:
          callHold(participantsId: ids);
          break;
        case FlyCallStatusEvent.callResume:
          callResume(participantsId: ids);
          break;
        case FlyCallStatusEvent.callTimeout:
          callTimeOut(participantsId: ids, isCallFailed: false, reason: 'callTimeout');
          break;
        case FlyCallStatusEvent.rejected:
          if (ids.isNotEmpty) rejected(userId: ids.first);
          break;
        case FlyCallStatusEvent.engaged:
          remoteUserIsEngaged(participants: ids);
          break;
        case FlyCallStatusEvent.callFailed:
          onCallFailed(participantsId: ids, reason: status.reason ?? '');
          break;
        default:
          break;
      }
    });

    _actionWorker = ever(_svc.lastActionEvent, (FlyCallAction? action) {
      if (action == null) return;
      final event = action.flyCallEvent;
      callkitLogger.info('[MirrorFly][OutgoingCallController] lastActionEvent $event');
      switch (event) {
        case FlyCallActionEvent.audioMuted:
          isAudioMute(isAudioMuted: true, participantId: action.participantId);
          break;
        case FlyCallActionEvent.audioUnMuted:
          isAudioMute(isAudioMuted: false, participantId: action.participantId);
          break;
        case FlyCallActionEvent.videoMuted:
          isVideoMute(isVideoMuted: true, participantId: action.participantId);
          break;
        case FlyCallActionEvent.videoUnMuted:
          isVideoMute(isVideoMuted: false, participantId: action.participantId);
          break;
        // case FlyCallActionEvent.toAudioCallAfterCallSwitch:
        //   audioCallAfterCallSwitch();
        //   break;
        case FlyCallActionEvent.onCallModeChange:
          // onParticipantListUpdated();
          break;
        case FlyCallActionEvent.onAudioRouteChanged:
          if (action.flyAudioDevice != null) {
            onAudioRouteChanged(action.flyAudioDevice!);
          }
          break;
        case FlyCallActionEvent.connectionQualityUpdated:
          onConnectionQualityUpdated(
              quality: action.connectionQuality,
              participantId: action.participantId);
          break;
        case FlyCallActionEvent.activeSpeaker:
          onActiveSpeakerChange(
              isSpeaking: false,
              audioLevel: action.audioLevel ?? 0,
              participantId: action.participantId ?? '');
          break;
        // Dialog events — already handled by BaseController calling uiController directly
              case FlyCallActionEvent.outgoingCallSwitchRequest:
          showOutGoingCallSwitchRequestDialog();
          break;
        case FlyCallActionEvent.incomingCallSwitchRequest:
          showIncomingCallSwitchRequestDialog();
          break;
        case FlyCallActionEvent.outgoingCallSwitchAccepted:
          onVideoCallSwitchAccept();
          break;
        case FlyCallActionEvent.outgoingCallSwitchCancelled:
          onRemoteUserCancelledTheSwitchRequest();
          break;
        case FlyCallActionEvent.outgoingCallSwitchDeclined:
          onCallSwitchRemoteUserDeclined();
          break;
        case FlyCallActionEvent.outgoingCallSwitchTimeout:
          onVideoCallSwitchTimeOut(isIncomingTimeout: false);

        case FlyCallActionEvent.incomingCallSwitchTimeout:
          onVideoCallSwitchTimeOut(isIncomingTimeout: true);

          break;
        default:
          break;
      }
    });
    // ─────────────────────────────────────────────────────────────────────────

    // Seed current service state into controller fields immediately.
    // ever() only fires on future changes — if PIP was expanded and the call
    // is already connected/running, the view would show defaults without this.
    _seedStateFromService();

    //Moved to OnReady
    super.onInit();
  }

  void _disposeCallTimer() {
    callkitLogger.info('[MirrorFly][OutgoingCallController] _disposeCallTimer called');
    callTimerStream?.cancel();
    callTimerStream = null;
  }

  void _listenToSDKCallTimer() {
    callkitLogger.info('[MirrorFly][OutgoingCallController] _listenToSDKCallTimer called');

    if (callTimerStream != null) {
      callkitLogger.info('[MirrorFly][OutgoingCallController] _listenToSDKCallTimer callTimerStream is already active');
      return;
    }

    callTimerStream = MirrorFlyCallKit.flyCallTimer.listen((timer) {
    //  callkitLogger.info('[MirrorFly][OutgoingCallController] _listenToSDKCallTimer timer: $timer');
      callDuration(timer);
    });
  }

  /// Copies the current [CallStateService] state into this controller's Rx
  /// fields in one shot.  Called at the end of [onInit] so that when the
  /// call screen is reconstructed after PIP expand (a fresh controller
  /// instance), the view immediately shows the live call state rather than
  /// the defaults that the controller fields start with.
  ///
  /// [ever()] subscriptions only fire on *future* changes; this seeds the
  /// initial snapshot so no event needs to be re-fired.
  void _seedStateFromService() {
    callkitLogger.info('[MirrorFly][OutgoingCallController] _seedStateFromService — restoring state from service');

    // ── Call metadata (required for Meet mode and onReady() to work correctly
    //    when PIP is expanded and NavUtils.arguments is null) ─────────────────
    callType.value         = _svc.callType.value;
    groupId.value          = _svc.groupId.value;
    callMode.value         = _svc.callMode.value;
    currentCallMode.value  = _svc.currentCallMode.value;
    isIncoming.value       = _svc.isIncoming.value;
    callKind               = _svc.callKind;
    isMeet.value           = _svc.isMeet.value;

    callStatus.value           = _svc.callStatus.value;
    isAudioMuted.value         = _svc.isAudioMuted.value;
    isVideoEnabled.value       = _svc.isVideoEnabled.value;
    isOnGoingCallViewEnable.value = _svc.isOnGoingCallViewEnable.value;
    // isGroupCall.value          = _svc.isGroupCall.value;
    // isGroupOnGoingCallEnabled.value = _svc.isGroupOnGoingCallEnabled.value;
    isCallModeChangedToOneToMany.value = _svc.isCallModeChangedToOneToMany.value;
    titleAfterCallModeChange.value = _svc.titleAfterCallModeChange.value;
    // chatNameForGroupCall.value = _svc.chatNameForGroupCall.value;
    selectedDeviceType.value   = _svc.selectedDeviceType.value;
    mainCallViewUserId.value   = _svc.mainCallViewUserId.value;
    secondaryCallViewUserId.value = _svc.secondaryCallViewUserId.value;
    callerNames.value = _svc.callerNames.value;
    callDuration.value         = _svc.callDuration.value;

    cameraPosition.value      = _svc.cameraPosition.value;
    cameraSwitch.value         = _svc.cameraSwitch.value;

    if (_svc.callerList.isNotEmpty) {
      callerList.value = List.from(_svc.callerList);
      callerList.refresh();
    }
    if (_svc.remoteUserNameMap.isNotEmpty) {
      remoteUserNameMap.value = Map.from(_svc.remoteUserNameMap);
    }
    if (_svc.callerAudioLevel.isNotEmpty) {
      callerAudioLevel.value = Map.from(_svc.callerAudioLevel);
    }
    if (_svc.callerConnectionQuality.isNotEmpty) {
      callerConnectionQuality.value = Map.from(_svc.callerConnectionQuality);
    }
    if (_svc.availableTypes.isNotEmpty) {
      availableTypes.value = List.from(_svc.availableTypes);
    }
    if (_svc.callAgainUserList.isNotEmpty) {
      callAgainUserList.value = List.from(_svc.callAgainUserList);
    }

    callkitLogger.info(
        '[MirrorFly][OutgoingCallController] _seedStateFromService done '
        'callStatus=${callStatus.value} isOnGoing=${isOnGoingCallViewEnable.value} '
        'duration=${callDuration.value} callers=${callerList.length}');

    // ── Replay pending call-switch event ──────────────────────────────────
    // Any call-switch event (request or resolution) that arrived while the
    // controller was absent (PIP mode) is stored in the service. We replay
    // it now and clear so it doesn't fire again on future re-creations.
    final switchEvent = _svc.lastCallSwitchEvent.value;
    if (switchEvent != null) {
      callkitLogger.info(
          '[MirrorFly][OutgoingCallController] _seedStateFromService — replaying call-switch ${switchEvent.flyCallEvent}');
      switch (switchEvent.flyCallEvent) {
        case FlyCallActionEvent.outgoingCallSwitchRequest:
          showOutGoingCallSwitchRequestDialog();
          break;
        case FlyCallActionEvent.incomingCallSwitchRequest:
          showIncomingCallSwitchRequestDialog();
          break;
        case FlyCallActionEvent.outgoingCallSwitchAccepted:
          onVideoCallSwitchAccept();
          break;
        case FlyCallActionEvent.outgoingCallSwitchDeclined:
          onCallSwitchRemoteUserDeclined();
          break;
        case FlyCallActionEvent.outgoingCallSwitchCancelled:
          onRemoteUserCancelledTheSwitchRequest();
          break;
        case FlyCallActionEvent.outgoingCallSwitchTimeout:
          onVideoCallSwitchTimeOut(isIncomingTimeout: false);
        case FlyCallActionEvent.incomingCallSwitchTimeout:
          onVideoCallSwitchTimeOut(isIncomingTimeout: true);
          break;
        default:
          break;
      }
      // Clear so it doesn't replay again if the screen is recreated.
      _svc.lastCallSwitchEvent.value = null;
    } else {
      callkitLogger.info(
          '[MirrorFly][OutgoingCallController] _seedStateFromService — no pending call-switch event to replay');
    }
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

      // Write canonical values into the service so PIP and BaseController
      // have them from the moment the call screen opens.
      _svc.callType.value = callType.value;
      _svc.groupId.value = groupId.value;
      _svc.callMode.value = callMode.value;
      _svc.isIncoming.value = isIncoming.value;
      _svc.currentCallMode.value = currentCallMode.value;
      _svc.callKind = callKind;

      if(currentCallMode.value == "MEET"){
        isMeet.value = true;
        _svc.isMeet.value = true;
        if (callerList.length >= 2) {
          callkitLogger.info("[MirrorFly][OutgoingCallController] join via meet link local and remote participant present");
          isOnGoingCallView();
        } else {
          callkitLogger.info("[MirrorFly][OutgoingCallController] join via meet link local participant only present ");
          callStatus("");
        }
        // bool isAudioMute = MirrorFlyCallKit.getAudioMuteStatus(userJid: CallUtils.getIdFromJidList(SessionManagement.getUserJID() ?? ""));
        // bool isVideoMuted = MirrorFlyCallKit.getVideoMuteStatus(userJid: CallUtils.getIdFromJidList(SessionManagement.getUserJID() ?? ""));
        // callkitLogger.info("[MirrorFly][OutgoingCallController] Current call mode is MEET, enabling ongoing call view and fetching video mute status $isVideoMuted and audio mute status $isAudioMute");
        // if(!isVideoMuted){
        //   isVideoEnabled.value = true;
        //   _svc.isVideoEnabled.value = true;
        // } else {
        //   isVideoEnabled.value = false;
        //   _svc.isVideoEnabled.value = false;
        // }
        // if (isAudioMute){
        //   isAudioMuted.value = true;
        //   _svc.isAudioMuted.value = true;
        // } else {
        //   isAudioMuted.value = false;
        //   _svc.isAudioMuted.value = false;
        // }
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

 /* void _handleCallTypeLogic() {
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
*/
  Future<void> initCallViewIds() async{
    final localId = getLocalParticipant()?.identity ?? "";
    final remoteId = getRemoteParticipants().firstOrNull?.identity ?? "";

    mainCallViewUserId.value = remoteId;     // show remote as main view
    secondaryCallViewUserId.value = localId; // local goes to small preview
  }


  @override
  void onReady() async {

    //Moved from onInit

    callKind = MirrorFlyCallKit.getCallKind();
        await getCurrentCallParticipants();
        await initCallViewIds();

    if (NavUtils.arguments != null) {
      await _initCallArguments();
      // _handleCallTypeLogic();
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] No call arguments found");
    }
    await _handleInitialCallStatus();

    await _getCallRemoteUserName();
    initPlayer();

    callkitLogger.info("[MirrorFly][OutgoingCallController] callviewinit");
    if (callType.value.isNotEmpty) {
      _handleWakelock(callType.value);
    }

    ever(callType, (String type) {
      _handleWakelock(type);
    });

    // await configureCallMode(callMode: callMode.value, chatId: groupId.value);
    // _svc.configureCallMode(callMode: callMode.value, chatId: groupId.value);
    // onParticipantListUpdated();
    callkitLogger.info("[MirrorFly][OutgoingCallController] callview");

    if (isIncoming.value) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] onConnected: Initial audio route set for incoming call");
      await setInitialAudioRouteDevice();
    }

    _listenToSDKCallTimer();

    //


    // if (isGroupCall.value || isGroupOnGoingCallEnabled.value) {
    //   callkitLogger.info("[MirrorFly][OutgoingCallController] onReady getRemoteAndLocalUserNameForGroupCall, isGroupCall :${isGroupCall.value}");

      // if (groupId.value.isNotEmpty) {
      //   callkitLogger.info("[MirrorFly][OutgoingCallController] onReady groupId is not empty, calling getChatNameForGroupCall");
      //   await getChatNameForGroupCall(chatId: groupId.value);
      // } else {
        await getCallMembersName();
        callkitLogger.info("[MirrorFly][OutgoingCallController] onReady groupId is empty, skipping getChatNameForGroupCall");
      // }

      // if(currentCallMode.value != "MEET"){
      //   // Only derive isVideoEnabled from callType when this is a fresh screen
      //   // open (NavUtils.arguments present). On PIP expand (no nav args), the
      //   // value was already seeded correctly from the service — don't overwrite.
      //   if (NavUtils.arguments != null) {
      //     callType.value == "audio"
      //         ? isVideoEnabled.value = false
      //         : isVideoEnabled.value = true;
      //   }
      // }

    super.onReady();
  }

  ///
  /// Get current participants in the call
  ///
  Future<List<FlyCallParticipant>> getCurrentCallParticipants() async {
    final participants = MirrorFlyCallKit.getCurrentCallParticipants();

    callkitLogger.info(
        "[MirrorFly][OutgoingCallController] Current call participants: ${participants.length},"
            " participants: ${participants.map((p) => p.toJson()).toList()}",);

    if (participants.isNotEmpty) {
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

        /// Check and update local user mute status
        /// Scenario: for MEET and LINK join we get the event from sdk before the
        /// controllers and service are getting ready so that we check once here
        if (flyCallParticipant.isLocalParticipant) {
          checkLocalUserMuteStatus(flyCallParticipant);
        }

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

    return participants;
  }

  void checkLocalUserMuteStatus(FlyCallParticipant participant) {
    final bool isParticipantAudioMuted = participant.isAudioMuted ?? false;
    final bool isParticipantVideoMuted = participant.isVideoMuted ?? false;
    callkitLogger.info("[MirrorFly][OutgoingCallController] #checkLocalUserMuteStatus "
        "called with isParticipantAudioMuted: $isParticipantAudioMuted, isParticipantVideoMuted: $isParticipantVideoMuted");

    if(!isParticipantVideoMuted){
      isVideoEnabled.value = true;
      _svc.isVideoEnabled.value = true;
    } else {
      isVideoEnabled.value = false;
      _svc.isVideoEnabled.value = false;
    }

    if (isParticipantAudioMuted){
      isAudioMuted.value = true;
      _svc.isAudioMuted.value = true;
    } else {
      isAudioMuted.value = false;
      _svc.isAudioMuted.value = false;
    }
  }

  ///
  /// Verify the call mode
  ///
  // Future<void> configureCallMode(
  //     {required String callMode, required String chatId}) async {
  //   callkitLogger.info(
  //       "[MirrorFly][OutgoingCallController] #configureCallMode with callMode: $callMode, chatId: $chatId");
  //
  //   // Consider as one to one call
  //   if (chatId.isEmpty) {
  //     callkitLogger.info(
  //         "[MirrorFly][OutgoingCallController] #configureCallMode with remote participantId for "
  //             "one to one call");
  //   }
  //   await getCallMembersName();
  //
  //   // Validate for group call
  //   final bool yes = callMode == "TO-ONE-TO-MANY" || callMode == "ONE-TO-MANY";
  //   isGroupCall.value = yes;
  //   if (yes) {
  //     callkitLogger.info(
  //         "[MirrorFly][OutgoingCallController] #configureCallMode isGroupCall: true");
  //
  //     if (chatId.isEmpty && callMode == "ONE-TO-MANY") {
  //       callkitLogger.info(
  //           "[MirrorFly][OutgoingCallController] #configureCallMode with chatId for group call: $chatId");
  //       getCallMembersName();
  //       isCallModeChangedToOneToMany(true);
  //     }
  //     getCallTitleForOneToManyCall();
  //   } else if(callerList.length > 2 && isIncoming.value){
  //     callkitLogger.info("[MirrorFly][OutgoingCallController] callerList.length value  ${callerList.length} isIncoming.value ${isIncoming.value}");
  //     isGroupCall.value = true;
  //     isCallModeChangedToOneToMany(true);
  //     getCallTitleForOneToManyCall();
  //   }
  //   callkitLogger.info("[MirrorFly][OutgoingCallController] callerList.length ${callerList.length}");
  //
  //   callkitLogger.info(
  //       "[MirrorFly][OutgoingCallController] #configureCallMode isGroupCall: ${isGroupCall
  //           .value}");
  // }

  Future<void> getCallMembersName({List<String>? id}) async {
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

    if (id != null) {
      for (var identity in id) {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] #getRemoteAndLocalUserNameForParticularUser Getting user name for: $identity,t}");
        ProfileDetails profile = await getProfileDetails(
            validId(userId: identity, isGroup: false),
            isFromCallKit: true);
        String username = (profile.name?.trim().isNotEmpty == true)
            ? profile.name!.trim()
            : (profile.nickName?.trim().isNotEmpty == true)
            ? profile.nickName!.trim()
            : trimAfterAt(profile.jid ?? "");
        remoteUserNameMap[identity] =
        identity == CallUtils.getIdFromJidList(SessionManagement.getUserJID() ?? identity) ? "You" : username;
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] #getRemoteAndLocalUserNameForParticularUser  User Name for $identity: $username");
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
    final bool isGroupComesOneToOneCall = callerList.length == 2;

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
          callkitLogger.info("onGoingCallEnabledAddLocalUser block not to remove local participant ${callerList.length}");
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
        callerNames.value = value;
      });
    } catch (e) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Remote User name error: $e");
      callerNames.value = "MF Call";
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
  // Future<void> getChatNameForGroupCall({required String chatId}) async {
  //   callkitLogger.info("[MirrorFly][OutgoingCallController] #getChatNameForGroupCall called with chatId: $chatId");
  //   // if (isGroupCall.value && chatId.isNotEmpty) {
  //     callkitLogger.info(
  //         "[MirrorFly][OutgoingCallController] #getChatNameForGroupCall with chatId: ${groupId.value}");
  //     ProfileDetails profile = await getProfileDetails(validId(userId: chatId,isGroup: true), isFromCallKit: true);
  //     String chatName =
  //     (profile.name?.trim().isNotEmpty == true)
  //         ? profile.name!.trim()
  //         : (profile.nickName?.trim().isNotEmpty == true)
  //         ? profile.nickName!.trim()
  //         : trimAfterAt(profile.jid ?? "");
  //     chatNameForGroupCall.value = chatName;
  //   // } else {
  //     callkitLogger.info(
  //         "[MirrorFly][OutgoingCallController] #getChatNameForGroupCall Chat name for groupId: ${groupId.value} is ${chatNameForGroupCall.value}");
  //   // } else {
  //   //   callkitLogger.info(
  //   //       "[MirrorFly][OutgoingCallController] #getChatNameForGroupCall Not a group call chatId: ${groupId.value}");
  //   // }
  // }

  ///
  /// Get call title for the one-to-many call.
  ///
  // String getCallTitleForOneToManyCall()  {
  //   callkitLogger.info(
  //       "[MirrorFly][OutgoingCallController] #getCallTitleForOneToManyCall called");
  //
  //   if (!isGroupCall.value) {
  //     callkitLogger.info("[MirrorFly][OutgoingCallController] Not a group call");
  //     return "";
  //   }
  //
  //   // Filter remote participants:
  //   // 1. Exclude local user using isSelfId()
  //   // 2. Exclude any name that equals "you"
  //   final filteredNames = remoteUserNameMap.entries
  //       .where((entry) {
  //         final id = entry.key;
  //         final name = entry.value.trim();
  //
  //         // Exclude self
  //         if (isSelfId(id: id)) return false;
  //
  //         // Exclude redundant "you"
  //         if (name.toLowerCase() == "you") return false;
  //
  //         return true;
  //       })
  //       .map((e) => e.value.trim())
  //       .toList();
  //
  //   final count = filteredNames.length;
  //
  //   if (count == 0) {
  //     titleAfterCallModeChange.value = "You";
  //     return "";
  //   }
  //
  //   String title;
  //
  //   if (count == 1) {
  //     title = "You and ${filteredNames[0]}";
  //   } else if (count == 2) {
  //     title = "You, ${filteredNames[0]} & ${filteredNames[1]}";
  //   } else {
  //     final others = count - 1;
  //     title =
  //         "You, ${filteredNames[0]} & $others ${others == 1 ? 'other' : 'others'}";
  //
  //   }
  //   callkitLogger.info(
  //       "[MirrorFly][OutgoingCallController] #getCallTitleForOneToManyCall -> $title");
  //
  //  titleAfterCallModeChange.value = title;
  //  return title;
  //
  //
  // }

  ///
  /// Handle the UI based on the current call status
  ///
  Future<void> _handleInitialCallStatus() async {
    callkitLogger.info("[MirrorFly] _handleInitialCallStatus called");
    final FlyCallStatusEvent? currentStatusEvent =
        MirrorFlyCallKit.currentCallStatus?.flyCallStatusEvent;
    callkitLogger.info("[MirrorFly] currentStatusEvent: $currentStatusEvent");
    if (currentStatusEvent == FlyCallStatusEvent.connected) {
      if (!isOnGoingCallViewEnable.value && !isMeet.value) {
        isOnGoingCallView();
      }
      callStatus("Connected");
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
       remoteUserNameMap: ${remoteUserNameMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}
       callerList length: ${callerList.length}
       isLocalTracksPublished: ${isLocalTracksPublished.value}
       isRemoteTracksPublished: ${isRemoteTracksPublished.value}
          ''');
  }

  @override
  void onClose() {
    // Manually dispose service workers — guarantees cleanup even if GetX's
    // internal disposeWorkers() is skipped in edge cases.
    _statusWorker?.dispose();
    _actionWorker?.dispose();
    _disposeCallTimer();
    callkitLogger.info('[MirrorFly][OutgoingCallController] onClose — service workers disposed');
    super.onClose();
  }


  @override
  void dispose(){
    callkitLogger.info("[MirrorFly][OutgoingCallController] CallKitOutgoingCallController dispose called");
    _player?.dispose();
    _disposeCallTimer();
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
    // showControls.value = !showControls.value;
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
              isAudioMuted: existing.isAudioMuted,
              isReconnecting: existing.isReconnecting,
              isVideoMuted: existing.isVideoMuted,
            );
          } else {
            final bool isAudioMuted = MirrorFlyCallKit.getCurrentCallParticipants().firstWhereOrNull((e) => e.identity == id)?.isAudioMuted ?? false;
            final bool isVideoMuted = MirrorFlyCallKit.getCurrentCallParticipants().firstWhereOrNull((e) => e.identity == id)?.isVideoMuted ?? false;
            final bool isLocalUserReconnecting = MirrorFlyCallKit.getCurrentCallParticipants().firstWhereOrNull((e) => e.identity == id)?.isReconnecting ?? false;

             callkitLogger.info("[MirrorFly][OutgoingCallController] updateCallerStatusList new participant with id: $id, "
                 "isAudioMuted: $isAudioMuted, isVideoMuted: $isVideoMuted, reconnecting: $isLocalUserReconnecting");

            // Participant not found — add new
            callkitLogger.info("[MirrorFly][OutgoingCallController] updateCallerStatusList adding new participant");
            final bool isLocalParticipant = id == getLocalParticipant()?.identity;
            !isLocalParticipant ? callerList.insert(callerList.length - 1, FlyCallParticipant(
              identity: id,
              isLocalParticipant: isLocalParticipant,
              flyCallStatusEvent: status,
              flyCallActionEvent: null,
              isAudioMuted: isAudioMuted,
              isVideoMuted: isVideoMuted,
              isReconnecting: isLocalUserReconnecting,
            )) : callerList.add(
              FlyCallParticipant(
                identity: id,
                isLocalParticipant: isLocalParticipant,
                flyCallStatusEvent: status,
                flyCallActionEvent: null,
                isAudioMuted: isAudioMuted,
                isVideoMuted: isVideoMuted,
                isReconnecting: isLocalUserReconnecting,
              ),
            );
          }
      }
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


    callkitLogger.info("[Controller] isAudioMute before: ${callerList.map((p) => '${p.toJson()}')}");

    final updated = callerList[index].copyWith(isAudioMuted: isAudioMuted);
    callerList.value = List.from(callerList)..[index] = updated;
    // callerList.refresh();

    callkitLogger.info("[Controller] isAudioMute after: ${callerList.map((p) => '${p.toJson()}')}");

    if (participantId == getLocalParticipant()?.identity) {
      callkitLogger.info("[Controller] isAudioMute: Updating local audio mute status to $isAudioMuted");
      this.isAudioMuted(isAudioMuted);
    } else {
      callkitLogger.info("[Controller] isAudioMute: Received for Remote participantId: $participantId");
    }

    callkitLogger.info("[Controller] isAudioMute: Updated ${updated.identity} mute status to $isAudioMuted");
  }

  void isVideoMute({required bool isVideoMuted,required String? participantId}) {

    final index = callerList.indexWhere((p) => p.identity == participantId);

    callkitLogger.info("[Controller] isVideoMute called for participantId: $participantId, isVideoMuted: $isVideoMuted, index: $index");

    if(isSelfId(id: participantId)){
      callkitLogger.info("[Controller] Updating local video mute status to $isVideoMuted");
      isVideoEnabled.value = !(isVideoMuted);
    }

    final muteStatusUpdate = callerList[index].copyWith(isVideoMuted: isVideoMuted);
    callerList.value = List.from(callerList)..[index] = muteStatusUpdate;

    callkitLogger.info("[Controller] isVideoMute: Updated ${muteStatusUpdate.identity} list: ${callerList.map((p) => '${p.toJson()}')}");

  }

  // void audioCallAfterCallSwitch(){
  //   callkitLogger.info("audioCallAfterCallSwitch change the call type into audio call");
  //   // switchCamera();
  //   callType.value = "audio";
  // }

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

    participantsId = participantsId
        .map((id) => id.split('@').firstOrNull?.trim() ?? "")
        .toList();

    callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, group call is ongoing");
    callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, current call participant list: ${callerList.map((e) => e.identity).toList()}");

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
        // checkParticipantForCallMode();
        await _getCallRemoteUserName();
      } else {
        // checkParticipantForCallMode();
        await _getCallRemoteUserName();
        // callerList.refresh();
        callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, participantId: $p not found in callerList");
      }
      await initCallViewIds();
    }
    // for (var id in participantsId) {
    //   final target = callerList.firstWhereOrNull((p) => p.identity == id);
    //   if (target != null) {
    //     callkitLogger.info("[MirrorFly][OutgoingCallController] Timeout, removing participantId: ${target.identity}");
    //     callerList.remove(target);
    //   }
    // }

    bool shouldNavigate = false;

    if(callerList.length <= 1){
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


    if (participantsId.isEmpty) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Call Timeout, no participantsId found");
      return;
    }


  }

  void _navigateToTimeout({required bool isCallFailed, required String reason}) {
    final String message = isCallFailed ? "Call Failed. Reason: $reason" : "Call timed out";
    callkitLogger.info("[MirrorFly][OutgoingCallController] Navigating to timeout view with message: $message");

    toToast(message);

    final String type       = callType.value;
    final String calleeName = callerNames.value;

    final List<dynamic> callUserList = callAgainUserList.toList();
    final String callsMode = callMode.value;
    final String chatId    = groupId.value;

    callkitLogger.info(
      "[MirrorFly][OutgoingCallController] Timeout → navigating to CallKitTimeOutView "
          "type:$type, calleeName:$calleeName, userList:$callUserList, callMode:$callsMode, chatId:$chatId, callKind:$callKind",
    );
    _resetValues();
    CallStateService.stop();
    NavUtils.offNamed(Routes.callKitTimeOutView, arguments: {
      "callType": type,
      "userJid": callUserList,
      "calleeName": calleeName,
      "callMode": callsMode,
      "groupId": chatId,
      "callKind": callKind,
    });
  }

  // void checkParticipantForCallMode() async {
  //   callkitLogger.info("[MirrorFly][OutgoingCallController] checkParticipantForCallMode called");
  //   final List<FlyCallParticipant> participants = await getCurrentCallParticipants();
  //   if (participants.isEmpty) {
  //     callkitLogger.info(
  //         "[MirrorFly][OutgoingCallController] checkParticipantForCallMode: No participants found");
  //     return;
  //   }
  //   if (participants.length <= 2 &&
  //       isGroupCall.value &&
  //       isGroupOnGoingCallEnabled.value) {
  //     callkitLogger.info(
  //         "[MirrorFly][OutgoingCallController] checkParticipantForCallMode: Switching to one-to-one call mode");
  //     isCallModeChangedToOneToMany.value = false;
  //     callMode.value = "TO-ONE-TO-ONE";
  //     isGroupCall.value = false;
  //     isGroupOnGoingCallEnabled.value = false;
  //     titleAfterCallModeChange.value = '';
  //   } else {
  //     callkitLogger.info(
  //         "[MirrorFly][OutgoingCallController] checkParticipantForCallMode: No call mode change needed");
  //   }
  // }

  void rejected({required String userId}) async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] Call rejected by userId: $userId");

    // if (isGroupCall.value) {
    //   callkitLogger.info(
    //       "[MirrorFly][OutgoingCallController] Call rejected, but group call is ongoing, "
    //           "current remote participant name map: ${remoteUserNameMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}");

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
        toToast("$name is busy");
        _resetValues();
        CallStateService.stop();
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));
      toToast("$name is busy");
      _getCallRemoteUserName();
      await initCallViewIds();
    // }

    // callkitLogger.info("[MirrorFly][OutgoingCallController] Call rejected, ending call");
    // await Future.delayed(const Duration(milliseconds: 500));
    // toToast("User Busy");
    // _resetValues();
    // NavUtils.back();
  }

  void connecting({List<String>? participantsId , FlyCallStatusEvent? connecting}) {
    callStatus("Connecting...");
    updateCallerStatusList(participantsId: participantsId, status: FlyCallStatusEvent.connecting);
    _getCallRemoteUserName();
    getCallMembersName(id: participantsId);
    callkitLogger.info("[MirrorFly] connecting.. called");
  }

  void outGoingCallCalling({ FlyCallStatusEvent? calling, List<String>? participantsId}) {
    callkitLogger.info("[MirrorFly][OutgoingCallController] outgoing calling");
    callStatus("Calling...");
    updateCallerStatusList(participantsId: participantsId, status: FlyCallStatusEvent.calling);
    _getCallRemoteUserName();
    getCallMembersName(id: participantsId);
  }

  /// When ever the participant connected in the ongoing call this method will gets triggered

  void onConnected(List<String> participantIds) async {
    if (callerList.length <= 2) {

      final bool isUserOnHold = callerList.any((p) =>
      participantIds.contains(p.identity) &&
          p.flyCallStatusEvent == FlyCallStatusEvent.callHold);
      if (isUserOnHold) {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] #onConnected: Users on hold found, updating their status to connected");
        updateCallerStatusList(
            participantsId: participantIds,
            status: FlyCallStatusEvent.connected);
        return;
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] #onConnected: No users on hold, skipping update");
      }

      for (var p in participantIds) {
        if (!isSelfId(id: p)) {
          if (!isOnGoingCallViewEnable.value) {
            callkitLogger.info("[MirrorFly][OutgoingCallController] #onConnected for one to one call");
            callStatus("Connected");
            isOnGoingCallView();
          }

          final index = callerList.indexWhere((e) => e.identity == p);
          callkitLogger.info("[MirrorFly][OutgoingCallController] #onConnected: Updating participantId: $p at index: $index");

          if (index != -1) {
            final old = callerList[index];
            callerList[index] = old.copyWith(
              flyCallStatus: FlyCallStatusEvent.connected,
            );
          } else {
            callkitLogger.info("[MirrorFly][OutgoingCallController] #onConnected: ParticipantId: $p not found in callerList, adding new entry");
            updateCallerStatusList(participantsId: participantIds,status: FlyCallStatusEvent.connected);
          }

          callerList.refresh();
        } else {
          callkitLogger.info("[MirrorFly][OutgoingCallController] #onConnected: Skipping self id: $p, callerList length: ${callerList.length}");
          final index = callerList.indexWhere((e) => e.identity == p);
          callkitLogger.info("[MirrorFly][OutgoingCallController] #onConnected: Updating local participant at index: $index");
          final old = callerList[index];
          callerList[index] = old.copyWith(
            flyCallStatus: FlyCallStatusEvent.connected,
          );
        }
      }
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] #onConnected for group call");
      final bool isUserOnHold = callerList.any((p) => participantIds.contains(p.identity) &&
          p.flyCallStatusEvent == FlyCallStatusEvent.callHold);
      if (isUserOnHold) {
        callkitLogger.info("[MirrorFly][OutgoingCallController] #onConnected: Users on hold found, updating their status to connected");
        updateCallerStatusList(participantsId: participantIds, status: FlyCallStatusEvent.connected);
        return;
      } else {
        callkitLogger.info("[MirrorFly][OutgoingCallController] #onConnected: No users on hold, skipping update");
      }

      if (!isOnGoingCallViewEnable.value) {
        callkitLogger.info("[MirrorFly][OutgoingCallController] #onConnected for group call, enabling ongoing call view");
        // callStatus("Connected");
        for (var p in participantIds) {
          if (!isSelfId(id: p) && !isOnGoingCallViewEnable.value) {
            callkitLogger.info(
                "[MirrorFly][OutgoingCallController] #onConnected for one to one call");
            callStatus("Connected");
            isOnGoingCallView();
          }
        }
      }

      updateCallerStatusList(participantsId: participantIds,status: FlyCallStatusEvent.connected);
    }

    if (isMeet.value) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] #onConnected: Call mode is MEET, skipping toast and name fetch");
      for (var p in participantIds) {
        if (!isSelfId(id: p)) {
          final String userJid = CallUtils.getJidFromUserId(userId: p, isGroup: false);
          final ProfileDetails profileDetails = await getProfileDetails(userJid);
          final String name = profileDetails.name ?? "";
          callkitLogger.info("[MirrorFly] #OutgoingCallController #onConnected #name: $name joined ");
          toToast("$name joined");
        }
      }
    }

    await _getCallRemoteUserName();
    getCallMembersName(id: participantIds);
    await initCallViewIds();
  }

  void disconnectCall({required List<String> userIds, required String reason}) {
    if (userIds.isEmpty) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] #disconnectCall: No userIds");
      _endCallAndExit(reason);
      return;
    }

    final String userId = userIds.firstOrNull ?? "";
    final bool isLocalHangup = isSelfId(id: userId);
    callkitLogger.info("[MirrorFly][OutgoingCallController] #disconnectCall userId=$userId reason=$reason");

    // Group call disconnect
    if (callerList.length > 2) {
      _handleGroupCallDisconnect(userId, reason);
      return;
    }

    if (isMeet.value && !isLocalHangup) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] #disconnectCall Meet remote left");

      callerList.removeWhere((e) => e.identity == userId);
      final String name = remoteUserNameMap[userId] ?? "";
      remoteUserNameMap.remove(userId);

      toToast("$name is left");
      _getCallRemoteUserName();

      isOnGoingCallViewEnable.value = false;
      return;
    }

    callkitLogger.info("[MirrorFly][OutgoingCallController] #disconnectCall One-One call ending");
    _endCallAndExit(reason);
  }

  void _handleGroupCallDisconnect(String userId, String reason) {
    callkitLogger.info("[MirrorFly][OutgoingCallController] #disconnectCall Group call disconnect");

    final bool isLocalHangup = isSelfId(id: userId);
    if (isLocalHangup) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] #disconnectCall Local hangup");
      _endCallAndExit(reason);
      return;
    }

    callerList.removeWhere((e) => e.identity == userId);

    final String name = remoteUserNameMap[userId] ?? "";
    remoteUserNameMap.remove(userId);
    if (isMeet.value) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] #disconnectCall Meet remote left, showing toast for $name");
      toToast("$name is left");
    }
    initCallViewIds();

    callkitLogger.info("[MirrorFly][OutgoingCallController] #disconnectCall removed userId=$userId len=${callerList.length}");
    _getCallRemoteUserName();

    if (callerList.length <= 1 && !isMeet.value) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] #disconnectCall Last user left");
      _endCallAndExit(reason);
      return;
    }

    if (callerList.length <= 1 && isMeet.value) {
      isOnGoingCallViewEnable.value = false;
    }
    callkitLogger.info("[MirrorFly][OutgoingCallController] #disconnectCall call still ongoing");
  }

  void _endCallAndExit(String reason) {
    _resetValues();
    closeDialog();

    if (isAudioDialogOpen.value) {
      callkitLogger.info("[MirrorFly] #disconnectCall Closing audio dialog");
      Get.back();
      isAudioDialogOpen.value = false;
    }

    if (NavUtils.currentRoute == Routes.callKitParticipantView) {
      NavUtils.back();
      NavUtils.back();
    } else if (NavUtils.currentRoute == Routes.callKitOutGoingCallView) {
      callStatus("Disconnected");

      // reason == "reconnectAttemptsExceeded"
      //     ? toToast("Reconnection attempt exceeded")
      //     : toToast("Call Disconnected");

      NavUtils.back();
    } else if (NavUtils.currentRoute == Routes.contacts) {
      NavUtils.back();
      NavUtils.back();
    }
    toToast("Call Disconnected");
    CallStateService.stop();
  }

  void isOnGoingCallView() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] isOnGoingCallViewEnable.value = true");
    isOnGoingCallViewEnable.value = true;
  }

  void setMicroPhoneEnabled({required bool enabled}) async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] muteAudio start with mute : $enabled");
    MirrorFlyCallKit.setMicrophoneMuted(
      mute: enabled,
      result: ({
        required bool success,
        bool? isMuted,
        required String message,
        required int code
      }) {
        callkitLogger.info("[MirrorFly][OutgoingCallController] Mute ON result → success=$success, isMuted=$isMuted, message=$message");
        if (success && isMuted != null) {
          callkitLogger.info("[MirrorFly][OutgoingCallController] muteAudio : $isMuted, and setting isAudioEnabled to ${!isMuted}");
          isAudioMuted.value = isMuted;

          // For group calls when local user mutes the audio we need to update the
          // caller list to reflect the change in the UI, as the local participant is also part of the caller list in group calls
          if (callMode.value == "ONE-TO-MANY") {
            callkitLogger.info("[MirrorFly][OutgoingCallController] muteAudio: Updating callerList for ONE-TO-MANY call");
            final localIndex = callerList.indexWhere((p) => p.isLocalParticipant);
            if (localIndex != -1) {
              final old = callerList[localIndex];
              callerList[localIndex] = old.copyWith(isAudioMuted: isMuted);
              callkitLogger.info("[MirrorFly][OutgoingCallController] muteAudio: Updated local participant mute status to $isMuted in callerList");
            } else {
              callkitLogger.info("[MirrorFly][OutgoingCallController] muteAudio: Local participant not found in callerList");
            }
          }

        } else {
          if (code == FlyCallErrorCode.microPhonePermissionDenied || code == FlyCallErrorCode.microPhonePermissionPermanentlyDenied) {
            toToast(message);
          }
          callkitLogger.info("[MirrorFly][OutgoingCallController]  Error muteAudio status  result → success=$success, message=$message");
        }
      },
    );
  }

  void setCameraEnable({required bool enable}) async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable start");
    final FlyCallType? flyCallType = MirrorFlyCallKit.getCurrentCallType();

    if (flyCallType == null) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable: Unable to get current call type.");
      return;
    }

    final bool callStatus = await MirrorFlyCallKit.isCallConnected();
    final isMeetCall = MirrorFlyCallKit.getCurrentCallMode() == "MEET";

    if (flyCallType == FlyCallType.audio && callStatus && !isMeetCall) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable: Current call is not a video call, so requesting to switch video call. callStatus- $callStatus");
      requestVideoCallSwitch();
      return;
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable: Current call type is $flyCallType callStatus $callStatus");
    }

    callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable: value : $enable");

    MirrorFlyCallKit.setCameraEnable(
      enable: enable,
      result: ({
        required bool success,
        required String message,
        required int code,
      }) async {
        if (success) {
          callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable : $success");
          isVideoEnabled.value = enable;
          final localIndex = callerList.indexWhere((p) => p.isLocalParticipant);
          if (localIndex != -1) {
            final old = callerList[localIndex];
            callerList[localIndex] = old.copyWith(isAudioMuted: !enable);
            callkitLogger.info("[MirrorFly][OutgoingCallController] muteVideo: Updated local participant mute status to ${!enable} in callerList");
          } else {
            callkitLogger.info("[MirrorFly][OutgoingCallController] muteVideo: Local participant not found in callerList");
          }
        } else {
          if (code == FlyCallErrorCode.cameraPermissionDenied || code == FlyCallErrorCode.cameraPermissionPermanentlyDenied) {
            toToast(message);
          }
          callkitLogger.info("[MirrorFly][OutgoingCallController] Error setCameraEnable status → success: $success message: $message code: $code");
        }
      },
    );
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

    callkitLogger.info("[MirrorFly][OutgoingCallController] remoteUserIsEngaged with participants: $participants,");

    if (callerList.isEmpty) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] remoteUserIsEngaged: No participants found");
      return;
    }

    callkitLogger.info("[MirrorFly][OutgoingCallController] remoteUserIsEngaged: "
        "Checking current call user list, items: ${callerList.map((p) => p.identity).toList()}");

    callkitLogger.info("[MirrorFly][OutgoingCallController] remoteUserIsEngaged ,"
        " participantsList: ${callerList.map((p) => '${p.identity}: ${p.flyCallStatusEvent}').toList()}");

    if (callerList.length > 2) {
      /// One - Many call user engaged logic
      callkitLogger.info("[MirrorFly][OutgoingCallController] Group call is ongoing, skipping single user engaged logic");

      if (callerList.firstWhereOrNull((e) => e.identity == participants.first)?.flyCallStatusEvent != FlyCallStatusEvent.engaged) {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] remoteUserIsEngaged: The specified participant is not engaged, so removing the user");
        callerList.removeWhere((e) => e.identity == participants.firstOrNull);
        callerList.refresh();
        callkitLogger.info("[MirrorFly][OutgoingCallController] remoteUserIsEngaged: callerList length : ${callerList.length}");
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
          _resetValues();
          return;
        } else {
          _getCallRemoteUserName();
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
        CallStateService.stop();
      }
      _resetValues();
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
      // Write back to service so position survives PIP cycles.
      _svc.cameraPosition.value = cameraPosition.value;
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
      debugPrint("$e $stack");
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

    if(callerList.length >= 3){
      callkitLogger.info("[MirrorFly][OutgoingCallController] requestVideoCallSwitch: Call switch  supported in group calls.");
      await MirrorFlyCallKit.toggleVideoForGroupCall();
      isVideoEnabled.value = toggleVideoEnabledStatus;
      return;
    }

    final bool callStatus = await MirrorFlyCallKit.isCallConnected();
    final FlyCallType? flyCallType = MirrorFlyCallKit.getCurrentCallType();
    final isMeetCall = MirrorFlyCallKit.getCurrentCallMode() == "MEET";

    callkitLogger.info("MirrorFlyCallKit.getVideoMuteStatus(userJid: getRemoteParticipantIdForOneToOneCall()) called ${MirrorFlyCallKit.getVideoMuteStatus(userJid: getRemoteParticipantIdForOneToOneCall())}");

    if (flyCallType == FlyCallType.audio && callStatus) {
      callkitLogger.info("[MirrorFly][OutgoingCallController]  makeCallSwitch invoked...");
      if(await MirrorFlyCallKit.validateSwitchRequest() && !isMeetCall) {
        _videoCallSwitchRequestConfirmationPopup();
      } else {
        MirrorFlyCallKit.setCameraEnable(
          enable: toggleVideoEnabledStatus,
          result: ({
            required bool success,
            required String message,
            required int code,
          }) {
            if (success) {
              callkitLogger.info("[MirrorFly][OutgoingCallController] setCameraEnable : $success");
              isVideoEnabled.value = toggleVideoEnabledStatus;
            } else {
              if (code == FlyCallErrorCode.cameraPermissionDenied || code == FlyCallErrorCode.cameraPermissionPermanentlyDenied) {
                toToast(message);
              }
              callkitLogger.info("[MirrorFly][OutgoingCallController] Error setCameraEnable status → success: $success message: $message code: $code");
            }
          },
        );
      }
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] Current call is not an audio call or call is not connected, cannot switch to video. callStatus- $callStatus, flyCallType- $flyCallType");
    }
  }

  ///
  void cancelVideoCallSwitchRequest() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController]  cancelVideoCallSwitch invoked...");
    await MirrorFlyCallKit.cancelVideoCallSwitchRequest();
    // toToast("Video call switch canceled");
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
    _svc.lastCallSwitchEvent.value = null;
    await MirrorFlyCallKit.declineIncomingVideoCallSwitchRequest();
    closeDialog();
  }

  ///

  void onVideoCallSwitchAccept() {
    onVideoCallSwitchRequestAccepted();
    processCallSwitchUI();
  }

  void onVideoCallSwitchTimeOut({required bool isIncomingTimeout}) {
    callkitLogger.info("[MirrorFly][OutgoingCallController] onVideoCallSwitchTimeOut called, isIncomingTimeout: $isIncomingTimeout");
    closeDialog();
    if (isIncomingTimeout) {
      return;
    } else {
      final String remoteId = getRemoteParticipants().firstOrNull?.identity ?? "";
      final remoteUserName = remoteUserNameMap[remoteId] ?? "";
      toToast(getTranslated("noResponseFrom").replaceFirst("%d", remoteUserName));
    }
  }

  ///
  void processCallSwitchUI() async {
    callkitLogger.info("[MirrorFly][OutgoingCallController] Processing call switch UI changes...");
    final FlyCallType? flyCallType = MirrorFlyCallKit.getCurrentCallType();
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
      /// Apply AudioContext ONLY for Android
      /// iOS → DO NOT override audio session (let LiveKit handle it)
      if (Platform.isAndroid) {
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
      }


      await _player?.setVolume(1.0);
      await _player?.setReleaseMode(ReleaseMode.loop);
      await _player?.play(AssetSource('sounds/reconnecting.mp3'));

      await Future.delayed(const Duration(milliseconds: 300));

      final state = _player?.state;
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController] Player state after play(): $state");

      if (state == PlayerState.playing) {
        _isPlaying = true;
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] Ringtone is playing!");
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] Not playing, state=$state");
      }

      callkitLogger.info(
          "[MirrorFly][OutgoingCallController][DEBUG] AudioPlayer started playing");
    } catch (e) {
      callkitLogger.info(
          "[MirrorFly][OutgoingCallController][DEBUG] Failed to play ringtone: $e");
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

    if (MirrorFlyCallKit.getCurrentCallType() == FlyCallType.video) {
      return;
    }

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
      // NavUtils.back();
      Get.back();
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

    if(NavUtils.previousRoute == Routes.callKitParticipantView){
      NavUtils.back();
      NavUtils.back();
    } else if(NavUtils.currentRoute == Routes.callKitParticipantView){
      NavUtils.back();
      NavUtils.back();
    } else if (NavUtils.currentRoute == Routes.callKitOutGoingCallView) {
      NavUtils.back();
    }
    toToast("Call Disconnected");
    CallStateService.stop();
    return;
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

    final inviteUser = NavUtils.toNamed(
        Routes.callKitParticipantView,
        arguments: {
          "joinViaLink": false,
          "meet": isMeet.value,
          "callList": callerList,
        });
    List<String> invitedUsers = await inviteUser;
    for(var i in invitedUsers) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] inviteParticipants: add invite partcipant $i");
      // final addInviteUser = FlyCallParticipant(identity: i, isLocalParticipant: false,flyCallStatusEvent: FlyCallStatusEvent.calling,flyCallActionEvent: null);
      // callerList.add(addInviteUser);
    }
    updateCallerStatusList(participantsId: invitedUsers ,status: FlyCallStatusEvent.calling);
    // callerList.refresh();
    getCallMembersName(id: invitedUsers);
    _getCallRemoteUserName();
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
  // void onParticipantListUpdated() async {

    // callkitLogger.info(
    //     "[MirrorFly][OutgoingCallController] onCallModeChanged called with callMode");
    // final preCallUserListCount = callerList.length;
    // callkitLogger.info(
    //     "[MirrorFly][OutgoingCallController] onCallModeChanged preCallUserListCount: $preCallUserListCount");
    // await getCurrentCallParticipants();
    //
    // callkitLogger.info(
    //     "[MirrorFly][OutgoingCallController] onCallModeChanged fetched callerList with length: ${callerList.length}");
    //
    // if (preCallUserListCount > 2) {
    //   final (bool isIncomingSwitchAvailable, bool isOutgoingSwitchAvailable) result = await MirrorFlyCallKit.getIsSwitchCallRequestOngoing();
    //   final isDialogOpen = DialogUtils.isDialogOpen() && NavUtils.canPop;
    //
    //   callkitLogger.info("[MirrorFly][OutgoingCallController] onCallModeChanged"
    //       " isIncomingSwitchAvailable: ${result.$1},"
    //       " isOutgoingSwitchAvailable: ${result.$2}"
    //       " isDialogOpen: $isDialogOpen");
    //
    //   if (result.$2 && isDialogOpen) {
    //     // Switch is in progress
    //     cancelVideoCallSwitchRequest();
    //     callkitLogger.info("[MirrorFly][OutgoingCallController] onCallModeChanged closed"
    //         " outgoing call switch dialog due to call mode change");
    //   } else if (isDialogOpen) {
    //     // dialog only opened not yet switch started
    //     NavUtils.back();
    //     callkitLogger.info("[MirrorFly][OutgoingCallController] Dialog closed");
    //   } else {
    //     callkitLogger.info("[MirrorFly][OutgoingCallController] No dialog to close");
    //   }
    // }
    //
    // await configureCallMode(
    //     callMode: callerList.length > 2 ? "ONE-TO-MANY" : "ONE-TO-ONE",
    //     chatId: groupId.value);
    //
    // callkitLogger.info("[MirrorFly][OutgoingCallController] onCallModeChanged updated "
    //     "local callMode: ${callMode.value}, isGroupCall: ${isGroupCall.value} "
    //     "isGroupOnGoingCallEnabled: ${isGroupOnGoingCallEnabled.value}");
    //
    // if(!isGroupCall.value){
    //   isGroupOnGoingCallEnabled(!(callerList.length <= 2));
    //   isCallModeChangedToOneToMany(!(callerList.length <= 2));
    // }
    // if(isOnGoingCallViewEnable.value){
    //   isGroupOnGoingCallEnabled(!(callerList.length <= 2));
    // }
    //
    //
    // callkitLogger.info(
    //     "[MirrorFly][OutgoingCallController] onCallModeChanged completed, fetching current call"
    //         " participants..., with isGroupOnGoingCallEnabled: ${isGroupOnGoingCallEnabled.value}, "
    //         "isCallModeChangedToOneToMany: ${isCallModeChangedToOneToMany.value}");
    // await getCallMembersName();
    // getCallTitleForOneToManyCall();
    // await initCallViewIds();
    // await moveLocalParticipantToLast();
    // await _getCallRemoteUserName();
  // }
    // ///



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

    if (participantsId.contains(userId)) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] callHold: Participant $userId is in the provided participantsId list.");
      isLocalUserOnHold.value = true;
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] callHold: Participant $userId is NOT in the provided participantsId list.");
    }

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

    if (participantsId.contains(userId)) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] callResume: Participant $userId is in the provided participantsId list.");
      isLocalUserOnHold.value = false;
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] callResume: Participant $userId is NOT in the provided participantsId list.");
    }

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

    if (participant?.isAudioMuted == true) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] onActiveSpeakerChange: "
          "Participant $participantId is audio muted, ignoring speaker change");
      callerAudioLevel[participantId] = 0;
      callerAudioLevel.refresh();
      return;
    }

    if (participant != null) {
      callerAudioLevel[participantId] = audioLevel;
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
    isLocalTracksPublished(false);
    isRemoteTracksPublished(false);
    isManualDeviceSelected(false);
    callTryStatus("");
    groupId("");
    callerList.clear();
    callAgainUserList.clear();
    remoteUserNameMap({});
    // isGroupCall(false);
    // chatNameForGroupCall("");
    // isGroupOnGoingCallEnabled(false);
    // groupCallTitle("");
    isCallModeChangedToOneToMany(false);
    titleAfterCallModeChange("");
    _isPlaying = false;
    mainCallViewUserId.value = "";
    secondaryCallViewUserId.value = "";
    currentCallMode.value = "";
    isMeet.value = false;
    isSwapped.value = false;
    isLocalUserOnHold.value = false;
    callkitLogger.info("[MirrorFly][OutgoingCallController] _resetValues");
  }

  void videoSwap() {
    callkitLogger.info("[MirrorFly][OutgoingCallController] videoSwap called with isOnGoingCallViewEnable: ${isOnGoingCallViewEnable.value}, callerList length: ${callerList.length}");
    if (isOnGoingCallViewEnable.value && callerList.length == 2) {
      isSwapped.value = !isSwapped.value;
      callkitLogger.info("[MirrorFly][OutgoingCallController] videoSwap: isSwapped updated to ${isSwapped.value}");
    } else {
      callkitLogger.info("[MirrorFly][OutgoingCallController] videoSwap: Swap not allowed, either not in ongoing call view or callerList length is not 2");
    }
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
        pipWindowWidth: AppUtils.getSizeFromAspectRatio(NavUtils.width, NavUtils.height).width * 0.7,
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
