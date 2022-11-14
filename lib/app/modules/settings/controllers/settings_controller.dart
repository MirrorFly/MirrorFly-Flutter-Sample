import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../data/SessionManagement.dart';

class SettingsController extends GetxController{
   PackageInfo? packageInfo = null ;
  @override
  void onInit() {
    super.onInit();
    getPackageInfo();
  }
  getPackageInfo() async{
    packageInfo.obs.value = await PackageInfo.fromPlatform();
  }

  logout() {
    Helper.progressLoading();
    PlatformRepo().logout().then((value) {
      Helper.hideLoading();
      if(value) {
        var token = SessionManagement().getToken().checkNull();
        SessionManagement.clear().then((value){
          SessionManagement.setToken(token);
          Get.offAllNamed(Routes.LOGIN);
        });
      }else{
        Get.snackbar("Logout", "Logout Failed");
      }
    }).catchError((er){
      Helper.hideLoading();
    });
  }

}