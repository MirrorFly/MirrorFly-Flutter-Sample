import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/app_style_config.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';
import 'package:mirror_fly_demo/app/routes/route_settings.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

class WebLoginController extends GetxController {

  var loginQr = <String>[];
  final _webLogins = <WebLogin>[].obs;

  set webLogins(value) => _webLogins.value = value;

  List<WebLogin> get webLogins => _webLogins;


  @override
  void dispose() {
    /*if (controller != null) {
      controller!.dispose();
    }*/
    super.dispose();
  }


  logoutWebUser() async {
    if(await AppUtils.isNetConnected()) {
      DialogUtils.progressLoading();
      Mirrorfly.logoutWebUser(logins: loginQr).then((value) {
        if (value != null && value) {
          // SessionManagement.setWebChatLogin(false);
          // NavUtils.back();
          toToast(getTranslated("qaWebLogoutSuccess"));
        }else{
          DialogUtils.hideLoading();
          toToast(getTranslated("qaWebLogoutFailure"));
        }
      });
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }


  getWebLoginDetails() {
    loginQr.clear();
    Mirrorfly.getWebLoginDetails().then((value) {
      if (value != null) {
        var list = webLoginFromJson(value);
        /*[{"id":1,"lastLoginTime":"Thu, 27 Mar 2025 12:46:31 pm","osName":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36","qrUniqeToken":"eM8xrgDqNNxuW5WWAAEx","webBrowserName":"Chrome 134.0.0.0"}]*/
        _webLogins(list);
        loginQr = List<String>.from(list.map((e) => e.qrUniqeToken));
      }
    });
  }

  getImageForBrowser(WebLogin item) {
    var name = item.webBrowserName.toLowerCase();
    if (name.contains("chrome")) {
      return icChrome;
    } else if (name.contains("edge")) {
      return icEdgeBrowser;
    } else if (name.contains("firefox")) {
      return icMozilla;
    } else if (name.contains("safari")) {
      return icSafari;
    } else if (name.contains("ie")) {
      return icIe;
    } else if (name.contains("opera")) {
      return icOpera;
    } else if (name.contains("uc")) {
      return icUc;
    } else {
      return icDefaultBrowser;
    }
  }

  addLogin() async {
    if (await AppUtils.isNetConnected()) {
    NavUtils.toNamed(Routes.scanner)?.then((value) {
      getWebLoginDetails();
    });
    } else {
    toToast(getTranslated("noInternetConnection"));
    }
  }

  logoutWeb() {
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getTranslated("logoutConfirmation"), actions: [
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            NavUtils.back();
          },
          child: Text(getTranslated("no").toUpperCase(), )),
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            NavUtils.back();
            logoutWebUser();
          },
          child: Text(getTranslated("yes").toUpperCase(), )),
    ]);
  }

  void onWebLogout(List<String> socketIdList) {
    var webLoginIndex = _webLogins.indexWhere((webLogin) =>
        socketIdList.contains(webLogin.qrUniqeToken));
    if (!webLoginIndex.isNegative) {
      _webLogins.removeWhere((e) => socketIdList.contains(e.qrUniqeToken));
      loginQr.removeWhere((e) => socketIdList.contains(e));
      DialogUtils.hideLoading();
      if (_webLogins.isEmpty) {
        SessionManagement.setWebChatLogin(false);
        LogMessage.d("WebLogin", "Moving back to the screen");
        NavUtils.back();
      }
    } else {
      LogMessage.d("WebLogin", "Socket ID is already removed");
    }
  }
}