
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/countryModel.dart';

import '../../../data/SessionManagement.dart';
import '../../../model/registerModel.dart';
import '../../../nativecall/platformRepo.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  var india = CountryData(name: "India", dialCode: "+91", code: "IN");
  var selectedCountry = CountryData(name: "India", dialCode: "+91", code: "IN").obs;
  TextEditingController mobileNumber = TextEditingController();


  void registerUser(BuildContext context) {

    if(mobileNumber.text.isEmpty){
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('Please Enter Mobile Number'),
          action: SnackBarAction(label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
        ),
      );
    }else{
      Helper.showLoading(message: "Logging In...");
      RegisterModel userData;
      PlatformRepo().registerUser(mobileNumber.text).then((value) {
        if (value.contains("data")) {
          userData = registerModelFromJson(value);//message
          SessionManagement.setLogin(userData.data!.username!.isNotEmpty);
          SessionManagement.setUser(userData.data!);
          setUserJID(userData.data!.username!);

        }
      }).catchError((error) {
        debugPrint("issue===> $error");
        debugPrint(error.message);
      });
    }


  }

  setUserJID(String username) {
    PlatformRepo().getUserJID(username).then((value) {
      if(value != null){
        SessionManagement.setUserJID(value);
        Helper.hideLoading();
        Get.offNamed(Routes.PROFILE,arguments: {"mobile":mobileNumber.text.toString(),"from":Routes.LOGIN});
      }
    }).catchError((error) {
      debugPrint(error.message);
    });
  }

}
