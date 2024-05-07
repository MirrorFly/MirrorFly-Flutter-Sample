import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';

import 'datausage_controller.dart';

class DataUsageListView extends GetView<DataUsageController> {
  const DataUsageListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(getTranslated("dataUsageSettings")),
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      getTranslated("mediaAutoDownload"),
                      style: const TextStyle(
                          color: appbarTextColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      getTranslated("whenUsingMobileData"),
                      style: const TextStyle(
                          color: textColor,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600),
                    ),
                    trailing: SvgPicture.asset(
                        controller.openMobileData ? arrowUp : arrowDown),
                    onTap: () {
                      controller.openMobile();
                    },
                  ),
                  Visibility(
                    visible: controller.openMobileData,
                    child: Column(
                      children: [
                        mediaItem(getTranslated("autoDownloadPhoto"), controller.autoDownloadMobilePhoto, controller.mobile),
                        mediaItem(getTranslated("autoDownloadVideo"), controller.autoDownloadMobileVideo, controller.mobile),
                        mediaItem(getTranslated("autoDownloadAudio"), controller.autoDownloadMobileAudio, controller.mobile),
                        mediaItem(getTranslated("autoDownloadDocument"), controller.autoDownloadMobileDocument, controller.mobile),
                      ],
                    )//buildMediaTypeList(controller.mobile),
                  ),
                  ListTile(
                    title: Text(
                      getTranslated("whenUsingWifiData"),
                      style: const TextStyle(
                          color: textColor,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600),
                    ),
                    trailing: SvgPicture.asset(
                        controller.openWifiData ? arrowUp : arrowDown),
                    onTap: () {
                      controller.openWifi();
                    },
                  ),
                  Visibility(
                    visible: controller.openWifiData,
                      child: Column(
                        children: [
                          mediaItem(getTranslated("autoDownloadPhoto"), controller.autoDownloadWifiPhoto, controller.wifi),
                          mediaItem(getTranslated("autoDownloadVideo"), controller.autoDownloadWifiVideo, controller.wifi),
                          mediaItem(getTranslated("autoDownloadAudio"), controller.autoDownloadWifiAudio, controller.wifi),
                          mediaItem(getTranslated("autoDownloadDocument"), controller.autoDownloadWifiDocument, controller.wifi),
                        ],
                      )//buildMediaTypeList(controller.wifi),
                  ),
                ],
              );
            }),
          ),
        ));
  }

  Widget mediaItem(String item, bool on, String type) {
    return Padding(
          padding: const EdgeInsets.only(
              left: 15.0, right: 5, bottom: 5),
          child: InkWell(
            child: Row(
              children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(item,
                          style: const TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    on ? tickRoundBlue : tickRound,
                  ),
                ),
              ],
            ),
            onTap: () {
              controller.onClick(type,item);
            },
          ),
        );
  }
}
