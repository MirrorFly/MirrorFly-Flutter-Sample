import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

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
          title: controller.search.value
              ? TextField(
            onChanged: (text) => controller.onSearchTextChanged(text),
            autofocus: true,
            decoration: const InputDecoration(
                hintText: "Search", border: InputBorder.none),
          )
              : Text('Contacts'),
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
          ],
        ),
        body: Container(
          child: Obx(() =>
          controller.contactList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : contactListView()),
        ),
      );
    });
  }

  contactListView() {
    return Obx(() {
      return controller.searchList.length > 0 ? ListView.builder(
          itemCount: controller.searchList.length,
          shrinkWrap: true,
          // reverse: true,
          // controller: controller.scrollController,
          itemBuilder: (context, index) {
            // int reversedIndex = chatList.length - 1 - index;
            return InkWell(
              onTap: (){
                controller.shareContact(controller.searchList.elementAt(index).phones,controller.searchList
                    .elementAt(index)
                    .displayName!);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    ProfileTextImage(
                      text: controller.searchList
                          .elementAt(index)
                          .displayName!,
                    ),
                    SizedBox(width: 10,),
                    Text(controller.searchList
                        .elementAt(index)
                        .displayName!),
                  ],
                ),
              ),
            );
          }
      ) :  ListView.builder(
          itemCount: controller.contactList.length,
          shrinkWrap: true,
          // reverse: true,
          // controller: controller.scrollController,
          itemBuilder: (context, index) {
            // int reversedIndex = chatList.length - 1 - index;
            return InkWell(
              onTap: (){
                controller.shareContact(controller.contactList.elementAt(index).phones, controller.contactList.elementAt(index).displayName!);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    ProfileTextImage(
                      text: controller.contactList
                          .elementAt(index)
                          .displayName!,
                    ),
                    SizedBox(width: 10,),
                    Text(controller.contactList
                        .elementAt(index)
                        .displayName!),
                  ],
                ),
              ),
            );
          }
      );
    });
  }
}
