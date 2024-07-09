import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/routes/route_settings.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../common/app_localizations.dart';

class JoinCallController extends FullLifeCycleController with FullLifeCycleMixin, CallLinkEventListeners {

  final _users = <String>[].obs;
  get users => _users;

  final videoMuted = false.obs;
  // get videoMuted => _videoMuted.value;

  final muted = false.obs;
  // get muted => _muted.value;

  var callLinkId = "";

  var subscribeSuccess = false.obs;

  @override
  void onInit(){
    super.onInit();
    checkPermission();
    Mirrorfly.setCallLinkEventListener(this);
    callLinkId = NavUtils.arguments["callLinkId"].toString();
    initializeCall();
  }

  Future<void> checkPermission() async {
    muted(true);
    videoMuted(true);
    if(await AppPermission.askAudioCallPermissions()){
      muted(false);
      if(await AppPermission.askVideoCallPermissions()){
        videoMuted(false);
      }
    }
  }

  // initialize the meet
  void initializeCall() {
    Mirrorfly.initializeMeet(callLinkId: callLinkId,userName: SessionManagement.getName().checkNull(),flyCallback: (res){
      LogMessage.d("initializeMeet", res.toString());
    });
  }

  void disposePreview() {
    Mirrorfly.disposePreview();
  }

  Future<void> joinCall() async {
    if (await AppUtils.isNetConnected()) {
      if(await AppPermission.askVideoCallPermissions()) {
        if (await AppPermission.askNotificationPermission()) {
          subscribeSuccess(false);
          Mirrorfly.joinCall(flyCallback: (res) {
            LogMessage.d("joinCall", res.toString());
            if (res.isSuccess) {
              NavUtils.offNamed(Routes.onGoingCallView,
                  arguments: {"userJid": users, "joinViaLink": true});
            } else {
              subscribeSuccess(true);
              toToast(res.errorMessage);
            }
          });
        }
      }
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }

  muteAudio() {
    Mirrorfly.muteAudio(status: !muted.value, flyCallBack: (res){
      if(res.isSuccess) {
        muted(!muted.value);
      }
    });
  }

  videoMute() async {
    if (await AppPermission.askVideoCallPermissions()) {
      Mirrorfly.muteVideo(status: !videoMuted.value, flyCallBack: (_) {});
      videoMuted(!videoMuted.value);
    }
  }

  @override
  void onError(FlyException error) {

  }

  @override
  void onLocalVideoTrackAdded(String userJid) {

  }

  @override
  void onSubscribeSuccess() {
    subscribeSuccess(true);
  }

  @override
  void onUsersUpdated(List<String> users) {
    _users(users);
  }

  @override
  void onDetached() {

  }

  @override
  void onHidden() {

  }

  @override
  void onInactive() {

  }

  var paused = false;
  @override
  void onPaused() {
    paused = true;
  }

  @override
  void onResumed() {
    if(paused){
      paused = false;
      checkPermission();
    }
  }

}