import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/base_controller.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/pushnotification.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';

import 'package:flysdk/flysdk.dart';

class MainController extends GetxController with BaseController
    /*with FullLifeCycleMixin */{
  var authToken = "".obs;
  Rx<String> uploadEndpoint = "".obs;
  var maxDuration = 100.obs;
  var currentPos = 0.obs;
  var isPlaying = false.obs;
  var audioPlayed = false.obs;
  AudioPlayer player = AudioPlayer();
  String currentPostLabel = "00:00";

  @override
  void onInit() {
    super.onInit();
    PushNotifications.init();
    initListeners();
    getMediaEndpoint();
    uploadEndpoint(SessionManagement.getMediaEndPoint().checkNull());
    authToken(SessionManagement.getAuthToken().checkNull());
    getAuthToken();
  }



  getMediaEndpoint() async {
    if (SessionManagement
        .getMediaEndPoint()
        .checkNull()
        .isEmpty) {
      FlyChat.mediaEndPoint().then((value) {
        mirrorFlyLog("media_endpoint", value.toString());
        if(value!=null) {
          if (value.isNotEmpty) {
            uploadEndpoint(value);
            SessionManagement.setMediaEndPoint(value);
          } else {
            uploadEndpoint(SessionManagement.getMediaEndPoint().checkNull());
          }
        }
      });
    }
  }

  getAuthToken() async {
    if (SessionManagement
        .getUsername()
        .checkNull()
        .isNotEmpty &&
        SessionManagement
            .getPassword()
            .checkNull()
            .isNotEmpty) {
      await FlyChat.authToken().then((value) {
        mirrorFlyLog("RetryAuth", value.toString());
        if(value!=null) {
          if (value.isNotEmpty) {
            authToken(value);
            SessionManagement.setAuthToken(value);
          } else {
            authToken(SessionManagement.getAuthToken().checkNull());
          }
          update();
        }
      });
    }
  }

  handleAdminBlockedUser(String jid, bool status){
    if(SessionManagement.getUserJID().checkNull()==jid){
      if(status) {
        //show Admin Blocked Activity
        SessionManagement.setAdminBlocked(status);
        Get.toNamed(Routes.adminBlocked);
      }
    }
  }

  handleAdminBlockedUserFromRegister(){

  }
}
