import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/scanner/scanner_controller.dart';

import '../../common/constants.dart';

class WebLoginResultView extends GetView<ScannerController> {
  const WebLoginResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Settings'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(onPressed: ()=>controller.addLogin(), icon: Icon(Icons.add))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(ic_qr_scanner_web_login, fit: BoxFit.cover,),
            FutureBuilder(
                future: controller.getWebLoginDetails(),
                builder: (c, data) {
                  return Obx(() {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.weblogins.length,
                        itemBuilder: (context, index) {
                          var item = controller.weblogins[index];
                          return ListItem(
                            leading: Image.asset(
                                controller.getImageForBrowser(item),width: 50,height: 50,),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.webBrowserName.checkNull()),
                                Text("Last Login", style: TextStyle(
                                    color: textcolor, fontSize: 14),),
                                Text(item.lastLoginTime.checkNull(),
                                  style: TextStyle(
                                      color: textcolor, fontSize: 14),),
                              ],
                            ),
                            dividerpadding: EdgeInsets.zero,
                            onTap: () {},);
                        });
                  });
                }),
            ListTile(contentPadding: EdgeInsets.zero, title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.power_settings_new_rounded),
                SizedBox(width: 8,),
                Text("LOGOUT FROM ALL COMPUTERS"),
              ],
            ), onTap: () =>controller.logoutWeb()),
            Text("Visit " + Constants.WEB_CHAT_LOGIN,
              style: TextStyle(color: textcolor, fontSize: 14),),
          ],
        ),
      ),
    );
  }
}
