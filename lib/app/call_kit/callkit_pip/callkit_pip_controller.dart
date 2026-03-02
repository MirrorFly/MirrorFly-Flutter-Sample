
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../../call_modules/call_widgets.dart';
import '../../data/helper.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../../routes/app_pages.dart';
import '../callkit_logger.dart';

class CallKitPipController extends GetxController {

  var callerList = <FlyCallParticipant>[].obs;

  RxMap<String, String> remoteUserNameMap = <String, String>{}.obs;

  RxBool isGroupCall = false.obs;
  RxString callType = "".obs;
  RxString callMode = "".obs;
  RxString currentCallMode = "".obs;
  FlyCallKind callKind = FlyCallKind.standard;
  RxString groupId = "".obs;
  var isPIPActive = false.obs;
  var showExpand = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    callerList(await MirrorFlyCallKit.getCurrentCallParticipants());
    callType((MirrorFlyCallKit.getCurrentCallType()).toString());
    groupId(MirrorFlyCallKit.getCurrentCallGroupId());
    callMode(MirrorFlyCallKit.getCurrentCallMode());
    currentCallMode(MirrorFlyCallKit.getCurrentCallMode());
    callKind = await MirrorFlyCallKit.getCallKind();
  }

  void expandPIP() {
    PictureInPicture.stopPiP();
    NavUtils.toNamed(AppPages.callKitCallView);
  }

  @override
  void onClose() {
    super.onClose();

  }

  @override
  onReady() async {
    super.onReady();
  }

  Widget getUserProfileImageWithName({
    required String participantId,
    bool isGroup = false,
  }) {

    if (participantId.isEmpty) {
      return const SizedBox();
    }

    final String normalizedId = validId(userId: participantId, isGroup: isGroup);
    final Future<ProfileDetails> profileFuture = isGroup
        ? getGroupProfileDetails(normalizedId)
        : getProfileDetails(normalizedId);

    return FutureBuilder<ProfileDetails>(
      future: profileFuture,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }

        final profile = snapshot.data!;
        final String displayName = (profile.name?.trim().isNotEmpty == true)
            ? profile.name!.trim()
            : (profile.nickName?.trim().isNotEmpty == true)
            ? profile.nickName!.trim()
            : trimAfterAt(profile.jid ?? "");

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Profile Image
            buildProfileImage(
              profile,
              size: 45,
            ),

            /// Name
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

  String validId({required String userId,required bool isGroup}) {
    if(isGroup){
      callkitLogger.info("[MirrorFly][CallKitPIPController] validId for group called with userId: $userId isGroup: $isGroup, containing @: ${userId.contains("@")}");
      return userId.contains("@") ? userId : "$userId@mix.xmpp-uikit-qa.contus.us";
    }else{
      return userId.contains("@") ? userId : "$userId@xmpp-uikit-qa.contus.us";
    }
  }

  /// Get Local participant
  FlyCallParticipant? getLocalParticipant() {
    final FlyCallParticipant? localParticipant = callerList
        .firstWhereOrNull((p) => p.isLocalParticipant);
    callkitLogger.info("[MirrorFly][CallKitPIPController] getLocalParticipant: $localParticipant");
    return localParticipant;
  }

  bool isSelfId({required String? id}) {
    final String? currentUserId = SessionManagement.getUserJID();
    if (currentUserId == null) {
      callkitLogger.info("[MirrorFly][CallKitPIPController] isSelfId: is null id=$id");
      return true;
    } else {
      //
      final String participantId = "$id@xmpp-uikit-qa.contus.us";
      callkitLogger.info("[MirrorFly][CallKit PIP Controller] isSelfId $currentUserId $participantId");
      callkitLogger.info("[MirrorFly][CallKit PIP Controller] isSelfId: ${currentUserId == participantId}");
      return currentUserId == participantId;
    }
  }

  String getParticipantConnectionState(FlyCallStatusEvent? status) {
    callkitLogger.info("[MirrorFly][CallKitPIPController] getParticipantConnectionState called with status: $status");
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

  String trimAfterAt(String input) {
    return input.split('@').firstOrNull?.trim() ?? "";
  }

  void stopPIP() {
    PictureInPicture.stopPiP();
  }

  void closePip() async {
    await MirrorFlyCallKit.localHangup();
    toToast("Call Disconnected");
    stopPIP();
  }

  /// On disconnected
  void onDisconnected({required List<String> participantId}) async {
    callkitLogger.info("[MirrorFly][CallKitPIPController] onDisconnected called with participantId: $participantId");

    final bool isLocalDisconnected = participantId.any((id) => id == CallUtils.getIdFromJidList(id));
    if (isLocalDisconnected) {
      callkitLogger.info("[MirrorFly][CallKitPIPController] Local user disconnected");
      stopPIP();
      return;
    }

    final flyCallParticipant = await MirrorFlyCallKit.getCurrentCallParticipants() ?? [];
    final bool isLastParticipantLeft = flyCallParticipant.length <= 1;

    if (isLastParticipantLeft) {
      callkitLogger.info("[MirrorFly][CallKitPIPController] Last participant left → stopping PIP");
      stopPIP();
      return;
    }

    callkitLogger.info("[MirrorFly][CallKitPIPController] No PIP action required");
  }

  /// On Rejected
  void onRejected({required String participantId}) async {
    callkitLogger.info("[MirrorFly][CallKitPIPController] onRejected called with participantId: $participantId");
    final ProfileDetails profileDetails = await getProfileDetails((CallUtils.getJidFromUserId(userId: participantId, isGroup: false)));

    if (callMode.value == "ONE-TO-ONE") {
      toToast("${profileDetails.name} is busy");
      stopPIP();
      return;
    } else if (callMode.value == "ONE-TO-MANY") {
      // Remove ringing participant
    } else {}
  }

  void onEngaged({required String participantId}) async {
    callkitLogger.info("[MirrorFly][CallKitPIPController] onEngaged called with participantId: $participantId");
    final ProfileDetails profileDetails = await getProfileDetails((CallUtils.getJidFromUserId(userId: participantId, isGroup: false)));

    if (callMode.value == "ONE-TO-ONE") {
      toToast("${profileDetails.name} is busy");
      stopPIP();
      return;
    } else if (callMode.value == "ONE-TO-MANY") {
      // Remove ringing participant
    } else {}
  }
}