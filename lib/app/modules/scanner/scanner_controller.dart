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

class ScannerController extends GetxController {
  final qrKeyNotifier = ValueNotifier(GlobalKey(debugLabel: 'QR'));
  QRViewController? controller;

  var loginQr = <String>[];
  final _webLogins = <WebLogin>[].obs;

  set webLogins(value) => _webLogins.value = value;

  List<WebLogin> get webLogins => _webLogins;

  bool gotScannedData = true;

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      debugPrint("scanData ${scanData.code}");
      processScannedData(scanData);
    });
  }

  Future<void> processScannedData(scanData) async {
    if (await AppUtils.isNetConnected()) {
      controller?.pauseCamera();
      if (gotScannedData) {
        gotScannedData = false;
        DialogUtils.showLoading(
            message: getTranslated("pleaseWait"),
            dialogStyle: AppStyleConfig.dialogStyle);
        loginWebChatViaQRCode(scanData.code);
      } else {
        debugPrint("gotScannedData $gotScannedData");
      }
    } else {
      DialogUtils.hideLoading();
      controller?.resumeCamera();
      gotScannedData = true;
      toToast(getTranslated("noInternetConnection"));
    }
  }

  @override
  void refresh() {
    super.refresh();
    debugPrint("ScannerController ->refresh qr controller");
    if (controller != null) {
      if (Platform.isAndroid) {
        controller?.pauseCamera();
      } else {
        controller?.resumeCamera();
      }
    }
  }

  loginWebChatViaQRCode(String? barcode) async {
    LogMessage.d("barcode", barcode.toString());
    if (barcode != null) {
      Mirrorfly.loginWebChatViaQRCode(
          barcode: barcode,
          flyCallBack: (FlyResponse response) {
            DialogUtils.hideLoading();
            if (response.isSuccess) {
              SessionManagement.setWebChatLogin(true);
              NavUtils.back(result: true);
            } else {
              gotScannedData = true;
              controller?.resumeCamera();
              toToast(response.errorMessage);
            }
          });
    }
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('ScannerController camera dispose:');
  }

  focusGained(bool isFocusGained) {
    debugPrint('ScannerController focusGained: $isFocusGained');
    if (controller != null) {
      if (isFocusGained) {
        debugPrint('ScannerController camera resumeCamera:');
        safeResumeCamera();
      } else {
        debugPrint('ScannerController camera stopCamera:');
      }
    }
  }

  void recreateQRView() {
    qrKeyNotifier.value = GlobalKey(debugLabel: 'QR');
  }

  void safeResumeCamera() async {
    try {
      await controller?.resumeCamera();
    } catch (e) {
      if (e is CameraException && e.code == '404') {
        debugPrint("QR view lost, recreating...");
        recreateQRView();
      } else {
        debugPrint("Camera resume error: $e");
      }
    }
  }

  logoutWebUser() async {
    if (await AppUtils.isNetConnected()) {
      DialogUtils.progressLoading();
      /*Mirrorfly.webLoginDetailsCleared();
      Mirrorfly.logoutWebUser(loginQr).then((value) {
        DialogUtils.hideLoading();
        if (value != null && value) {
          SessionManagement.setWebChatLogin(false);
          NavUtils.back();
        }
      });*/
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
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
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("logoutConfirmation"),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(
                getTranslated("no").toUpperCase(),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
                logoutWebUser();
              },
              child: Text(
                getTranslated("yes").toUpperCase(),
              )),
        ]);
  }
}
