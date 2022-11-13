import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/modules/scanner/scanner_controller.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerView extends GetView<ScannerController> {
  const ScannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan code'),
        automaticallyImplyLeading: true,
      ),
      body:  Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: const Center(child: Text("Visit "+Constants.WEB_CHAT_LOGIN+" on your computer and scan the QR code",style: TextStyle(fontSize: 17),),),
          ),
          Expanded(
            child: QRView(
              key: controller.qrKey,
              onQRViewCreated: controller.onQRViewCreated,
              overlay: QrScannerOverlayShape(
                  borderColor: Colors.orange,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300),
            ),
          ),
        ],
      ),
    );
  }
}
