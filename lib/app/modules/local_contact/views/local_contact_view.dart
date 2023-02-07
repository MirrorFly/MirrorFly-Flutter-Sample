import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/model/local_contact_model.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../controllers/local_contact_controller.dart';

class LocalContactView extends GetView<LocalContactController> {
  const LocalContactView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          titleSpacing: 0.0,
          title: controller.search.value
              ? TextField(
                  controller: controller.searchTextController,
                  onChanged: (text) => controller.onSearchTextChanged(text),
                  autofocus: true,
                  decoration: const InputDecoration(
                      hintText: "Search...", border: InputBorder.none),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact to send',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      '${controller.contactsSelected.length} Selected',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
          actions: [
            controller.search.value
                ? const SizedBox()
                : IconButton(
                    icon: SvgPicture.asset(
                      searchIcon,
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
          ],
        ),
        body: WillPopScope(
          onWillPop: () {
            if (controller.search.value) {
              controller.searchTextController.text = "";
              controller.onSearchCancelled();
              controller.search.value = false;
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: SafeArea(
            child: Obx(() => controller.contactList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : contactListView()),
          ),

        ),
        floatingActionButton: Visibility(
          visible: controller.contactsSelected.isNotEmpty,
          child: FloatingActionButton(onPressed: () {
            controller.shareContact();
          },
            child:  SvgPicture.asset(
              rightArrowProceed,
              width: 18,
            ),
          ),
        ),
      );
    });
  }

  selectedListView(RxList<LocalContact> contactsSelected) {
    return contactsSelected.isNotEmpty
        ? SizedBox(
            height: 70,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: contactsSelected.length,
                itemBuilder: (context, index) {
                  var item = contactsSelected.elementAt(index);
                  return InkWell(
                    onTap: () {
                      controller.contactSelected(item);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              ProfileTextImage(
                                text: controller.name(item.contact),
                                radius: 22,
                              ),
                              Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: SvgPicture.asset(
                                    closeContactIcon,
                                    width: 18,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          )
        : const SizedBox.shrink();
  }

  contactListView() {
    return Obx(() {
      return Column(
        children: [
          selectedListView(controller.contactsSelected),
          controller.searchList.isEmpty &&
                  controller.searchTextController.text.isNotEmpty
              ? const Center(child: Text("No result found"))
              : Expanded(
                  child: ListView.builder(
                      itemCount: controller.searchList.length,
                      itemBuilder: (context, index) {
                        var item = controller.searchList.elementAt(index);
                        return InkWell(
                          onTap: () {
                            controller.contactSelected(
                                controller.searchList.elementAt(index));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    ProfileTextImage(
                                      text: controller.name(item.contact),
                                      radius: 17.5,
                                    ),
                                    Visibility(
                                      visible: item.isSelected,
                                      child: Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: SvgPicture.asset(
                                            contactSelectTick,
                                            width: 12,
                                          )),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                    child: Text(
                                  controller.name(item.contact),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
        ],
      );
    });
  }
}
