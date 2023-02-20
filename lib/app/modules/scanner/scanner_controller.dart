
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:flysdk/flysdk.dart';
import '../../data/apputils.dart';
import '../../routes/app_pages.dart';

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
    mirrorFlyLog("barcode", barcode.toString());
    if (barcode != null) {
      if(await AppUtils.isNetConnected()) {
        controller!.pauseCamera();
        FlyChat.loginWebChatViaQRCode(barcode).then((value) {
          if (value != null) {
            SessionManagement.setWebChatLogin(value);
            Get.back();
          } else {

          }
        }).catchError((er) {
          controller!.resumeCamera();
        });
      }else{
        toToast(Constants.noInternetConnection);
      }

    }
  }

  logoutWebUser() async {
    if(await AppUtils.isNetConnected()) {
      Helper.progressLoading();
      FlyChat.webLoginDetailsCleared();
      FlyChat.logoutWebUser(loginQr).then((value) {
        Helper.hideLoading();
        if (value != null && value) {
          SessionManagement.setWebChatLogin(false);
          Get.back();
        }
      });
    }else{
      toToast(Constants.noInternetConnection);
    }
  }

  webLoginDetailsCleared() {
    FlyChat.webLoginDetailsCleared().then((value) {
      if (value != null && value) {
        //SessionManagement.setWebChatLogin(false);
      }
    });
  }

  getWebLoginDetails() {
    loginQr.clear();
    FlyChat.getWebLoginDetails().then((value) {
      if (value != null) {
        var list = webLoginFromJson(value);
        _webLogins(list);
        for (var element in list) {
          loginQr.add(element.qrUniqeToken);
        }
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
    FlyChat.webLoginDetailsCleared();
    Get.toNamed(Routes.scanner)?.then((value) {
      getWebLoginDetails();
    });
  }

  logoutWeb() {
    Helper.showAlert(message: "Are you want to logout?", actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("NO")),
      TextButton(
          onPressed: () {
            Get.back();
            logoutWebUser();
          },
          child: const Text("YES")),
    ]);
  }
}
