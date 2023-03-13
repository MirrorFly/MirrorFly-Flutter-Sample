import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';

import 'datausage_controller.dart';

class DataUsageListView extends GetView<DataUsageController> {
  const DataUsageListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Data Usage Setting'),
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    title: Text(
                      Constants.mediaAutoDownload,
                      style: TextStyle(
                          color: appbarTextColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      Constants.whenUsingMobileData,
                      style: TextStyle(
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
                        mediaItem(Constants.photo, controller.autoDownloadMobilePhoto, controller.mobile),
                        mediaItem(Constants.video, controller.autoDownloadMobileVideo, controller.mobile),
                        mediaItem(Constants.audio, controller.autoDownloadMobileAudio, controller.mobile),
                        mediaItem(Constants.document, controller.autoDownloadMobileDocument, controller.mobile),
                      ],
                    )//buildMediaTypeList(controller.mobile),
                  ),
                  ListTile(
                    title: const Text(
                      Constants.whenUsingWifiData,
                      style: TextStyle(
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
                          mediaItem(Constants.photo, controller.autoDownloadWifiPhoto, controller.wifi),
                          mediaItem(Constants.video, controller.autoDownloadWifiVideo, controller.wifi),
                          mediaItem(Constants.audio, controller.autoDownloadWifiAudio, controller.wifi),
                          mediaItem(Constants.document, controller.autoDownloadWifiDocument, controller.wifi),
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
