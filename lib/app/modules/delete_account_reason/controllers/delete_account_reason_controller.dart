import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../common/app_localizations.dart';
import '../../../data/apputils.dart';
import '../../../data/session_management.dart';
import '../../../data/helper.dart';
import '../../../routes/route_settings.dart';

class DeleteAccountReasonController extends FullLifeCycleController
    with FullLifeCycleMixin {
  var reasonValue = "".obs;
  TextEditingController feedback = TextEditingController();

  var deleteReasons = getTranslatedList("deleteReasons");

  get focusNode => FocusNode();

  deleteAccount() {
    Helper.showAlert(
        title: getTranslated("proceedDeleteAccount"),
        message:
            getTranslated("proceedDeleteAccountContent"),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(getTranslated("cancel"),style: const TextStyle(color: buttonBgColor))),
          TextButton(
              onPressed: () async {
                // Get.back();
                deleteUserAccount();
              },
              child: Text(getTranslated("ok").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
        ]);
  }

  Future<void> deleteUserAccount() async {
    if (await AppUtils.isNetConnected()) {
      Get.back();
      // Future.delayed(const Duration(milliseconds: 100), () {
       Helper.showLoading(message: getTranslated("deletingAccount"));
      debugPrint("on DeleteAccount");
      SessionManagement.setLogin(false);
      Mirrorfly.deleteAccount(reason: reasonValue.value, feedback: feedback.text, flyCallBack: (FlyResponse response) {
        debugPrint('DeleteAccount $response');
        if(response.isSuccess) {
          Future.delayed(const Duration(milliseconds: 500), () {
            Helper.hideLoading();
            SessionManagement.clear()
                .then((value) => Get.offAllNamed(Routes.login));
            toToast(getTranslated("accountDeleted"));
          });
        }else{
          SessionManagement.setLogin(true);
          toToast(getTranslated("unableToDeleteAccount"));
        }
      }).catchError((error) {
        Helper.hideLoading();
      });
      // });
    } else {
      toToast(getTranslated("noInternetConnection"));
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
