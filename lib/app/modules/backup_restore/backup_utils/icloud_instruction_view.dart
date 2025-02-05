import 'package:flutter/material.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../settings/views/settings_widgets.dart';

class IcloudInstructionView extends StatelessWidget {
  const IcloudInstructionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("restoreBackup")),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
              onPressed: () => NavUtils.back(),
              child: Text(getTranslated("done")))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Text(
                getTranslated("iCloudTitleDesc"),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: AppUtils.assetIcon(
                    assetName: restoreSetting, width: 30, height: 30),
                title: Text(
                  getTranslated("openIphoneSettings"),
                  style: TextStyle(fontSize: 12, color: Color(0xff767676)),
                ),
              ),
              ListTile(
                leading: AppUtils.assetIcon(
                    assetName: restoreCloud, width: 30, height: 30),
                title: Text(getTranslated("iCloudSignInDesc"),
                    style: TextStyle(fontSize: 12, color: Color(0xff767676))),
              ),
              ListTile(
                leading: AppUtils.assetIcon(
                    assetName: restoreCloud, width: 30, height: 30),
                title: Text(getTranslated("iCloudDriveOnDesc"),
                    style: TextStyle(fontSize: 12, color: Color(0xff767676))),
              ),
              ListTile(
                leading: AppUtils.assetIcon(
                    assetName: restoreCloud, width: 30, height: 30),
                title: Text(getTranslated("iCloudDriveMirrorFlyOnDesc"),
                    style: TextStyle(fontSize: 12, color: Color(0xff767676))),
              ),
              const SizedBox(height: 35),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: lockItem(
                    title: getTranslated("appName"),
                    on: true,
                    onToggle: (value) {},
                    subtitle: ''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}