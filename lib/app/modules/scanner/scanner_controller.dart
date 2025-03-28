
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../../common/constants.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../app_style_config.dart';
import '../../common/app_localizations.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../../routes/route_settings.dart';

class ScannerController extends GetxController {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  var loginQr = <String>[];
  final _webLogins = <WebLogin>[].obs;

  set webLogins(value) => _webLogins.value = value;

  List<WebLogin> get webLogins => _webLogins;

  bool gotScannedData = true;

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    // controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      debugPrint("scanData ${scanData.code}");
      controller.pauseCamera();

      if (gotScannedData) {
        gotScannedData = false;
        DialogUtils.showLoading(message: getTranslated("pleaseWait"),dialogStyle: AppStyleConfig.dialogStyle);
        // Mirrorfly.webLoginDetailsCleared();
        loginWebChatViaQRCode(scanData.code);
      }
    });
  }

  @override
  void dispose() {
    /*if (controller != null) {
      controller!.dispose();
    }*/
    super.dispose();
  }

  @override
  void refresh() {
    super.refresh();
    if (controller != null) {
      if (Platform.isAndroid) {
        controller!.pauseCamera();
      } else {
        controller!.resumeCamera();
      }
    }
  }

  loginWebChatViaQRCode(String? barcode) async {
    LogMessage.d("barcode", barcode.toString());
    if (barcode != null) {
      if(await AppUtils.isNetConnected()) {
        Mirrorfly.loginWebChatViaQRCode(barcode: barcode, flyCallBack: (FlyResponse response) {
          if(DialogUtils.isDialogOpen()){
            DialogUtils.hideLoading();
          }
          if (response.isSuccess) {
            SessionManagement.setWebChatLogin(true);
            NavUtils.back();
          } else {
            controller?.resumeCamera();
            toToast(response.errorMessage);
          }
        });
      }else{
        toToast(getTranslated("noInternetConnection"));
      }

    }
  }

  logoutWebUser() async {
    if(await AppUtils.isNetConnected()) {
      DialogUtils.progressLoading();
      // Mirrorfly.webLoginDetailsCleared();
      Mirrorfly.logoutWebUser(logins: loginQr).then((value) {
        // DialogUtils.hideLoading();
        if (value != null && value) {
          // SessionManagement.setWebChatLogin(false);
          // NavUtils.back();
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

  addLogin() {
    // Mirrorfly.webLoginDetailsCleared();
    gotScannedData=true;
    NavUtils.toNamed(Routes.scanner)?.then((value) {
      getWebLoginDetails();
    });
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
    _webLogins.removeWhere((e)=>socketIdList.contains(e.qrUniqeToken));
    loginQr.removeWhere((e)=>socketIdList.contains(e));
    DialogUtils.hideLoading();
    if(_webLogins.isEmpty){
      SessionManagement.setWebChatLogin(false);
      NavUtils.back();
    }
  }
}
