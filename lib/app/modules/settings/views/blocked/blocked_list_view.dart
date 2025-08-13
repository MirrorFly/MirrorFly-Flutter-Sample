import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app_style_config.dart';
import '../../../../common/app_localizations.dart';
import '../../../../data/helper.dart';
import '../../../../extensions/extensions.dart';
import '../../../../modules/settings/views/blocked/blocked_list_controller.dart';

import '../../../../common/widgets.dart';

class BlockedListView extends NavViewStateful<BlockedListController> {
  const BlockedListView({Key? key}) : super(key: key);

  @override
  BlockedListController createController({String? tag}) =>
      Get.put(BlockedListController());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          appBarTheme: AppStyleConfig.blockedListPageStyle.appbarTheme),
      child: Scaffold(
        appBar: AppBar(
          title: Text(getTranslated("blockedContactList")),
          automaticallyImplyLeading: true,
        ),
        body: Obx(() {
          return Center(
            child: controller.blockedUsers.isEmpty
                ? Text(
                    getTranslated("noBlockedContactsFound"),
                    style: AppStyleConfig.blockedListPageStyle.noDataTextStyle,
                    // style: const TextStyle(fontSize: 17, color: Colors.grey),
                  )
                : ListView.builder(
                    itemCount: controller.blockedUsers.length,
                    itemBuilder: (context, index) {
                      var item = controller.blockedUsers[index];
                      return MemberItem(
                        name: getMemberName(item).checkNull(),
                        image: item.image.checkNull(),
                        status: item.mobileNumber.checkNull(),
                        onTap: () {
                          if (item.jid.checkNull().isNotEmpty) {
                            controller.unBlock(item);
                          }
                        },
                        blocked: item.isBlockedMe.checkNull() ||
                            item.isAdminBlocked.checkNull(),
                        unknown: (!item.isItSavedContact.checkNull() ||
                            item.isDeletedContact()),
                        itemStyle: AppStyleConfig
                            .blockedListPageStyle.blockedUserItemStyle,
                      );
                    }),
          );
        }),
      ),
    );
  }
}
