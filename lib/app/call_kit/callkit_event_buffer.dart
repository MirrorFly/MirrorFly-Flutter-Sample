
import 'dart:convert';

import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../common/constants.dart';
import 'callkit_call_state_service.dart';
import 'callkit_outgoing_call_controller.dart';

class CallKitEventBuffer {
  static final List<FlyCallStatus> _status = [];
  static final List<FlyCallAction> _actions = [];

  static void addStatus(FlyCallStatus e) {
    callkitLogger.info("Adding status event to buffer: ${e.flyCallStatusEvent} for participants: ${e.participantsIds}");
    _status.add(e);
  }
  static void addAction(FlyCallAction e) {
    callkitLogger.info("Adding action event to buffer: ${e.flyCallEvent} for participant: ${e.participantId}");
    _actions.add(e);
  }

  // ---------------------------------------------------------------------------
  // Primary flush target: CallStateService
  // ---------------------------------------------------------------------------

  /// Flush all buffered events into the [CallStateService].
  /// This is the preferred flush path — called by BaseController once the
  /// service is registered.
  static void flushToService(CallStateService service) {
    if (_status.isEmpty && _actions.isEmpty) {
      callkitLogger.info('No statuses or actions to flush to CallStateService');
      return;
    }

    callkitLogger.info('Flushing ${_status.length} statuses and ${_actions.length} actions to CallStateService');

    for (final s in _status) {
      _dispatchStatusToService(service, s);
    }
    for (final a in _actions) {
      _dispatchActionToService(service, a);
    }
    _status.clear();
    _actions.clear();
  }

  // ---------------------------------------------------------------------------
  // Legacy flush target: CallKitOutgoingCallController (kept for safety)
  // ---------------------------------------------------------------------------

  /// Flush all buffered events into the legacy [CallKitOutgoingCallController].
  /// Kept for backward-compatibility; prefer [flushToService] for new code.
  static void flushTo(CallKitOutgoingCallController c) {

    if (_status.isEmpty && _actions.isEmpty) {
      callkitLogger.info('No statuses or actions to flush to CallKitOutgoingCallController');
      return;
    }

    callkitLogger.info('Flushing ${_status.length} statuses and ${_actions.length} actions to CallKitOutgoingCallController');

    for (final s in _status) {
      _dispatchStatus(c, s);
    }
    for (final a in _actions) {
      _dispatchAction(c, a);
    }
    _status.clear();
    _actions.clear();
  }

  static void flushAllEvents() {
    _status.clear();
    _actions.clear();
    callkitLogger.info('Cleared all buffered statuses and actions in CallKitEventBuffer');
  }

  // ---------------------------------------------------------------------------
  // Dispatch to CallStateService
  // ---------------------------------------------------------------------------

  static Future<void> _dispatchStatusToService(
      CallStateService service,
      FlyCallStatus e,
      ) async {
    callkitLogger.info('Dispatching status event to service: ${e.flyCallStatusEvent} for participants: ${e.participantsIds}');
    switch (e.flyCallStatusEvent) {
      case FlyCallStatusEvent.connecting:
        service.connecting();
        break;
      case FlyCallStatusEvent.connected:
        service.onConnected(e.participantsIds);
        break;
      case FlyCallStatusEvent.ringing:
        service.ringing(participantsId: e.participantsIds);
        break;
      case FlyCallStatusEvent.tryingToConnect:
        service.tryingToConnect();
        break;
      case FlyCallStatusEvent.calling:
        service.outGoingCallCalling(participantsId: e.participantsIds);
        break;
      case FlyCallStatusEvent.reconnecting:
        service.reconnecting(participantIds: e.participantsIds);
        break;
      case FlyCallStatusEvent.reconnected:
        service.reconnected(participantIds: e.participantsIds);
        break;
      case FlyCallStatusEvent.disconnected:
        service.disconnectCall(userIds: e.participantsIds, reason: e.reason ?? '');
        break;
      case FlyCallStatusEvent.callHold:
        service.callHold(participantsId: e.participantsIds);
        break;
      case FlyCallStatusEvent.callResume:
        service.callResume(participantsId: e.participantsIds);
        break;
      case FlyCallStatusEvent.callTimeout:
        service.callTimeOut(participantsId: e.participantsIds, isCallFailed: false);
        break;
      case FlyCallStatusEvent.rejected:
        if (e.participantsIds.isNotEmpty) {
          service.rejected(userId: e.participantsIds.first);
        }
        break;
      case FlyCallStatusEvent.engaged:
        service.remoteUserIsEngaged(participants: e.participantsIds);
        break;
      case FlyCallStatusEvent.permissionDenied:
        final Map<String, dynamic>? err = e.reason == null ? null : jsonDecode(e.reason!) as Map<String, dynamic>?;
        final message = err?['message'] as String?;
        if (message != null) toToast(message);
        break;
      case FlyCallStatusEvent.callFailed:
        service.onCallFailed(participantsId: e.participantsIds, reason: e.reason ?? '');
        break;
      default:
        break;
    }
  }

  static void _dispatchActionToService(
      CallStateService service,
      FlyCallAction e,
      ) {
    callkitLogger.info('Dispatching action event to service: ${e.flyCallEvent} for participant: ${e.participantId}');
    switch (e.flyCallEvent) {
      // case FlyCallActionEvent.toAudioCallAfterCallSwitch:
      //   service.audioCallAfterCallSwitch();
      //   break;
      case FlyCallActionEvent.audioMuted:
        service.isAudioMute(isAudioMuted: true, participantId: e.participantId);
        break;
      case FlyCallActionEvent.audioUnMuted:
        service.isAudioMute(isAudioMuted: false, participantId: e.participantId);
        break;
      case FlyCallActionEvent.videoMuted:
        service.isVideoMute(isVideoMuted: true, participantId: e.participantId);
        break;
      case FlyCallActionEvent.videoUnMuted:
        service.isVideoMute(isVideoMuted: false, participantId: e.participantId);
        break;
      case FlyCallActionEvent.connectionQualityUpdated:
        service.onConnectionQualityUpdated(
          quality: e.connectionQuality,
          participantId: e.participantId,
        );
        break;
      case FlyCallActionEvent.activeSpeaker:
        service.onActiveSpeakerChange(
          isSpeaking: false,
          audioLevel: e.audioLevel ?? 0,
          participantId: e.participantId ?? '',
        );
        break;
      case FlyCallActionEvent.onAudioRouteChanged:
        if (e.flyAudioDevice != null) service.onAudioRouteChanged(e.flyAudioDevice!);
        break;
      // outgoingRequest, incomingRequest, accept, cancel, decline, timeout
      // are dialog actions — they still need the UI controller, so they are
      // NOT dispatched through the service from the buffer. The UI controller
      // handles these via its own ever(lastActionEvent) subscription,
      // or by being registered when the event fires live.
      default:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Legacy dispatch to CallKitOutgoingCallController
  // ---------------------------------------------------------------------------

  static Future<void> _dispatchStatus(
      CallKitOutgoingCallController c,
      FlyCallStatus e,
      ) async {
    callkitLogger.info('Dispatching status event: ${e.flyCallStatusEvent} for participants: ${e.participantsIds}');
    switch (e.flyCallStatusEvent) {
      case FlyCallStatusEvent.connecting:
        c.connecting();
        break;
      case FlyCallStatusEvent.connected:
        c.onConnected(e.participantsIds);
        break;
      case FlyCallStatusEvent.ringing:
        c.ringing(participantsId: e.participantsIds, ringing: FlyCallStatusEvent.ringing);
        break;
      case FlyCallStatusEvent.tryingToConnect:
        c.tryingToConnect();
        break;
      case FlyCallStatusEvent.calling:
        c.outGoingCallCalling(participantsId: e.participantsIds, calling: FlyCallStatusEvent.calling);
        break;
      case FlyCallStatusEvent.reconnecting:
        c.reconnecting(participantIds: e.participantsIds);
        break;
      case FlyCallStatusEvent.reconnected:
        c.reconnected(participantIds: e.participantsIds);
        break;
      case FlyCallStatusEvent.disconnected:
        /// During disconnect receive callKitOutgoingCallController dispose is already called so not need to flush disconnect again
        /// But we have to work for the pip scenario
        c.disconnectCall(userIds: e.participantsIds, reason: e.reason ?? '');
        break;
      case FlyCallStatusEvent.callHold:
        c.callHold(participantsId: e.participantsIds);
        break;
      case FlyCallStatusEvent.callResume:
        c.callResume(participantsId: e.participantsIds);
        break;
      case FlyCallStatusEvent.callTimeout:
        c.callTimeOut(participantsId: e.participantsIds, isCallFailed: false);
        break;
      case FlyCallStatusEvent.rejected:
        if (e.participantsIds.isNotEmpty) {
          c.rejected(userId: e.participantsIds.first);
        }
        break;
      case FlyCallStatusEvent.engaged:
        c.remoteUserIsEngaged(participants: e.participantsIds);
        break;
      case FlyCallStatusEvent.permissionDenied:
        final Map<String, dynamic>? err = e.reason == null ? null : jsonDecode(e.reason!) as Map<String, dynamic>?;
        final message = err?['message'] as String?;
        if (message != null) toToast(message);
        break;

      case FlyCallStatusEvent.callFailed:
        c.onCallFailed(participantsId: e.participantsIds, reason: e.reason ?? '');
        break;
    // FlyCallStatusEvent.none, FlyCallStatusEvent.declined, FlyCallStatusEvent.joinSync -> no-op
      default:
        break;
    }
  }

  static void _dispatchAction(
      CallKitOutgoingCallController c,
      FlyCallAction e,
      ) {
    callkitLogger.info('Dispatching action event: ${e.flyCallEvent} for participant: ${e.participantId}');
    switch (e.flyCallEvent) {
    // answerCall is handled earlier (navigation), so ignore here
    //   case FlyCallActionEvent.toAudioCallAfterCallSwitch:
    //     c.audioCallAfterCallSwitch();
    //     break;
      case FlyCallActionEvent.outgoingCallSwitchRequest:
        c.showOutGoingCallSwitchRequestDialog();
        break;
      case FlyCallActionEvent.incomingCallSwitchRequest:
        c.showIncomingCallSwitchRequestDialog();
        break;
      case FlyCallActionEvent.outgoingCallSwitchAccepted:
        c.onVideoCallSwitchAccept();
        break;
      case FlyCallActionEvent.outgoingCallSwitchCancelled:
        c.onRemoteUserCancelledTheSwitchRequest();
        break;
      case FlyCallActionEvent.outgoingCallSwitchDeclined:
        c.onCallSwitchRemoteUserDeclined();
        break;
      case FlyCallActionEvent.outgoingCallSwitchTimeout:
        c.onVideoCallSwitchTimeOut(isIncomingTimeout: false);

      case FlyCallActionEvent.incomingCallSwitchTimeout:
        c.onVideoCallSwitchTimeOut(isIncomingTimeout: true);

        break;
      case FlyCallActionEvent.audioMuted:
        c.isAudioMute(isAudioMuted: true, participantId: e.participantId);
        break;
      case FlyCallActionEvent.audioUnMuted:
        c.isAudioMute(isAudioMuted: false, participantId: e.participantId);
        break;
      case FlyCallActionEvent.videoMuted:
        c.isVideoMute(isVideoMuted: true, participantId: e.participantId);
        break;
      case FlyCallActionEvent.videoUnMuted:
        c.isVideoMute(isVideoMuted: false, participantId: e.participantId);
        break;
      case FlyCallActionEvent.connectionQualityUpdated:
        c.onConnectionQualityUpdated(
          quality: e.connectionQuality,
          participantId: e.participantId,
        );
        break;
      case FlyCallActionEvent.activeSpeaker:
        c.onActiveSpeakerChange(
          isSpeaking: false,
          audioLevel: e.audioLevel ?? 0,
          participantId: e.participantId ?? '',
        );
        break;
      // case FlyCallActionEvent.onCallModeChange:
      //   // c.onParticipantListUpdated();
      //   break;
      case FlyCallActionEvent.onAudioRouteChanged:
        if (e.flyAudioDevice != null) c.onAudioRouteChanged(e.flyAudioDevice!);
        break;
      default:
        break;
    }
  }

}
