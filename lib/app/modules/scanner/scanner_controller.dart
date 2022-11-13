import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/SessionManagement.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../nativecall/platformRepo.dart';

class ScannerController extends GetxController {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
     loginWebChatViaQRCode(scanData.code);
    });
  }

  @override
  void dispose() {
    if(controller!=null) {
      controller!.dispose();
    }
    super.dispose();
  }

  @override
  void refresh() {
    super.refresh();
    if(controller!=null) {
      if (Platform.isAndroid) {
        controller!.pauseCamera();
      } else {
        controller!.resumeCamera();
      }
    }
  }

  loginWebChatViaQRCode(String? barcode){
    Log("barcode", barcode.toString());
    if(barcode!=null) {
      PlatformRepo().loginWebChatViaQRCode(barcode).then((value) {
        if (value != null) {
          SessionManagement.setWebChatLogin(value);
          Get.back();
        }
      });
    }
  }
  logoutWebUser(String? barcode){
    if(barcode!=null) {
      PlatformRepo().logoutWebUser([]).then((value) {
        if (value != null && value) {
          SessionManagement.setWebChatLogin(false);
        }
      });
    }
  }
  webLoginDetailsCleared(String? barcode){
    if(barcode!=null) {
      PlatformRepo().webLoginDetailsCleared().then((value) {
        if (value != null && value) {
          //SessionManagement.setWebChatLogin(false);
        }
      });
    }
  }
  getWebLoginDetails(){
    PlatformRepo().getWebLoginDetails().then((value){
      if(value!=null){

      }
    });
  }
}