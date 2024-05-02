import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../data/apputils.dart';
import '../../../data/session_management.dart';
import '../../../data/helper.dart';
import '../../../routes/route_settings.dart';

class DeleteAccountReasonController extends FullLifeCycleController
    with FullLifeCycleMixin {
  var reasonValue = "".obs;
  TextEditingController feedback = TextEditingController();

  var deleteReasons = [
    'I am changing my device',
    'I am changing my phone number',
    'MirrorFly is missing a feature',
    'MirrorFly is not working',
    'Other',
  ];

  get focusNode => FocusNode();

  deleteAccount() {
    Helper.showAlert(
        title: "Proceed to delete your account?",
        message:
            "Deleting your account is permanent. Your data cannot be recovered if you reactivate your MirrorFly account in future.",
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("CANCEL",style: TextStyle(color: buttonBgColor))),
          TextButton(
              onPressed: () async {
                // Get.back();
                deleteUserAccount();
              },
              child: const Text("OK",style: TextStyle(color: buttonBgColor))),
        ]);
  }

  Future<void> deleteUserAccount() async {
    if (await AppUtils.isNetConnected()) {
      Get.back();
      // Future.delayed(const Duration(milliseconds: 100), () {
       Helper.showLoading(message: "Deleting Account");
      debugPrint("on DeleteAccount");
      SessionManagement.setLogin(false);
      Mirrorfly.deleteAccount(reason: reasonValue.value, feedback: feedback.text, flyCallBack: (FlyResponse response) {
        debugPrint('DeleteAccount $response');
        if(response.isSuccess) {
          Future.delayed(const Duration(milliseconds: 500), () {
            Helper.hideLoading();
            SessionManagement.clear()
                .then((value) => Get.offAllNamed(Routes.login));
            toToast('Your MirrorFly account has been deleted');
          });
        }else{
          SessionManagement.setLogin(true);
          toToast("Unable to delete the account");
        }
      }).catchError((error) {
        Helper.hideLoading();
      });
      // });
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {
    if (!KeyboardVisibilityController().isVisible) {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          focusNode.requestFocus();
        });
      }
    }
  }

  @override
  void onHidden() {

  }
}
