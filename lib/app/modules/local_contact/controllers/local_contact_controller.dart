import 'package:contacts_service/contacts_service.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';


class LocalContactController extends GetxController {
  //TODO: Implement LocalContactController

  var search=false.obs;
  var contactList = List<Contact>.empty(growable: true).obs;
  var searchList = List<Contact>.empty(growable: true).obs;

  var contactsSelected = List<Contact>.empty(growable: true).obs;

  @override
  void onInit() {
    super.onInit();
    getContacts();
  }


  getContacts() async{
    contactList.addAll(await ContactsService.getContacts());

  }
  onSearchTextChanged(String text) async {
    searchList.clear();
    if (text.isEmpty) {
      return;
    }

    for (var userDetail in contactList) {
      if (name(userDetail).toString().toLowerCase().contains(text.toLowerCase())) {
        searchList.add(userDetail);
      }
    }

  }

  shareContact(List<Item>? mobileNumberList, String contactName) async {
    var contactList = List<String>.empty(growable: true);
    for (var mobileNumber in mobileNumberList!) {
      // final number = FlutterLibphonenumber().formatNumberSync(mobileNumber.value!, phoneNumberFormat: PhoneNumberFormat.international, phoneNumberType: PhoneNumberType.mobile);
      final number = mobileNumber.value;
      contactList.add(number!.replaceAll(RegExp('[+() -]'), ''));
    }

    Get.toNamed(Routes.previewContact, arguments: {"contactList" : contactList, "contactName": contactName, "from": "contact_pick"});

  }

  name(Contact item) {
    return item.displayName ?? item.givenName ?? item.middleName ?? item.androidAccountName ?? item.familyName ?? "";
  }
}
