import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/contact_controller.dart';

import '../../../common/debouncer.dart';
import '../../../common/widgets.dart';
import '../../../routes/app_pages.dart';

class ContactListView extends GetView<ContactController> {
  const ContactListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final debouncer = Debouncer(milliseconds: 700);
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: controller.isForward.value
                ? const Icon(Icons.close, color: iconcolor)
                : const Icon(Icons.arrow_back, color: iconcolor),
            onPressed: () {
              controller.isForward.value
                  ? Get.back()
                  : controller.search.value
                      ? controller.backFromSearch()
                      : Get.back();
              // if (controller.search.value) {
              //   controller.backFromSearch();
              // } else {
              //   Get.back();
              // }
            },
          ),
          title: controller.search.value
              ? TextField(
                  onChanged: (text) {
                    debouncer.run(() {
                      controller.searchListener(text);
                    });
                  },
                  controller: controller.searchQuery,
                  autofocus: true,
                  decoration: const InputDecoration(
                      hintText: "Search", border: InputBorder.none),
                )
              : controller.isForward.value
                  ? const Text("Forward to...")
                  : const Text('Contact'),
          iconTheme: const IconThemeData(color: iconcolor),
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
            const SizedBox(width: 10,),
            // Container(
            //   margin: const EdgeInsets.all(16),
            //   child: SvgPicture.asset(moreicon, width: 3.66, height: 16.31),
            // ),
          ],

        ),
        floatingActionButton: controller.isForward.value && controller.selectedUsersList.isNotEmpty ? FloatingActionButton(
          tooltip: "Forward",
          onPressed: () {
            FocusManager.instance.primaryFocus!.unfocus();
            controller.forwardMessages();
          },
          backgroundColor: buttonbgcolor,
          child: const Icon(Icons.check)
        ) : const SizedBox.shrink(),
        body: Obx(() {
          return controller.isPageLoading.value
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: controller.scrollable.value
                      ? controller.usersList.length + 1
                      : controller.usersList.length,
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= controller.usersList.length) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      var item = controller.usersList[index];
                      var image = controller.imagePath(item.image);
                      return InkWell(
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 19.0, top: 10, bottom: 10, right: 10),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: item.image.checkNull().isEmpty
                                    ? iconbgcolor
                                    : buttonbgcolor,
                                shape: BoxShape.circle,
                              ),
                              child: item.image.checkNull().isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : ImageNetwork(
                                      url: item.image.toString(),
                                      width: 48,
                                      height: 48,
                                      clipoval: true,
                                      errorWidget: ProfileTextImage(
                                        text: item.name.checkNull().isEmpty
                                            ? item.mobileNumber.checkNull()
                                            : item.name.checkNull(),
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name.toString(),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    item.mobileNumber.toString(),
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  )
                                ],
                              ),
                            ),
                            const Spacer(),
                            controller.isForward.value
                                ? Checkbox(
                                    value: item.isSelected,
                                    onChanged: (value) {},
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                        onTap: () {
                          controller.isForward.value
                              ? controller.contactSelected(item)
                              : Get.offNamed(Routes.CHAT,
                                  arguments: controller.usersList[index]);
                        },
                      );
                    }
                  });
        }),
      ),
    );
  }
}
