import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../controllers/busy_status_controller.dart';
import 'add_busy_status_view.dart';

class BusyStatusView extends StatefulWidget {
  const BusyStatusView({super.key, this.status, this.enableAppBar = true});
  final String? status;
  final bool enableAppBar;

  @override
  State<BusyStatusView> createState() => _BusyStatusViewState();
}

class _BusyStatusViewState extends State<BusyStatusView> {
  final BusyStatusController controller = BusyStatusController().get();


  @override
  void initState() {
    controller.init(widget.status);
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<BusyStatusController>();
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(getTranslated("editBusyStatus")),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslated("yourBusyStatus"),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                ),
                Obx(
                      () =>
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(controller.busyStatus.value,
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
                          controller.addStatusController.text = controller.busyStatus.value;
                          controller.onChanged();
                          NavUtils.to(AddBusyStatusView(status: controller.selectedStatus.value,),arguments: {"status":controller.selectedStatus.value})?.then((value){
                            if(value!=null){
                              controller.insertBusyStatus(value);
                            }
                          });
                        },
                      ),
                ),
                const SizedBox(
                  height: 5,
                ),

                Text(
                  getTranslated("busyStatusDescription"),
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  getTranslated("selectYourBusyStatus"),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: Obx(() {
                    debugPrint("reloading list");
                    return controller.busyStatusList.isNotEmpty
                        ?  ListView.builder(
                        itemCount: controller.busyStatusList.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var item = controller.busyStatusList[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.status.checkNull(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: item.status ==
                                        controller.busyStatus.value
                                        ? textBlack1color
                                        : textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                            trailing: item.status == controller.busyStatus.value
                                ? SvgPicture.asset(
                              tickIcon,
                              fit: BoxFit.contain,
                            ) : const SizedBox(),
                            onTap: () {
                              controller.updateBusyStatus(
                                  index, item.status.checkNull());
                            },
                            onLongPress: () {
                              controller.deleteBusyStatus(item, context);
                            },
                          );
                        }) : const SizedBox();
                  }),
                ),
              ],
            ),
          ),
        ));
  }
}
