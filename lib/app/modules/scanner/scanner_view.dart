import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../modules/scanner/scanner_controller.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../extensions/extensions.dart';

class ScannerView extends NavView<ScannerController> {
  const ScannerView({Key? key}) : super(key: key);

  @override
 ScannerController createController({String? tag}) => ScannerController();

  @override
  Widget build(BuildContext context) {
    // var scanArea = (NavUtils.size.width < 400 ||
    //     NavUtils.size.height < 400)
    //     ? 150.0
    //     : 300.0;
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
            child: const Center(child: Text("Visit ${Constants.webChatLogin} on your computer and scan the QR code",style: TextStyle(fontSize: 17),),),
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
