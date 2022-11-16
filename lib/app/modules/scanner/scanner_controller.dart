
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/SessionManagement.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/web_login_model.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../nativecall/platformRepo.dart';
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

  loginWebChatViaQRCode(String? barcode) {
    Log("barcode", barcode.toString());
    if (barcode != null) {
      controller!.pauseCamera();
      PlatformRepo().loginWebChatViaQRCode(barcode).then((value) {
        if (value != null) {
          SessionManagement.setWebChatLogin(value);
          Get.back();
        } else {
          controller!.resumeCamera();
        }
      }).catchError((er) {
        controller!.resumeCamera();
      });
    }
  }

  logoutWebUser() {
    Helper.progressLoading();
    PlatformRepo().webLoginDetailsCleared();
    PlatformRepo().logoutWebUser(loginQr).then((value) {
      Helper.hideLoading();
      if (value != null && value) {
        SessionManagement.setWebChatLogin(false);
        Get.back();
      }
    });
  }

  webLoginDetailsCleared() {
    PlatformRepo().webLoginDetailsCleared().then((value) {
      if (value != null && value) {
        //SessionManagement.setWebChatLogin(false);
      }
    });
  }

  getWebLoginDetails() {
    loginQr.clear();
    PlatformRepo().getWebLoginDetails().then((value) {
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
      return ic_chrome;
    } else if (name.contains("edge")) {
      return ic_edge_browser;
    } else if (name.contains("firefox")) {
      return ic_mozilla;
    } else if (name.contains("safari")) {
      return ic_safari;
    } else if (name.contains("ie")) {
      return ic_ie;
    } else if (name.contains("opera")) {
      return ic_opera;
    } else if (name.contains("uc")) {
      return ic_uc;
    } else {
      return ic_default_browser;
    }
  }

  addLogin() {
    PlatformRepo().webLoginDetailsCleared();
    Get.toNamed(Routes.SCANNER)?.then((value) {
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
