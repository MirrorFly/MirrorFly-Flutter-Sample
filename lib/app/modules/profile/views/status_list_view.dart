import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/profile/controllers/status_controller.dart';

import '../../../common/constants.dart';
import 'add_status_view.dart';

class StatusListView extends GetView<StatusListController> {
  const StatusListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Status'),
      ),
      body: WillPopScope(
        onWillPop: () {
          Get.back(result: controller.selectedStatus.value);
          return Future.value(false);
        },
        child: Container(
          padding: const EdgeInsets.all(
            20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your current status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
                    Get.to(const AddStatusView(), arguments: {
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
              const Text(
                'Select Your new status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
