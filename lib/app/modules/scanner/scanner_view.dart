import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../../common/constants.dart';
import '../../modules/scanner/scanner_controller.dart';

import '../../extensions/extensions.dart';

class ScannerView extends NavViewStateful<ScannerController> {
  const ScannerView({Key? key}) : super(key: key);

  @override
  ScannerController createController({String? tag}) =>
      Get.put(ScannerController());

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        if (Get.isRegistered<ScannerController>()) {
          Get.find<ScannerController>().focusGained(true);
        }
      },
      onFocusLost: () {
        if (Get.isRegistered<ScannerController>()) {
          Get.find<ScannerController>().focusGained(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan code'),
          automaticallyImplyLeading: true,
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: const Center(
                child: Text(
                  "Visit ${Constants.webChatLogin} on your computer and scan the QR code",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<GlobalKey>(
                valueListenable: controller.qrKeyNotifier,
                builder: (_, key, __) {
                  return QRView(
                    key: key,
                    onQRViewCreated: controller.onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: Colors.orange,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 300,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
