
import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';
import 'package:mirror_fly_demo/app/model/call_user_list.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

class PipViewController extends FullLifeCycleController with FullLifeCycleMixin, CallEventListeners {

  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;

  get isOneToOneCall =>
      callList.length <= 2;

  var callList = List<CallUserList>.empty(growable: true).obs;
  var availableAudioList = List<AudioDevices>.empty(growable: true).obs;
  var isPIPActive = false.obs;

  @override
  Future<void> onInit() async {
    checkPIP();
    Mirrorfly.setCallEventListener(this);
    try {
      var value = await Mirrorfly.getCallUsersList();
      final callUserList = callUserListFromJson(value);
      callList(callUserList);
    }catch(e){
      LogMessage.d("PipView",e);
    }
    super.onInit();
  }





  @override
  void onCallAction(String userJid, String callMode, String callType, String callAction) {
    // TODO: implement onCallAction
  }

  @override
  void onCallLogDeleted(String callLogId) {
    // TODO: implement onCallLogDeleted
  }

  @override
  void onCallLogsCleared() {
    // TODO: implement onCallLogsCleared
  }

  @override
  void onCallLogsUpdated() {
    // TODO: implement onCallLogsUpdated
  }

  @override
  void onCallStatusUpdated(String userJid, String callMode, String callType, String callStatus) {
    if(CallStatus.disconnected == callStatus){
      callDisconnected();
    }
  }

  @override
  void onLocalVideoTrackAdded(String userJid) {
    // TODO: implement onLocalVideoTrackAdded
  }

  @override
  void onMissedCall(String userJid, String groupId, bool isOneToOneCall, String callType, List<String> userList) {
    // TODO: implement onMissedCall
  }

  @override
  void onMuteStatusUpdated(String userJid, String muteEvent) {
    // TODO: implement onMuteStatusUpdated
  }

  @override
  void onRemoteVideoTrackAdded(String userJid) {
    // TODO: implement onRemoteVideoTrackAdded
  }

  @override
  void onTrackAdded(String userJid) {
    // TODO: implement onTrackAdded
  }

  var speakingUsers = <SpeakingUsers>[].obs;
  @override
  void onUserSpeaking(String userJid, int audioLevel) {
    var index = speakingUsers.indexWhere(
            (element) => element.userJid.toString() == userJid.toString());
    // LogMessage.d("speakingUsers indexWhere", "$index");
    if (index.isNegative) {
      speakingUsers
          .add(SpeakingUsers(userJid: userJid, audioLevel: audioLevel.obs));
      // LogMessage.d("speakingUsers", "added");
    } else {
      speakingUsers[index].audioLevel(audioLevel);
      // LogMessage.d("speakingUsers", "updated");
    }
  }

  int audioLevel(String userJid) {
    var index =
    speakingUsers.indexWhere((element) => element.userJid == userJid);
    var value = index.isNegative ? -1 : speakingUsers[index].audioLevel.value;
    // debugPrint("speakingUsers Audio level $value");
    return value;
  }

  @override
  void onUserStoppedSpeaking(String userJid) {
    Future.delayed(const Duration(milliseconds: 300), () {
      var index =
      speakingUsers.indexWhere((element) => element.userJid == userJid);
      if (!index.isNegative) {
        speakingUsers[index].audioLevel(0);
      }
    });
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  void onInactive() {
    // checkPIP();
  }

  var hasPaused = false;
  @override
  void onPaused() {
    hasPaused = true;
  }

  @override
  Future<void> onResumed() async {
    ///when notification drawer was dragged then app goes inactive,when closes the drawer its trigger onResume
    ///so that this checking hasPaused added, this will invoke only when app is opened from background state.
    if (hasPaused) {
      hasPaused = false;
      // var status = await FlPiP().isActive;
      // if((status?.isCreateNewEngine).checkNull()) {
      //   FlPiP().disable();
      // }
    }
    checkPIP();
  }

  Future<void> checkPIP() async {
    debugPrint("checkPIP");
    isPIPActive((await FlPiP().isActive)?.status == PiPStatus.enabled);
  }

  void hideOptions(){
    isPIPActive(true);
  }

  void expandPIP() {
    PictureInPicture.stopPiP();
    NavUtils.toNamed(AppPages.onGoingCall);
  }

  void stopPIP() {
    // enterPIPMode();
    PictureInPicture.stopPiP();
  }

  void callDisconnected() {
    PictureInPicture.stopPiP();
    FlPiP().toggle(AppState.foreground);
  }


}