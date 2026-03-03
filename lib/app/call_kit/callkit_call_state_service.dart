import 'dart:async';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../call_modules/call_utils.dart';
import '../common/constants.dart';
import '../data/utils.dart';
import '../routes/route_settings.dart';

// ---------------------------------------------------------------------------
// Signal emitted by the service when the call ends, so the UI controller
// can perform navigation without the service knowing about routes.
// ---------------------------------------------------------------------------
enum CallEndReason { disconnected, timedOut, callFailed }

extension CallEndExtString on CallEndReason {
  String get endReasonStringValue {
    switch(this) {
      case CallEndReason.disconnected:
        return "disconnected";
      case CallEndReason.timedOut:
        return "timedOut";
      case CallEndReason.callFailed:
        return "callFailed";

    }
  }

}

class CallEndSignal {
  final CallEndReason reason;
  final List<String> userIds;
  final String detail; // raw reason string from SDK
  final bool isCallFailed;

  const CallEndSignal({
    required this.reason,
    required this.userIds,
    this.detail = '',
    this.isCallFailed = false,
  });
}

// ---------------------------------------------------------------------------
// CallStateService — single source of truth for call state.
//
// Lifecycle:
//   CallStateService.start()  → call initiated / answered
//   CallStateService.stop()   → call fully ended
//
// Both CallKitOutgoingCallController and CallKitPipController read state
// from this service.  SDK events flow:
//
//   SDK → BaseController → CallStateService  (via buffer or directly)
//                               │
//                         reactive Rx state
//                          ┌────┴────┐
//                 UI Controller    PIP Controller
// ---------------------------------------------------------------------------
class CallStateService extends GetxService {

  // ── Singleton helpers ──────────────────────────────────────────────────
  static CallStateService get instance => Get.find<CallStateService>();

  static bool get isRegistered => Get.isRegistered<CallStateService>();

  /// Start the service.  Must be called before navigating to the call screen.
  static Future<CallStateService> start() async {
    if (!isRegistered) {
      callkitLogger.info('[CallStateService] starting service');
      return Get.putAsync<CallStateService>(() async => CallStateService());
    }
    callkitLogger.info('[CallStateService] already running, reusing instance');
    return instance;
  }

  /// Stop and clean up the service when the call ends.
  static void stop() {
    if (isRegistered) {
      callkitLogger.info('[CallStateService] stopping service');
      Get.delete<CallStateService>(force: true);
    }
  }

  // ── Call type / mode / identity ─────────────────────────────────────────
  RxString callType = ''.obs;           // "audio" | "video"
  RxString groupId = ''.obs;
  RxString callMode = ''.obs;
  RxString currentCallMode = ''.obs;
  final RxBool isIncoming = false.obs;
  FlyCallKind callKind = FlyCallKind.standard;
  RxBool isMeet = false.obs;

  // ── Participant list ─────────────────────────────────────────────────────
  var callerList = <FlyCallParticipant>[].obs;
  RxMap<String, String> remoteUserNameMap = <String, String>{}.obs;
  RxMap<String, double> callerAudioLevel = <String, double>{}.obs;
  RxMap<String, FlyConnectionQuality?> callerConnectionQuality =
      <String, FlyConnectionQuality?>{}.obs;

  // ── Call status ──────────────────────────────────────────────────────────
  var callStatus = 'Trying to connect'.obs;
  var callTryStatus = ''.obs;

  // ── Media state ──────────────────────────────────────────────────────────
  RxBool isVideoEnabled = false.obs;
  RxBool isAudioMuted = false.obs;
  RxBool speakerOn = false.obs;
  RxBool isRemoteVideoMuted = true.obs;
  RxString cameraPosition = CameraType.front.obs;
  final RxBool cameraSwitch = false.obs;
  final RxBool isManualDeviceSelected = false.obs;
  RxString selectedDeviceType = ''.obs;
  var availableTypes = <FlyAudioDevice>[].obs;
  final String audioRoutingTag = '[AUDIO_ROUTING]';

  // ── Track publication ────────────────────────────────────────────────────
  final RxBool isLocalTracksPublished = false.obs;
  final RxBool isRemoteTracksPublished = false.obs;

  // ── View state ───────────────────────────────────────────────────────────
  RxBool showControls = true.obs;
  RxBool isOnGoingCallViewEnable = false.obs;
  RxBool isGroupCall = false.obs;
  RxBool isGroupOnGoingCallEnabled = false.obs;
  RxBool isCallModeChangedToOneToMany = false.obs;
  RxString titleAfterCallModeChange = ''.obs;
  RxString chatNameForGroupCall = ''.obs;
  RxString groupCallTitle = ''.obs;
  RxString getOneToOneCallRemoteUserName = ''.obs;
  RxString mainCallViewUserId = ''.obs;
  RxString secondaryCallViewUserId = ''.obs;

  // ── Audio dialog ──────────────────────────────────────────────────────────
  final RxBool isAudioDialogOpen = false.obs;

  // ── Call again list ───────────────────────────────────────────────────────
  var callAgainUserList = <String>[].obs;

  // ── Call duration / timer ──────────────────────────────────────────────
  var callDuration = ''.obs;
  StreamSubscription<String>? _timerSubscription;

  // ── Navigation signal ─────────────────────────────────────────────────
  /// The UI controller `ever()`-listens to this to handle navigation when
  /// the call ends (disconnect, timeout, failed).  The service never touches
  /// routes directly.
  final Rxn<CallEndSignal> callEndSignal = Rxn<CallEndSignal>();

  /// Raw SDK status event — subscribers can `ever()` this to call their own
  /// methods when a new status arrives (e.g. CallKitOutgoingCallController).
  final Rxn<FlyCallStatus> lastStatusEvent = Rxn<FlyCallStatus>();

  /// Raw SDK action event — subscribers can `ever()` this to call their own
  /// methods when a new action arrives.
  final Rxn<FlyCallAction> lastActionEvent = Rxn<FlyCallAction>();

  /// Persists the most recent call-switch event (outgoingRequest, incomingRequest,
  /// accept, decline, cancel, timeout) so the controller can replay it when
  /// PIP is expanded and the controller is recreated. Cleared after the
  /// controller handles it.
  final Rxn<FlyCallAction> lastCallSwitchEvent = Rxn<FlyCallAction>();

  // =========================================================================
  // Lifecycle
  // =========================================================================

  @override
  Future<void> onInit() async {
    callkitLogger.info('[CallStateService] onInit');
    getCurrentCallParticipants();
    // Listen to the SDK call timer — same source as CallKitOutgoingCallController.
    // No separate Timer needed; the SDK manages the clock.
    _timerSubscription = MirrorFlyCallKit.flyCallTimer.listen((timer) {
      callDuration.value = timer;
      callkitLogger.info('[CallStateService] flyCallTimer tick: $timer');
    });
    super.onInit();
  }

  @override
  void onClose() {
    callkitLogger.info('[CallStateService] onClose — cancelling timer subscription');
    _timerSubscription?.cancel();
    _timerSubscription = null;
    super.onClose();
  }

  // =========================================================================
  // SDK Event Handler Methods  (called by BaseController / EventBuffer)
  // =========================================================================

  void tryingToConnect() {
    callStatus('Trying to connect...');
    callkitLogger.info('[CallStateService] tryingToConnect');
  }

  void connecting({List<String>? participantsId}) {
    callStatus('Connecting...');
    updateCallerStatusList(
        participantsId: participantsId,
        status: FlyCallStatusEvent.connecting);
    callkitLogger.info('[CallStateService] connecting');
  }

  void ringing({List<String>? participantsId}) {
    callStatus('Ringing...');
    updateCallerStatusList(
        participantsId: participantsId,
        status: FlyCallStatusEvent.ringing);
    callkitLogger.info('[CallStateService] ringing');
  }

  void outGoingCallCalling({List<String>? participantsId}) {
    callStatus('Calling...');
    updateCallerStatusList(
        participantsId: participantsId,
        status: FlyCallStatusEvent.calling);
    callkitLogger.info('[CallStateService] outGoingCallCalling');
  }

  void onConnected(List<String> participantIds) async {
    callkitLogger.info(
        '[CallStateService] onConnected participantIds=$participantIds');

    if (!isGroupCall.value) {
      final bool isUserOnHold = callerList.any((p) =>
          participantIds.contains(p.identity) &&
          p.flyCallStatusEvent == FlyCallStatusEvent.callHold);
      if (!isUserOnHold) {
        callStatus('Connected');
        isOnGoingCallViewEnable.value = true;
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] onConnected: No users on hold, skipping update");
      }

      for (var p in participantIds) {
        if (!isSelfId(id: p)) {
          final index = callerList.indexWhere((e) => e.identity == p);
          if (index != -1) {
            final old = callerList[index];
            callerList[index] =
                old.copyWith(flyCallStatus: FlyCallStatusEvent.connected);
          } else {
            updateCallerStatusList(
                participantsId: participantIds,
                status: FlyCallStatusEvent.connected);
          }
          callerList.refresh();
        }
      }
      if (!isUserOnHold) {
        // timer runs automatically via flyCallTimer stream
      }
    } else {
      final bool isUserOnHold = callerList.any((p) =>
          participantIds.contains(p.identity) &&
          p.flyCallStatusEvent == FlyCallStatusEvent.callHold);
      if (!isUserOnHold) {
        callStatus('Connected');
        isOnGoingCallViewEnable.value = true;
        updateCallerStatusList(
            participantsId: participantIds,
            status: FlyCallStatusEvent.connected);
        if (!isGroupOnGoingCallEnabled.value) {
          isGroupOnGoingCallEnabled.value = true;
        }
        // timer runs automatically via flyCallTimer stream
      } else {
        callkitLogger.info(
            "[MirrorFly][OutgoingCallController] onConnected: Users on hold found, updating their status to connected");

        updateCallerStatusList(
            participantsId: participantIds,
            status: FlyCallStatusEvent.connected);
      }
    }
  }

  void reconnecting({required List<String> participantIds}) {
    callkitLogger.info(
        '[CallStateService] reconnecting participantIds=$participantIds');
    for (final id in participantIds) {
      final index = callerList.indexWhere((e) => e.identity == id);
      if (index != -1) {
        final target = callerList[index];
        callerList[index] = target.copyWith(
            isReconnecting: true,
            flyCallStatus: FlyCallStatusEvent.reconnecting);
      }
    }
    callerList.refresh();
  }

  void reconnected({required List<String> participantIds}) {
    callkitLogger.info(
        '[CallStateService] reconnected participantIds=$participantIds');
    for (final id in participantIds) {
      final index = callerList.indexWhere((e) => e.identity == id);
      if (index != -1) {
        final target = callerList[index];
        if (target.isReconnecting == true) {
          callerList[index] = target.copyWith(
              isReconnecting: false,
              flyCallStatus: FlyCallStatusEvent.reconnected);
          callkitLogger.info(
              '[CallStateService] reconnected updated participant id=$id status set to reconnected');
        } else {
          callkitLogger.info(
              "[MirrorFly] → Participant $id was not in reconnecting state");
        }
        if (target.isLocalParticipant) {
          callerList[index] = target.copyWith(
              isReconnecting: false,
              flyCallStatus: FlyCallStatusEvent.reconnected);
          callStatus('Connected');
          callTryStatus('Connected');
          callkitLogger.info(
              '[CallStateService] reconnected local participant id=$id status set to reconnected, call status set to Connected');
        }
      } else {
        callkitLogger.info(
            "[MirrorFly] → No participant found in callerList for id: $id");
      }
    }
    callerList.refresh();
  }

  void isAudioMute({
    required bool isAudioMuted,
    required String? participantId,
  }) {
    final index = callerList.indexWhere((p) => p.identity == participantId);
    callkitLogger.info(
        '[CallStateService] isAudioMute participantId=$participantId isAudioMuted=$isAudioMuted index=$index');

    if (index.isNegative) {
      callkitLogger.info("[Controller] isAudioMute: No participant found for id: $participantId");
      return;
    }

    final updated = callerList[index].copyWith(isAudioMuted: isAudioMuted);
    callerList.value = List.from(callerList)..[index] = updated;

    if (participantId == getLocalParticipant()?.identity) {
      callkitLogger.info("[Controller] isAudioMute: Updating local audio mute status to $isAudioMuted");
      this.isAudioMuted(isAudioMuted);
    } else {
      callkitLogger.info("[Controller] isAudioMute: Received for Remote participantId: $participantId");
    }

    callkitLogger.info("[Controller] isAudioMute: Updated ${updated.identity} mute status to $isAudioMuted");
  }

  void isVideoMute(
      {required bool isVideoMuted, required String? participantId}) {
    callkitLogger.info(
        '[CallStateService] isVideoMute participantId=$participantId isVideoMuted=$isVideoMuted');
    if (isSelfId(id: participantId)) {
      callkitLogger.info("[Controller] Updating local video mute status to $isVideoMuted");
      isVideoEnabled.value = isVideoMuted;
    } else {
      callkitLogger.info("[Controller] Updating remote video mute status to $isVideoMuted");
      isRemoteVideoMuted.value = isVideoMuted;
    }
  }

  void audioCallAfterCallSwitch() {
    callkitLogger
        .info('[CallStateService] audioCallAfterCallSwitch → audio call');
    callType.value = 'audio';
  }

  void callHold({required List<String> participantsId}) {
    callkitLogger.info(
        '[CallStateService] callHold participantsId=$participantsId');
    if (participantsId.isEmpty) return;
    final userId = participantsId.firstOrNull ?? '';
    updateCurrentCallParticipant(
        id: userId, status: FlyCallStatusEvent.callHold);
    if (callMode.string == 'ONE-TO-ONE') {
      callStatus('On Hold');
    }
  }

  void callResume({required List<String> participantsId}) {
    callkitLogger.info(
        '[CallStateService] callResume participantsId=$participantsId');
    if (participantsId.isEmpty) return;
    final userId = participantsId.firstOrNull ?? '';
    updateCurrentCallParticipant(
        id: userId, status: FlyCallStatusEvent.connected);
    if (callMode.string == 'ONE-TO-ONE') {
      callStatus('');
    }
  }

  void onActiveSpeakerChange(
      {required bool isSpeaking,
      required double audioLevel,
      required String participantId}) {
    callerAudioLevel[participantId] = isSpeaking ? audioLevel : 0;
    callerAudioLevel.refresh();
  }

  void onConnectionQualityUpdated(
      {FlyConnectionQuality? quality, String? participantId}) {
    if (participantId == null || quality == null) return;
    callerConnectionQuality[participantId] = quality;
  }

  void onAudioRouteChanged(FlyAudioDevice flyAudioDevice) async {
    callkitLogger.info(
        '$audioRoutingTag [CallStateService] onAudioRouteChanged flyAudioDevice=$flyAudioDevice');
    availableTypes.value = await MirrorFlyCallKit.getAvailableAudioRoutes();
    selectedDeviceType.value = flyAudioDevice.type.value;
  }

  // ── Disconnect / timeout / failed ─────────────────────────────────────

  /// Called by BaseController when the SDK fires a disconnect event.
  /// The service updates state and fires [callEndSignal] so the UI
  /// controller can navigate without the service touching routes.
  void disconnectCall({required List<String> userIds, required String reason}) {
    callkitLogger.info(
        '[CallStateService] disconnectCall userIds=$userIds reason=$reason isGroupCall=${isGroupCall.value} isGroupOnGoingCallEnabled=${isGroupOnGoingCallEnabled.value} isMeet=${isMeet.value}');

    if (userIds.isEmpty) {
      _resetValues();
      callEndSignal.value = CallEndSignal(
        reason: CallEndReason.disconnected,
        userIds: [],
        detail: reason,
      );
      return;
    }

    final String userId = userIds.firstOrNull ?? '';

    if (isGroupCall.value && isGroupOnGoingCallEnabled.value) {
      callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: Group call is ongoing, applying disconnect logic.");

      callerList.removeWhere((e) => e.identity == userId);
      remoteUserNameMap.remove(userId);

      // Check if local user hung up
      final bool isLocalHangup = isSelfId(id: userId);
      if (isLocalHangup) {
        callEndSignal.value = CallEndSignal(
          reason: CallEndReason.disconnected,
          userIds: userIds,
          detail: reason,
        );
        return;
      }

      if (callerList.length <= 1 && !isMeet.value) {
        callEndSignal.value = CallEndSignal(
          reason: CallEndReason.disconnected,
          userIds: userIds,
          detail: reason,
        );
        return;
      }

      if (callerList.length <= 1 && isMeet.value) {
        callkitLogger.info("[MirrorFly][OutgoingCallController] disconnectCall: Only one participant left in a Meet call, so not ending call.");
        isOnGoingCallViewEnable.value = false;
      }
      return;
    }

    // One-to-one call
    // Check if local user hung up
    final bool isLocalHangup = isSelfId(id: userId);
    if (isMeet.value && !isLocalHangup) {
      callerList.removeWhere((e) => e.identity == userId);
      remoteUserNameMap.remove(userId);
      //** _getCallRemoteUserName(); Missing
      isOnGoingCallViewEnable.value = false;
      return;
    }

    _resetValues();
    callEndSignal.value = CallEndSignal(
      reason: CallEndReason.disconnected,
      userIds: userIds,
      detail: reason,
    );
  }

  void callTimeOut(
      {required List<String> participantsId,
      required bool isCallFailed,
      String reason = ''}) {
    callkitLogger.info(
        '[CallStateService] callTimeOut participantsId=$participantsId isCallFailed=$isCallFailed reason=$reason');

    for (final id in participantsId) {
      if (!callAgainUserList.contains(id)) {
        callAgainUserList.add(id);
      }
    }
    for (final id in participantsId) {
      final target = callerList.firstWhereOrNull((p) => p.identity == id);
      if (target != null) callerList.remove(target);
    }

    bool shouldSignal = false;
    if (!isGroupOnGoingCallEnabled.value && isGroupCall.value) {
      shouldSignal = callerList.length <= 1;
    } else if (!isGroupCall.value) {
      shouldSignal = true;
    } else if (callerList.length <= 1) {
      shouldSignal = true;
    }

    if (shouldSignal) {
      callEndSignal.value = CallEndSignal(
        reason:
            isCallFailed ? CallEndReason.callFailed : CallEndReason.timedOut,
        userIds: participantsId,
        detail: reason,
        isCallFailed: isCallFailed,
      );
    }
  }

  void onCallFailed(
      {required List<String>? participantsId, String reason = ''}) {
    callkitLogger.info(
        '[CallStateService] onCallFailed participantsId=$participantsId reason=$reason');
    if (participantsId == null || participantsId.isEmpty) return;
    _resetValues();
    callEndSignal.value = CallEndSignal(
      reason: CallEndReason.callFailed,
      userIds: participantsId,
      detail: reason,
      isCallFailed: true,
    );
  }

  void rejected({required String userId}) {
    callkitLogger.info('[CallStateService] rejected userId=$userId');
    if (isGroupCall.value) {
      callerList.removeWhere((e) => e.identity == userId);
      callerList.refresh();
      if (callerList.length <= 1) {
        callEndSignal.value = CallEndSignal(
          reason: CallEndReason.disconnected,
          userIds: [userId],
          detail: 'rejected',
        );
      }
      return;
    }
    callEndSignal.value = CallEndSignal(
      reason: CallEndReason.disconnected,
      userIds: [userId],
      detail: 'rejected',
    );
  }

  void remoteUserIsEngaged({required List<String> participants}) {
    callkitLogger.info(
        '[CallStateService] remoteUserIsEngaged participants=$participants');
    if (callerList.isEmpty) return;

    if (isGroupCall.value || isGroupOnGoingCallEnabled.value) {
      final first = participants.firstOrNull;
      if (callerList
              .firstWhereOrNull((e) => e.identity == first)
              ?.flyCallStatusEvent !=
          FlyCallStatusEvent.engaged) {
        callerList.removeWhere((e) => e.identity == first);
        final bool allEngaged = callerList
            .where((p) => !p.isLocalParticipant)
            .every((p) => p.flyCallStatusEvent == FlyCallStatusEvent.engaged);
        if (allEngaged && callerList.length > 1) {
          callEndSignal.value = CallEndSignal(
            reason: CallEndReason.disconnected,
            userIds: participants,
            detail: 'allEngaged',
          );
        }
      }
      return;
    }
    callEndSignal.value = CallEndSignal(
      reason: CallEndReason.disconnected,
      userIds: participants,
      detail: 'engaged',
    );
  }

  // =========================================================================
  // Participant helpers
  // =========================================================================

  List<FlyCallParticipant> getCurrentCallParticipants() {
    final participants = MirrorFlyCallKit.getCurrentCallParticipants();
    callkitLogger.info(
        '[CallStateService] getCurrentCallParticipants count=${participants.length}');

    if (participants.isNotEmpty) {
      final existingIds = callerList.map((e) => e.identity).toSet();
      for (final p in participants) {
        if (!existingIds.contains(p.identity)) {
          callerList.add(p);
        } else {
          final index = callerList.indexWhere((c) => c.identity == p.identity);
          final updated =
              callerList[index].copyWith(isAudioMuted: p.isAudioMuted);
          callerList.value = List.from(callerList)..[index] = updated;
        }
      }
      callerList.refresh();
    }
    return participants;
  }

  void updateCallerStatusList({
    List<String>? participantsId,
    FlyCallStatusEvent? status,
  }) async {
    callkitLogger.info(
        '[CallStateService] updateCallerStatusList participantsId=$participantsId status=$status');
    if (participantsId?.isNotEmpty ?? false) {
      for (final id in participantsId ?? []) {
        if (!isSelfId(id: id)) {
          final index = callerList.indexWhere((p) => p.identity == id);
          if (index != -1) {
            final existing = callerList[index];
            callkitLogger.info(
                '[CallStateService] updateCallerStatusList updating existing participant id=$id existingStatus=${existing.flyCallStatusEvent} newStatus=$status');
            callerList[index] = FlyCallParticipant(
              identity: existing.identity,
              isLocalParticipant: existing.isLocalParticipant,
              flyCallStatusEvent: status ?? existing.flyCallStatusEvent,
              flyCallActionEvent: existing.flyCallActionEvent,
            );
          } else {
            callkitLogger.info(
                '[CallStateService] updateCallerStatusList adding new participant id=$id status=$status');
            callerList.add(FlyCallParticipant(
              identity: id,
              isLocalParticipant: false,
              flyCallStatusEvent: status,
              flyCallActionEvent: null,
            ));
          }
        }
      }
      await moveLocalParticipantToLast();
      callerList.refresh();
    }
  }

  Future<void> updateCurrentCallParticipant(
      {required String id, required FlyCallStatusEvent status}) async {
    final index = callerList.indexWhere((p) => p.identity == id);
    if (index != -1) {
      final prev = callerList[index];
      callerList[index] = prev.copyWith(flyCallStatus: status);
      callerList.refresh();
    }
  }

  Future<void> moveLocalParticipantToLast() async {
    final index = callerList.indexWhere((e) => e.isLocalParticipant == true);
    if (index == -1) return;
    final localUser = callerList.removeAt(index);
    callerList.add(localUser);
  }

  // ── Participants query helpers ────────────────────────────────────────────

  FlyCallParticipant? getLocalParticipant() {
    return callerList.firstWhereOrNull((p) => p.isLocalParticipant);
  }

  List<FlyCallParticipant> getRemoteParticipants() {
    return callerList.where((p) => !p.isLocalParticipant).toList();
  }

  String getRemoteParticipantIdForOneToOneCall() {
    return callerList
            .where((p) => !p.isLocalParticipant)
            .map((p) => p.identity)
            .firstOrNull ??
        '';
  }

  // ── Connection state label ────────────────────────────────────────────────

  String getParticipantConnectionState(FlyCallStatusEvent? status) {
    switch (status) {
      case FlyCallStatusEvent.connecting:
        return 'Connecting';
      case FlyCallStatusEvent.disconnected:
        return 'Disconnected';
      case FlyCallStatusEvent.calling:
        return 'Calling';
      case FlyCallStatusEvent.ringing:
        return 'Ringing';
      case FlyCallStatusEvent.tryingToConnect:
        return 'Trying to connect';
      case FlyCallStatusEvent.callHold:
        return 'On Hold';
      case FlyCallStatusEvent.reconnecting:
        return 'Reconnecting';
      default:
        return '';
    }
  }

  // ── Identity helpers ──────────────────────────────────────────────────────

  bool isSelfId({required String? id}) {
    final String? currentUserId = SessionManagement.getUserJID();
    if (currentUserId == null || id == null) return true;
    final String participantId = '$id@xmpp-uikit-qa.contus.us';
    return currentUserId == participantId;
  }

  String validId({required String userId, required bool isGroup}) {
    if (isGroup) {
      return userId.contains('@')
          ? userId
          : '$userId@mix.xmpp-uikit-qa.contus.us';
    }
    return userId.contains('@')
        ? userId
        : '$userId@xmpp-uikit-qa.contus.us';
  }

  String trimAfterAt(String input) {
    return input.split('@').firstOrNull?.trim() ?? '';
  }

  // =========================================================================
  // Call mode / group helpers
  // =========================================================================

  Future<void> configureCallMode(
      {required String callMode, required String chatId}) async {
    callkitLogger.info(
        '[CallStateService] configureCallMode callMode=$callMode chatId=$chatId');
    final bool yes =
        callMode == 'TO-ONE-TO-MANY' || callMode == 'ONE-TO-MANY';
    isGroupCall.value = yes;

    if (yes) {
      if (chatId.isEmpty && callMode == 'ONE-TO-MANY') {
        isCallModeChangedToOneToMany(true);
      }
      getCallTitleForOneToManyCall();
    } else if (callerList.length > 2 && isIncoming.value) {
      isGroupCall.value = true;
      isCallModeChangedToOneToMany(true);
      getCallTitleForOneToManyCall();
    }
  }

  String getCallTitleForOneToManyCall() {
    if (!isGroupCall.value) {
      titleAfterCallModeChange.value = '';
      return '';
    }

    final filteredNames = remoteUserNameMap.entries
        .where((entry) {
          if (isSelfId(id: entry.key)) return false;
          if (entry.value.trim().toLowerCase() == 'you') return false;
          return true;
        })
        .map((e) => e.value.trim())
        .toList();

    final count = filteredNames.length;
    if (count == 0) {
      titleAfterCallModeChange.value = 'You';
      return '';
    }

    String title;
    if (count == 1) {
      title = 'You and ${filteredNames[0]}';
    } else if (count == 2) {
      title = 'You, ${filteredNames[0]} & ${filteredNames[1]}';
    } else {
      final others = count - 1;
      title =
          'You, ${filteredNames[0]} & $others ${others == 1 ? 'other' : 'others'}';
    }

    titleAfterCallModeChange.value = title;
    return title;
  }

  // =========================================================================
  // Reset
  // =========================================================================

  void _resetValues() {
    callkitLogger.info('[CallStateService] _resetValues');
    callType('');
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
    callTryStatus('');
    groupId('');
    callerList.clear();
    callAgainUserList.clear();
    remoteUserNameMap({});
    isGroupCall(false);
    chatNameForGroupCall('');
    isGroupOnGoingCallEnabled(false);
    groupCallTitle('');
    isCallModeChangedToOneToMany(false);
    titleAfterCallModeChange('');
    mainCallViewUserId.value = '';
    secondaryCallViewUserId.value = '';
    currentCallMode.value = '';
    isMeet.value = false;
    callDuration.value = '';
    isAudioMuted.value = false;
  }
}
