import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:flysdk/flysdk.dart';

import '../../../data/apputils.dart';
import '../../../data/session_management.dart';
import '../../../data/helper.dart';
import '../../../routes/app_pages.dart';

class DeleteAccountReasonController extends GetxController {

  var reasonValue = "".obs;
  TextEditingController feedback = TextEditingController();

  var deleteReasons = [
    'I am changing my phone number',
    'MirrorFly is missing a feature',
    'MirrorFly is not working',
    'Other',
  ];

  deleteAccount() {
    Helper.showAlert(title: "Proceed to delete your account?",
        message: "Deleting your account is permanent. Your data cannot be recovered if you reactivate your MirrorFly account in future.",
    actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("CANCEL")),
      TextButton(
          onPressed: () async {
            if(await AppUtils.isNetConnected()) {
              Get.back();
              Future.delayed(const Duration(milliseconds: 100), ()
              {
                Helper.showLoading(message: "Deleting Account");
                FlyChat
                    .deleteAccount(reasonValue.value, feedback.text)
                    .then((value) {
                  Helper.hideLoading();
                  SessionManagement.clear();
                  Get.offAllNamed(Routes.login);
                }).catchError((error) {
                  Helper.hideLoading();
                  toToast("Unable to delete the account");
                });
              });
            }else{
              toToast(Constants.noInternetConnection);
            }
          },
          child: const Text("OK")),
    ]);
  }

}
