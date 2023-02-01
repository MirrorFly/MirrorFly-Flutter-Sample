import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/blocked/blocked_list_controller.dart';

import '../../../../common/widgets.dart';

class BlockedListView extends GetView<BlockedListController> {
  const BlockedListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Contact List'),
        automaticallyImplyLeading: true,
      ),
      body: Obx(() {
        return Center(
          child: controller.blockedUsers.isEmpty ? const Text(
            "No Blocked Contacts found",
            style: TextStyle(fontSize: 17, color: Colors.grey),) :
          ListView.builder(
            itemCount: controller.blockedUsers.length,
              itemBuilder: (context, index) {
            var item = controller.blockedUsers[index];
            return memberItem(name :item.name.checkNull(),image: item.image.checkNull(),status: item.mobileNumber.checkNull(),onTap: (){
              if (item.jid.checkNull().isNotEmpty) {
                controller.unBlock(item);
              }
            });
          }),
        );
      }),
    );
  }
}
