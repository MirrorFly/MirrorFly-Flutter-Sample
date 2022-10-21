import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';

import '../../chat/controllers/chat_controller.dart';

class LocalContactController extends GetxController {
  //TODO: Implement LocalContactController

  var search=false.obs;
  var contactList = List<Contact>.empty(growable: true).obs;
  var searchList = List<Contact>.empty(growable: true).obs;

  @override
  void onInit() {
    super.onInit();
    getContacts();
  }

  @override
  void onReady() {
    super.onReady();
  }
  getContacts() async{
    contactList.addAll(await ContactsService.getContacts());

  }
  onSearchTextChanged(String text) async {
    searchList.clear();
    if (text.isEmpty) {
      return;
    }

    contactList.forEach((userDetail) {
      if (userDetail.displayName!.contains(text))
        searchList.add(userDetail);
    });

  }

  shareContact(List<Item>? mobileNumberList, String contactName) async {
    var contactList = List<String>.empty(growable: true);
    for (var mobileNumber in mobileNumberList!) {
      // final number = FlutterLibphonenumber().formatNumberSync(mobileNumber.value!, phoneNumberFormat: PhoneNumberFormat.international, phoneNumberType: PhoneNumberType.mobile);
      final number = mobileNumber.value;
      contactList.add(number!.replaceAll(RegExp('[+() -]'), ''));
    }

    Get.toNamed(Routes.PREVIEW_CONTACT, arguments: {"contactList" : contactList, "contactName": contactName, "from": "contact_pick"});

  }
}
