import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../chat/controllers/chat_controller.dart';

class PreviewContactController extends GetxController {


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
    if(await AppUtils.isNetConnected()) {
      if(contactList.isNotEmpty) {
        var response = await Get.find<ChatController>().sendContactMessage(
            contactList, contactName);
        debugPrint("ContactResponse ==> $response");
        if (response != null) {
          Get.back();
          Get.back();
        }
      }else{
        toToast("Contact Number is Empty");
      }
    }else{
      toToast(Constants.noInternetConnection);
    }

  }

}
