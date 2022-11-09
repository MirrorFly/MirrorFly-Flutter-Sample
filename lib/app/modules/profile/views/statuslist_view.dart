import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
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
              const Text(
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
                    Get.to(AddStatusView(),arguments: {"status":controller.selectedStatus.value})?.then((value){
                      if(value!=null){
                        controller.updateStatus();
                      }
                    });
                  },
                ),
              ),
              AppDivider(),
              const SizedBox(height: 10,),
              const Text(
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
                        title: Text(item.status.checkNull(),
                            style: TextStyle(
                                color: item.status==controller.selectedStatus.value ? textblack1color : textcolor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        trailing: item.status==controller.selectedStatus.value
                            ? SvgPicture.asset(
                          tickicon,
                          fit: BoxFit.contain,
                        )
                            : const SizedBox(),
                        onTap: (){
                          controller.updateStatus(item.status.checkNull());
                          /*Helper.showLoading();
                          PlatformRepo().updateProfileStatus(controller.addstatuscontroller.text.trim().toString()).then((value){
                            controller.selectedStatus.value=item.status.checkNull();
                            var data = json.decode(value.toString());
                            toToast(data['message'].toString());
                            Helper.hideLoading();
                            if(data['status']) {
                              controller.getStatusList();
                            }
                          }).catchError((er){
                            toToast(er);
                          });*/
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
