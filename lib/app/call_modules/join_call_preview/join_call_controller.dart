import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/routes/route_settings.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

class JoinCallController extends GetxController with CallLinkEventListeners {

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
    Mirrorfly.setCallLinkEventListener(this);
    callLinkId = NavUtils.arguments["callLinkId"].toString();
    initializeCall();
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

  void joinCall() {
    Mirrorfly.joinCall(flyCallback: (res){
      LogMessage.d("joinCall", res.toString());
      if(res.isSuccess) {
        NavUtils.offAllNamed(Routes.onGoingCallView,arguments: {"userJid": users,"joinViaLink": true});
      }else{
        toToast(res.errorMessage);
      }
    });
  }

  muteAudio() {
    Mirrorfly.muteAudio(status: !muted.value, flyCallBack: (res){
      if(res.isSuccess) {
        muted(!muted.value);
      }
    });
  }

  videoMute() {
    Mirrorfly.muteVideo(status: !videoMuted.value, flyCallBack: (res){
      if(res.isSuccess) {
        videoMuted(!videoMuted.value);
      }
    });
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

}