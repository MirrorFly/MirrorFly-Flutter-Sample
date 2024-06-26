import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/modules/profile/controllers/status_controller.dart';

import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';

class StatusListView extends NavViewStateful<StatusListController> {
  const StatusListView({Key? key}) : super(key: key);

  @override
StatusListController createController({String? tag}) => Get.put(StatusListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(getTranslated("status")),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop){
          if (didPop) {
            return;
          }
          controller.onBackPressed(controller.selectedStatus.value);
        },
        child: Container(
          padding: const EdgeInsets.all(
            20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated("yourCurrentStatus"),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Obx(
                () => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(controller.selectedStatus.value,
                      maxLines: null,
                      style: const TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.normal)),
                  trailing: SvgPicture.asset(
                    pencilEditIcon,
                    fit: BoxFit.contain,
                  ),
                  onTap: () {
                    NavUtils.toNamed(Routes.addProfileStatus, arguments: {
                      "status": controller.selectedStatus.value
                    })?.then((value) {
                      if (value != null) {
                        controller.insertStatus();
                      }
                    });
                  },
                ),
              ),
              const AppDivider(),
              const SizedBox(
                height: 10,
              ),
              Text(
                getTranslated("selectNewStatus"),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Obx(() => controller.statusList.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                          itemCount: controller.statusList.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var item = controller.statusList[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.status.checkNull(),
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: item.status ==
                                              controller.selectedStatus.value
                                          ? textBlack1color
                                          : textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              trailing:
                                  item.status == controller.selectedStatus.value
                                      ? SvgPicture.asset(
                                          tickIcon,
                                          fit: BoxFit.contain,
                                        )
                                      : const SizedBox(),
                              onTap: () {
                                controller.updateStatus(item.status.checkNull(),
                                    item.id.checkNull());
                              },
                              onLongPress: (){
                                debugPrint("Status list long press");
                                controller.deleteStatus(item);
                              },
                            );
                          }),
                    )
                  : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
