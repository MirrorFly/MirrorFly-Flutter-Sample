import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../common/widgets.dart';
import '../controllers/preview_contact_controller.dart';

class PreviewContactView extends GetView<PreviewContactController> {
  const PreviewContactView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: controller.from == "contact_pick"
              ? const Text('Send Contacts')
              : const Text('Contact Details'),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Obx(() {
                return SizedBox(
                  height: double.infinity,
                  child: ListView.builder(
                      itemCount: controller.contactList.length,
                      // shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        // var parentIndex = index;
                        var contactItem = controller.contactList[index];
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                              child: Row(
                                children: [
                                  ProfileTextImage(
                                    text: contactItem.userName,
                                    radius: 20,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Text(
                                      contactItem.userName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Colors.grey,
                              thickness: 0.1,
                            ),
                            ListView.builder(
                                itemCount: contactItem.contactNo.length,
                                physics: const ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder:
                                    (BuildContext context, int childIndex) {
                                  var phoneItem =
                                      contactItem.contactNo[childIndex];
                                  return ListTile(
                                    onTap: () {
                                      controller.changeStatus(phoneItem);
                                    },
                                    title: Text(
                                      phoneItem.mobNo,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    subtitle: Text(
                                      phoneItem.mobNoType,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    leading: const Icon(
                                      Icons.phone,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    trailing: Visibility(
                                      visible:
                                          contactItem.contactNo.length > 1 &&
                                              controller.from != "chat",
                                      child: Checkbox(
                                        activeColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        value: phoneItem.isSelected,
                                        onChanged: (bool? value) {
                                          controller.changeStatus(phoneItem);
                                        },
                                      ),
                                    ),
                                  );
                                }),
                            const Divider(
                              color: Colors.grey,
                              thickness: 0.8,
                            ),
                          ],
                        );
                      }),
                );
              }),
              controller.from == "contact_pick"
                  ? Positioned(
                      bottom: 25,
                      right: 20,
                      child: InkWell(
                        onTap: () {
                          controller.shareContact();
                        },
                        child: const CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            radius: 25,
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            )),
                      ))
                  : const SizedBox.shrink()
            ],
          ),
        ));
  }
}
