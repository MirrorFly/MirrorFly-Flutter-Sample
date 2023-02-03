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
              :  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contact to send', style: TextStyle(fontSize: 15),),
                  Text('${controller.contactsSelected.length} Selected', style: const TextStyle(fontSize: 12),),
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
        body: SafeArea(
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

      return controller.searchList.isNotEmpty && controller.search.value ? ListView.builder(
          itemCount: controller.searchList.length,
          itemBuilder: (context, index) {
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
                    const SizedBox(width: 10,),
                    Text(controller.searchList
                        .elementAt(index)
                        .displayName!),
                  ],
                ),
              ),
            );
          }
      ) :  controller.searchList.isEmpty && controller.searchTextController.text.isNotEmpty ? const Center(child: Text("No result found")) : ListView.builder(
          itemCount: controller.contactList.length,
          itemBuilder: (context, index) {
            var item = controller.contactList.elementAt(index);
            return InkWell(
              onTap: (){
                controller.shareContact(controller.contactList.elementAt(index).phones, controller.name(controller.contactList.elementAt(index)));
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    ProfileTextImage(
                      text: controller.name(item),
                    ),
                    const SizedBox(width: 10,),
                    Flexible(child: Text(controller.name(item), overflow: TextOverflow.ellipsis,)),
                  ],
                ),
              ),
            );
          }
      );
    });
  }
}
