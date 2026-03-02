
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:flutter_in_app_pip/pip_params.dart';
import 'package:flutter_in_app_pip/pip_view_corner.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../app_style_config.dart';
import '../../call_modules/call_widgets.dart';
import '../../call_modules/pip_view/pip_view.dart';
import '../../common/widgets.dart';
import '../../data/helper.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../callkit_logger.dart';
import 'callkit_pip_View.dart';

class CallKitPipController extends GetxController {

  var callerList = <FlyCallParticipant>[].obs;

  RxMap<String, String> remoteUserNameMap = <String, String>{}.obs;

  RxBool isGroupCall = false.obs;
  RxString callType = "".obs;
  RxString callMode = "".obs;
  RxString currentCallMode = "".obs;
  FlyCallKind callKind = FlyCallKind.standard;
  RxString groupId = "".obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    callerList(MirrorFlyCallKit.getCurrentCallParticipants());
    callType((MirrorFlyCallKit.getCurrentCallType()).toString());
    groupId(MirrorFlyCallKit.getCurrentCallGroupId());
    callMode(MirrorFlyCallKit.getCurrentCallMode());
    currentCallMode(MirrorFlyCallKit.getCurrentCallMode());
    callKind = MirrorFlyCallKit.getCallKind();

  }

  @override
  void onClose() {
    super.onClose();

  }

  @override
  onReady() async {
    await getCallMembersName();
    super.onReady();
  }


  Widget getUserProfileImageWithName({
    required String participantId,
    bool isGroup = false,
    double scale = 1.0,
    bool useMaxSize = false, required callKind,
    required bool isLocalTile,
    bool isGroupGrid = false,
  }) {

    callkitLogger.info("[getUserProfileImageWithName] Called with participantId: $participantId");

    if (participantId == "") {
      callkitLogger
          .info("[getUserProfileImageWithName] participantId is empty");
      return const Offstage();
    }

    callkitLogger.info("[getUserProfileImageWithName] isGroupCall: $isGroup");

    final String normalizedParticipantId = validId(userId: participantId, isGroup: isGroup);
    callkitLogger.info("[getUserProfileImageWithName] normalizedParticipantId: $normalizedParticipantId");

    final Future<ProfileDetails> profileDetails = isGroup == true
        ? getGroupProfileDetails(normalizedParticipantId)
        : getProfileDetails(normalizedParticipantId);

    return FutureBuilder<ProfileDetails>(
      future: profileDetails,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          callkitLogger.info("[getUserProfileImageWithName] Loading profile for: $normalizedParticipantId");
        } else if (snap.connectionState == ConnectionState.done) {
          if (snap.hasError) {
            callkitLogger.info("[getUserProfileImageWithName] Error loading profile for $normalizedParticipantId → ${snap.error}");
          } else if (!snap.hasData || snap.data == null) {
            callkitLogger.info("[getUserProfileImageWithName]  No data found for participantId: $normalizedParticipantId");
          } else {
            callkitLogger.info("[getUserProfileImageWithName] Profile loaded: ${snap.data!.name} (${snap.data})");
          }
        }

        // When we actually have valid profile data
        if (snap.hasData && snap.data != null) {

          RxBool isLocalView = (participantId == getLocalParticipant()?.identity).obs;
          return Stack(
            children: [

              /// LOCAL VIEW → CENTER
              if (isLocalView.value)
                Center(
                  child: callKind == FlyCallKind.sip
                      ? ProfileTextImage(
                    text: (remoteUserNameMap[participantId]?.trim().length ?? 0) > 3
                        ? remoteUserNameMap[participantId]!.trim().substring(3)
                        : "You",
                    radius:
                    (AppStyleConfig.outgoingCallPageStyle.profileImageSize.width /
                        scale) /
                        2,
                  )
                      : buildProfileImage(
                    snap.data!,
                    size: AppStyleConfig.outgoingCallPageStyle
                        .profileImageSize.width /
                        scale,
                  ),
                ),

              /// REMOTE VIEW → TOP CENTER
              if (!isLocalView.value)
                Positioned(
                  top: isGroupGrid ? 50 : 80,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: callKind == FlyCallKind.sip
                        ? ProfileTextImage(
                      text: (remoteUserNameMap[participantId]?.trim().length ?? 0) > 3
                          ? remoteUserNameMap[participantId]!.trim().replaceFirst(RegExp(r'^sip_'), '').substring(3) : "User",
                      radius:
                      (AppStyleConfig.outgoingCallPageStyle.profileImageSize.width /
                          scale) /
                          2,
                    )
                        : buildProfileImage(
                      snap.data!,
                      size: AppStyleConfig.outgoingCallPageStyle
                          .profileImageSize.width /
                          scale,
                    ),
                  ),
                ),

              /// "You" label
              if (isLocalTile && !isGroupCall.value)
                const Positioned(
                  bottom: 8,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "You",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
        return const Offstage();
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

  Future<void> getCallMembersName() async {

    if(callKind == FlyCallKind.sip){
      callkitLogger.info("[MirrorFly][CallKitPIPController] #getRemoteAndLocalUserNameForOneToOneCall SIP call - using identity as name");
      for(var user in callerList){
        remoteUserNameMap[user.identity] =
        user.isLocalParticipant ? "You" : user.identity;
        callkitLogger.info("[MirrorFly][CallKitPIPController] #getRemoteAndLocalUserNameForGroupCall Remote User Name for sip call ${user.identity}: ${remoteUserNameMap[user.identity]}");
      }
      return;
    }

    for (var user in callerList) {
      callkitLogger.info(
          "[MirrorFly][CallKitPIPController] #getRemoteAndLocalUserNameForGroupCall Getting user name for: ${user.identity}, isLocal: ${user.isLocalParticipant}");
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
          "[MirrorFly][CallKitPIPController] #getRemoteAndLocalUserNameForGroupCall Remote User Name for ${user.identity}: $username");
    }
    callkitLogger.info(
        "[MirrorFly][CallKitPIPController] #getRemoteAndLocalUserNameForGroupCall Completed fetching user names for group call, "
            "remoteUserNameMap: ${remoteUserNameMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}");
    return;
  }

  String trimAfterAt(String input) {
    return input.split('@').firstOrNull?.trim() ?? "";
  }

}