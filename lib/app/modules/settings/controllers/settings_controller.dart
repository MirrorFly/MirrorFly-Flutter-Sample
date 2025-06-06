
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:yaml/yaml.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/session_management.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';
import '../../backup_restore/backup_utils/backup_restore_manager.dart';


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
    if (SessionManagement.getEnablePin()) {
      NavUtils.toNamed(Routes.pin)?.then((value){
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
      DialogUtils.progressLoading();
      Mirrorfly.logoutOfChatSDK(flyCallBack: (response){
        clearAllPreferences();
      }).catchError((ex){
        LogMessage.d("logoutOfChatSDK", ex);
        clearAllPreferences();
      });
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  void clearAllPreferences()async{
    var token = SessionManagement.getToken().checkNull();
    var cameraPermissionAsked = SessionManagement.getBool(Constants.cameraPermissionAsked);
    var audioRecordPermissionAsked = SessionManagement.getBool(Constants.audioRecordPermissionAsked);
    var readPhoneStatePermissionAsked = SessionManagement.getBool(Constants.readPhoneStatePermissionAsked);
    var bluetoothPermissionAsked = SessionManagement.getBool(Constants.bluetoothPermissionAsked);
   if(BackupRestoreManager.instance.getGoogleAccountSignedIn != null) {
      await BackupRestoreManager.instance.googleSignIn.signOut();
    }
    SessionManagement.clear().then((value) {
      SessionManagement.setToken(token);
      SessionManagement.setBool(Constants.cameraPermissionAsked, cameraPermissionAsked);
      SessionManagement.setBool(Constants.audioRecordPermissionAsked, audioRecordPermissionAsked);
      SessionManagement.setBool(Constants.readPhoneStatePermissionAsked, readPhoneStatePermissionAsked);
      SessionManagement.setBool(Constants.bluetoothPermissionAsked, bluetoothPermissionAsked);
      DialogUtils.hideLoading();
      NavUtils.offAllNamed(Routes.login);
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