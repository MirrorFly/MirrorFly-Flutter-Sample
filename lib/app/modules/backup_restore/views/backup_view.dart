
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/backup_restore/controllers/backup_controller.dart';

import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/widgets.dart';
import '../../../extensions/extensions.dart';
import '../../settings/views/settings_widgets.dart';

class BackupView extends NavViewStateful<BackupController> {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("chatBackup")),
        centerTitle: true,
      ),
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(getTranslated("lastBackUp"), style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0),
              child: Text(getTranslated("lastBackUpDesc"), style: TextStyle(color: Color(0xff767676)),),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Text(getTranslated("lastBackUp"), style: TextStyle(color: Color(0xff767676))),
                  Text("8 March 2020 | 4:30 pm", style: const TextStyle(color: Colors.black),)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0),
              child: Row(
                children: [
                  Text(getTranslated("totalSize"), style: TextStyle(color: Color(0xff767676))),
                  Text("1.4 GB", style: const TextStyle(color: Colors.black)),
                ],
              ),
            ),
            const SizedBox(height: 30,),
            Center(
              child: ElevatedButton(
                style: AppStyleConfig.loginPageStyle.loginButtonStyle,
                onPressed: () {

                },
                child: Text(
                  getTranslated("backupNow"),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            const AppDivider(color: Color(0xffEBEBEB)),
            lockItem(title: getTranslated("autoBackup"),
                on: true,
                onToggle: (value) {}, subtitle: ''),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(getTranslated("googleDriveSettings"), style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
            ),

            ListTile(
              title: Text(getTranslated("googleAccount"), style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
              subtitle: Text(getTranslated("googleAccountEmail"), style: const TextStyle(color: Colors.black, fontSize: 12,)),
              trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            ),

            const AppDivider(color: Color(0xffEBEBEB)),

            ListTile(
              title: Text(getTranslated("backUpOver"), style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: Text(getTranslated("wifiOnly"), style: const TextStyle(color: Colors.black, fontSize: 12)),
              trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            ),

            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(getTranslated("localBackUpRestore"), style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0),
              child: Text(getTranslated("localBackupDesc"), style: TextStyle(color: Color(0xff767676))),
            ),

            const SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: AppStyleConfig.loginPageStyle.loginButtonStyle,
                  onPressed: () {

                  },
                  child: Text(
                    getTranslated("download"),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: AppStyleConfig.loginPageStyle.loginButtonStyle,
                  onPressed: () {

                  },
                  child: Text(
                    getTranslated("restore"),
                  ),
                ),
              ],
            )
          ],
        ),
      )),
    );

  }

  @override
  BackupController createController({String? tag}) =>
      Get.put(BackupController());

}