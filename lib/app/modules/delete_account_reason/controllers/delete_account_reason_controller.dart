import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import '../../../common/constants.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../data/session_management.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';

class DeleteAccountReasonController extends FullLifeCycleController
    with FullLifeCycleMixin {
  var reasonValue = "".obs;
  TextEditingController feedback = TextEditingController();

  var deleteReasons = getTranslatedList("deleteReasons");

  get focusNode => FocusNode();

  deleteAccount() {
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        title: getTranslated("proceedDeleteAccount"),
        message: getTranslated("proceedDeleteAccountContent"),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(
                getTranslated("cancel"),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () async {
                // NavUtils.back();
                deleteUserAccount();
              },
              child: Text(
                getTranslated("ok").toUpperCase(),
              )),
        ]);
  }

  Future<void> deleteUserAccount() async {
    if (await AppUtils.isNetConnected()) {
      NavUtils.back();
      // Future.delayed(const Duration(milliseconds: 100), () {
      DialogUtils.showLoading(
          message: getTranslated("deletingAccount"),
          dialogStyle: AppStyleConfig.dialogStyle);
      debugPrint("on DeleteAccount");
      SessionManagement.setLogin(false);
      Mirrorfly.deleteAccount(
          reason: reasonValue.value,
          feedback: feedback.text,
          flyCallBack: (FlyResponse response) {
            debugPrint('DeleteAccount $response');
            if (response.isSuccess) {
              Future.delayed(const Duration(milliseconds: 500), () {
                DialogUtils.hideLoading();
                SessionManagement.clear()
                    .then((value) => NavUtils.offAllNamed(Routes.login));
                toToast(getTranslated("accountDeleted"));
              });
            } else {
              SessionManagement.setLogin(true);
              toToast(getTranslated("unableToDeleteAccount"));
            }
          }).catchError((error) {
        DialogUtils.hideLoading();
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
  void onHidden() {}
}
