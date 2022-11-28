import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../data/session_management.dart';
import '../../../data/helper.dart';
import 'package:flysdk/flysdk.dart';
import '../../../routes/app_pages.dart';

class DeleteAccountController extends GetxController {

  var india = CountryData(name: "India", dialCode: "+91", code: "IN");
  var selectedCountry = CountryData(name: "India", dialCode: "+91", code: "IN").obs;

  String? get countryCode => selectedCountry.value.dialCode;
  TextEditingController mobileNumber = TextEditingController();


  deleteAccount() {
    if(mobileNumber.text.isEmpty){
      toToast("Please Enter Mobile Number");
      return;
    }
    if(mobileNumber.text != SessionManagement.getMobileNumber()){
      Helper.showAlert(message: "The mobile number you entered doesn't match your account", actions: [
        TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Ok")),
      ]);
      return;
    }

    Get.toNamed(Routes.DELETE_ACCOUNT_REASON);
  }

}
