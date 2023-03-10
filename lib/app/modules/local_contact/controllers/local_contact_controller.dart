
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';

import '../../../common/constants.dart';
import '../../../model/local_contact_model.dart';


class LocalContactController extends GetxController {

  var search=false.obs;

  var contactList = List<LocalContact>.empty(growable: true).obs;
  var searchList = List<LocalContact>.empty(growable: true).obs;
  var contactsSelected = List<LocalContact>.empty(growable: true).obs;
  TextEditingController searchTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getContacts();
  }

  getContacts() async{
    await ContactsService.getContacts().then((localContactList) {
      for (var userDetail in localContactList) {
        if (userDetail.phones != null && userDetail.phones!.isNotEmpty) {
          LocalContact localContact = LocalContact(contact: userDetail, isSelected: false);
          contactList.add(localContact);
          searchList.add(localContact);
        }
      }
    });
  }

  onSearchCancelled(){
    searchList.clear();
    searchList.addAll(contactList);
  }

  onSearchTextChanged(String text) async {
    debugPrint("ontextChanged--> $text");
    searchList.clear();
    if (searchTextController.text.trim().isEmpty) {
      searchList.addAll(contactList);
      return;
    }
    for (var userDetail in contactList) {
      if (name(userDetail.contact).toString().toLowerCase().contains(searchTextController.text.trim().toLowerCase())) {
        searchList.add(userDetail);
      }
    }
  }

  shareContact() async {
    // var contactList = List<LocalContact>.empty(growable: true);
    // for (var mobileNumber in contactsSelected) {
    //   final number = mobileNumber.value;
    //   contactList.add(number!.replaceAll(RegExp('[+() -]'), ''));
    // }

    Get.toNamed(Routes.previewContact, arguments: {"contactList" : contactsSelected,"shareContactList" : contactsSelected, "from": "contact_pick"});

  }

  name(Contact item) {
    return item.displayName ?? item.givenName ?? item.middleName ?? item.androidAccountName ?? item.familyName ?? "";
  }

  isValidContactNumber(List<Item> phones){
    return phones.isNotEmpty;
  }

  void contactSelected(LocalContact localContact) {

    if(contactsSelected.contains(localContact)){
      localContact.isSelected = false;
      contactsSelected.remove(localContact);
    }else {
      if(contactsSelected.length == 5){
        toToast("Can't share more than 5 contacts");
        return;
      }
      localContact.isSelected = true;
      contactsSelected.add(localContact);
    }
  }

}
