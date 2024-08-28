
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/constants.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../app_style_config.dart';
import '../../common/app_localizations.dart';
import '../../data/utils.dart';
import '../../routes/route_settings.dart';

class ScannerController extends GetxController {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  final loginQr = <String>[];
  final _webLogins = <WebLogin>[].obs;

  set webLogins(value) => _webLogins.value = value;

  List<WebLogin> get webLogins => _webLogins;

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      loginWebChatViaQRCode(scanData.code);
    });
  }

  @override
  void dispose() {
    if (controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }

  @override
  void refresh() {
    super.refresh();
    if (controller != null) {
      /*if (Platform.isAndroid) {
        controller!.pauseCamera();
      } else {
        controller!.resumeCamera();
      }*/
    }
  }

  loginWebChatViaQRCode(String? barcode) async {
    LogMessage.d("barcode", barcode.toString());
    if (barcode != null) {
      if(await AppUtils.isNetConnected()) {
        controller!.pauseCamera();
        /*Mirrorfly.loginWebChatViaQRCode(barcode).then((value) {
          if (value != null) {
            SessionManagement.setWebChatLogin(value);
            NavUtils.back();
          } else {

          }
        }).catchError((er) {
          controller!.resumeCamera();
        });*/
      }else{
        toToast(getTranslated("noInternetConnection"));
      }

    }
  }

  logoutWebUser() async {
    if(await AppUtils.isNetConnected()) {
      DialogUtils.progressLoading();
      /*Mirrorfly.webLoginDetailsCleared();
      Mirrorfly.logoutWebUser(loginQr).then((value) {
        DialogUtils.hideLoading();
        if (value != null && value) {
          SessionManagement.setWebChatLogin(false);
          NavUtils.back();
        }
      });*/
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }

  webLoginDetailsCleared() {
    /*Mirrorfly.webLoginDetailsCleared().then((value) {
      if (value != null && value) {
        //SessionManagement.setWebChatLogin(false);
      }
    });*/
  }

  getWebLoginDetails() {
    loginQr.clear();
    /*Mirrorfly.getWebLoginDetails().then((value) {
      if (value != null) {
        var list = webLoginFromJson(value);
        _webLogins(list);
        for (var element in list) {
          loginQr.add(element.qrUniqeToken);
        }
      }
    });*/
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
}
