import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/session_management.dart';
import '../../../data/helper.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../../../routes/app_pages.dart';

class DeleteAccountController extends GetxController {

  var india = CountryData(name: "India", dialCode: "+91", code: "IN");
  var selectedCountry = CountryData(name: "India", dialCode: "+91", code: "IN").obs;

  String? get countryCode => selectedCountry.value.dialCode;
  TextEditingController mobileNumber = TextEditingController();


  deleteAccount() async {
    if(await AppUtils.isNetConnected()) {
      if(mobileNumber.text.isEmpty){
        Helper.showAlert(message: getTranslated("enterYourMobileNumber"), actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(getTranslated("ok"),style: TextStyle(color: buttonBgColor))),
        ]);
        return;
      }
      LogMessage.d("SessionManagement.getMobileNumber()", SessionManagement.getMobileNumber().toString().trim());
      LogMessage.d("SessionManagement.getCountryCode()", SessionManagement.getCountryCode().toString());
      LogMessage.d("!Constants.enableContactSync", Constants.enableContactSync.toString());
      LogMessage.d("countryCode", countryCode.toString());
      var mobileNumberWithCountryCode = '${countryCode?.replaceAll('+', '')}${mobileNumber.text.trim()}';
      LogMessage.d("mobileNumberWithCountryCode", mobileNumberWithCountryCode);
      if(!Constants.enableContactSync) {
        if ((mobileNumber.text.trim() != SessionManagement.getMobileNumber() && mobileNumberWithCountryCode != SessionManagement.getMobileNumber()) ||
            SessionManagement.getCountryCode()?.replaceAll('+', '') !=
                countryCode?.replaceAll('+', '')) {
          Helper.showAlert(
              message: getTranslated("mobileNumberNotMatch"),
              actions: [
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(getTranslated("ok"),style: TextStyle(color: buttonBgColor))),
              ]);
          return;
        }
      }else{
        var mob = '${countryCode?.replaceAll('+', '').toString().checkNull()}${mobileNumber.text.trim()}';
        if (mob != SessionManagement.getMobileNumber()) {
          Helper.showAlert(
              message: getTranslated("mobileNumberNotMatch"),
              actions: [
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(getTranslated("ok"))),
              ]);
          return;
        }
      }
      Get.toNamed(Routes.deleteAccountReason);
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }

}
