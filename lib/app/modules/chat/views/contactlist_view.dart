import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/contact_controller.dart';

import '../../../common/widgets.dart';
import '../../../routes/app_pages.dart';

class ContactListView extends GetView<ContactController> {
  const ContactListView({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: iconcolor),
            onPressed: () {
              if (controller.search.value) {
                controller.backfromSearch();
              } else {
                Get.back();
              }
            },
          ),
          title: controller.search.value
              ? TextField(
                  onChanged: (text) => controller.searchListener(text),
                  controller: controller.searchQuery,
                  autofocus: true,
                  decoration: const InputDecoration(
                      hintText: "Search", border: InputBorder.none),
                )
              : Text('Contact'),
          iconTheme: IconThemeData(color: iconcolor),
          actions: [
            controller.search.value
                ? const SizedBox()
                : IconButton(
                    icon: SvgPicture.asset(
                      searchicon,
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                    onPressed: () {
                      if (controller.search.value) {
                        controller.search.value = false;
                      } else {
                        controller.search.value = true;
                      }
                    },
                  ),
            Container(
              margin: EdgeInsets.all(16),
              child: SvgPicture.asset(moreicon, width: 3.66, height: 16.31),
            ),
          ],
        ),
        body: Obx(() {
          return controller.isPageLoading.value
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: controller.scrollable.value
                      ? controller.userslist.value.length + 1
                      : controller.userslist.value.length,
                  controller: controller.scrollcontroller,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= controller.userslist.value.length) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      var item = controller.userslist.value[index];
                      var image = controller.imagepath(item.image);
                      return InkWell(
                        child: Container(
                          child: Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(
                                      left: 19.0,
                                      top: 10,
                                      bottom: 10,
                                      right: 10),
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color:
                                          item.image.checkNull().isEmpty
                                              ? iconbgcolor
                                              : buttonbgcolor,
                                      shape: BoxShape.circle,),
                                  child: item.image.checkNull().isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )
                                      : ImageNetwork(
                                          url: item.image.toString(),
                                          width: 48,
                                          height: 48,
                                          clipoval: true,
                                          errorWidget: ProfileTextImage(
                                            text: item.name.checkNull().isEmpty ? item.mobileNumber.checkNull() : item.name.checkNull(),
                                          ),
                                        ),
                                  ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      item.mobileNumber.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        onTap: () {
                          Get.offNamed(Routes.CHAT,
                              arguments: controller.userslist.value[index]);
                        },
                      );
                    }
                    /*return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text("${controller.users.value[index].name}"),
                      subtitle: Text("${controller.users.value[index].mobileNumber}"),
                      onTap: () {},
                    );*/
                  });
        }),
      ),
    );
  }
}
