
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../../call_modules/call_widgets.dart';
import '../../data/helper.dart';
import '../../data/utils.dart';
import '../../routes/app_pages.dart';
import '../callkit_call_state_service.dart';
import '../callkit_logger.dart';

class CallKitPipController extends GetxController {

  // ── Null-safe service accessor ─────────────────────────────────────────────
  // The PIP controller may be created before CallStateService is registered
  // (e.g., when the user taps the PIP widget during early call setup).
  // Never call Get.find() unconditionally — always guard with isRegistered.

  CallStateService? get _svc =>
      CallStateService.isRegistered ? CallStateService.instance : null;

  // ── Local fallback state (used when service is not yet available) ──────────
  final _callerList = <FlyCallParticipant>[].obs;
  final _remoteUserNameMap = <String, String>{}.obs;
  final _isGroupCall = false.obs;
  final _callType = ''.obs;
  final _callMode = ''.obs;
  final _callStatus = ''.obs;
  final _isAudioMuted = false.obs;
  final _isOnGoingCallViewEnable = false.obs;
  final _callDuration = ''.obs;

  // ── Proxy getters — prefer service, fall back to local field ───────────────
  RxList<FlyCallParticipant> get callerList =>
      _svc?.callerList ?? _callerList;
  RxMap<String, String> get remoteUserNameMap =>
      _svc?.remoteUserNameMap ?? _remoteUserNameMap;
  RxBool get isGroupCall => _svc?.isGroupCall ?? _isGroupCall;
  RxString get callType => _svc?.callType ?? _callType;
  RxString get callMode => _svc?.callMode ?? _callMode;
  RxString get callStatus => _svc?.callStatus ?? _callStatus;
  RxBool get isAudioMuted => _svc?.isAudioMuted ?? _isAudioMuted;
  RxBool get isOnGoingCallViewEnable =>
      _svc?.isOnGoingCallViewEnable ?? _isOnGoingCallViewEnable;
  RxString get callDuration => _svc?.callDuration ?? _callDuration;

  // PIP-specific UI state
  var isPIPActive = false.obs;
  var showExpand = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    callkitLogger.info('[MirrorFly][CallKitPIPController] onInit');

    // Only subscribe to callEndSignal if the service is already running.
    // If not, the signal will stop PIP naturally when the service emits it —
    // the service itself calls stop() which triggers PIP closure via the
    // outgoing controller's _handleCallEndSignal.
    if (CallStateService.isRegistered) {
      ever(_svc!.callEndSignal, _onCallEnded);
    }
  }

  /// Stop PIP when the service signals the call has ended.
  void _onCallEnded(CallEndSignal? signal) {
    if (signal == null) return;
    callkitLogger.info(
        '[MirrorFly][CallKitPIPController] _onCallEnded signal=$signal — stopping PIP');
    stopPIP();
  }

  void expandPIP() {
    // No syncStateFromSDK() needed — service state is always live.
    PictureInPicture.stopPiP();
    NavUtils.toNamed(AppPages.callKitCallView);
  }

  Widget getUserProfileImageWithName({
    required String participantId,
    bool isGroup = false,
  }) {
    if (participantId.isEmpty) {
      return const SizedBox();
    }

    final String normalizedId = _validId(userId: participantId, isGroup: isGroup);
    final Future<ProfileDetails> profileFuture = isGroup
        ? getGroupProfileDetails(normalizedId)
        : getProfileDetails(normalizedId);

    return FutureBuilder<ProfileDetails>(
      future: profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }
        final profile = snapshot.data!;
        final String displayName = (profile.name?.trim().isNotEmpty == true)
            ? profile.name!.trim()
            : (profile.nickName?.trim().isNotEmpty == true)
                ? profile.nickName!.trim()
                : _trimAfterAt(profile.jid ?? '');

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildProfileImage(profile, size: 45),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  String _validId({required String userId, required bool isGroup}) {
    if (isGroup) {
      return userId.contains('@') ? userId : '$userId@mix.xmpp-uikit-qa.contus.us';
    } else {
      return userId.contains('@') ? userId : '$userId@xmpp-uikit-qa.contus.us';
    }
  }

  FlyCallParticipant? getLocalParticipant() {
    return callerList.firstWhereOrNull((p) => p.isLocalParticipant);
  }

  bool isSelfId({required String? id}) {
    return _svc?.isSelfId(id: id) ?? false;
  }

  String getParticipantConnectionState(FlyCallStatusEvent? status) {
    return _svc?.getParticipantConnectionState(status) ?? '';
  }

  String _trimAfterAt(String input) {
    return input.split('@').firstOrNull?.trim() ?? '';
  }

  void stopPIP() {
    PictureInPicture.stopPiP();
  }
}