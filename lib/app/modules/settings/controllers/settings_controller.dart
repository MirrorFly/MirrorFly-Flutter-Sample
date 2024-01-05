
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:yaml/yaml.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/session_management.dart';

class SettingsController extends GetxController {
  // PackageInfo? packageInfo;
  RxString version = "".obs;
  RxString releaseDate = "".obs;
  @override
  void onInit() {
    super.onInit();
    getPackageInfo();
    // getReleaseDate();
  }

  getPackageInfo() async {
    // var packageInfo = await PackageInfo.fromPlatform();
    String yamlContent = await rootBundle.loadString('pubspec.yaml');
    YamlMap yamlMap = loadYaml(yamlContent);
    String buildVersion = yamlMap['version'];
    String buildReleaseDate = yamlMap['build_release_date'];
    version(buildVersion);
    releaseDate(buildReleaseDate);
  }

  logout() {
    Get.back();
    if (SessionManagement.getEnablePin()) {
      Get.toNamed(Routes.pin)?.then((value){
        if(value!=null && value){
          logoutFromSDK();
        }
      });
    } else {
      logoutFromSDK();
    }
  }

  logoutFromSDK() async {
    if (await AppUtils.isNetConnected()) {
      Helper.progressLoading();
      Mirrorfly.logoutOfChatSDK().then((value) {
        Helper.hideLoading();
        if (value) {
          clearAllPreferences();
        } else {
          Get.snackbar("Logout", "Logout Failed");
        }
      }).catchError((er) {
        Helper.hideLoading();
        SessionManagement.clear().then((value) {
          // SessionManagement.setToken(token);
          Get.offAllNamed(Routes.login);
        });
      });
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  void clearAllPreferences(){
    var token = SessionManagement.getToken().checkNull();
    var cameraPermissionAsked = SessionManagement.getBool(Constants.cameraPermissionAsked);
    var audioRecordPermissionAsked = SessionManagement.getBool(Constants.audioRecordPermissionAsked);
    var readPhoneStatePermissionAsked = SessionManagement.getBool(Constants.readPhoneStatePermissionAsked);
    var bluetoothPermissionAsked = SessionManagement.getBool(Constants.bluetoothPermissionAsked);
    SessionManagement.clear().then((value) {
      SessionManagement.setToken(token);
      SessionManagement.setBool(Constants.cameraPermissionAsked, cameraPermissionAsked);
      SessionManagement.setBool(Constants.audioRecordPermissionAsked, audioRecordPermissionAsked);
      SessionManagement.setBool(Constants.readPhoneStatePermissionAsked, readPhoneStatePermissionAsked);
      SessionManagement.setBool(Constants.bluetoothPermissionAsked, bluetoothPermissionAsked);
      Get.offAllNamed(Routes.login);
    });
  }

  // getReleaseDate() async {
  //   var releaseDate = "";
  //   String pathToYaml =
  //       join(dirname(Platform.script.toFilePath()), '../pubspec.yaml');
  //   File file = File(pathToYaml);
  //   file.readAsString().then((String content) {
  //     Map yaml = loadYaml(content);
  //     debugPrint(yaml['build_release_date']);
  //     releaseDate = yaml['build_release_date'];
  //   });
  //   return releaseDate;
  // }
}