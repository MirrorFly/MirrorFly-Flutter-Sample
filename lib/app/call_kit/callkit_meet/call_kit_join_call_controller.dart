import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirror_fly_demo/mention_text_field/src/string_extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../call_modules/call_widgets.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../../extensions/extensions.dart';
import '../../routes/route_settings.dart';
import '../callkit_call_state_service.dart';
import '../callkit_event_buffer.dart';


class CallKitJoinCallController extends FullLifeCycleController with FullLifeCycleMixin {

  var uiLoading = false.obs;
  var callLinkId = "";
  var isInitializeSuccess = false.obs;
  var audioPermissionGranted = false.obs;
  var videoPermissionGranted = false.obs;
  var meetInitialised = false.obs;
  var navigatedFrom = '';
  var displayStatus = getTranslated("connectingPleaseWait");
  var paused = false;

  var users = <String>[].obs;
  final videoMuted = true.obs;
  final audioMuted = true.obs;

  RxBool callEnded = false.obs;
  RxBool invalidLink = false.obs;
  String callEndedMessage = "";
  RxBool showPreview = false.obs;
  var callMode = "".obs;

  @override
  void onInit() async {
    super.onInit();

    uiLoading(true);
    callLinkId = NavUtils.arguments["callLinkId"].toString();
    navigatedFrom = NavUtils.arguments["navigatedFrom"].toString();

    await CallStateService.start();

    checkPermission().then((success) async {
      if (!success) {
        audioMuted.value = true;
        videoMuted.value = true;
        callkitLogger.info("Required permissions not granted, cannot initialize join via link");
        toToast(getTranslated("permissionsNotGranted"));
      }

      callkitLogger.info("Initializing from $navigatedFrom via link with callLinkId: $callLinkId");
      final InitializeJoinLinkResponse initializeJoinLinkResponse = await MirrorFlyCallKit.initializeJoinViaLink(callLink: callLinkId);

      if (initializeJoinLinkResponse.isSuccess) {
        if (success) {
          audioMuted.value = false;
          videoMuted.value = false;
        }
        isInitializeSuccess(true);
        callkitLogger.info("Join via link initialization successful");
        callMode.value = initializeJoinLinkResponse.callMode;
        await getCallDetails(participants: initializeJoinLinkResponse.callParticipants);
        // await getVideoLocalCapturePreview();
      } else {
        if (initializeJoinLinkResponse.code == 400) {
          callkitLogger.info("Join via link initialization failed with error: call is already ended");
          callEnded.value = true;
          // toToast(initializeJoinLinkResponse.errorMessage ?? "Call is Already ended");
          return;
        } else if (initializeJoinLinkResponse.code == 404) {
          callkitLogger.info("Join via link initialization failed with error: Invalid Call link");
          invalidLink.value = true;
          callEnded.value = true;
          callEndedMessage = getTranslated("invalidLink");
          return;
        } else if (initializeJoinLinkResponse.code == 411) {
          callkitLogger.info("Join via link initialization failed with error: carbon user in the call");
          toToast("You are already in this call on another device");
          NavUtils.back();
          return;
        }
        toToast(initializeJoinLinkResponse.errorMessage ?? "Invalid link");
        callkitLogger.info("Join via link initialization failed with error: ${initializeJoinLinkResponse.errorMessage}");
      }
      uiLoading(false);
    });
  }

  @override
  void onReady() {
    super.onReady();
    callkitLogger.info("JoinCallController onReady called, starting call initialization");
  }

  /// Get call members details
  Future<void> getCallDetails({required List<JoinLinkParticipant>? participants}) async {
    callkitLogger.info("Fetching call details for participants: ${participants?.map((p) => p.userId).toList()}");

    if (participants == null || participants.isEmpty) {
      callkitLogger.info("No participants found in call details");
    }

    for (var participant in participants ?? []) {

      final bool isLocalParticipant = isLocalParticipantId(participantId: participant.userId);
      if (isLocalParticipant) {
        callkitLogger.info("#CallKitJoinCallController #LocalParticipantFound #Ignoring user addition");
        continue;
      }

      var callKitId = participant.userId;
      callkitLogger.info("Fetching profile for participant callKitId: $callKitId");

      final String jid = CallUtils.getJidFromUserId(userId: callKitId, isGroup: false);
      callkitLogger.info("Constructed JID for participant: $jid");
      users.add(jid);
    }
  }

  /// Join call
  Future<void> joinCall() async {
    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.askAudioCallPermissions()) {
        if (await AppPermission.askNotificationPermission()) {
          await CallStateService.start();
          CallKitEventBuffer.flushAllEvents();
          final JoinViaLinkResponseModel response = await MirrorFlyCallKit.joinCallViaLink(callLink: callLinkId);
          if (response.isSuccess) {
            callkitLogger.info("Successfully joined call via link");
            NavUtils.offNamed(Routes.callKitOutGoingCallView, arguments: {
              "callType": CallType.video,
              "callMode": callMode.value,
              "chatId": ''
            });
          } else {
            final int errorCode = response.errorMap.keys.first;
            if (errorCode == 602) {
              callEnded.value = true;
              toToast("Call ended");
              return;
            } else if (errorCode == 410) {
                toToast(response.errorMap[410] ?? "");
                await AppPermission.askAudioCallPermissions();
            } else if (errorCode == 411) {
              toToast(response.errorMap[411] ?? "");
              await AppPermission.askVideoCallPermissions();
            } else if(errorCode == 400) {
              callkitLogger.info("Join call link initialization failed with error: call is already ended");
              callEnded.value = true;
            }else {
              callkitLogger.info("Failed to join call via link with error: ${response.errorMap}");
              toToast(response.errorMap.values.first);
            }
          }
        } else {
          toToast("Notification permission denied");
        }
      } else {
        toToast("Audio call permission denied");
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  /// Mute Audio
  Future<void> muteAudio() async {
    callkitLogger.info("Setting microphone mute state in CallKit to: ${audioMuted.value}");
    MirrorFlyCallKit.setMicrophoneMuted(mute: !audioMuted.value, result: ({bool? isMuted, required String message, required bool success, required String code}) async {
      if (success) {
        callkitLogger.info("Microphone mute state successfully set in CallKit response isMuted $isMuted. Current state: ${audioMuted.value}");
          audioMuted(isMuted);
          callkitLogger.info("Audio mute state changed. New state: ${audioMuted.value}");
      } else {
        callkitLogger.info("Audio mute state change failed: message: $message, code: $code");

        if (code == "410") {
          toToast(message);
          await AppPermission.askAudioCallPermissions();
        }
        if (code == "311") {
          toToast(message);
          await openAppSettings();
        }

        callkitLogger.info("Failed to set microphone mute state in CallKit. Error: $message");
      }
    });
  }

  /// Mute Video
  Future<void> videoMute() async {
    final currentState = videoMuted.value;

    callkitLogger.info("Toggling videoMute. Current state: $currentState");

    MirrorFlyCallKit.setCameraEnable(
      enable: currentState,
      result: ({required success, required message, required code}) async {
        callkitLogger.info("Camera response → success=$success message=$message code=$code");

        if (!success) {
          callkitLogger.error("Failed to toggle videoMute");
          if (code == "411") {
            toToast(message);
            await AppPermission.askVideoCallPermissions();
          }

          if (code == "302") {
            toToast(message);
            await openAppSettings();
          }

          return;
        }

        videoMuted(!currentState);
        callkitLogger.info("Video mute toggled → new state: ${videoMuted.value}");
      },
    );
  }

  /// Getter of profile image in future builder
  get getProfileImage => FutureBuilder<Widget>(
        future: _buildProfileImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(color: Colors.white);
          }
          if (snapshot.hasError) {
            return const Icon(Icons.error);
          }
          return snapshot.data ?? const SizedBox.shrink();
        });

  /// Fetches the profile image for the current user and returns a widget to display it.
  Future<Widget> _buildProfileImage() async {
    var jid = SessionManagement.getUserJID().checkNull();
    callkitLogger.info("Fetching profile image for JID: $jid");

    final completer = Completer<Widget>();
    await Mirrorfly.getUserProfile(
      jid: jid,
      fetchFromServer: false,
      flyCallback: (FlyResponse response) {
        LogMessage.d(
          "MyProfileUpdated base controller getUserProfile",
          response.toString(),
        );

        if (response.isSuccess) {
          var data = profileDataFromJson(response.data);

          final profileDetails = ProfileDetails(
            email: data.data?.email,
            image: data.data?.image,
            mobileNumber: data.data?.mobileNumber,
            nickName: data.data?.nickName,
            name: data.data?.name,
            status: data.data?.status,
          );

          callkitLogger.info(
            "Profile image fetched successfully for JID: $jid",
          );

          completer.complete(buildProfileImage(profileDetails));
        } else {
          callkitLogger.info(
            "Profile fetch failed for JID: $jid, returning default",
          );

          completer.complete(const SizedBox.shrink());
        }
      },
    );

    return completer.future;
  }

  /// Override the back button press to prevent navigating back during the call join process
  void onBackPressed({bool fromPopScope = false}) async {
    callkitLogger.info("Back button pressed during call join process, ignoring to prevent navigation");
    final bool isCancelled = await MirrorFlyCallKit.cancelInitializeJoinViaLink();
    CallStateService.stop();
    if (isCancelled && !fromPopScope) {
      callkitLogger.info("Join via link initialization cancelled successfully");
      NavUtils.back();
    } else {
      callkitLogger.info("Failed to cancel join via link initialization");
    }
  }

  /// check permission and set Mute Status
  Future<bool> checkPermission() async {
    var audioPermission = await AppPermission.askAudioCallPermissions();
    var videoPermission = await AppPermission.checkAndRequestPermissions(
        permissions: [Permission.camera],
        permissionIcon: cameraPermission,
        permissionContent: getTranslated("callPermissionContent").replaceAll("%d", "Camera"),
        permissionPermanentlyDeniedContent: getTranslated("callPermissionDeniedContent").replaceAll("%d", "Camera"));
    callkitLogger.info("Audio permission: $audioPermission, Video permission: $videoPermission");
    audioPermissionGranted(audioPermission);
    videoPermissionGranted(videoPermission);
    return audioPermission && videoPermission;
  }

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {
    paused = true;
  }

  @override
  Future<void> onResumed() async {
    if (paused) {
      paused = false;
      checkPermission();
    }
  }

  bool isLocalParticipantId({required String participantId}) {
    final String currentUserJid = SessionManagement.getUserJID() ?? "";
    final String currentUserId = CallUtils.getIdFromJidList(currentUserJid);
    return currentUserId == participantId;
  }

  void participantConnected({required List<String> participantsId}) async {

    if (participantsId.isEmpty) {
      callkitLogger.info("#CallKitJoinCallController #participantConnected #Empty");
      return;
    }

    callkitLogger.info("#CallKitJoinCallController #participantConnected #forParticipant: ${participantsId.first}");

    final bool isLocalParticipant = isLocalParticipantId(participantId: participantsId.first);
    callkitLogger.info("#CallKitJoinCallController #participantConnected #isLocalParticipant: $isLocalParticipant");

    if (isLocalParticipant) {
      callkitLogger.info("#CallKitJoinCallController #participantConnected #forLocalParticipant #ignoring");
      return;
    }

    callkitLogger.info("#CallKitJoinCallController #participantConnected #${participantsId.first}");

    final participant = JoinLinkParticipant(userId: participantsId.first, status: "CONNECTED");
    await getCallDetails(participants: [participant]);
  }

  void participantDisconnected({required String participant}) {
    callkitLogger.info("#CallKitJoinCallController #participantDisconnected #$participant, users: ${users.map((e) => e.toString())}");

    final jid = CallUtils.getJidFromUserId(
      userId: participant,
      isGroup: false,
    );
    callkitLogger.info("#CallKitJoinCallController #participantDisconnected #jid: $jid");

    if (users.contains(jid)) {
      callkitLogger.info("#CallKitJoinCallController #participantDisconnected #participantFound");
      users.remove(jid);
    } else {
      callkitLogger.info("#CallKitJoinCallController #participantDisconnected #noParticipant");
    }
  }

  void closePreviewScreen() {
    callkitLogger.info("#CallKitJoinCallController Closing preview screen and navigating back");
    NavUtils.back();
  }

}
