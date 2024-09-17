import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets.dart';
import '../../extensions/extensions.dart';
import '../../modules/scanner/scanner_controller.dart';

import '../../common/constants.dart';
import '../../data/utils.dart';

class WebLoginResultView extends NavViewStateful<ScannerController> {
  const WebLoginResultView({Key? key}) : super(key: key);

  @override
ScannerController createController({String? tag}) => Get.put(ScannerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Settings'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(onPressed: ()=>controller.addLogin(), icon: const Icon(Icons.add))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppUtils.assetIcon(assetName:icQrScannerWebLogin, fit: BoxFit.cover,),
            FutureBuilder(
                future: controller.getWebLoginDetails(),
                builder: (c, data) {
                  return Obx(() {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.webLogins.length,
                        itemBuilder: (context, index) {
                          var item = controller.webLogins[index];
                          return ListItem(
                            leading: AppUtils.assetIcon(assetName:
                                controller.getImageForBrowser(item),width: 50,height: 50,),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.webBrowserName.checkNull()),
                                const Text("Last Login", style: TextStyle(
                                    color: textColor, fontSize: 14),),
                                Text(item.lastLoginTime.checkNull(),
                                  style: const TextStyle(
                                      color: textColor, fontSize: 14),),
                              ],
                            ),
                            dividerPadding: EdgeInsets.zero,
                            onTap: () {},);
                        });
                  });
                }),
            ListTile(contentPadding: EdgeInsets.zero, title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.power_settings_new_rounded),
                SizedBox(width: 8,),
                Text("LOGOUT FROM ALL COMPUTERS"),
              ],
            ), onTap: () =>controller.logoutWeb()),
            const Text("Visit ${Constants.webChatLogin}",
              style: TextStyle(color: textColor, fontSize: 14),),
          ],
        ),
      ),
    );
  }
}
