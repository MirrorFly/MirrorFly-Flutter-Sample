
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
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
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
      controller.pauseCamera();

      if (gotScannedData) {
        gotScannedData = false;
        DialogUtils.showLoading(message: getTranslated("pleaseWait"),dialogStyle: AppStyleConfig.dialogStyle);
        loginWebChatViaQRCode(scanData.code);
      }else{
        debugPrint("gotScannedData $gotScannedData");
      }
    });
  }

  @override
  void refresh() {
    super.refresh();
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
      if(await AppUtils.isNetConnected()) {
        Mirrorfly.loginWebChatViaQRCode(barcode: barcode, flyCallBack: (FlyResponse response) {
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
      }else{
        gotScannedData = true;
        toToast(getTranslated("noInternetConnection"));
      }
    }
  }

}
