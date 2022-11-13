import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
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
          IconButton(onPressed: (){}, icon: Icon(Icons.add))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(ic_qr_scanner_web_login,fit: BoxFit.cover,),
            FutureBuilder(
              future: controller.getWebLoginDetails(),
                builder: (c,data){
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: 4,
                  itemBuilder: (context,index){
                    return ListItem(
                      leading:Icon(Icons.add_circle_outline),title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Chrome 107.0.0.0"),
                        Text("Last Login",style: TextStyle(color: textcolor,fontSize: 14),),
                        Text("Sat, 12 Nov 2022 22:12:37 PM",style: TextStyle(color: textcolor,fontSize: 14),),
                      ],
                    ),dividerpadding: EdgeInsets.zero,onTap: (){},);
                  });
            }),
            ListTile(contentPadding: EdgeInsets.zero,title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.power_settings_new_rounded),
                SizedBox(width: 8,),
                Text("LOGOUT FROM ALL COMPUTERS"),
              ],
            ), onTap: (){}),
            Text("Visit "+Constants.WEB_CHAT_LOGIN,style: TextStyle(color: textcolor,fontSize: 14),),
          ],
        ),
      ),
    );
  }
}
