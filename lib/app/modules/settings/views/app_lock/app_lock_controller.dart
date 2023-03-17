import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/main.dart';

import '../../../../routes/app_pages.dart';

class AppLockController extends GetxController {
  final _pinEnabled = false.obs;

  set pinEnabled(value) => _pinEnabled.value = value;

  get pinEnabled => _pinEnabled.value;

  final _bioEnabled = false.obs;

  set bioEnabled(value) => _bioEnabled.value = value;

  get bioEnabled => _bioEnabled.value;

  @override
  void onInit() {
    super.onInit();
    _pinEnabled(SessionManagement.getEnablePin());
    _bioEnabled(SessionManagement.getEnableBio());
  }

  final modifyPin = false.obs;
  final TextEditingController newPin = TextEditingController();
  final TextEditingController confirmPin = TextEditingController();
  final TextEditingController oldPin = TextEditingController();
  var fromBio = false;
  var offPin = false;

  enablePin() {
    if (SessionManagement.getEnablePin()) {
      //to confirm pin to off pin
      offPin = true;
      Get.toNamed(Routes.pin);
    } else {
      Get.toNamed(Routes.setPin);
    }
  }

  enableBio() {
    if (SessionManagement.getEnablePin()) {
      if (SessionManagement.getEnableBio()) {
        //to confirm pin to off bio
        SessionManagement.setEnableBio(false);
        _bioEnabled(false);
      } else {
        SessionManagement.setEnableBio(true);
        _bioEnabled(true);
      }
    } else {
      //enable pin to enable bio alert popup
      Helper.showAlert(
          message:
              "You need to set pin first in order to enable bio metric authentication",
          actions: [
            TextButton(
                onPressed: () {
                  fromBio = true;
                  enablePin();
                },
                child: const Text("OK")),
          ]);
    }
  }

  changePin() {
    modifyPin(true);
    Get.toNamed(Routes.pin);
  }

  savePin() {
    if (modifyPin.value) {
      if (oldPin.text.isNotEmpty) {
        if (oldPin.text == SessionManagement.getPin()) {
          setPin();
        } else {
          toToast("Old PIN not Matched");
        }
      } else {
        toToast("Enter Old PIN");
      }
    } else {
      setPin();
    }
  }

  setPin() {
    if (newPin.text.isNotEmpty && confirmPin.text.isNotEmpty) {
      if (newPin.text == confirmPin.text) {
        SessionManagement.setPIN(newPin.text);
        SessionManagement.setEnablePIN(true);
        SessionManagement.setEnableBio(fromBio);
        _pinEnabled(true);
        _bioEnabled(fromBio);
        modifyPin(false);
        Get.back();
      } else {
        toToast("PIN not Matched");
      }
    } else {
      toToast("Enter New and Confirm PIN");
    }
  }

  disablePIN() {
    if (SessionManagement.getEnablePin()) {
      //to confirm pin to off pin
      SessionManagement.setPIN("");
      SessionManagement.setEnablePIN(false);
      SessionManagement.setEnableBio(false);
      _pinEnabled(false);
      _bioEnabled(false);
      Get.back();
    }
  }

  final _pin1 = false.obs;

  get pin1 => _pin1.value;
  final _pin2 = false.obs;

  get pin2 => _pin2.value;
  final _pin3 = false.obs;

  get pin3 => _pin3.value;
  final _pin4 = false.obs;

  get pin4 => _pin4.value;

  var text = <int>[];

  numberClick(int num) {
    if (num != 10) {
      if (!pin1) {
        _pin1(true);
        text.add(num);
      } else if (!pin2) {
        _pin2(true);
        text.add(num);
      } else if (!pin3) {
        _pin3(true);
        text.add(num);
      } else if (!pin4) {
        _pin4(true);
        text.add(num);
      }
    } else {
      removeClick();
    }
    validateAndUnlock();
    mirrorFlyLog("add text", text.join().toString());
  }

  removeClick() {
    if (pin4) {
      _pin4(false);
      text.removeLast();
    } else if (pin3) {
      _pin3(false);
      text.removeLast();
    } else if (pin2) {
      _pin2(false);
      text.removeLast();
    } else if (pin1) {
      _pin1(false);
      text.removeLast();
    } else {}
    mirrorFlyLog("rem text", text.join().toString());
  }

  validateAndUnlock() {
    if (text.isNotEmpty && text.length == 4) {
      if (SessionManagement.getPin() == text.join()) {
        if (offPin) {
          offPin = false;
          disablePIN();
        } else if (modifyPin.value) {
          Get.offNamed(Routes.setPin);
        } else {
          debugPrint('route ${Get.previousRoute}');
          if (Get.previousRoute.isEmpty) {
            Get.offAllNamed(getInitialRoute());
          } else {
            Get.back(result: true);
          }
        }
      } else {
        toToast("Invalid PIN! Try again");
      }
    }
  }

  void forgetPin() {
    Get.dialog(AlertDialog(
      titlePadding: const EdgeInsets.only(top: 20,right: 20,left: 20),
      contentPadding: EdgeInsets.zero,
      title: const Text(
        Constants.forgetPinOTPText,
        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      actions: [
        TextButton(
            onPressed: () {},
            child: const Text(
              'CANCEL',
              style: TextStyle(color: buttonBgColor),
            )),
        TextButton(
            onPressed: () {},
            child: const Text(
              'GENERATE OTP',
              style: TextStyle(color: buttonBgColor),
            )),
      ],
    ));
  }
}
