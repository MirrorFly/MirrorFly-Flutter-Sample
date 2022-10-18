import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/modules/profile/controllers/status_controller.dart';

import '../../../common/constants.dart';
import '../../../nativecall/platformRepo.dart';
import 'addstatus_view.dart';

class StatusListView extends GetView<StatusListController> {
  StatusListView({Key? key}) : super(key: key);
  var controller = Get.put<StatusListController>(StatusListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Status'),
      ),
      body: WillPopScope(
        onWillPop: (){
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
              Text(
                'Your current status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Obx(
                () => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(controller.selectedStatus.value,
                      style: TextStyle(
                          color: textcolor,
                          fontSize: 14,
                          fontWeight: FontWeight.normal)),
                  trailing: SvgPicture.asset(
                    pencilediticon,
                    fit: BoxFit.contain,
                  ),
                  onTap: () {
                    Get.to(AddStatusView())?.then((value){
                      if(value!=null){
                        controller.selectedStatus.value=value;
                        controller.getStatusList();
                      }
                    });
                  },
                ),
              ),
              AppDivider(padding: 0.0,),
              SizedBox(height: 10,),
              Text(
                'Select Your new status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Obx(() => controller.statuslist.isNotEmpty
                  ? Expanded(
                child: ListView.builder(
                    itemCount: controller.statuslist.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var item = controller.statuslist[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.status,
                            style: TextStyle(
                                color: item.isCurrentStatus ? textblack1color : textcolor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        trailing: item.isCurrentStatus
                            ? SvgPicture.asset(
                          tickicon,
                          fit: BoxFit.contain,
                        )
                            : const SizedBox(),
                        onTap: (){
                          PlatformRepo().updateProfileStatus(controller.addstatuscontroller.text.trim().toString()).then((value){
                            controller.selectedStatus.value=item.status;
                            controller.getStatusList();
                          }).catchError((er){
                            toToast(er);
                          });
                        },
                      );
                    }),
              )
                  : SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
