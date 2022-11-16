import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../chat/controllers/chat_controller.dart';

class PreviewContactController extends GetxController {
  //TODO: Implement PreviewContactController


  late List<String> contactList;
  var contactName = "", from = "";

  @override
  void onInit() {
    super.onInit();

    contactList = Get.arguments['contactList'];
    contactName = Get.arguments['contactName'];
    from = Get.arguments['from'];
  }


  shareContact() async {
    var response = await Get.find<ChatController>().sendContactMessage(contactList, contactName);
    debugPrint("ContactResponse ==> $response");
    if(response != null){
      Get.back();
      Get.back();
    }
  }

}
